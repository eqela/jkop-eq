
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

public class SMTPClient
{
	static TCPSocket connect(String server, int port, Logger logger) {
		if(server == null || port < 1) {
			return(null);
		}
		var address = server;
		var dns = DNSResolver.create();
		if(dns != null) {
			address = dns.get_ip_address(server);
			if(address == null) {
				Log.error("SMTPClient: Could not resolve SMTP server address: `%s'".printf().add(server), logger);
				return(null);
			}
		}
		Log.debug("SMTPClient: Connecting to SMTP server `%s:%d' ..".printf().add(address).add(Primitive.for_integer(port)), logger);
		var v = TCPSocket.create(address, port);
		if(v != null) {
			Log.debug("SMTPClient: Connected to `%s:%d".printf().add(address).add(Primitive.for_integer(port)), logger);
		}
		else {
			Log.error("SMTPClient: FAILED connection to `%s:%d".printf().add(address).add(Primitive.for_integer(port)), logger);
		}
		return(v);
	}

	static bool writeline(OutputStream ops, String str) {
		return(ops.write_string("%s\r\n".printf().add(str).to_string()));
	}

	static String communicate(InputStream ins, String expect_code) {
		var sb = StringBuffer.create();
		var line = ins.readline();
		if(String.is_empty(line) == false) {
			sb.append(line);
		}
		while(line != null && line.get_char(3) == '-') {
			line = ins.readline();
			if(String.is_empty(line) == false) {
				sb.append(line);
			}
		}
		if(line != null && line.get_char(3) == ' ') {
			if(expect_code == null) {
				return(null);
			}
			var rc = line.substring(0, 3);
			foreach(String cc in expect_code.split((int)'|')) {
				if(cc.equals(rc)) {
					return(null);
				}
			}
		}
		var v = sb.to_string();
		if(String.is_empty(v)) {
			v = "XXX Unknown SMTP server error response";
		}
		return(v);
	}

	static String encode(String enc) {
		if(enc == null) {
			return(null);
		}
		return(Base64Encoder.encode(enc.to_utf8_buffer(false)));
	}

	static String rcpt_as_email_address(String ss) {
		if(ss == null) {
			return(ss);
		}
		var b = ss.chr((int)'<');
		if(b < 0) {
			return(ss);
		}
		var e = ss.rchr((int)'>');
		if(e < 0) {
			return(ss);
		}
		return(ss.substring(b+1, e-b-1));
	}

	static String resolve_mx_server_for_domain(String domain) {
		var dns = DNSResolver.instance();
		if(dns == null) {
			Log.error("Unable to instantiate a DNS resolver");
			return(null);
		}
		var rcs = dns.get_ns_records(domain, "MX");
		if(Collection.is_empty(rcs)) {
			return(null);
		}
		String v;
		int pr;
		foreach(DNSRecordMX mx in rcs) {
			var p = mx.get_priority();
			if(v == null || p < pr) {
				pr = p;
				v = mx.get_address();
			}
		}
		return(v);
	}

	public static SMTPClientResult send_message(SMTPMessage msg, URL server, String server_name, Logger logger = null) {
		if(msg == null) {
			return(SMTPClientResult.for_message(msg).add_transaction(SMTPClientTransactionResult.for_error("No message")));
		}
		var rcpts = msg.get_all_rcpts();
		if(server != null) {
			// simple case. single server transaction with a supplied address.
			var t = execute_transaction(msg, server, rcpts, server_name, logger);
			if(t != null) {
				t.set_server(server.get_host());
				t.set_recipients(rcpts);
			}
			return(SMTPClientResult.for_message(msg).add_transaction(t));
		}
		var r = SMTPClientResult.for_message(msg);
		var servers = HashTable.create();
		foreach(String rcpt in rcpts) {
			var em = rcpt_as_email_address(rcpt);
			if(String.is_empty(em)) {
				r.add_transaction(SMTPClientTransactionResult.for_error("Invalid recipient address: `%s'".printf().add(rcpt).to_string()));
				break;
			}
			var at = em.chr((int)'@');
			if(at < 0) {
				r.add_transaction(SMTPClientTransactionResult.for_error("Invalid recipient address: `%s'".printf().add(rcpt).to_string()));
				break;
			}
			var sa = em.substring(at+1);
			if(String.is_empty(sa)) {
				r.add_transaction(SMTPClientTransactionResult.for_error("Invalid recipient address: `%s'".printf().add(rcpt).to_string()));
				break;
			}
			var ss = servers.get(sa) as Collection;
			if(ss == null) {
				ss = LinkedList.create();
				servers.set(sa, ss);
			}
			ss.add(rcpt);
		}
		foreach(String domain in servers.iterate_keys()) {
			var ds = resolve_mx_server_for_domain(domain);
			if(String.is_empty(ds)) {
				r.add_transaction(
					SMTPClientTransactionResult.for_error("Unable to determine mail server for `%s'".printf().add(domain).to_string()));
			}
			else {
				Log.debug("SMTP server for domain `%s': `%s'".printf().add(domain).add(ds));
				var trcpts = servers.get(domain) as Collection;
				var t = execute_transaction(msg, URL.for_string("smtp://".append(ds)), trcpts, server_name, logger);
				if(t != null) {
					t.set_domain(domain);
					t.set_server(ds);
					t.set_recipients(trcpts);
				}
				r.add_transaction(t);
			}
		}
		if(Collection.is_empty(r.get_transactions())) {
			r.add_transaction(SMTPClientTransactionResult.for_error("Unknown error in SMTPClient"));
		}
		return(r);
	}

	static SMTPClientTransactionResult execute_transaction(SMTPMessage msg, URL server, Collection rcpts, String server_name, Logger logger) {
		var url = server;
		if(url == null) {
			return(SMTPClientTransactionResult.for_error("No server URL"));
		}
		ConnectedSocket socket = null;
		var scheme = url.get_scheme();
		var host = url.get_host();
		int port = url.get_port_int();
		int n;
		for(n=0; n<3; n++) {
			if("smtp".equals(scheme) || "smtp+tls".equals(scheme)) {
				if(port < 1) {
					port = 25;
				}
				socket = connect(host, port, logger);
			}
			else if("smtp+ssl".equals(scheme)) {
				if(port < 1) {
					port = 465;
				}
				var ts = connect(host, port, logger);
				if(ts != null) {
					socket = SSLSocket.for_client(ts);
					if(socket == null) {
						return(SMTPClientTransactionResult.for_error("Failed to start SSL"));
					}
				}
			}
			else {
				return(SMTPClientTransactionResult.for_error("SMTPClient: Unknown SMTP URI scheme `%s'".printf().add(scheme).to_string()));
			}
			if(socket != null) {
				break;
			}
			Log.debug("Failed to connect to SMTP server `%s:%d'. Waiting to retry ..".printf().add(host).add(port), logger);
			SystemEnvironment.sleep(1);
		}
		if(socket == null) {
			return(SMTPClientTransactionResult.for_error("Unable to connect to SMTP server `%s:%d'".printf().add(host).add(port).to_string()));
		}
		var ops = OutputStream.create(socket);
		var ins = InputStream.create(socket);
		if(ops == null || ins == null) {
			return(SMTPClientTransactionResult.for_error("Unable to establish SMTP I/O streams"));
		}
		String err;
		if((err = communicate(ins, "220")) != null) {
			return(SMTPClientTransactionResult.for_error(err));
		}
		var sn = server_name;
		if(String.is_empty(sn)) {
			sn = "eq.net.smtpclient";
		}
		if(writeline(ops, "EHLO ".append(sn)) == false) {
			return(SMTPClientTransactionResult.for_network_error());
		}
		if((err = communicate(ins, "250")) != null) {
			return(SMTPClientTransactionResult.for_error(err));
		}
		if("smtp+tls".equals(scheme)) {
			if(writeline(ops, "STARTTLS") == false) {
				return(SMTPClientTransactionResult.for_network_error());
			}
			if((err = communicate(ins, "220")) != null) {
				return(SMTPClientTransactionResult.for_error(err));
			}
			ops = null;
			ins = null;
			socket = SSLSocket.for_client(socket);
			if(socket == null) {
				return(SMTPClientTransactionResult.for_error("Failed to start SSL"));
			}
			ops = OutputStream.create(socket);
			ins = InputStream.create(socket);
		}
		var username = url.get_username();
		var password = url.get_password();
		if(String.is_empty(username) == false) {
			if(writeline(ops, "AUTH login") == false) {
				return(SMTPClientTransactionResult.for_network_error());
			}
			if((err = communicate(ins, "334")) != null) {
				return(SMTPClientTransactionResult.for_error(err));
			}
			if(writeline(ops, encode(username)) == false) {
				return(SMTPClientTransactionResult.for_network_error());
			}
			if((err = communicate(ins, "334")) != null) {
				return(SMTPClientTransactionResult.for_error(err));
			}
			if(writeline(ops, encode(password)) == false) {
				return(SMTPClientTransactionResult.for_network_error());
			}
			if((err = communicate(ins, "235|530")) != null) {
				return(SMTPClientTransactionResult.for_error(err));
			}
		}
		if(writeline(ops, "MAIL FROM:<%s>".printf().add(msg.get_my_address()).to_string()) == false) {
			return(SMTPClientTransactionResult.for_network_error());
		}
		if((err = communicate(ins, "250")) != null) {
			return(SMTPClientTransactionResult.for_error(err));
		}
		if(rcpts != null) {
			foreach(String rcpt in rcpts) {
				if(writeline(ops, "RCPT TO:<%s>".printf().add(rcpt_as_email_address(rcpt)).to_string()) == false) {
					return(SMTPClientTransactionResult.for_network_error());
				}
				if((err = communicate(ins, "250")) != null) {
					return(SMTPClientTransactionResult.for_error(err));
				}
			}
		}
		if(writeline(ops, "DATA") == false) {
			return(SMTPClientTransactionResult.for_network_error());
		}
		if((err = communicate(ins, "354")) != null) {
			return(SMTPClientTransactionResult.for_error(err));
		}
		if(String.is_empty(msg.get_message_id())) {
			msg.generate_message_id(sn);
		}
		var bod = msg.get_message_body();
		Log.debug("Sending message body: `%s'".printf().add(bod));
		if(ops.write_string(bod) == false) {
			return(SMTPClientTransactionResult.for_network_error());
		}
		if(ops.write_string("\r\n.\r\n") == false) {
			return(SMTPClientTransactionResult.for_network_error());
		}
		if((err = communicate(ins, "250")) != null) {
			return(SMTPClientTransactionResult.for_error(err));
		}
		if(writeline(ops, "QUIT") == false) {
			return(SMTPClientTransactionResult.for_network_error());
		}
		return(SMTPClientTransactionResult.for_success());
	}
}
