
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

class TCPSocketImpl : TCPSocket, ConnectedSocket, Reader, Writer, ReaderWriter
{
	embed "cs" {{{
		public System.Net.Sockets.Socket socket;
	}}}

	bool is_connected = false;

 	~TCPSocketImpl() {
 		close();
 	}

	public static TCPSocket create() {
		return(new TCPSocketImpl());
	}

	public bool set_blocking(bool block) {
		embed "cs" {{{
			if(socket != null) {
				socket.Blocking = block;
			}
		}}}
		return(false);
	}

	public String get_remote_address() {
		return(null);
	}

	public int get_remote_port() {
		return(0);
	}

	public String get_local_address() {
		return(null);
	}

	public int get_local_port() {
		return(0);
	}

	public bool connect(String address, int port) {
		if(address == null) {
			return(false);
		}
		embed "cs" {{{
			var ip_endpt = new System.Net.DnsEndPoint(address.to_strptr(), port);
			var socketarg = new System.Net.Sockets.SocketAsyncEventArgs();
			socketarg = new System.Net.Sockets.SocketAsyncEventArgs();
			socket = new System.Net.Sockets.Socket(
				System.Net.Sockets.AddressFamily.InterNetwork,
				System.Net.Sockets.SocketType.Stream,
				System.Net.Sockets.ProtocolType.Tcp);
			socket.NoDelay = true;
			var mutex = new System.Threading.ManualResetEvent(false);;
			socketarg.Completed += new System.EventHandler<System.Net.Sockets.SocketAsyncEventArgs>((object sender, System.Net.Sockets.SocketAsyncEventArgs arg) => {
				if(arg.SocketError == System.Net.Sockets.SocketError.Success) {
					is_connected = true;
				}
				mutex.Set();
			});
			socketarg.RemoteEndPoint = ip_endpt;
			socketarg.UserToken = socket;
			socket.ConnectAsync(socketarg);
			mutex.WaitOne();
			mutex.Reset();
		}}}
		return(is_connected);
	}

	void _debug(strptr sp) {
		Log.debug(String.for_strptr(sp));
	}

	void _warning(strptr sp) {
		Log.warning(String.for_strptr(sp));
	}

	public bool listen(int port) {
		IFDEF("target_wp7sl") {
			//XXX : Not implemented on SL
			return(false);
		}
		ELSE {
			bool v = true;
			embed "cs" {{{
				try {
					socket = new System.Net.Sockets.Socket(
						System.Net.Sockets.AddressFamily.InterNetwork,
						System.Net.Sockets.SocketType.Stream,
						System.Net.Sockets.ProtocolType.Tcp);
					socket.NoDelay = true;
					var ep = new System.Net.IPEndPoint(System.Net.IPAddress.Any, port);
					socket.Bind(ep);
					socket.Listen(256);
				}
				catch(System.Exception e) {
					v = false;
				}
				if(v == false) {
					close();
				}
			}}}
			return(v);
		}
	}

	public TCPSocket accept() {
		IFDEF("target_wp7sl") {
			//XXX : Not implemented on SL
			return(null);
		}
		ELSE {
			embed "cs" {{{
				if(socket == null) {
					return(null);
				}
				System.Net.Sockets.Socket nsocket;
				try {
					nsocket = socket.Accept();
				}
				catch(System.Exception e) {
					nsocket = null;
				}
				if(nsocket != null) {
					nsocket.NoDelay = true;
					var v = new TCPSocketImpl();
					v.socket = nsocket;
					return(v);
				}
			}}}
			return(null);
		}
	}

	public int read(Buffer buf) {
		if(buf == null) {
			return(0);
		}
		int v = 0;
		var ptr = buf.get_pointer().get_native_pointer();
		embed "cs" {{{
			try {
				v = socket.Receive(ptr);
			}
			catch(System.Net.Sockets.SocketException e) {
				if(e.ErrorCode == 10035) { // WSAEWOULDBLOCK
					return(0);
				}
				else {
					v = -1;
				}
			}
			catch(System.Exception e) {
				v = -1;
			}
			if(v < 1) {
				close();
				v = -1;
			}
		}}}
		return(v);
	}

	public int write(Buffer buf, int size = -1) {
		if(buf == null) {
			return(-1);
		}
		int v = 0;
		var ptr = buf.get_pointer().get_native_pointer();
		embed "cs" {{{
			int nsize = size;
			if(nsize < 0) {
				nsize =  ptr.Length;
			}
			try {
				v = socket.Send(ptr, 0, nsize, 0);
			}
			catch(System.Net.Sockets.SocketException e) {
				if(e.ErrorCode == 10035) { // WSAEWOULDBLOCK
					return(0);
				}
				else {
					v = -1;
				}
			}
			catch(System.Exception e) {
				v = -1;
			}
			if(v < 1) {
				close();
				v = -1;
			}
		}}}
		return(v);
	}

	public void close() {
		embed "cs" {{{
			if(socket == null) {
				return;
			}
		}}}
		embed "cs" {{{
			try {
				socket.Shutdown(System.Net.Sockets.SocketShutdown.Both);
			}
			catch(System.Exception e) {
			}
		}}}
		// In UWP, the Close() method has been removed (?), and no documentation
		// seems to exist as for what to do instead. Maybe this will do?
		IFNDEF("target_uwp") {
			embed "cs" {{{
				socket.Close();
			}}}
		}
		embed "cs" {{{
			socket = null;
		}}}
	}
}

