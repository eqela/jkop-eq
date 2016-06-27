
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

IFNDEF("target_j2me") {
public class TCPSocketImpl : TCPSocket, ConnectedSocket, ReaderWriter, Reader, Writer
{
	private String remote_address = null;
	private int remote_port = 0;
	embed "Java" {{{
		private java.net.Socket socket = null;
		private java.net.ServerSocket server = null;
	}}}

	public static TCPSocket create() {
		return(new TCPSocketImpl());
	}

	embed "Java" {{{
		public java.net.Socket get_native_socket() {
			return(socket);
		}
	}}}

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
				java.io.InputStream ins = socket.getInputStream();
				v = ins.read(jptr);
			}
			catch(Exception e) {
				System.out.println("EXCEPTION CAUGHT IN TCPSocketImpl.read:");
				e.printStackTrace();
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
				java.io.OutputStream ous = socket.getOutputStream();
				ous.write(jptr, 0, len);
				v = len;
			}
			catch(Exception e) {
				System.out.println("EXCEPTION CAUGHT IN TCPSocketImpl.write:");
				e.printStackTrace();
			}
		}}}
		return(v);
	}

	public void close() {
		embed "Java" {{{
			try {
				socket.close();
			}
			catch(Exception e) {
				System.out.println("EXCEPTION CAUGHT IN TCPSocketImpl.close:");
				e.printStackTrace();
			}
		}}}
	}

	public String get_remote_address() {
		strptr v = null;
		embed "Java" {{{
			if(socket == null) {
				return(null);
			}
			v = socket.getInetAddress().getHostAddress();
		}}}
		return(String.for_strptr(v));
	}

	public int get_remote_port() {
		int v = 0;
		embed "Java" {{{
			if(socket != null) {
				v = socket.getPort();
			}
		}}}
		return(v);
	}

	public String get_local_address() {
		strptr jadd = null;
		embed "Java" {{{
			if(socket == null) {
				return(null);
			}
			jadd = socket.getLocalAddress().getHostAddress();
		}}}
		return(String.for_strptr(jadd));
	}

	public int get_local_port() {
		int v = 0;
		embed "Java" {{{
			if(socket != null) {
				v = socket.getLocalPort();
			}
		}}}
		return(v);
	}

	public bool connect(String address, int port) {
		bool v = true;
		embed "Java" {{{
			try {
				socket = new java.net.Socket(address.to_strptr(), port);
			}
			catch(Exception e) {
				System.out.println("EXCEPTION CAUGHT IN TCPSocketImpl.connect:");
				e.printStackTrace();
				v = false;
			}
		}}}
		return(v);
	}

	public bool listen(int port) {
		bool v = true;
		embed "Java" {{{
			try {
				server = new java.net.ServerSocket(port);
			}
			catch(Exception e) {
				System.out.println("EXCEPTION CAUGHT IN TCPSocketImpl.listen:");
				e.printStackTrace();
				v = false;
			}
		}}}
		return(v);
	}

	public TCPSocket accept() {
		var v = new TCPSocketImpl();
		embed "Java" {{{
			try {
				v.socket = server.accept();
			}
			catch(Exception e) {
				System.out.println("EXCEPTION CAUGHT IN TCPSocketImpl.accept:");
				e.printStackTrace();
				v = null;
			}
		}}}
		return(v);
	}
}
}

