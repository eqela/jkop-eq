
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

public class VgPathCustom : VgPath, Iterateable
{
	public static VgPathCustom create(int x, int y) {
		var v = new VgPathCustom();
		v.start_x = x;
		v.start_y = y;
		return(v);
	}

	int x;
	int y;
	int w;
	int h;
	int start_x;
	int start_y;
	Collection elements;

	public VgPathCustom() {
		elements = LinkedList.create();
	}

	public Iterator iterate() {
		return(elements.iterate());
	}

	public int get_start_x() {
		return(start_x);
	}

	public int get_start_y() {
		return(start_y);
	}

	public int get_x() {
		compute_height_width();
		return(x);
	}

	public int get_y() {
		compute_height_width();
		return(y);
	}

	public int get_w() {
		compute_height_width();
		return(w);
	}

	public int get_h() {
		compute_height_width();
		return(h);
	}

	private void compute_height_width() {
		if(x > 0 && y > 0 && w > 0 && h > 0) {
			return;
		}
		int wh = start_x, wl = start_x, hh = start_y, hl = start_y;
		var it = iterate();
		while(it != null) {
			var e = it.next() as VgPathElement;
			if(e == null) {
				break;
			}
			int wc = 0, hc = 0;
			var op = e.get_operation();
			if(op == VgPathElement.OP_LINE) {
				wc = e.get_x1();
				hc = e.get_y1();
			}
			else if(op == VgPathElement.OP_CURVE) {
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
			else if(op == VgPathElement.OP_ARC) {
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

	public VgPathCustom line(int ax, int ay) {
		var x = ax;
		var y = ay;
		elements.add(VgPathElement.create(VgPathElement.OP_LINE).set_x1(x).set_y1(y));
		x = -1;
		y = -1;
		w = -1;
		h = -1;
		return(this);
	}

	public VgPathCustom curve(int x1, int y1, int x2, int y2, int x3, int y3) {
		elements.add(VgPathElement.create(VgPathElement.OP_CURVE)
			.set_x1(x1).set_y1(y1)
			.set_x2(x2).set_y2(y2)
			.set_x3(x3).set_y3(y3));
		x = -1;
		y = -1;
		w = -1;
		h = -1;
		return(this);
	}

	public VgPathCustom arc(int ax, int ay, int radius, double angle1, double angle2) {
		var x = ax;
		var y = ay;
		elements.add(VgPathElement.create(VgPathElement.OP_ARC)
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

