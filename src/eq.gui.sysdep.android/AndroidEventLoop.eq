
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

public class AndroidEventLoop : BackgroundTaskManager
{
	embed "java" {{{
		private static class TimerWrapper extends eq.api.Object implements java.lang.Runnable, eq.os.task.BackgroundTask
		{
			private android.os.Handler handler = null;
			private eq.os.task.TimerHandler timer = null;
			private eq.api.Object arg = null;
			private boolean stop = false;
			private int msec = 0;
			public TimerWrapper(eq.os.task.TimerHandler timer, eq.api.Object arg) {
				handler = new android.os.Handler();
				this.timer = timer;
				this.arg = arg;
			}
			public void start(int msec) {
				this.msec = msec;
				handler.postDelayed(this, (long)msec);
			}
			public boolean abort() {
				stop = true;
				return(true);
			}
			public void run() {
				if(stop == false) {
					if(timer != null) {
						if(timer.on_timer(arg)) {
							handler.postDelayed(this, (long)msec);
						}
					}
				}
			}
		}
	}}}

	public BackgroundTask start_timer(int usec, TimerHandler o, Object arg = null) {
		if(o == null) {
			return(null);
		}
		BackgroundTask v = null;
		embed "java" {{{
			v = new TimerWrapper(o, arg);
			((TimerWrapper)v).start(usec / 1000);
		}}}
		return(v);
	}

	public BackgroundTask start_task(RunnableTask task, EventReceiver listener, BackgroundTaskListener tasklistener) {
		if(task == null) {
			return(null);
		}
		var tt = new AndroidTaskThread();
		var v = new BackgroundTaskAdapter().set_task(task as BackgroundTask);
		tt.schedule(task, v.get_abortflag(), listener, tasklistener);
		return(v);
	}
}
