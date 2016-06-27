
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

public class Win32MainQueue : EventLoop, BackgroundTaskManager
{
	static Win32MainQueue _instance;

	// FIXME: Should be per-thread?
	public static Win32MainQueue instance() {
		if(_instance == null) {
			_instance = new Win32MainQueue();
		}
		return(_instance);
	}

	Collection timers = null;
	Queue queue = null;
	int thread_id = -1;
	bool exit_flag = false;
	Mutex mut;
	String message_window_class;
	int message_window_handle = -1;

	embed "c" {{{
		#define WM_COMPLETE (WM_APP + 100)
		#define WM_NETWORK (WM_APP + 101)
		#include <windows.h>
		#include <stdio.h>
	}}}

	embed "c" {{{
		LRESULT CALLBACK GetMessageProc(int code, WPARAM wParam, LPARAM lParam) {
			if(code < 0) {
				return(CallNextHookEx(0, code, wParam, lParam));
			}
			if(code == HC_ACTION) {		
				MSG* m = (MSG*)lParam;
				if(m->message == WM_COMPLETE && m->wParam != NULL) {
					eq_os_eventloop_Win32MainQueue_on_queue_event((void*)m->wParam);
				}
			}
			return(CallNextHookEx(0, code, wParam, lParam));
		}
	}}}

	public Win32MainQueue() {
		timers = LinkedList.create();
		queue = Queue.create();
		mut = Mutex.create();
	}

	~Win32MainQueue() {
		delete_message_window();
	}

	embed {{{
		LRESULT CALLBACK myWndProcedure(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam) {
			int v = 0;
			void* queue = (void*)GetProp(hWnd, "__queue");
			switch(Msg) {
				case WM_NETWORK:
					{
						int socket = (int)wParam;
						int event = (int)WSAGETSELECTEVENT(lParam);
						if(event & FD_READ || event & FD_ACCEPT) {
							eq_os_eventloop_Win32MainQueue_on_network_read_traffic(queue, socket);
						}
						else if(event & FD_WRITE) {
							eq_os_eventloop_Win32MainQueue_on_network_write_traffic(queue, socket);
						}
					}
					break;
				default:
					v = DefWindowProc(hWnd, Msg, wParam, lParam);
					break;
			}
			return(v);
		}
	}}}

	public void on_network_read_traffic(int socket) {
		foreach(MyEntry e in entries) {
			if(e.is_socket(socket)) {
				var rrl = e.get_rrl();
				if(rrl != null) {
					rrl.on_read_ready();
				}
			}
		}
	}

	public void on_network_write_traffic(int socket) {
		foreach(MyEntry e in entries) {
			if(e.is_socket(socket)) {
				var wrl = e.get_wrl();
				if(wrl != null) {
					wrl.on_write_ready();
				}
			}
		}
	}

	bool init_message_window() {
		if(message_window_class != null && message_window_handle >= 0) {
			return(true);
		}
		Log.debug("Win32MainQueue: Initializing Win32 invisible message window.");
		var classname = "_Win32MainQueue_class_%x".printf().add((int)this).to_string();
		var clptr = classname.to_strptr();
		int handle = -1;
		embed {{{
			WNDCLASSEX wx;
			ZeroMemory(&wx, sizeof(WNDCLASSEX));
			wx.cbSize = sizeof(WNDCLASSEX);
			wx.lpfnWndProc = myWndProcedure;
			wx.hInstance = GetModuleHandle(NULL);
			wx.lpszClassName = clptr;
			RegisterClassEx(&wx);
			handle = (int)CreateWindowEx(0, clptr, clptr, 0, 0, 0, 0, 0, HWND_MESSAGE, NULL, NULL, NULL);
		}}}
		if(handle < 0) {
			Log.error("Win32MainQueue: Failed to create invisible message window.");
			return(false);
		}
		embed {{{
			SetProp((HWND)handle, "__queue", (HANDLE)self);
		}}}
		message_window_class = classname;
		message_window_handle = handle;
		return(true);
	}

	void delete_message_window() {
		if(message_window_handle >= 0) {
			Log.debug("Win32MainQueue: Destroying invisible message window.");
			var h = message_window_handle;
			embed {{{
				DestroyWindow((HWND)h);
			}}}
			message_window_handle = -1;
		}
		if(message_window_class != null) {
			Log.debug("Win32MainQueue: Unregistering message window class.");
			var clptr = message_window_class.to_strptr();
			embed {{{
				UnregisterClass((LPCTSTR)clptr, GetModuleHandle(NULL));
			}}}
			message_window_class = null;
		}
	}

	Collection entries;

	class MyEntry : EventLoopEntry
	{
		public static MyEntry create(FileDescriptor fd, Win32MainQueue queue) {
			return(new MyEntry().set_fd(fd).set_queue(queue));
		}

		property FileDescriptor fd;
		property Win32MainQueue queue;
		property int message_window;
		property EventLoopReadListener rrl;
		property EventLoopWriteListener wrl;

		public bool is_socket(int socket) {
			if(socket == fd.get_fd()) {
				return(true);
			}
			return(false);
		}

		public void set_listeners(EventLoopReadListener rrl, EventLoopWriteListener wrl) {
			this.rrl = rrl;
			this.wrl = wrl;
			var socket = fd.get_fd();
			var handle = message_window;
			embed {{{
				WSAAsyncSelect((SOCKET)socket, (HWND)handle, WM_NETWORK, FD_READ | FD_ACCEPT | FD_WRITE);
			}}}
		}

		public void set_read_listener(EventLoopReadListener rrl) {
			this.rrl = rrl;
			this.wrl = null;
			var socket = fd.get_fd();
			var handle = message_window;
			embed {{{
				WSAAsyncSelect((SOCKET)socket, (HWND)handle, WM_NETWORK, FD_READ | FD_ACCEPT);
			}}}
		}

		public void set_write_listener(EventLoopWriteListener wrl) {
			this.rrl = null;
			this.wrl = wrl;
			var socket = fd.get_fd();
			var handle = message_window;
			embed {{{
				WSAAsyncSelect((SOCKET)socket, (HWND)handle, WM_NETWORK, FD_WRITE);
			}}}
		}

		public void remove() {
			if(queue == null) {
				return;
			}
			var q = queue;
			queue = null;
			q.remove_entry(this);
		}
	}

	public EventLoopEntry entry_for_object(Object o) {
		var fd = o as FileDescriptor;
		if(fd == null) {
			return(null);
		}
		if(init_message_window() == false) {
			Log.error("Win32MainQueue: Unable to initialize message window. Unable to create entries.");
			return(null);
		}
		var e = MyEntry.create(fd, this);
		e.set_message_window(message_window_handle);
		if(entries == null) {
			entries = LinkedList.create();
		}
		entries.add(e);
		return(e);
	}

	public void remove_entry(EventLoopEntry e) {
		if(entries == null || e == null) {
			return;
		}
		e.set_listeners(null, null);
		entries.remove(e);
	}

	bool _running = false;

	public bool is_running() {
		return(_running);
	}

	public void execute() {
		_running = true;
		int thread_id = -1;
		embed "c" {{{
			thread_id = GetCurrentThreadId();
		}}}
		this.thread_id = thread_id;
		embed "c" {{{
			HHOOK msghook = SetWindowsHookEx(WH_GETMESSAGE, GetMessageProc, 0, thread_id);
			MSG Msg;
			while(1) {
				}}}
				if(exit_flag) {
					break;
				}
				embed {{{
				if(PeekMessage(&Msg, NULL, 0, 0, PM_REMOVE) == 0) {
					WaitMessage();
					continue;
				}
				DispatchMessage(&Msg);
				if(Msg.message == WM_TIMER) {
					eq_os_eventloop_Win32MainQueue_run_timer((void*)self, Msg.wParam);
				}
				else if(Msg.message == WM_QUIT) {
					break;
				}
				}}}
				if(exit_flag) {
					break;
				}
				embed "c" {{{
				while(1) {
					if(PeekMessage(&Msg, NULL, WM_TIMER, WM_TIMER, PM_REMOVE) == 0) {
							break;
					}
					if(Msg.message == WM_QUIT) {
						}}} exit_flag = true; embed "c" {{{
						break;
					}
					eq_os_eventloop_Win32MainQueue_run_timer((void*)self, Msg.wParam);
				}
				}}}
				if(exit_flag) {
					break;
				}
				embed {{{
			}
			if(msghook) {
				UnhookWindowsHookEx(msghook); 
			}
		}}}
		_running = false;
	}

	public void run_timer(int wparam) {
		// FIXME: With a large number of timers, this one becomes unbearable ..
		var timers = this.timers;
		if(timers == null) {
			return;
		}
		foreach(Win32Timer tw in timers) {
			if(tw.get_handle() == wparam) {
				tw.run_timer();
			}
		}
	}

	public void on_queue_event() {
		mut.lock(); {
			var queue = this.queue;
			if(queue == null) {
				return;
			}
			var handler = queue.pop() as Win32MainQueueHandler;
			if(handler != null) {
				handler.on_main_queue_event();
			}
		}
		mut.unlock();
	}

	public void add_to_queue(Win32MainQueueHandler o) {
		if(o == null) {
			return;
		}
		var queue = this.queue;
		if(queue == null) {
			return;
		}
		int thread_id = this.thread_id;
		mut.lock(); {
			bool posted;
			embed "c" {{{
				posted = PostThreadMessage(thread_id, WM_COMPLETE, (WPARAM)self, 0);
			}}}
			if(posted) {
				queue.push(o);
			}
		}
		mut.unlock();
	}

	public void stop() {
		exit_flag = true;
	}

	public BackgroundTask start_task(RunnableTask task, EventReceiver listener, BackgroundTaskListener tasklistener) {
		if(task == null) {
			return(null);
		}
		var tt = new Win32TaskThread();
		var v = new BackgroundTaskAdapter().set_task(task as BackgroundTask);
		tt.set_mainqueue(this);
		tt.schedule(task, v.get_abortflag(), listener, tasklistener);
		return(v);
	}

	public BackgroundTask start_timer(int usec, TimerHandler o, Object arg = null) {
		var v = Win32Timer.create(o, arg);
		v.set_mainqueue(this);
		v.start(usec);
		timers.add(v);
		return(v);
	}

	public void remove_timer(Object o) {
		timers.remove(o);
	}
}
