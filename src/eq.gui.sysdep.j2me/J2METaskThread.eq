
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

class J2METaskThread : EventReceiver, Runnable
{
	embed "java" {{{
		private static class EventLoopProxy implements java.lang.Runnable{
			J2METaskThread tt = null;
			javax.microedition.lcdui.Display display = null;
			public static EventLoopProxy create(J2METaskThread tt) {
				EventLoopProxy v = new EventLoopProxy();
				v.tt = tt;
				v.display = J2MEDisplay.get_display();
				return(v);
			}
			public void run() {
				if(tt != null) {
					tt.on_proxy_event_loop_reader_event();
				}
			}
			public void send_signal() {
				if(display != null) {
					display.callSerially(this);
				}
			}
		}
	}}}

	Mutex mutex;
	Collection schedulequeue = null;
	Collection messagequeue = null;
	bool running = false;
	bool inited = false;
	EventReceiver true_listener = null;
	embed "java" {{{
		private EventLoopProxy elp = null;
	}}}

	public static J2METaskThread create() {
		return(new J2METaskThread());
	}

	public J2METaskThread() {
		mutex = Mutex.create();
		messagequeue = LinkedList.create();
	}

	private bool init() {
		if(inited == false) {
			embed "java" {{{
				elp = EventLoopProxy.create(this);
				if(elp == null) {
					return(false);
				}
			}}}
			inited = true;
		}
		if(running == false) {
			running = Thread.start(this);
		}
		return(true);
	}

	public void on_proxy_event_loop_reader_event() {
		Collection mq = null;
		bool rst = false;
		mutex.lock();
		{
			mq = messagequeue;
			rst = running;
			messagequeue = LinkedList.create();
		}
		mutex.unlock();
		if(mq != null) {
			foreach(TaskThreadMessage o in mq) {
				o.trigger();
			}
		}
		if(rst == false) {
			shutdown();
		}
	}

	private void shutdown() {
		embed "java" {{{
			elp = null;
		}}}
		inited = false;
	}

	public void send_thread_signal() {
		embed "java" {{{
			if(elp != null) {
				elp.send_signal();
			}
		}}}
	}

	public void schedule(RunnableTask task, BooleanValue flag, EventReceiver listener, BackgroundTaskListener tasklistener) {
		if(task == null) {
			return;
		}
		int max = 100 * 1000000;
		mutex.lock();
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

	public void on_event(Object o) {
		add_to_messagequeue(TaskThreadMessage.create(o, true_listener));
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
		send_thread_signal();
	}

	private void add_to_messagequeue(Object o) {
		mutex.lock();
		{
			messagequeue.add(o);
		}
		mutex.unlock();
		send_thread_signal();
	}
}
