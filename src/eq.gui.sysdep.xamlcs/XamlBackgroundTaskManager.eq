
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

public class XamlBackgroundTaskManager : BackgroundTaskManager
{
	class DispatcherTimerWrapper : BackgroundTask
	{
		embed {{{
			Windows.UI.Xaml.DispatcherTimer timer;
			Windows.UI.Core.CoreDispatcher dispatcher;
		}}}
		TimerHandler handler;
		Object param;

		public static DispatcherTimerWrapper create(int usec, TimerHandler handler, Object param) {
			var v = new DispatcherTimerWrapper();
			v.handler = handler;
			v.param = param;
			if(handler != null) {
				embed {{{
					var cw = Windows.UI.Core.CoreWindow.GetForCurrentThread();
					if(cw == null) {
						return(null);
					}
					v.dispatcher = cw.Dispatcher;
					v.timer = new Windows.UI.Xaml.DispatcherTimer();
					v.timer.Tick += v.on_dispatcher_tick;
					v.timer.Interval = new System.TimeSpan(0, 0, 0, usec/1000000, usec/1000%1000);
					v.timer.Start();
				}}}
				return(v);
			}
			return(null);
		}

		embed {{{
			protected void on_dispatcher_tick(object o, object e) {
				if(handler.on_timer(param) == false) {
					timer.Stop();
				}
			}
		}}}

		public bool abort() {
			embed {{{
				try {
					dispatcher.RunAsync(Windows.UI.Core.CoreDispatcherPriority.Normal, () => {
						if(timer != null) {
							timer.Stop();
						}
					});
				}
				catch(System.Exception) {
				}
			}}}
			return(true);
		}
	}

	class DispatcherEventReceiver : EventReceiver
	{
		property EventReceiver origevent;
		embed {{{
			Windows.UI.Core.CoreDispatcher dispatcher;

			public DispatcherEventReceiver(Windows.UI.Core.CoreDispatcher d, eq.api.EventReceiver e) {
				dispatcher = d;
				origevent = e;
			}
		}}}

		public void on_event(Object o) {
			var ttm = TaskThreadMessage.create(o, origevent);
			embed {{{
				dispatcher.RunAsync(Windows.UI.Core.CoreDispatcherPriority.Normal, () => {
					ttm.trigger();
				});
			}}}
		}
	}

	class DispatcherTaskWrapper : BackgroundTask
	{
		embed {{{
			System.Threading.CancellationTokenSource cancel_token_src;
		}}}
		RunnableTask task;

		public static DispatcherTaskWrapper schedule(RunnableTask task, BooleanValue flag, EventReceiver listener, BackgroundTaskListener tasklistener) {
			var v = new DispatcherTaskWrapper();
			v.task = task;
			if(v.start_native_task(listener, tasklistener, flag) == false) {
				return(null);
			}
			return(v);
		}

		public bool start_native_task(EventReceiver e, BackgroundTaskListener tasklistener, BooleanValue flag) {
			embed {{{
				var d = Windows.UI.Core.CoreWindow.GetForCurrentThread().Dispatcher;
				cancel_token_src = new System.Threading.CancellationTokenSource();
				var canceltoken = cancel_token_src.Token;
				DispatcherEventReceiver listener = new DispatcherEventReceiver(d, e);
				System.Threading.Tasks.Task.Run(() => {
					if(canceltoken.IsCancellationRequested) {
						canceltoken.ThrowIfCancellationRequested();
					}
					task.run(listener, flag);
					if(tasklistener != null) {
						listener.on_event(new eq.os.task.BackgroundTaskListenerEvent().set_tasklistener(tasklistener));
					}
				});
			}}}
			return(true);
		}

		public bool abort() {
			embed {{{
				if(cancel_token_src != null) {
					cancel_token_src.Cancel();
				}
			}}}
			return(false);
		}
	}

	public BackgroundTask start_timer(int usec, TimerHandler o, Object arg = null) {
		return(DispatcherTimerWrapper.create(usec, o, arg));
	}

	public BackgroundTask start_task(RunnableTask task, EventReceiver listener, BackgroundTaskListener tasklistener) {
		var bt = new BackgroundTaskAdapter().set_task(task as BackgroundTask);
		var taskthread = DispatcherTaskWrapper.schedule(task, bt.get_abortflag(), listener, tasklistener);
		return(bt);
	}
}