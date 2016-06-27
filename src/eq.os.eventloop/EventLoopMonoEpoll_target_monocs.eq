
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

/*
public class MonoEpoll
{
	public static int EPOLL_CTL_ADD = 1;
	public static int EPOLL_CTL_DEL = 2;
	public static int EPOLL_CTL_MOD = 3;
	public static int EPOLLIN = 0x001;
	public static int EPOLLOUT = 0x004;
	public static int EPOLLERR = 0x008;
	public static int EPOLLHUP = 0x010;

	embed "cs" {{{
		[System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)]
		public struct EpollEvent
		{
			public int events;			// uint32_t events
			public System.IntPtr ptr;	// void* ptr
			public int fd;				// int fd
			public uint u32;			// uint32_t u32
			public ulong u64;			// uint64_t u64
		}

		[System.Runtime.InteropServices.DllImport("libc.so.6")]
		public static extern int epoll_create(int size);

		[System.Runtime.InteropServices.DllImport("libc.so.6")]
		public static extern int close(int fd);

		[System.Runtime.InteropServices.DllImport("libc.so.6")]
		public static extern int epoll_ctl(int epfd, int op, int fd, ref EpollEvent evt);

		[System.Runtime.InteropServices.DllImport("libc.so.6")]
		public static extern int epoll_wait(int epfd, ref EpollEvent evt, int maxevents, int timeout); 
	}}}
}
*/

public class EventLoopMonoEpoll : LoggerObject, EventLoop, BackgroundTaskManager
{
	public static EventLoopMonoEpoll instance(Logger logger) {
		var v = new EventLoopMonoEpoll();
		v.set_logger(logger);
		return(v);
	}

	property int epollfd;

	public EventLoopMonoEpoll() {
		embed "cs" {{{
			epollfd = Mono.Unix.Native.Syscall.epoll_create(1);
		}}}
	}

	~EventLoopMonoEpoll() {
		close();
	}

	public void close() {
		if(epollfd >= 0) {
			embed "cs" {{{
				Mono.Unix.Native.Syscall.close(epollfd);
			}}}
		}
		epollfd = -1;
	}

	class MyEventLoopEntry : LoggerObject, EventLoopEntry
	{
		property FileDescriptor fdo;
		property EventLoopMonoEpoll master;
		EventLoopReadListener rrl;
		EventLoopWriteListener wrl;
		bool added = false;

		void epoll_error(String f, int fd) {
			/* FIXME
			strptr ee;
			embed "c" {{{
				ee = strerror(errno);
			}}}
			log_error("epoll error %s / %d: %s".printf().add(f).add(fd).add(String.for_strptr(ee)));
			*/
		}

		public void on_epoll_error() {
			if(rrl != null) {
				var rr = rrl;
				rr.on_read_ready();
			}
			else if(wrl != null) {
				var wr = wrl;
				wr.on_write_ready();
			}
		}

		public void on_read_ready() {
			if(rrl != null) {
				var rr = rrl;
				rr.on_read_ready();
			}
		}

		public void on_write_ready() {
			if(wrl != null) {
				var wr = wrl;
				wr.on_write_ready();
			}
		}

		public void set_listeners(EventLoopReadListener rrl, EventLoopWriteListener wrl) {
			this.rrl = rrl;
			this.wrl = wrl;
			update_epoll();
		}

		public void set_read_listener(EventLoopReadListener rrl) {
			this.rrl = rrl;
			update_epoll();
		}

		public void set_write_listener(EventLoopWriteListener wrl) {
			this.wrl = wrl;
			update_epoll();
		}

		void update_epoll() {
			/* FIXME
			remove();
			if(fdo == null || master == null) {
				return;
			}
			if(rrl == null && wrl == null) {
				return;
			}
			embed {{{
				struct epoll_event ev;
				ev.events = 0;
			}}}
			if(rrl != null) {
				embed {{{
	  				ev.events |= EPOLLIN;
				}}}
			}
			if(wrl != null) {
				embed {{{
					ev.events |= EPOLLOUT;
				}}}
			}
			var fd = fdo.get_fd();
			var epollfd = master.get_epollfd();
			bool v = false;
			embed {{{
				ev.data.fd = fd;
				ev.data.ptr = ref_eq_api_Object(self);
				if(epoll_ctl(epollfd, EPOLL_CTL_ADD, fd, &ev) == -1) {
					unref_eq_api_Object(self);
					v = 0;
					}}}
					epoll_error("epoll_ctl/ADD", fd);
					embed {{{
				}
				else {
					v = 1;
				}
			}}}
			added = v;
			*/
		}

		public void remove() {
			/* FIXME
			if(added == false || fdo == null || master == null) {
				return;
			}
			var fd = fdo.get_fd();
			var epollfd = master.get_epollfd();
			embed {{{
				if(epoll_ctl(epollfd, EPOLL_CTL_DEL, fd, (void*)0) == -1) {
					}}}
					epoll_error("epoll_ctl/DEL", fd);
					embed {{{
				}
				unref_eq_api_Object(self);
			}}}
			added = false;
			*/
		}
	}

	public EventLoopEntry entry_for_object(Object o) {
		var fdo = o as FileDescriptor;
		if(fdo == null) {
			return(null);
		}
		var v = new MyEventLoopEntry().set_master(this).set_fdo(fdo);
		v.set_logger(get_logger());
		return(v);
	}

	public BackgroundTask start_timer(int interval_usec, TimerHandler o, Object arg = null) {
		/* FIXME
		var v = new TimerFDTimer();
		v.set_logger(get_logger());
		v.set_listener(o);
		v.set_arg(arg);
		return(v.start(this, interval_usec));
		*/
		return(null);
	}

	public BackgroundTask start_task(RunnableTask task, EventReceiver listener, BackgroundTaskListener tasklistener) {
		/*
		if(task == null) {
			return(null);
		}
		var tt = new PosixTaskThread();
		var v = new BackgroundTaskAdapter().set_task(task as BackgroundTask);
		tt.set_eventloop(this);
		tt.schedule(task, v.get_abortflag(), listener, tasklistener);
		return(v);
		*/
		return(null);
	}

	bool exitflag;
	bool running = false;
	int commpipewritefd = -1;

	public void execute() {
		var epollfd = this.epollfd;
		if (epollfd < 0) {
			log_error("FAILED to create an epoll fd.");
		}
		int r;
		exitflag = false;
		running = true;
		embed "cs" {{{
			var pipes = new int[2];
			if(Mono.Unix.Native.Syscall.pipe(pipes) != 0) {
				}}} log_error("EventLoopMonoEpoll: Failed to create controller pipe"); embed {{{
			}
			var ev = new Mono.Unix.Native.EpollEvent();
			ev.events = Mono.Unix.Native.EpollEvents.EPOLLIN;
			ev.fd = pipes[0];
			ev.ptr = (System.IntPtr)0;
			if(Mono.Unix.Native.Syscall.epoll_ctl(epollfd, Mono.Unix.Native.EpollOp.EPOLL_CTL_ADD, pipes[0], ref ev) == -1) {
				}}} log_error("EventLoopMonoEpoll: Failed to add controller pipe to epoll"); embed {{{
			}
			commpipewritefd = pipes[1];
			var events = new Mono.Unix.Native.EpollEvent[1024];
		}}}
		log_debug("EventLoopMonoEpoll started");
		while(exitflag == false) {
			embed "cs" {{{
				r = Mono.Unix.Native.Syscall.epoll_wait(epollfd, events, 1024, -1);
			}}}
			/* FIXME
			if(r < 0) {
				embed {{{
					var errnostr = new System.Text.StringBuilder();
					if(errno != EINTR) {
						errnostr = strerror(errno);
					}
				}}}
				if(errnostr != null) {
					log_error("Call to 'epoll()' returned error status %d: '%s'".printf().add(r).add(String.for_strptr(errnostr)));
				}
			}
			if(r > 0) {
				embed {{{
					int x;
					for (x=0; x<r; x++) {
						if(events[x].events & EPOLLERR || events[x].events & EPOLLHUP) {
							if(events[x].data.ptr != NULL) {
								ref_eq_api_Object(events[x].data.ptr);
								eq_os_eventloop_EventLoopMonoEpoll_MyEventLoopEntry_on_epoll_error(events[x].data.ptr);
								unref_eq_api_Object(events[x].data.ptr);
							}
						}
						if(events[x].events & EPOLLIN) {
							if(events[x].data.ptr == NULL) {
								char b[16];
								read(pipes[0], b, 16);
							}
							else {
								ref_eq_api_Object(events[x].data.ptr);
								eq_os_eventloop_EventLoopMonoEpoll_MyEventLoopEntry_on_read_ready(events[x].data.ptr);
								unref_eq_api_Object(events[x].data.ptr);
							}
						}
						if(events[x].events & EPOLLOUT) {
							ref_eq_api_Object(events[x].data.ptr);
							eq_os_eventloop_EventLoopMonoEpoll_MyEventLoopEntry_on_write_ready(events[x].data.ptr);
							unref_eq_api_Object(events[x].data.ptr);
						}
					}
				}}}
			}
			*/
		}
		embed "cs" {{{
			Mono.Unix.Native.Syscall.close(pipes[0]);
			Mono.Unix.Native.Syscall.close(pipes[1]);
			pipes = null;
		}}}
		commpipewritefd = -1;
		running = false;
		log_debug("EventLoopMonoEpoll ended");
	}

	public void stop() {
		exitflag = true;
		/* FIXME
		var fd = commpipewritefd;
		if(fd >= 0) {
			embed {{{
				char c = 1;
				write(fd, &c, 1);
			}}}
		}
		*/
	}

	public bool is_running() {
		return(running);
	}
}
