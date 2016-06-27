
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

class WPCSTaskThread : EventReceiver, Runnable
{
	Mutex mutex;
	Collection messagequeue;
	Collection schedulequeue;
	bool inited = false;
	bool running = false;
	EventReceiver true_listener = null;
	embed "cs" {{{
		public delegate void DispatcherDelegate();
		System.Windows.Threading.Dispatcher dispatcher;
		DispatcherDelegate dd;
	}}}

	public WPCSTaskThread() {
		mutex = Mutex.create();
		messagequeue = LinkedList.create();
	}

	private bool init() {
		if(inited == false) {
			embed "cs" {{{
				dispatcher = System.Windows.Deployment.Current.Dispatcher;
				dd = new DispatcherDelegate(on_proxy_event_loop_reader_event);
				if(dispatcher == null) {
					return(false);
				}
				inited = true;
			}}}
		}
		if(running == false) {
			running = Thread.start(this);
		}
		return(running);
	}

	public void schedule(RunnableTask task, BooleanValue flag, EventReceiver listener, BackgroundTaskListener tasklistener) {
		if(task == null) {
			return;
		}
		int max = 100 * 1000000;
		if(mutex != null) {
			mutex.lock();
		}
		else {
		}
		{
			if(schedulequeue == null) {
				schedulequeue = LinkedList.create();
			}
			if(max < 0 || schedulequeue.count() < max+1) {
				schedulequeue.add(TaskThreadInfo.create(task, flag, listener, tasklistener));
			}
			else {
				Log.warning("Maximum task queue size %d reached. Discarding task.".printf().add(Primitive.for_integer(max)));
			}
			if(init() == false) {
				Log.error("TaskThread failed to initialize!");
			}
		}
		mutex.unlock();
	}

	public void run() {
		Log.debug("TaskThread started");
		while(true) {
			Collection q = null;
			mutex.lock();
			{
				q = schedulequeue;
				schedulequeue = null;
				if(q == null) {
					running = false;
				}
			}
			mutex.unlock();
			if(q == null) {
				break;
			}
			foreach(TaskThreadInfo o in q.iterate()) {
				if(o.task != null) {
					true_listener = o.listener;
					o.task.run(this, o.flag);
					true_listener = null;
					if(o.tasklistener != null) {
						on_event(new BackgroundTaskListenerEvent().set_tasklistener(o.tasklistener));
					}
				}
			}
		}
		Log.debug("TaskThread ended");
		trigger_dispatcher();
	}

	public void on_event(Object o) {
		add_to_messagequeue(TaskThreadMessage.create(o, true_listener));
	}

	private void add_to_messagequeue(Object o) {
		mutex.lock();
		{
			messagequeue.add(o);
		}
		mutex.unlock();
		trigger_dispatcher();
	}

	private void on_proxy_event_loop_reader_event() {
		Collection mq = null;
		bool rst = false;
		mq = messagequeue;
		rst = running;
		messagequeue = LinkedList.create();
		if(mq != null) {
			foreach(TaskThreadMessage o in mq) {
				o.trigger();
			}
		}
		if(rst == false) {
			shutdown();
		}
	}

	private void trigger_dispatcher() {
		embed "cs" {{{
			if(dispatcher != null) {
				dispatcher.BeginInvoke(dd, null);
			}
		}}}
	}

	private void shutdown() {
		embed "cs" {{{
			dd = null;
			dispatcher = null;			
		}}}
		inited = false;
	}
}

