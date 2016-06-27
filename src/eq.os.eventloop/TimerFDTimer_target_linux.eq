
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

class TimerFDTimer : LoggerObject, BackgroundTask, EventLoopReadListener, FileDescriptor
{
	embed {{{
		#include <sys/timerfd.h>
	}}}

	property TimerHandler listener;
	property EventLoop eloop;
	property Object arg;
	EventLoopEntry ee;
	int fd;

	public int get_fd() {
		return(fd);
	}

	public TimerFDTimer start(EventLoop eloop, int usec) {
		if(eloop == null) {
			log_error("EventLoopEpoll timer start: null eventloop");
			return(null);
		}
		int fd;
		embed {{{
			fd = timerfd_create(CLOCK_MONOTONIC, TFD_CLOEXEC);
		}}}
		if(fd < 0) {
			log_error("EventLoopEpoll timer start: Failed to create timer fd");
			return(null);
		}
		this.fd = fd;
		embed {{{
			struct itimerspec tt;
			int ss = usec / 1000000;
			int ns = (usec % 1000000) / 1000;
			tt.it_interval.tv_nsec = ns;
			tt.it_interval.tv_sec = ss;
			tt.it_value.tv_nsec = ns;
			tt.it_value.tv_sec = ss;
			if(timerfd_settime(fd, 0, &tt, NULL) < 0) {
				close(fd);
				}}}
				log_error("timerfd_settime failed");
				this.fd = -1;
				return(null);
				embed {{{
			}
		}}}
		ee = eloop.entry_for_object(this);
		if(ee == null) {
			log_error("Failed to create event loop object for timer");
			abort();
			return(null);
		}
		log_debug("timerfd timer fd=%d, usec=%d successfully created".printf().add(fd).add(usec));
		ee.set_read_listener(this);
		return(this);
	}

	public bool abort() {
		if(ee != null) {
			ee.remove();
			ee = null;
		}
		var fd = this.fd;
		if(fd >= 0) {
			embed {{{
				struct itimerspec tt;
				tt.it_interval.tv_nsec = 0;
				tt.it_interval.tv_sec = 0;
				tt.it_value.tv_nsec = 0;
				tt.it_value.tv_sec = 0;
				timerfd_settime(fd, 0, &tt, NULL);
				close(fd);
			}}}
			this.fd = -1;
		}
		return(true);
	}

	public void on_read_ready() {
		var fd = this.fd;
		if(fd >= 0) {
			embed {{{
				char buf[64];
				if(read(fd, buf, 64) < 1) {
					}}}
					abort();
					return;
					embed {{{
				}
			}}}
		}
		if(listener == null) {
			abort();
		}
		else if(listener.on_timer(arg) == false) {
			abort();
		}
	}
}
