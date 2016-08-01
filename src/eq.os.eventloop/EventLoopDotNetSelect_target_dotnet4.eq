
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

public class EventLoopDotNetSelect : LoggerObject, EventLoop, BackgroundTaskManager
{
	class MyEventLoopEntry : EventLoopEntry
	{
		property EventLoopDotNetSelect master;
		property TCPSocket socket;
		EventLoopReadListener rrl;
		EventLoopWriteListener wrl;
		bool added = false;

		public void on_read_ready() {
			var rrl = this.rrl;
			if(rrl != null) {
				rrl.on_read_ready();
			}
		}

		public void on_write_ready() {
			var wrl = this.wrl;
			if(wrl != null) {
				wrl.on_write_ready();
			}
		}

		public void set_listeners(EventLoopReadListener rrl, EventLoopWriteListener wrl) {
			this.rrl = rrl;
			this.wrl = wrl;
			update();
		}

		public void set_read_listener(EventLoopReadListener rrl) {
			this.rrl = rrl;
			update();
		}

		public void set_write_listener(EventLoopWriteListener wrl) {
			this.wrl = wrl;
			update();
		}

		void update() {
			remove();
			if(socket == null || master == null) {
				return;
			}
			if(rrl == null && wrl == null) {
				return;
			}
			if(rrl != null) {
				master.readlist.add(this);
			}
			if(wrl != null) {
				master.writelist.add(this);
			}
			added = true;
		}

		public void remove() {
			if(added == false || master == null) {
				return;
			}
			master.readlist.remove(this);
			master.writelist.remove(this);
			added = false;
		}

		embed "cs" {{{
			public System.Net.Sockets.Socket getNetSocket() {
				var ss = socket as eq.net.socket.TCPSocketImpl;
				if(ss == null) {
					return(null);
				}
				return(ss.socket);
			}
		}}}
	}

	class TimerTask : RunnableTask
	{
		property int interval_usec;
		property TimerHandler handler;
		property Object arg;

		public void run(EventReceiver listener, BooleanValue abortflag) {
			// FIXME: This is not abortable. Would be better to sleep
			// in smaller increments, and then loop through it.
			SystemEnvironment.usleep(interval_usec);
			if(listener != null) {
				listener.on_event(this);
			}
		}
	}

	public static EventLoopDotNetSelect instance(Logger logger) {
		var v = new EventLoopDotNetSelect();
		v.set_logger(logger);
		return(v);
	}

	bool exitflag;
	bool running = false;
	int signalPort = -1;
	public Collection readlist = null;
	public Collection writelist = null;

	public EventLoopDotNetSelect() {
		readlist = LinkedList.create();
		writelist = LinkedList.create();
	}

	public EventLoopEntry entry_for_object(Object o) {
		var ss = o as TCPSocket;
		if(ss == null) {
			return(null);
		}
		return(new MyEventLoopEntry().set_master(this).set_socket(ss));
	}

	class TimerTaskExecuter : EventReceiver
	{
		property EventLoopDotNetSelect eventloop;
		public void on_event(Object o) {
			var tt = o as TimerTask;
			if(tt == null) {
				return;
			}
			var hh = tt.get_handler();
			if(hh != null) {
				if(hh.on_timer(tt.get_arg())) {
					eventloop.start_timer(tt.get_interval_usec(), hh, tt.get_arg());
				}
			}
		}
	}

	public BackgroundTask start_timer(int interval_usec, TimerHandler o, Object arg = null) {
		if(interval_usec < 0) {
			log_error("start_timer called with negative interval: %d. Integer overflow?".printf().add(interval_usec));
			return(null);
		}
		var task = new TimerTask();
		task.set_interval_usec(interval_usec);
		task.set_handler(o);
		task.set_arg(arg);
		return(start_task(task, new TimerTaskExecuter().set_eventloop(this), null));
	}

	public BackgroundTask start_task(RunnableTask task, EventReceiver listener, BackgroundTaskListener tasklistener) {
		log_error("start_task: Not implemented.");
		return(null);
	}

	embed "cs" {{{
		MyEventLoopEntry getEntryForSocket(System.Net.Sockets.Socket socket, eq.api.Collection list) {
			var it = list.iterate();
			if(it == null) {
				return(null);
			}
			while(true) {
				var ee = it.next() as MyEventLoopEntry;
				if(ee == null) {
					break;
				}
				if(ee.getNetSocket() == socket) {
					return(ee);
				}
			}
			return(null);
		}
	}}}

	public bool execute_select(Collection reads, Collection writes) {
		embed "cs" {{{
			var fdsetr = new System.Collections.ArrayList();
			var fdsetw = new System.Collections.ArrayList();
		}}}
		foreach(MyEventLoopEntry myo1 in readlist) {
			embed "cs" {{{
				fdsetr.Add(myo1.getNetSocket());
			}}}
		}
		foreach(MyEventLoopEntry myo2 in writelist) {
			embed "cs" {{{
				fdsetw.Add(myo2.getNetSocket());
			}}}
		}
		embed "cs" {{{
			try {
				System.Net.Sockets.Socket.Select(fdsetr, fdsetw, null, -1);
			}
			catch(System.Exception e) {
				log_error((eq.api.Object)_S("Call to Select failed: " + e.ToString()));
				return(false);
			}
			foreach(System.Net.Sockets.Socket socket in fdsetr) {
				var e = getEntryForSocket(socket, readlist);
				if(e != null) {
					reads.append(e);
				}
			}
			foreach(System.Net.Sockets.Socket socket in fdsetw) {
				var e = getEntryForSocket(socket, writelist);
				if(e != null) {
					writes.append(e);
				}
			}
		}}}
		return(true);
	}

	class PipeReader : EventLoopReadListener
	{
		property TCPSocket socket;
		public void on_read_ready() {
			if(socket == null) {
				return;
			}
			var ss = socket.accept();
			if(ss != null) {
				ss.close();
			}
		}
	}

	TCPSocket open_signal_socket() {
		var v = TCPSocket.create();
		int n;
		for(n=1024; n<11024; n++) {
			if(v.listen(n)) {
				signalPort = n;
				return(v);
			}
		}
		return(null);
	}

	TCPSocket signalClient;

	public void execute() {
		exitflag = false;
		running = true;
		var signalSocket = open_signal_socket();
		if(signalSocket != null) {
			var ee = entry_for_object(signalSocket);
			if(ee != null) {
				ee.set_read_listener(new PipeReader().set_socket(signalSocket));
			}
		}
		var reads = Array.create();
		var writes = Array.create();
		log_debug("EventLoopDotNetSelect started");
		while(exitflag == false) {
			if(execute_select(reads, writes) == false) {
				continue;
			}
			foreach(MyEventLoopEntry ele in reads) {
				ele.on_read_ready();
			}
			foreach(MyEventLoopEntry ele in writes) {
				ele.on_write_ready();
			}
			reads.clear();
			writes.clear();
		}
		if(signalSocket != null) {
			signalSocket.close();
			signalSocket = null;
		}
		if(signalClient != null) {
			signalClient.close();
			signalClient = null;
		}
		readlist.clear();
		writelist.clear();
		signalPort = -1;
		running = false;
		log_debug("EventLoopDotNetSelect ended");
	}

	public void stop() {
		exitflag = true;
		if(signalPort < 1) {
			return;
		}
		if(signalClient != null) {
			signalClient.close();
			signalClient = null;
		}
		signalClient = TCPSocket.create("127.0.0.1", signalPort);
	}

	public bool is_running() {
		return(running);
	}
}
