
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

public class Win32Timer : BackgroundTask
{
	embed "c" {{{
		#include <windows.h>
	}}}

	TimerHandler timer;
	Object arg;
	int handle = -1;
	property Win32MainQueue mainqueue;

	public static Win32Timer create(TimerHandler timer, Object arg) {
		var v = new Win32Timer();
		v.timer = timer;
		v.arg = arg;
		return(v);
	}

	~Win32Timer() {
		stop();
	}

	public void run_timer() {
		if(handle >= 0) {
			if(timer.on_timer(arg) == false) {
				stop();
			}
		}
	}

	public void start(int usec) {
		int msec = usec / 1000;
		int timer_id = 0;
		if(msec == 0) {
			msec = 1;
		}
		embed "c" {{{
			timer_id = SetTimer(NULL, 0, msec, NULL);
		}}}
		this.handle = timer_id;
	}

	public void stop() {
		if(handle >= 0) {
			int timer_id = this.handle;
			embed "c" {{{
				if(timer_id >= 0) {
					KillTimer(NULL, timer_id);
				}
			}}}
			this.handle = -1;
		}
		if(mainqueue != null) {
			mainqueue.remove_timer(this);
			mainqueue = null;
		}
	}

	public bool abort() {
		stop();
		return(true);
	}

	public int get_handle() {
		return(this.handle);
	}
}
