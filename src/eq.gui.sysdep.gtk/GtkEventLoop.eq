
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

public class GtkEventLoop : BackgroundTaskManager
{
	embed "c" {{{
		#include <gtk/gtk.h>
	}}}

	private Collection readers = null;

	public GtkEventLoop() {
		readers = LinkedList.create();
	}

	public BackgroundTask start_task(RunnableTask task, EventReceiver listener, BackgroundTaskListener tasklistener) {
		if(task == null) {
			return(null);
		}
		var tt = new GtkTaskThread();
		var v = new BackgroundTaskAdapter().set_task(task as BackgroundTask);
		tt.set_eventloop(this);
		tt.schedule(task, v.get_abortflag(), listener, tasklistener);
		return(v);
	}

	public void execute() {
		embed "c" {{{
			gtk_main();
		}}}
	}

	public void stop() {
		embed "c" {{{
			gtk_main_quit();
		}}}
	}

	private class ReaderWrapper : Object
	{
		public FileDescriptor fd = null;
		public EventLoopReader cb = null;
		public ptr channel = null;

		public static ReaderWrapper create(FileDescriptor fd, EventLoopReader cb, ptr channel) {
			var v = new ReaderWrapper();
			v.fd = fd;
			v.cb = cb;
			v.channel = channel;
			return(v);
		}
	}

	private class TimerWrapper : BackgroundTask
	{
		embed "c" {{{
			#include <gtk/gtk.h>
		}}}

		TimerHandler timer;
		Object arg;
		int id;
		bool stop_flag = false;

		public static TimerWrapper create(TimerHandler timer, Object arg) {
			var v = new TimerWrapper();
			v.timer = timer;
			v.arg = arg;
			return(v);
		}

		public bool run_timer() {
			if(stop_flag) {
				embed "c" {{{
					unref_eq_api_Object(self);
				}}}
				return(false);
			}
			if(timer != null) {
				if(timer.on_timer(arg) == false) {
					embed "c" {{{
						unref_eq_api_Object(self);
					}}}
					return(false);
				}
			}
			return(true);
		}

		embed "c" {{{
			gboolean exec_timer(gpointer data) {
				return(eq_gui_sysdep_gtk_GtkEventLoop_TimerWrapper_run_timer(data));
			}
		}}}

		public bool start(int usec) {
			bool v = false;
			int val = usec / 1000;
			int id;
			if(val <= 9) {
				val = 10;
			}
			embed "c" {{{
				ref_eq_api_Object(self);
				id = g_timeout_add(val, (GSourceFunc)exec_timer, self);
			}}}
			if(id <= 0) {
				Log.warning("g_timeout_add returned %d <= 0".printf().add(id));
			}
			v = true;
			this.id = id;
			return(v);
		}

		public bool abort() {
			stop_flag = true;
			return(true);
		}
	}

	public BackgroundTask start_timer(int usec, TimerHandler o, Object arg) {
		var v = TimerWrapper.create(o, arg);
		if(v.start(usec) == false) {
			v = null;
		}
		return(v);
	}

	public bool check_fd(int cfd) {
		if(cfd < 0) {
			return(false);
		}
		bool v = false;
		int fd;
		if(readers != null) {
			var it = readers.iterate();
			if(it != null) {
				ReaderWrapper o;
				while((o = it.next() as ReaderWrapper) != null) {
					if(o.fd == null) {
						continue;
					}
					fd = o.fd.get_fd();
					if(cfd == fd) {
						if(o.cb != null) {
							o.cb.on_event_loop_reader_event();
						}
						v = true;
						break;
					}
				}
			}
		}
		return(v);
	}

	embed "c" {{{
		static gboolean wait_readers(GIOChannel * iochannel, GIOCondition condition, gpointer data) {
			gboolean v = TRUE;
			if(condition == G_IO_NVAL || condition == G_IO_HUP) {
				v = FALSE;
			}
			if(condition == G_IO_IN || condition == G_IO_PRI) {
				int fd = g_io_channel_unix_get_fd(iochannel);
				if(fd >= 0) {
					v = eq_gui_sysdep_gtk_GtkEventLoop_check_fd(data, fd);
				}
				else {
					v = FALSE;
				}
			}
			return v;
		}
	}}}

	public bool add_reader(Object o, EventLoopReader cb) {
		bool v = false;
		var loopreader = cb;
		if(loopreader == null) {
			loopreader = o as EventLoopReader;
		}
		if(o is FileDescriptor) {
			var ofd = o as FileDescriptor;
			if(ofd != null) {
				int fd = ofd.get_fd();
				if(fd >= 0 && loopreader != null) {
					ptr ioc;
					embed "c" {{{
						GIOChannel *channel = g_io_channel_unix_new(fd);
						if(channel == NULL) {
							g_error("Cannot create new GIOChannel\n");
						}
						else if(!g_io_add_watch(channel, G_IO_IN | G_IO_PRI | G_IO_NVAL | G_IO_HUP, (GIOFunc)wait_readers, self)) {
							g_error("Cannot add watch\n");
							g_io_channel_unref(channel);
							channel = NULL;
						}
						ioc = channel;
					}}}
					var rw = ReaderWrapper.create(ofd, loopreader, ioc);
					readers.add(rw);
					v = true;
				}
			}
		}
		return(v);
	}

	public void remove_reader(Object o) {
		Object fd;
		ptr channel;
		foreach(ReaderWrapper read in readers) {
			fd = read.fd;
			if(fd == o) {
				channel = read.channel;
				embed "c" {{{
					g_io_channel_shutdown(channel, TRUE, NULL);
					g_io_channel_unref(channel);
				}}}
				readers.remove(read);
				break;
			}
		}
	}

	public void remove_writer(Object o) {
		//FIXME
	}
}
