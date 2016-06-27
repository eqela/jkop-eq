
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

class SocketConnectionSession : SocketConnectionSessionBase, EventReceiver
{
	class SocketConnectionSessionTask : LoggerObject, RunnableTask
	{
		property SocketConnection socket;
		property String address;
		property int port;
		Mutex mutex;
		Queue send_queue;
		property bool abortflag = false;
		embed {{{
			java.nio.channels.Pipe.SinkChannel pipewrite;
		}}}

		public SocketConnectionSessionTask() {
			mutex = Mutex.create();
			send_queue = Queue.create();
		}

		public void add_send_data(Buffer data) {
			if(mutex != null) { mutex.lock(); }
			send_queue.push(data);
			if(mutex != null) { mutex.unlock(); }
		}

		public int get_queue_count_atomic() {
			int v;
			if(mutex != null) { mutex.lock(); }
			v = send_queue.count();
			if(mutex != null) { mutex.unlock(); }
			return(v);
		}

		public void wakeup() {
			embed {{{
				new Thread(new Runnable() {
					public void run() {
						if(mutex!=null) { mutex.lock(); }
						try {
							if(pipewrite != null) {
								java.nio.ByteBuffer buf = java.nio.ByteBuffer.allocate(4);
								buf.putInt(0xffffffff);
								buf.flip();
								int write = pipewrite.write(buf);
							}
						}
						catch(Exception e) {
							e.printStackTrace();
						}
						if(mutex!=null) { mutex.unlock(); }
					}
				}).start();
			}}}
		}

		embed {{{
			eq.api.Buffer receive_data(java.nio.channels.SocketChannel socketc) {
				java.nio.ByteBuffer buf = java.nio.ByteBuffer.allocateDirect(4096);
				int r = -1;
				try {
					r = socketc.read(buf);
					if(r < 0) {
						return(null);
					}
				}
				catch(Exception e) {
					e.printStackTrace();
					return(null);
				}
				eq.api.Buffer buffer = eq.api.Buffer.Static.for_pointer(eq.api.Pointer.Static.create(buf.array()), buf.capacity());
				if(r == buffer.get_size()) {
					return(buffer);
				}
				return(eq.api.SubBuffer.Static.create(buffer, 0, r));
			}

			boolean send_data(java.nio.channels.SocketChannel socketc) {
				if(mutex != null) { mutex.lock(); }
				eq.api.Object tmp = send_queue.pop();
				eq.api.Buffer buf = null;
				if(tmp != null && tmp instanceof eq.api.Buffer) {
					buf = (eq.api.Buffer)tmp;
				}
				eq.api.String s = eq.api.String.Static.for_utf8_buffer(buf, false);
				if(mutex != null) { mutex.unlock(); }
				if(buf == null) {
					return(true);
				}
				java.nio.ByteBuffer bb = java.nio.ByteBuffer.wrap(buf.get_pointer().get_native_pointer());
				int r = -1;
				try {
					r = socketc.write(bb);
					if(r < 0) {
						return(false);
					}
				}
				catch(Exception e) {
					return(false);
				}
				if(r < buf.get_size()) {
					int osz = buf.get_size();
					if(mutex != null) { mutex.lock(); }
					send_queue.push_first((eq.api.Object)eq.api.SubBuffer.Static.create(buf, r, osz - r));
					if(mutex != null) { mutex.unlock(); }
				}
				return(true);
			}
		}}}

		public void run(EventReceiver listener, BooleanValue af) {
			bool w = true;
			abortflag = false;
			if(af.get_value()) {
				return;
			}
			if(String.is_empty(address)) {
				EventReceiver.event(listener, "err:invalid_hostname");
				EventReceiver.event(listener, "end");
				return;
			}
			embed {{{
				java.nio.channels.SocketChannel socketc;
				try {
					socketc = java.nio.channels.SocketChannel.open(new java.net.InetSocketAddress(address.to_strptr(), port));
					if(socketc != null) {
						}}} EventReceiver.event(listener, "ok"); embed {{{
					}
					else {
						}}} EventReceiver.event(listener, "err:failed_to_connect"); return; embed {{{
					}
					java.nio.channels.Pipe pipe = java.nio.channels.Pipe.open();
					if(pipe == null) {
						socketc.close();
						}}} EventReceiver.event(listener, "err:failed_to_open_pipe"); return; embed {{{						
					}
					java.nio.channels.Selector selector = java.nio.channels.Selector.open();
					if(selector == null) {
						socketc.close();
						}}} EventReceiver.event(listener, "err:failed_to_open_selector"); return; embed {{{
					}
					java.nio.channels.Pipe.SourceChannel piperead = pipe.source();
					if(piperead == null) {
						socketc.close();
						selector.close();
						}}} EventReceiver.event(listener, "err:failed_to_get_pipe_read"); return; embed {{{
					}
					pipewrite = pipe.sink();
					if(pipewrite == null) {
						socketc.close();
						selector.close();
						}}} EventReceiver.event(listener, "err:failed_to_get_pipe_write"); return; embed {{{
					}
					socketc.configureBlocking(false);
					piperead.configureBlocking(false);
					pipewrite.configureBlocking(false);
					piperead.register(selector, java.nio.channels.SelectionKey.OP_READ);
					socketc.register(selector, java.nio.channels.SelectionKey.OP_READ);
					java.util.Iterator<java.nio.channels.SelectionKey> itr;
					System.out.println("SocketConnection: Connection OK, waiting for I/O");
					while(true) {
						int sel = selector.select();
						if(abortflag || af.get_value()) {
							selector.close();
							break;
						}
						itr = selector.selectedKeys().iterator();
						while(itr.hasNext()) {
							java.nio.channels.SelectionKey sk = itr.next();
							itr.remove();
							if(sk.isReadable()) {
								java.nio.channels.Channel ch = (java.nio.channels.Channel)sk.channel();
								if(ch instanceof java.nio.channels.SocketChannel) {
									java.nio.channels.SocketChannel sc = (java.nio.channels.SocketChannel)ch;
									}}}
									Buffer buf;
									embed {{{ 
										buf = receive_data(sc);
									}}}
									if(buf == null) {
										EventReceiver.event(listener, "err:socket_closed");
										abortflag = true;
										break;
									}
									if(buf.get_size() > 0) {
										EventReceiver.event(listener, buf);
										buf = null;
									}
									embed {{{
								}
								else if(ch instanceof java.nio.channels.ReadableByteChannel){
									java.nio.channels.ReadableByteChannel rbc = (java.nio.channels.ReadableByteChannel)ch;
									java.nio.ByteBuffer buf = java.nio.ByteBuffer.allocate(4);
									int r = rbc.read(buf);
									buf.clear();
									buf = null;
									if(send_data(socketc) == false) {
										}}}
										EventReceiver.event(listener, "err:send_data_failed");
										abortflag = true;
										break;
										embed {{{
									}
								}
							}
						}
					}
					System.out.println("SocketConnection: Connection closed");
					socketc.close();
				}
				catch(Exception e) {
					e.printStackTrace();
				}
			}}}
			EventReceiver.event(listener, "end");
		}
	}

	~SocketConnectionSession() {
		close();
	}

	SocketConnectionSessionTask task;

	public void connect(String aaddress, int port) {
		var socket = get_socket();
		if(aaddress == null) {
			socket.on_connection_error("no_address");
			socket.on_connection_ended();
			return;
		}
		var btmgr = get_btmgr();
		task = new SocketConnectionSessionTask();
		task.set_logger(get_logger());
		var address = aaddress;
		task.set_address(address);
		task.set_port(port);
		task.set_socket(socket);
		var tt = btmgr.start_task(task, this);
		if(tt == null) {
			socket.on_connection_error("unable_to_start_background_task");
			socket.on_connection_ended();
			task = null;
		}
	}

	public void on_event(Object o) {
		var socket = get_socket();
		if(o == null) {
		}
		else if("ok".equals(o)) {
			socket.on_connection_opened();
		}
		else if("end".equals(o)) {
			socket.on_connection_ended();
		}
		else if(o is String && ((String)o).has_prefix("err:")) {
			socket.on_connection_error(((String)o).substring(4));
		}
		else if(o is Buffer) {
			socket.on_data_received((Buffer)o);
		}
	}

	public void close() {
		if(task != null) {
			task.set_abortflag(true);
			task.wakeup();
		}
	}

	public bool send(Buffer data) {
		if(data == null || task == null) {
			return(false);
		}
		task.add_send_data(data);
		task.wakeup();
		return(true);
	}
}
