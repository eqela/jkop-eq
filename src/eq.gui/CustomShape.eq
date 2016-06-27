
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

public class CustomShape : Shape, Iterateable
{
	public static CustomShape create(double x = 0.0, double y = 0.0) {
		var v = new CustomShape();
		v.start_x = x;
		v.start_y = y;
		return(v);
	}

	double x;
	double y;
	double w;
	double h;
	double start_x;
	double start_y;
	Collection elements;

	public CustomShape() {
		elements = LinkedList.create();
	}

	public Iterator iterate() {
		return(elements.iterate());
	}

	public double get_start_x() {
		return(start_x);
	}

	public double get_start_y() {
		return(start_y);
	}

	public double get_x() {
		compute_height_width();
		return(x);
	}

	public double get_y() {
		compute_height_width();
		return(y);
	}

	public double get_width() {
		compute_height_width();
		return(w);
	}

	public double get_height() {
		compute_height_width();
		return(h);
	}

	void compute_height_width() {
		if(x > 0 && y > 0 && w > 0 && h > 0) {
			return;
		}
		int wh = start_x, wl = start_x, hh = start_y, hl = start_y;
		foreach(CustomShapeElement e in iterate()) {
			int wc = 0, hc = 0;
			var op = e.get_operation();
			if(op == CustomShapeElement.OP_LINE) {
				wc = e.get_x1();
				hc = e.get_y1();
			}
			else if(op == CustomShapeElement.OP_CURVE) {
				wc = e.get_x1();
				hc = e.get_y1();
				if(wc <= e.get_x2()) {
					wc = e.get_x2();
				}
				if(wc <= e.get_x3()) {
					wc = e.get_x3();
				}
				if(hc <= e.get_y2()) {
					hc = e.get_y2();
				}
				if(hc <= e.get_y3()) {
					hc = e.get_y3();
				}
			}
			else if(op == CustomShapeElement.OP_ARC) {
				wc = e.get_x1()+e.get_radius();
				hc = e.get_y1()+e.get_radius();
			}
			if(wh <= wc) {
				wh = wc;
			}
			if(wl >= wc) {
				wl = wc;
			}
			if(hh <= hc) {
				hh = hc;
			}
			if(hl >= hc) {
				hl = hc;
	    	}
		}
		x = wl;
		y = hl;
		w = wh - wl;
		h = hh - hl;
	}

	public CustomShape line(double ax, double ay) {
		var x = ax;
		var y = ay;
		elements.add(CustomShapeElement.create(CustomShapeElement.OP_LINE).set_x1(x).set_y1(y));
		x = -1;
		y = -1;
		w = -1;
		h = -1;
		return(this);
	}

	public CustomShape curve(double x1, double y1, double x2, double y2, double x3, double y3) {
		elements.add(CustomShapeElement.create(CustomShapeElement.OP_CURVE)
			.set_x1(x1).set_y1(y1)
			.set_x2(x2).set_y2(y2)
			.set_x3(x3).set_y3(y3));
		x = -1;
		y = -1;
		w = -1;
		h = -1;
		return(this);
	}

	public CustomShape arc(double ax, double ay, double radius, double angle1, double angle2) {
		var x = ax;
		var y = ay;
		elements.add(CustomShapeElement.create(CustomShapeElement.OP_ARC)
			.set_x1(x).set_y1(y)
			.set_radius(radius)
			.set_angle1(angle1).set_angle2(angle2));
		x = -1;
		y = -1;
		w = -1;
		h = -1;
		return(this);
	}
}
