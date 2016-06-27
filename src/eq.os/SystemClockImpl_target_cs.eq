
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
	public static long seconds() {
		long v = 0;
		embed "cs" {{{
			v = get_usec_ticks() / 1000000;
		}}}
		return(v);
	}

	public static TimeVal timeval() {
		var v = TimeVal.create();
		update(v);
		return(v);
	}
	embed "cs" {{{
		private static long get_usec_ticks() {
			var epoch = new System.DateTime(1970, 1, 1).Ticks;
			var now = System.DateTime.Now.AddSeconds(-(epoch/10000000));
			var v = (long)(now.Ticks)/10;
			return(v);
		}
	}}}

	public static void update(TimeVal v) {
		if(v != null) {
			embed "cs" {{{
				long ct = get_usec_ticks();
				v.set_seconds((int)(ct / 1000000));
				long us = ct % 1000000;
				v.set_useconds((int)(us));
			}}}
		}
	}
}

