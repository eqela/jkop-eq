
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

public class SEMoverAnimationElement : SEAnimationElement
{
	public static SEMoverAnimationElement for_element(SEElement element, double sx, double sy, double ex, double ey, double factor = 1.0, bool fadeout = false, bool fadein = false) {
		var v = new SEMoverAnimationElement().set_element(element).set_start(sx, sy).set_end(ex, ey);
		v.set_factor(factor);
		v.set_fadeout(fadeout);
		v.set_fadein(fadein);
		return(v.initialize());
	}

	class MyPoint {
		property double x;
		property double y;
	}

	property SEElement element;
	property bool fadeout = false;
	property bool fadein = false;
	MyPoint start;
	MyPoint end;

	public SEMoverAnimationElement set_start(double x, double y) {
		start = new MyPoint().set_x(x).set_y(y);
		return(this);
	}

	public SEMoverAnimationElement set_end(double x, double y) {
		end = new MyPoint().set_x(x).set_y(y);
		return(this);
	}

	public SEMoverAnimationElement initialize() {
		if(element != null) {
			if(fadeout) {
				element.set_alpha(1.0);
			}
			if(fadein) {
				element.set_alpha(0.0);
			}
			if(start != null) {
				element.move(start.get_x(), start.get_y());
			}
		}
		return(this);
	}

	public void on_first_tick() {
		if(element == null) {
			return;
		}
		if(start == null) {
			start = new MyPoint().set_x(element.get_x()).set_y(element.get_y());
		}
		if(end == null) {
			end = new MyPoint().set_x(element.get_x()).set_y(element.get_y());
		}
	}
	
	public void on_animation_element_tick(double f) {
		var x = start.get_x() + (end.get_x() - start.get_x()) * f;
		var y = start.get_y() + (end.get_y() - start.get_y()) * f;
		if(fadeout) {
			element.set_alpha(1.0 - f);
		}
		if(fadein) {
			element.set_alpha(f);
		}
		element.move(x,y);
	}
}
