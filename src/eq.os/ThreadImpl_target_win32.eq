
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

class ThreadImpl
{
	embed "c" {{{
		#include <windows.h>
	}}}

	public static ptr thread_function(ptr arg) {
		((Runnable)arg).run();
		embed "c" {{{
			unref_eq_api_Object((void*)arg);
		}}}
		return(null);
	}

	public static bool start(Runnable r) {
		bool v = false;
		if(r == null) {
			return(v);
		}
		int rv = 0;
		embed "c" {{{
			HANDLE hThread;
			DWORD dwThreadId;
			ref_eq_api_Object((void*)r);
        		hThread = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)eq_os_ThreadImpl_thread_function, (void*)r, 0, &dwThreadId);
			if(hThread != NULL) {
				rv = 1;
			}
		}}}
		if(rv == 1) {
			v = true;
		}
		else {
			Log.error("Failed to create a thread!");
		}
		return(v);
	}
}

