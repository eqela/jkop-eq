
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

public class Animation : TickHandler
{
	public static Animation for_duration(int dur) {
		return(new Animation().set_duration(dur));
	}

	property int duration = 1000000;
	property int repeat_count;
	property bool repeat_infinitely;
	TimeVal starttime;
	Collection items;
	Collection targets;
	Collection listeners;
	bool stopflag = false;
	bool active;

	public Animation() {
		items = new LinkedList();
		targets = new LinkedList();
		listeners = new LinkedList();
	}

	public void set_active() {
		active = true;
	}

	public void stop() {
		stopflag = true;
	}

	public bool is_active() {
		return(active);
	}

	public Animation add_item(AnimationItem ii) {
		if(ii != null) {
			items.append(ii);
		}
		return(this);
	}

	public Animation add_target(AnimationTarget target) {
		if(target != null) {
			targets.add(target);
		}
		return(this);
	}

	public Animation add_listener(AnimationListener listener) {
		if(listener != null) {
			listeners.add(listener);
		}
		return(this);
	}

	public void on_ended(bool aborted) {
		if(starttime != null) {
			starttime = null;
			foreach(AnimationTarget at in targets) {
				at.on_animation_end();
			}
			foreach(AnimationListener al in listeners) {
				al.on_animation_listener_end(aborted);
			}
		}
		items.clear();
		targets.clear();
		listeners.clear();
		stopflag = false;
		active = false;
	}

	public bool tick(TimeVal now) {
		if(starttime == null) {
			starttime = now;
			foreach(AnimationTarget at in targets) {
				at.on_animation_start();
			}
		}
		var diff = TimeVal.diff(now, starttime);
		if(diff > duration) {
			diff = duration;
		}
		var f = ((double)diff / (double)duration);
		foreach(AnimationItem ai in items) {
			ai.update(f);
		}
		foreach(AnimationTarget at in targets) {
			at.on_animation_update();
		}
		if(diff >= duration || stopflag) {
			if(stopflag == false) {
				if(repeat_infinitely) {
					starttime = now;
					return(true);
				}
				if(repeat_count > 0) {
					starttime = now;
					repeat_count --;
					return(true);
				}
			}
			on_ended(stopflag);
			return(false);
		}
		return(true);
	}
}
