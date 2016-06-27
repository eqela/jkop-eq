
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

class TCPSocketImpl : TCPSocket, ConnectedSocket, ReaderWriter, Reader, Writer
{
	embed "Java" {{{
		private javax.microedition.io.SocketConnection soc = null;
		private javax.microedition.io.ServerSocketConnection ssc = null;
	}}}

	public static TCPSocket create() {
		return(new TCPSocketImpl());
	}

	public bool set_blocking(bool block) {
		// FIXME
		return(false);
	}

	public int read(Buffer buf) {
		if(buf == null) {
			return(0);
		}
		ptr jptr = buf.get_pointer().get_native_pointer();
		int v = 0;
		embed "Java" {{{
			try {
				java.io.InputStream ins = soc.openInputStream();
				v = ins.read(jptr);
			}
			catch(Exception e) {
			}
		}}}
		return(v);
	}

	public int write(Buffer buf, int len) {
		if(buf == null) {
			return(0);
		}
		ptr jptr = buf.get_pointer().get_native_pointer();
		int v = 0;
		embed "Java" {{{
			try {
				java.io.OutputStream ous = soc.openOutputStream();
				ous.write(jptr, 0, len);
				v = len;
			}
			catch(Exception e) {
			}
		}}}
		return(v);
	}

	public void close() {
		embed "Java" {{{
			try {
				soc.close();
			}
			catch(Exception e) {
			}
		}}}
	}

	public String get_remote_address() {
		String v = null;
		embed "Java" {{{
			if(soc != null) {
				try {
					java.lang.String host = soc.getAddress();
					v = eq.api.StringStatic.eq_api_StringStatic_for_strptr(host);
				}
				catch(Exception e) {
					v = null;
				}		
			}
		}}}
		return(v);
	}

	public int get_remote_port() {
		int v = 0;
		embed "Java" {{{
			if(soc != null) {
				try {
					v = soc.getPort(); 
				}
				catch(Exception e) {
					v = 0;
				}	
			}
		}}}
		return(v);
	}

	public String get_local_address() {
		String v = null;
		embed "Java" {{{
			if(soc != null) {
				try {
					java.lang.String localAddress = soc.getLocalAddress();
					v = eq.api.StringStatic.eq_api_StringStatic_for_strptr(localAddress);
				}
				catch(Exception e) {
					v = null;
				}		
			}
			
		}}}
		return(v);
	}

	public int get_local_port() {
		int v = 0;
		embed "Java" {{{
			if(soc != null) {
				try {
					v = soc.getLocalPort();
				}
				catch(Exception e) {
					v = 0;
				}			
			}
		}}}
		return(v);
	}

	public bool connect(String address, int port) {
		bool v = true;
		strptr url = "socket://%s:%d".printf().add(address).add(String.for_integer(port)).to_string().to_strptr();
		embed "Java" {{{
			try {
				soc = (javax.microedition.io.SocketConnection)javax.microedition.io.Connector.open(url);
			}
			catch(Exception e) {
				v = false;
			}
		}}}
		return(v);
	}

	public bool listen(int port) {
		bool v = true;
		strptr jport = "socket://:%d".printf().add(String.for_integer(port)).to_string().to_strptr();
		embed "Java" {{{
			try {
				ssc = (javax.microedition.io.ServerSocketConnection)javax.microedition.io.Connector.open(jport);
			}
			catch(Exception e) {
				v = false;
			}
		}}}
		return(v);
	}

	public TCPSocket accept() {
		var v = new TCPSocketImpl();
		embed "Java" {{{
			try {
				v.soc = (javax.microedition.io.SocketConnection)ssc.acceptAndOpen();
			}
			catch(Exception e) {
				v = null;
			}
		}}}
		return(v);
	}
}

