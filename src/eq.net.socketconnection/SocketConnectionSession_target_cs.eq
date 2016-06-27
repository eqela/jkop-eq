
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

IFDEF("target_wp8cs")
{
	class SocketConnectionSession : SocketConnectionSessionBase
	{
		embed "cs" {{{
			System.Net.Sockets.Socket nsock;
			System.Windows.Threading.Dispatcher ui_dispatcher;
		}}}

		Mutex mutex;

		public SocketConnectionSession() {
			embed "cs" {{{
				ui_dispatcher = System.Windows.Application.Current.RootVisual.Dispatcher;			
			}}}
			mutex = Mutex.create();
		}

		embed "cs" {{{
			void on_process_complete(object sender, System.Net.Sockets.SocketAsyncEventArgs arg) {
				SocketConnection socket = null;
				mutex._lock(); { socket = get_socket(); } mutex.unlock();
				switch(arg.LastOperation) {
					case System.Net.Sockets.SocketAsyncOperation.Connect:
						if(arg.SocketError == System.Net.Sockets.SocketError.Success) {
							dispatch_socket_event(1, null);
						}
						break;
					case System.Net.Sockets.SocketAsyncOperation.Receive:
						int rsz = arg.BytesTransferred;
						if(rsz > 0 && arg.SocketError == System.Net.Sockets.SocketError.Success) {
							var rbuf = arg.Buffer;
							if(rbuf != null) {
								var readbuffer = eq.api.BufferStatic.eq_api_BufferStatic_for_pointer(eq.api.PointerStatic.eq_api_PointerStatic_create(rbuf), rsz);
								dispatch_socket_event(3, (eq.api.Object)readbuffer);
							}
						}
						else {
							dispatch_socket_event(4, (eq.api.Object)eq.api.StringStatic.eq_api_StringStatic_for_strptr("socket_closed"));
							dispatch_socket_event(2, null);
							return;
						}
						break;
					case System.Net.Sockets.SocketAsyncOperation.Send:
						int wsz = arg.BytesTransferred;
						if(arg.BytesTransferred > 0 && arg.SocketError == System.Net.Sockets.SocketError.Success) {
							var writebuf = arg.Buffer;
							var writebuffer = eq.api.BufferStatic.eq_api_BufferStatic_for_pointer(eq.api.PointerStatic.eq_api_PointerStatic_create(writebuf), wsz);
						}
						else {
							dispatch_socket_event(4, (eq.api.Object)eq.api.StringStatic.eq_api_StringStatic_for_strptr("send_data_failed"));
							dispatch_socket_event(2, null);
						}
						break;
					default:
						eq.api.Log.eq_api_Log_warning((eq.api.Object)eq.api.StringStatic.eq_api_StringStatic_for_strptr("Invalid socket operation completed"), null);
						break;
				}
				socket_receive_async();
			}

			void dispatch_socket_event(int type, eq.api.Object o) {
				if(ui_dispatcher != null) {
					ui_dispatcher.BeginInvoke(new System.Action(() => {
						var socket = get_socket();
						if(socket == null) {
							return;
						}
						if(type == 1) {
							socket.on_connection_opened();
						}
						else if(type == 2) {
							socket.on_connection_ended();
							close();
						}
						else if(type == 3) {
							socket.on_data_received((eq.api.Buffer)o);
						}
						else if(type == 4) {
							socket.on_connection_error((eq.api.String)o);
						}	
					}));
				}
			}

			System.Net.Sockets.SocketAsyncEventArgs prepare_socket_arg() {
				var v = new System.Net.Sockets.SocketAsyncEventArgs();
				v.Completed += new System.EventHandler<System.Net.Sockets.SocketAsyncEventArgs>(on_process_complete);
				return(v);
			}

		
			void socket_receive_async() {
				var v = prepare_socket_arg();
				byte[] buf = new byte[4096];
				v.SetBuffer(buf, 0, buf.Length);
				mutex._lock(); { nsock.ReceiveAsync(v); } mutex.unlock();
			}
		}}}

		String address;
		int port;

		public void connect(String address, int port) {
			var socket = get_socket();
			if(address == null) {
				socket.on_connection_error("no_address");
				socket.on_connection_ended();
				return;
			}
			this.address = address;
			this.port = port;
			embed "cs" {{{
				nsock = new System.Net.Sockets.Socket(
					System.Net.Sockets.AddressFamily.InterNetwork,
					System.Net.Sockets.SocketType.Stream,
					System.Net.Sockets.ProtocolType.Tcp);
				var socketarg = prepare_socket_arg();
				socketarg.RemoteEndPoint = new System.Net.DnsEndPoint(address.to_strptr(), port);
				nsock.ConnectAsync(socketarg);
			}}}
		}

		public void close() {
			embed {{{
				if(nsock != null) {
					try {
						mutex._lock(); {
							nsock.Shutdown(System.Net.Sockets.SocketShutdown.Both);
							nsock.Close();
						}
						mutex.unlock();
					}
					catch(System.Exception e) {
					}
				}
			}}}
		}

		public bool send(Buffer data) {
			embed {{{
				if(data == null || nsock == null) {
					return(false);
				}
				var ptr = data.get_pointer().get_native_pointer();
				int size = data.get_size();
				var socketarg = prepare_socket_arg();
				socketarg.SetBuffer(ptr, 0, size);
				socketarg.UserToken = nsock;
				mutex._lock(); { nsock.SendAsync(socketarg); } mutex.unlock();
			}}}
			return(true);
		}
	}
}

ELSE
{
	class SocketConnectionSession : SocketConnectionSessionBase
	{
		public void connect(String aaddress, int aport) {
			var socket = get_socket();
			socket.on_connection_error("not_implemented");
			socket.on_connection_ended();
		}

		public void close() {
		}

		public bool send(Buffer data) {
			return(false);
		}
	}
}