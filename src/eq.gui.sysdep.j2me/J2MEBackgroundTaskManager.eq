
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

class J2MEBackgroundTaskManager : BackgroundTaskManager
{
	public J2MEBackgroundTaskManager() {
	}

	embed "java" {{{
		class SerialTimerRunnable implements Runnable
		{
			eq.os.task.TimerHandler timer = null;
			eq.api.Object arg = null;
			TimerWrapper timerwrapper = null;

			public SerialTimerRunnable(TimerWrapper tw) {
				this.timerwrapper = tw;
			}

			public void run() {
				if(timerwrapper.timer.on_timer(timerwrapper.arg) == false) {
					timerwrapper.abort();
					return;
				}
			}
		}
		class TimerWrapper extends java.util.TimerTask implements eq.os.task.BackgroundTask
		{
			boolean abort = false;
			public eq.os.task.TimerHandler timer = null;
			public eq.api.Object arg = null;
			public TimerWrapper(eq.os.task.TimerHandler timer, eq.api.Object arg) {
				this.timer = timer;
				this.arg = arg;
			}
			public void run() {
				J2MEDisplay.get_display().callSerially(new SerialTimerRunnable(this));
			}
			public boolean abort() {
				cancel();
				return(true);
			}
		}
	}}}

	public BackgroundTask start_task(RunnableTask task, EventReceiver listener, BackgroundTaskListener tasklistener) {
		if(task == null) {
			return(null);
		}
		var tt = new J2METaskThread();
		var v = new BackgroundTaskAdapter().set_task(task as BackgroundTask);
		tt.schedule(task, v.get_abortflag(), listener, tasklistener);
		return(v);
	}

	embed "java" {{{
		java.util.Timer timer = new java.util.Timer();
	}}}

	public BackgroundTask start_timer(int usec, TimerHandler o, Object arg = null) {
		int millis = usec/1000;
		if(millis < 1) {
			millis = 1;
		}
		BackgroundTask v = null;
		embed "java" {{{
			v = (eq.os.task.BackgroundTask)new TimerWrapper(o, arg);
			timer.schedule((java.util.TimerTask)v, millis, millis);
		}}}
		return(v);
	}
}
