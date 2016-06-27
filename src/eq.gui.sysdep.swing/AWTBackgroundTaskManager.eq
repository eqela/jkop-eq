
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

public class AWTBackgroundTaskManager : BackgroundTaskManager
{
	class MyBackgroundTask : BackgroundTask
	{
		embed {{{
			public javax.swing.Timer timer;
		}}}

		public bool abort() {
			embed {{{
				if(timer != null) {
					timer.stop();
					return(true);
				}
			}}}
			return(false);
		}
	}

	public BackgroundTask start_timer(int usec, TimerHandler o, Object arg) {
		var v = new MyBackgroundTask();
		embed {{{
			final eq.api.Object farg = arg;
			final eq.os.task.TimerHandler fo = o;
			final javax.swing.Timer timer = new javax.swing.Timer(usec / 1000, null);
			timer.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent evt) {
					if(fo.on_timer(farg) == false) {
						timer.stop();
					}
				}
			});
			timer.start();
			v.timer = timer;
		}}}
		return(v);
	}

	class MyWorkerBackgroundTask : BackgroundTask
	{
		embed {{{
			public javax.swing.SwingWorker worker;
		}}}

		public bool abort() {
			bool v = false;
			embed {{{
				if(worker != null) {
					v = worker.cancel(true);
				}
			}}}
			return(v);
		}
	}

	class DispatcherEventReceiver : EventReceiver
	{
		public EventReceiver origevent;
		public void on_event(Object o) {
			embed {{{
				final eq.api.Object fo = o;
				javax.swing.SwingUtilities.invokeLater(new Runnable() {
					public void run() {
						origevent.on_event(fo);
					}
				});
			}}}
		}
	}

	public BackgroundTask start_task(RunnableTask task, EventReceiver listener, BackgroundTaskListener tasklistener) {
		var v = new MyWorkerBackgroundTask();
		embed {{{
			final eq.os.task.RunnableTask ftask = task;
			final eq.api.EventReceiver flistener = listener;
			final eq.os.task.BackgroundTaskListener ftasklistener = tasklistener;
			javax.swing.SwingWorker worker = new javax.swing.SwingWorker<Object, Void>() {
				public eq.api.Object doInBackground() {
					DispatcherEventReceiver dispatcher = new DispatcherEventReceiver();
					dispatcher.origevent = flistener;
					eq.api.BooleanValue abortion = new eq.api.BooleanValue();
					ftask.run(dispatcher, abortion);
					if(abortion.get_value()) {
						cancel(true);
					}
					return(null);
				}
				public void done() {
					if(ftasklistener != null) {
						ftasklistener.on_background_task_ended();
					}
				}
			};
			v.worker = worker;
			worker.execute();
		}}}
		return(v);
	}
}
