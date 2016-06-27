
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

class WPCSEventLoop : BackgroundTaskManager
{
	class DispatcherTimerWrapper : BackgroundTask {
		embed "cs" {{{
			System.Windows.Threading.DispatcherTimer dt;
			System.Windows.Threading.Dispatcher ui_dispatcher;
		}}}
		TimerHandler timer;
		Object arg;

		public static DispatcherTimerWrapper start(int usec, TimerHandler timer, Object arg) {
			var v = new DispatcherTimerWrapper();
			v.timer = timer;
			v.arg = arg;
			if(v._start(usec) == false) {
				v = null;
			}
			return(v);
		}

		private bool _start(int usec) {
			bool v = false;
			embed "cs" {{{
				if(timer != null) {
					ui_dispatcher = System.Windows.Application.Current.RootVisual.Dispatcher;
					dt = new System.Windows.Threading.DispatcherTimer();
					dt.Interval = new System.TimeSpan(0, 0, 0, usec/1000000, usec/1000%1000);
					dt.Tick += new System.EventHandler(tick);
					dt.Start();
					v = true;
				}
			}}}
			return(v);
		}

		public bool abort() {
			embed "cs" {{{
				if(dt != null) {
					dt.Stop();
					dt = null;
				}
			}}}
			return(true);
		}

		embed "cs" {{{
			void tick(object sender, System.EventArgs e) {
				ui_dispatcher.BeginInvoke(new System.Action(() => {
					if(timer.on_timer(arg) == false) {
						((System.Windows.Threading.DispatcherTimer)sender).Stop();
					}
				}));
			}
		}}}
	}

	public BackgroundTask start_task(RunnableTask task, EventReceiver listener, BackgroundTaskListener tasklistener) {
		if(task == null) {
			return(null);
		}
		var tt = new WPCSTaskThread();
		var v = new BackgroundTaskAdapter().set_task(task as BackgroundTask);
		tt.schedule(task, v.get_abortflag(), listener, tasklistener);
		return(v);
	}

	public BackgroundTask start_timer(int usec, TimerHandler o, Object arg = null) {
		return(DispatcherTimerWrapper.start(usec, o, arg));
	}
}

