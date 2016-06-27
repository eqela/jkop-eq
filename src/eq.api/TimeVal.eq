
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

public class TimeVal
{
	public static TimeVal for_seconds(int seconds) {
		var v = new TimeVal();
		v.set_seconds(seconds);
		return(v);
	}

	public static TimeVal create() {
		return(new TimeVal());
	}

	int s = 0;
	int us = 0;

	public TimeVal dup() {
		var v = new TimeVal();
		v.copy_from(this);
		return(v);
	}

	public void reset() {
		s = 0;
		us = 0;
	}

	public void copy_from(TimeVal timeval) {
		s = timeval.s;
		us = timeval.us;
	}

	public int get_seconds() {
		return(s);
	}

	public int get_useconds() {
		return(us);
	}

	public void set_timeval(TimeVal tv) {
		set_seconds(tv.get_seconds());
		set_useconds(tv.get_useconds());
	}

	public void set_seconds(int s) {
		this.s = s;
	}

	public void set_useconds(int us) {
		this.us = us;
	}

	public TimeVal add(int s, int us) {
		int ts = this.get_seconds() + s,
			tus = this.get_useconds() + us;
		if(tus > 1000000) {
			ts += tus / 1000000;
			tus = tus % 1000000;
		}
		while(tus < 0) {
			ts --;
			tus += 1000000;
		}
		var v = new TimeVal();
		v.set_seconds(ts);
		v.set_useconds(tus);
		return(v);
	}

	public TimeVal add_timeval(TimeVal tv) {
		return(add(tv.get_seconds(), tv.get_useconds()));
	}

	public TimeVal sub_timeval(TimeVal tv) {
		return(add(-tv.get_seconds(), -tv.get_useconds()));
	}

	public int usec() {
		return((int)(this.get_seconds() * 1000000 + this.get_useconds()));
	}

	public static int diff(TimeVal a, TimeVal b) {
		if(a == null && b == null) {
			return(0);
		}
		if(a == null) {
			return(b.usec());
		}
		if(b == null) {
			return(a.usec());
		}
		var r = (a.s - b.s) * 1000000 + (a.us - b.us);
		if(r < 0) {
			r = -r;
		}
		return(r);
	}
}
