
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

public class EventLoopSelect : LoggerObject, EventLoop, BackgroundTaskManager
{
	class MyEventLoopEntry : EventLoopEntry, FileDescriptor
	{
		property FileDescriptor fdo;
		property EventLoopSelect master;
		EventLoopReadListener rrl;
		EventLoopWriteListener wrl;
		bool added = false;

		public int get_fd() {
			if(fdo == null) {
				return(-1);
			}
			return(fdo.get_fd());
		}

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
			if(fdo == null || master == null) {
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

	public static EventLoopSelect instance(Logger logger) {
		var v = new EventLoopSelect();
		v.set_logger(logger);
		return(v);
	}

	embed {{{
		#include <stdio.h>
		#include <stdlib.h>
		#include <errno.h>
		#include <string.h>
		#include <sys/select.h>
		#include <unistd.h>
	}}}

	bool exitflag;
	bool running = false;
	int commpipewritefd = -1;
	public Collection readlist = null;
	public Collection writelist = null;

	public EventLoopSelect() {
		readlist = LinkedList.create();
		writelist = LinkedList.create();
	}

	public EventLoopEntry entry_for_object(Object o) {
		var fdo = o as FileDescriptor;
		if(fdo == null) {
			return(null);
		}
		return(new MyEventLoopEntry().set_master(this).set_fdo(fdo));
	}

	class TimerTaskExecuter : EventReceiver
	{
		property EventLoopSelect eventloop;
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

	static bool thread_timer_warning_flag = false;

	public BackgroundTask start_timer(int interval_usec, TimerHandler o, Object arg = null) {
		if(interval_usec < 0) {
			log_error("start_timer called with negative interval: %d. Integer overflow?".printf().add(interval_usec));
			return(null);
		}
		IFDEF("target_linux") {
			var v = new TimerFDTimer();
			v.set_logger(get_logger());
			v.set_listener(o);
			v.set_arg(arg);
			return(v.start(this, interval_usec));
		}
		ELSE {
			if(thread_timer_warning_flag == false) {
				log_debug("*** Starting thread based timers. Warning: This is the fallback implementation. ***");
				thread_timer_warning_flag = true;
			}
			var task = new TimerTask();
			task.set_interval_usec(interval_usec);
			task.set_handler(o);
			task.set_arg(arg);
			return(start_task(task, new TimerTaskExecuter().set_eventloop(this), null));
		}
	}

	public BackgroundTask start_task(RunnableTask task, EventReceiver listener, BackgroundTaskListener tasklistener) {
		if(task == null) {
			return(null);
		}
		var tt = new PosixTaskThread();
		var v = new BackgroundTaskAdapter().set_task(task as BackgroundTask);
		tt.set_eventloop(this);
		tt.schedule(task, v.get_abortflag(), listener, tasklistener);
		return(v);
	}

	public bool execute_select(ptr fdr, ptr fdw, int timeout) {
		int n = 0, fd;
		embed "c" {{{
			FD_ZERO((fd_set*)fdr);
			FD_ZERO((fd_set*)fdw);
		}}}
		int rc = 0, wc = 0;
		foreach(FileDescriptor o in readlist) {
			fd = o.get_fd();
			if(fd >= 0) {
				embed "c" {{{
					FD_SET(fd, (fd_set*)fdr);
				}}}
			}
			if(fd > n) {
				n = fd;
			}
			rc++;
		}
		foreach(FileDescriptor o in writelist) {
			fd = o.get_fd();
			if(fd >= 0) {
				embed "c" {{{
					FD_SET(fd, (fd_set*)fdw);
				}}}
			}
			if(fd > n) {
				n = fd;
			}
			wc++;
		}
		int nc = 0;
		if(n > 0) {
			nc = n + 1;
		}
		int r = -1;
		if(timeout < 0) {
			embed "c" {{{ r = select(nc, (fd_set*)fdr, (fd_set*)fdw, (void*)0, (void*)0); }}}
		}
		else {
			embed "c" {{{
				struct timeval tv;
				tv.tv_sec = (long)timeout / 1000000;
				tv.tv_usec = (long)timeout % 1000000;
				r = select(nc, (fd_set*)fdr, (fd_set*)fdw, (void*)0, &tv);
			}}}
		}
		bool v = false;
		if(r < 0) {
			strptr err = null;
			embed "c" {{{
				if(errno != EINTR) {
					err = strerror(errno);
				}
			}}}
			if(err != null) {
				log_error("Call to 'select()' returned error status %d: '%s'".printf().add(r)
					.add(String.for_strptr(err)).to_string());
			}
		}
		else if(r > 0) {
			v = true;
		}
		return(v);
	}

	class PipeReader : EventLoopReadListener
	{
		property int fd;
		public void on_read_ready() {
			var fd = this.fd;
			embed {{{
				char b[16];
				read(fd, b, 16);
			}}}
		}
	}

	public void execute() {
		int r;
		exitflag = false;
		running = true;
		int prd = -1;
		int pfd = -1;
		embed {{{
			int pipes[2];
			if(pipe(pipes) != 0) {
				}}} log_error("EventLoopSelect: Failed to create controller pipe"); embed {{{
			}
			else {
				prd = pipes[0];
				pfd = pipes[1];
			}
		}}}
		if(prd >= 0) {
			var ee = entry_for_object(FileDescriptor.for_fd(prd));
			if(ee != null) {
				ee.set_read_listener(new PipeReader().set_fd(prd));
			}
		}
		ptr fdsetr;
		ptr fdsetw;
		embed {{{
			fd_set fdr;
			fd_set fdw;
			fdsetr = &fdr;
			fdsetw = &fdw;
		}}}
		commpipewritefd = pfd;
		log_debug("EventLoopSelect started");
		while(exitflag == false) {
			if(execute_select(fdsetr, fdsetw, -1) == false) {
				continue;
			}
			foreach(MyEventLoopEntry ele in readlist) {
				int fd = ele.get_fd();
				if(fd < 0) {
					continue;
				}
				embed "c" {{{
					if(FD_ISSET(fd, &fdr) != 0) {
						FD_CLR(fd, &fdr);
						}}}
						ele.on_read_ready();
						embed {{{
					}
				}}}
			}
			foreach(MyEventLoopEntry ele in writelist) {
				int fd = ele.get_fd();
				if(fd < 0) {
					continue;
				}
				embed "c" {{{
					if(FD_ISSET(fd, &fdw) != 0) {
						FD_CLR(fd, &fdw);
						}}}
						ele.on_write_ready();
						embed {{{
					}
				}}}
			}
		}
		embed {{{
			close(pipes[0]);
			close(pipes[1]);
		}}}
		commpipewritefd = -1;
		running = false;
		log_debug("EventLoopSelect ended");
	}

	public void stop() {
		exitflag = true;
		var fd = commpipewritefd;
		if(fd >= 0) {
			embed {{{
				char c = 1;
				write(fd, &c, 1);
			}}}
		}
	}

	public bool is_running() {
		return(running);
	}
}
