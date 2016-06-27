
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
	class SocketConnectionSessionTask : LoggerObject, RunnableTask, Win32MainQueueHandler
	{
		embed "c" {{{
			#include <windows.h>
			#include <winsock2.h>
		}}}

		property String address;
		property int port;
		property SocketConnection socket;
		Queue send_queue;
		Mutex mutex;
		property bool abortflag = false;
		Win32MainQueue mq;
		TCPSocket tcpsocket;
		bool send_failed = false;

		public SocketConnectionSessionTask() {
			send_queue = Queue.create();
			mutex = Mutex.create();
			mq = GUI.engine.get_background_task_manager() as Win32MainQueue;
		}

		public void add_send_data(Buffer data) {
			if(mutex != null) { mutex.lock(); }
			send_queue.push(data);
			if(mutex != null) { mutex.unlock(); }
		}

		public void wakeup() {
			if(mq != null) {
				mq.add_to_queue(this);
			}
		}

		public void on_main_queue_event() {
			if(mutex != null) { mutex.lock(); }
			int c = send_queue.count();
			if(mutex != null) { mutex.unlock(); }
			if(c > 0) {
				if(send_data() == false) {
					send_failed = true;
				}
			}
			if(abortflag) {
				tcpsocket.close();
			}
		}

		Buffer receive_data(TCPSocket socket) {
			var buf = DynamicBuffer.create(4096);
			var r = socket.read(buf);
			if(r < 1) {
				return(null);
			}
			if(r == buf.get_size()) {
				return(buf);
			}
			return(SubBuffer.create(buf, 0, r));
		}

		bool send_data() {
			if(mutex != null) { mutex.lock(); }
			var buf = send_queue.pop() as Buffer;
			if(mutex != null) { mutex.unlock(); }
			if(buf == null) {
				return(true);
			}
			var r = tcpsocket.write(buf);
			if(r < 0) {
				return(false);
			}
			if(r < buf.get_size()) {
				int osz = buf.get_size();
				if(mutex != null) { mutex.lock(); }
				send_queue.push_first(SubBuffer.create(buf, r, osz - r));
				if(mutex != null) { mutex.unlock(); }
				wakeup();
			}
			return(true);
		}

		public void run(EventReceiver listener, BooleanValue af) {
			abortflag = false;
			log_debug("SocketConnection: Resolving `%s' ..".printf().add(this.address));
			var address = DNSCache.resolve(this.address);
			if(abortflag) {
				return;
			}
			if(String.is_empty(address)) {
				EventReceiver.event(listener, "err:invalid_hostname");
				EventReceiver.event(listener, "end");
				return;
			}
			log_debug("SocketConnection: Connecting to `%s:%d' ..".printf().add(address).add(port));
			var ss = TCPSocket.create(address, port);
			if(ss == null) {
				EventReceiver.event(listener, "err:failed_to_connect");
				EventReceiver.event(listener, "end");
				return;
			}
			if(abortflag) {
				ss.close();
				return;
			}
			tcpsocket = ss;
			if(ss is FileDescriptor == false) {
				ss.close();
				EventReceiver.event(listener, "err:invalid_socket");
				EventReceiver.event(listener, "end");
				return;
			}
			var fd = ((FileDescriptor)ss).get_fd();
			if(fd < 0) {
				ss.close();
				EventReceiver.event(listener, "err:invalid_file_descriptor");
				EventReceiver.event(listener, "end");
				return;
			}
			EventReceiver.event(listener, "ok");
			log_debug("SocketConnection: Connected OK, waiting for I/O");
			Buffer bb;
			while(true)
			{
				if(abortflag) {
					break;
				}
				int r;
				embed {{{
					fd_set rfd;
					FD_ZERO(&rfd);
					FD_SET(fd, &rfd);
					r = select(fd+1, &rfd, NULL, NULL, NULL);
				}}}
				if(r < 0) {
					EventReceiver.event(listener, "err:select_error");
					break;
				}
				if(r == 0) {
					continue;
				}
				if(send_failed) {
					EventReceiver.event(listener, "err:send_data_failed");
					break;
				}
				bb = receive_data(ss);
				if(bb == null) {
					EventReceiver.event(listener, "err:socket_closed");
					break;
				}
				EventReceiver.event(listener, bb);
				bb = null;
			}
			ss.close();
			tcpsocket = null;
			log_debug("SocketConnection: Connection closed");
			EventReceiver.event(listener, "end");
		}
	}

	SocketConnectionSessionTask task;

	public void connect(String aaddress, int aport) {
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
		var port = aport;
		if(address.chr(':') >= 0) {
			var sp = StringSplitter.split(address, ':', 2);
			address = sp.next() as String;
			var pp = sp.next() as String;
			if(pp != null) {
				port = pp.to_integer();
			}
		}
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
}
