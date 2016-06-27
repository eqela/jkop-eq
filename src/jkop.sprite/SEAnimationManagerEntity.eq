
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

public class SEAnimationManagerEntity : SEEntity
{
	property int duration = 750000;
	property SEAnimationListener listener;
	TimeVal start;
	bool endflag;
	Collection elements;

	public SEAnimationManagerEntity add_element(SEAnimationElement ae) {
		if(elements == null) {
			elements = LinkedList.create();
		}
		if(ae != null) {
			elements.add(ae);
		}
		return(this);
	}

	public virtual void on_animation_manager_tick(double f) {
		foreach(SEAnimationElement ae in elements) {
			if(ae.get_done()) {
				continue;
			}
			var ff = f * ae.get_factor();
			ae.on_animation_element_tick(ff);
			if(ff >= 1.0) {
				ae.set_done(true);
			}
		}
	}

	public virtual void on_first_tick() {
		foreach(SEAnimationElement ae in elements) {
			ae.on_first_tick();
		}
	}

	public void tick(TimeVal now, double delta) {
		if(start == null) {
			start = now;
			endflag = false;
			on_first_tick();
		}
		var diff = TimeVal.diff(now, start);
		var f = (double)diff / (double)duration;
		var ef = false;
		if(f > 1) {
			f = 1;
			ef = true;
		}
		on_animation_manager_tick(f);
		if(endflag) {
			remove_entity();
			if(listener != null) {
				listener.on_animation_ended();
			}
		}
		endflag = ef;
	}
}
