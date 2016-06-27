
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

class UDPSocketImpl : UDPSocket
{
	embed "Java" {{{
		javax.microedition.io.UDPDatagramConnection socket = null;
	}}}

	public void close() {
		embed "Java" {{{
			try {
				socket.close();
			}
			catch(Exception e) {
				e.printStackTrace();
			}
		}}}
	}

	public int send(Buffer message, String address, int port) {
		if(message == null || address == null || port < 0) {
			return(0);
		}
		strptr jaddress = address.to_strptr();
		ptr jbuffer = message.get_pointer().get_native_pointer();
		int length = message.get_size();
		int v = 0;
		embed "Java" {{{
			try {
				if(bind(port)) {
					socket.send(socket.newDatagram(jbuffer, length, jaddress));
					v = jbuffer.length;
				}
			}
			catch(Exception e) {
				e.printStackTrace();
			}
		}}}
		return(v);
	}

	public int send_broadcast(Buffer message, String address, int port) {
		// Broadcast or Multicast not is not supported by bb java
		return(0);
	}

	public int receive(Buffer message, int timeout) {
		if(message == null) {
			return(0);
		}
		ptr jbuffer = message.get_pointer().get_native_pointer();
		int length = message.get_size();
		int v = 0;
		embed "Java" {{{
			try {
				socket.receive(socket.newDatagram(jbuffer, length));
				v = jbuffer.length;
			}
			catch(Exception e) {
				e.printStackTrace();
			}
		}}}
		return(v);
	}

	public bool bind(int port) {
		bool v = false;
		strptr jport = "datagram://:%s".printf().add(String.for_integer(port)).to_string().to_strptr();
		embed "Java" {{{
			try {
				socket = (javax.microedition.io.UDPDatagramConnection)javax.microedition.io.Connector.open(jport);
				v = true;
			}
			catch(Exception e) {
				e.printStackTrace();
			}						
		}}}
		return(v);
	}

	public static UDPSocket create() {
		return(new UDPSocketImpl());
	}
}
