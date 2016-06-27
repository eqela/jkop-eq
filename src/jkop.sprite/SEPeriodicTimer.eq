
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

public class SEPeriodicTimer : SEEntity
{
	public static SEPeriodicTimer for_handler(SEPeriodicTimerHandler handler, int delay) {
		return(new SEPeriodicTimer().set_handler(handler).set_delay(delay));
	}

	property int delay;
	property SEPeriodicTimerHandler handler;
	TimeVal starttime;
	property bool remove_when_timer_expired = true;

	public virtual bool on_timer(TimeVal now) {
		if(handler != null) {
			return(handler.on_timer(now));
		}
		return(false);
	}

	public void tick(TimeVal now, double delta) {
		if(starttime == null) {
			starttime = now;
		}
		bool v = true;
		if(TimeVal.diff(now, starttime) >= delay) {
			starttime = now;
			v = on_timer(now);
		}
		if(v == false) {
			if(remove_when_timer_expired) {
				remove_entity();
			}
		}
	}
}
