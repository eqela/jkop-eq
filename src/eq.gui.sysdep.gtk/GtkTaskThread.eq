
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

public class GtkTaskThread : FileDescriptor, EventLoopReader, EventReceiver, Runnable
{
	property GtkEventLoop eventloop = null;
	Mutex mutex;
	int fd1 = -1;
	int fd2 = -1;
	Collection schedulequeue = null;
	Collection messagequeue = null;
	bool running = false;
	bool inited = false;
	EventReceiver true_listener = null;

	public GtkTaskThread() {
		mutex = Mutex.create();
		messagequeue = LinkedList.create();
	}

	embed "c" {{{
		#include <sys/types.h>
		#include <sys/socket.h>
		#include <unistd.h>
		#include <fcntl.h>
	}}}

	private bool init() {
		if(inited == false) {
			int fd1 = -1;
			int fd2 = -1;
			embed "c" {{{
				int fds[2];
				if(socketpair(AF_UNIX, SOCK_STREAM, 0, fds) == 0) {
					int f;
					fd1 = fds[0];
					fd2 = fds[1];
					f = fcntl(fd1, F_GETFL, 0);
					fcntl(fd1, F_SETFL, f | O_NONBLOCK);
					f = fcntl(fd2, F_GETFL, 0);
					fcntl(fd2, F_SETFL, f | O_NONBLOCK);
				}
			}}}
			this.fd1 = fd1;
			this.fd2 = fd2;
			if(fd1 < 1 || fd2 < 1) {
				return(false);
			}
			if(eventloop != null) {
				eventloop.add_reader(this, this);
			}
			inited = true;
		}
		if(running == false) {
			running = Thread.start(this);
		}
		return(true);
	}

	private void shutdown() {
		if(eventloop != null) {
			eventloop.remove_reader(this);
		}
		if(fd1 >= 0) {
			var fd1 = this.fd1;
			embed "c" {{{
				close(fd1);
			}}}
			this.fd1 = -1;
		}
		if(fd2 >= 0) {
			var fd2 = this.fd2;
			embed "c" {{{
				close(fd2);
			}}}
			this.fd2 = -1;
		}
		inited = false;
	}

	public void on_event_loop_reader_event() {
		bool v = false;
		var fd1 = this.fd1;
		int n = 0;
		embed "c" {{{
			unsigned char buf[8];
			int r = 0;
			while((r = read(fd1, buf, 8)) > 0) {
				v = 1;
				n ++;
			}
		}}}
		if(v == false) {
			return;
		}
		Collection mq = null;
		bool rst = false;
		mutex.lock();
		{
			mq = messagequeue;
			rst = running;
			messagequeue = LinkedList.create();
		}
		mutex.unlock();
		if(rst == false) {
			shutdown();
		}
		if(mq != null) {
			foreach(TaskThreadMessage o in mq) {
				o.trigger();
			}
		}
	}

	public int get_fd() {
		return(fd1);
	}

	public void send_thread_signal() {
		if(fd2 < 0) {
			return;
		}
		var fd2 = this.fd2;
		int r;
		embed "c" {{{
			unsigned char buf[8];
			buf[0] = 1;
			buf[1] = 1;
			buf[2] = 1;
			buf[3] = 1;
			buf[4] = 1;
			buf[5] = 1;
			buf[6] = 1;
			buf[7] = 1;
			r = write(fd2, buf, 8);
		}}}
		if(r < 0) {
			Log.error("GtkTaskThread failed to write to the signal pipe!");
			embed "c" {{{
				perror("write");
			}}}
		}
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
				Log.error("GtkTaskThread failed to initialize!");
			}
		}
		mutex.unlock();
	}

	public void on_event(Object o) {
		mutex.lock();
		{
			messagequeue.add(TaskThreadMessage.create(o, true_listener));
		}
		mutex.unlock();
		send_thread_signal();
	}

	public void run() {
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
			foreach(TaskThreadInfo o in q) {
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
		send_thread_signal();
	}
}
