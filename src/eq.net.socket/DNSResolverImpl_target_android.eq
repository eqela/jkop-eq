
/*
 * This file is part of Jkop
 * Copyright (c) 2016 Job and Esther Technologies, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

class AndroidDNSServer
{
	public static String get_server() {
		var ads = new AndroidDNSServer();
		var v = ads.android_server();
		return(v);
	}

	public String android_server () {
		strptr v = null;
		embed "java" {{{
			try {
				java.lang.Class<?> class_sysprop = java.lang.Class.forName("android.os.SystemProperties");
				java.lang.Class[] paramTypes = new java.lang.Class[] {
					String.class
				};
				java.lang.reflect.Method reflect_get = class_sysprop.getMethod("get", paramTypes);
				java.lang.Object[] params = new java.lang.Object[1];
				for(int x = 1; x <= 12; x++) {
					params[0] = "net.dns" + x;
					v = (java.lang.String)reflect_get.invoke(class_sysprop, params);
					if(v != null || v.length() > 0) {
						break;
					}
				}
			}
			catch(Exception e) {
				eq.api.Log.Static.warning((eq.api.Object)eq.api.String.Static.for_strptr("Exception caught: " + e), null);
			}
		}}}
		return(String.for_strptr(v));
	}
}

class DNSResolverImpl : DNSResolver
{
	UDPSocket client = null;
	int packet_size;
	uint8 counter = 0;

	public static DNSResolver create() {
		return(new DNSResolverImpl());
	}

	public DNSResolverImpl() {
		this.client = UDPSocket.create();
	}

	private String get_server() {
		var v = AndroidDNSServer.get_server();
		if(v == null || v.get_length() < 1) {
			Log.warning("No DNS server configured. Cannot resolve addresses.");
		}
		else {
			Log.debug("DNS resolver using nameserver '%s'".printf().add(v).to_string());
		}
		return(v);
	}

	private int get_dns_timeout() {
		return(30000000);
	}

	private bool is_ip(String address) {
		bool v = true;
		var it = address.iterate();
		int c;
		while((c = it.next_char()) > 0) {
			if(c == '.' || (c >= '0' && c <= '9')) {
				; // all good
			}
			else {
				v = false;
				break;
			}
		}
		return(v);
	}

	public Collection get_ns_records(String host, String type, Logger logger) {
		return(null);
	}

	public String get_ip_address(String hostname, Logger logger) {
		String v = null;
		var ips = get_ip_addresses(hostname, logger);
		int ipsl = ips.count();
		if(ips!=null && ipsl > 0) {
			if(ipsl == 1) {
				v = ips.get_index(0) as String;
			}
			else {
				v = ips.get_index(Math.random(0,ipsl)) as String;
			}
		}
		return(v);
	}

	public Collection get_ip_addresses(String hostname, Logger logger) {
		if(is_ip(hostname)) {
			var v = LinkedList.create();
			v.add(hostname);
			return(v);
		}
		else if(hostname != null && hostname.equals("localhost")) {
			var v = LinkedList.create();
			v.add("127.0.0.1");
			return(v);
		}
		return(gethostinfo(hostname, 1));
	}

	public Collection get_aliases(String hostname) {
		return(gethostinfo(hostname, 5));
	}

	public Collection get_mail_servers(String domain) {
		return(gethostinfo(domain, 15));
	}

	private Collection gethostinfo(String hostname, int type) {
		if(hostname == null || client == null) {
			return(LinkedList.create());
		}
		var msg = create_packet(hostname, type);
		int bytes;
		if((bytes = client.send(msg, get_server(), 53)) > 0) {
			if(type == 1) {
				return(receive_answer(1));
			}
			else if(type == 5) {
				return(receive_answer(5));
			}
			else if(type == 15) {
				return(receive_answer(15));
			}
		}
		return(LinkedList.create());
	}

	private Buffer create_packet(String hostname, int type) {
		packet_size = (int)(16 + (hostname.get_length()) + 1);
		var message = DynamicBuffer.create(packet_size + 1);
		var ptr = message.get_pointer();
		int index = 12;
		ptr.set_byte(0, 0);
		ptr.set_byte(1, counter++);
		ptr.set_byte(2, 1);
		ptr.set_byte(3, 0);
		ptr.set_byte(4, 0);
		ptr.set_byte(5, 1);
		ptr.set_byte(6, 0);
		ptr.set_byte(7, 0);
		ptr.set_byte(8, 0);
		ptr.set_byte(9, 0);
		ptr.set_byte(10, 0);
		ptr.set_byte(11, 0);
		var buffer_ptr = hostname.split((int)'.');
		String bps = null;
		while(buffer_ptr!=null && (bps = buffer_ptr.next() as String) != null) {
			int len = bps.get_length();
			ptr.set_byte(index, (uint8)len);
			index++;
			int i;
			for(i = 0; i < len; i++) {
				ptr.set_byte(index, (uint8)bps.get_char(i));
				index++;
			}
		}
		ptr.set_byte(index, 0);
		ptr.set_byte(++index, 0);
		ptr.set_byte(++index, (uint8)type);
		ptr.set_byte(++index, 0);
		ptr.set_byte(++index, 1);
		return(message);
	}

	private Collection receive_answer(int x) {
		if(client == null) {
			return(LinkedList.create());
		}
		var resolved_address = LinkedList.create();
		int bytes = 0;
		var r_message = DynamicBuffer.create(8192);
		bytes = client.receive(r_message, get_dns_timeout());
		if(bytes < 1) {
			return(LinkedList.create());
		}
		var ptr = r_message.get_pointer();
		int no_of_answers = ptr.get_byte(7);
		int i;
		for(i = 0; i < no_of_answers; i++) {
			uint8 type = ptr.get_byte(packet_size + 4);
			uint8 data_length = ptr.get_byte(packet_size + 12);
			if(type == x) {
				if(type == 1) {
					uint8 octet1 = ptr.get_byte(packet_size+13);
					uint8 octet2 = ptr.get_byte(packet_size+14);
					uint8 octet3 = ptr.get_byte(packet_size+15);
					uint8 octet4 = ptr.get_byte(packet_size+16);
					var address = "%d.%d.%d.%d".printf().add(Primitive.for_integer(octet1 & 0xFF)).add(Primitive.for_integer(octet2 & 0xFF)).add(Primitive.for_integer(octet3 & 0xFF)).add(Primitive.for_integer(octet4 & 0xFF)).to_string();
					resolved_address.add(address);
				}
				else if(type == 5) {
					resolved_address.add(convert_to_ascii(ptr, packet_size + 13));
				}
				else if(type == 15) {
					resolved_address.add(convert_to_ascii(ptr, packet_size + 15));
				}
			}
			packet_size += 12 + data_length;
		}
		return(resolved_address);
	}

	private String convert_to_ascii(Pointer msg, int aindex) {
		var index = aindex;
		if(msg.get_byte(index) == 192) {
			index = msg.get_byte(index+1);
			index++;
		}
		else {
			index++ ;
		}
		uint8 d = ' ';
		String cname = "";
		do {
			d = msg.get_byte(index);
			if(d > 0 && d <= 32) {
				d = (int)'.';
				cname = "%s%c".printf().add(cname).add(Primitive.for_integer(d)).to_string();
				index++;
				d = msg.get_byte(index);
			}
			else if(d == (uint8)(-64)) {
				index = msg.get_byte(index+1);
			}
			else {
				cname = "%s%c".printf().add(cname).add(Primitive.for_integer(d)).to_string();
				index++;
			}
		}
		while(d != 0);
		return(cname);
	}
}

