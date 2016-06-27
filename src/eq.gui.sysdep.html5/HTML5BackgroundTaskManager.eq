
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

public class HTML5BackgroundTaskManager : BackgroundTaskManager
{
	class TimerWrapper : BackgroundTask
	{
		TimerHandler apitimer = null;
		Object arg = null;
		int interval = 0;
		bool is_stop = false;

		public static TimerWrapper create(TimerHandler t, Object arg) {
			var v = new TimerWrapper();
			v.apitimer = t;
			v.arg = arg;
			embed "js" {{{
				v.timer = null;
			}}}
			return(v);
		}

		public bool start(int usec) {
			bool v = false;
			embed "js" {{{
				var self = this;
				this.timer = setInterval(function() { self.on_timer(); }, usec / 1000);
				v = true;
			}}}
			interval = usec;
			return(v);
		}

		public bool abort() {
			embed "js" {{{
				clearInterval(this.timer);
			}}}
			is_stop = true;
			return(true);
		}

		public void on_timer() {
			if(apitimer != null && !is_stop) {
				if(apitimer.on_timer(arg) == false) {
					abort();
				}
			}
		}
	}

	public BackgroundTask start_timer(int usec, TimerHandler o, Object arg = null) {
		var v = TimerWrapper.create(o, arg);
		if(v.start(usec) == false) {
			v = null;
		}
		return(v);
	}

	public BackgroundTask start_task(RunnableTask task, EventReceiver listener, BackgroundTaskListener tasklistener) {
		return(null); // FIXME: Implement with web workers
	}
}

