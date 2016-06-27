
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

public class BrowserProgressTimer : BrowserTimer
{
	int starttime;
	property int duration;

	public BrowserProgressTimer() {
		starttime = timenow();
	}

	public BrowserProgressTimer execute() {
		start(1000000 / 60);
		return(this);
	}

	int timenow() {
		int v;
		embed {{{
			v = new Date().getTime();
		}}}
		return(v);
	}

	public virtual void on_progress(double f) {
	}

	public bool on_timer() {
		int dt = timenow() - starttime;
		double f = (double)dt / (double)(duration / 1000);
		if(f >= 1.0) {
			f = 1.0;
		}
		on_progress(f);
		if(f >= 1.0) {
			return(false);
		}
		return(true);
	}
}
