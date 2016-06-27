
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

class SystemClockImpl
{
	embed "c" {{{
		#include <windows.h>
	}}}

	public static long seconds() {
		long v = 0;
		int a = 0, b = 0, c = 0, d = 0;
		embed "c" {{{
			FILETIME ft;
			unsigned __int64 tm = 0;
			GetSystemTimeAsFileTime(&ft);
			tm |= ft.dwHighDateTime;
			tm <<= 32;
			tm |= ft.dwLowDateTime;
			tm /= 10;
			tm-=11644473600000000ULL;
			v = (long)(tm / 1000000UL);
		}}}
		return(v);
	}

	public static TimeVal timeval() {
		var v = TimeVal.create();
		update(v);
		return(v);
	}

	public static void update(TimeVal v) {
		if(v != null) {
			int sec;
			int usec;
			embed "c" {{{
				FILETIME ft;
				unsigned __int64 tm = 0;
				GetSystemTimeAsFileTime(&ft);
				tm |= ft.dwHighDateTime;
				tm <<= 32;
				tm |= ft.dwLowDateTime;
				tm /= 10;
				tm-=11644473600000000ULL;
				sec = (int)(tm / 1000000UL);;
				usec = (int)(tm % 1000000UL);
			}}}
			v.set_seconds(sec);
			v.set_useconds(usec);
		}
	}
}
