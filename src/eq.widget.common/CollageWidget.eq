
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

public class CollageWidget : ContainerWidget
{
	public static CollageWidget instance() {
		return(new CollageWidget());
	}

	int margin_left = 0;
	int margin_right = 0;
	int margin_top = 0;
	int margin_bottom = 0;
	int spacing = 0;
	property bool align_center = true;

	public CollageWidget set_margin(int n) {
		margin_left = n;
		margin_right = n;
		margin_top = n;
		margin_bottom = n;
		if(is_initialized()) {
			layout();
		}
		return(this);
	}

	public CollageWidget set_margins(int left, int right, int top, int bottom) {
		margin_left = left;
		margin_right = right;
		margin_top = top;
		margin_bottom = bottom;
		if(is_initialized()) {
			layout();
		}
		return(this);
	}

	public int get_margin_left() {
		return(margin_left);
	}

	public int get_margin_right() {
		return(margin_right);
	}

	public int get_margin_top() {
		return(margin_top);
	}

	public int get_margin_bottom() {
		return(margin_bottom);
	}

	public CollageWidget set_margin_left(int n) {
		margin_left = n;
		if(is_initialized()) {
			layout();
		}
		return(this);
	}

	public CollageWidget set_margin_right(int n) {
		margin_right = n;
		if(is_initialized()) {
			layout();
		}
		return(this);
	}

	public CollageWidget set_margin_top(int n) {
		margin_top = n;
		if(is_initialized()) {
			layout();
		}
		return(this);
	}

	public CollageWidget set_margin_bottom(int n) {
		margin_bottom = n;
		if(is_initialized()) {
			layout();
		}
		return(this);
	}

	public CollageWidget set_spacing(int n) {
		spacing = n;
		if(is_initialized()) {
			layout();
		}
		return(this);
	}

	public override void arrange_children() {
		var mywidth = get_width() - margin_left - margin_right;
		var myheight = get_height() - margin_top - margin_bottom;
		if(mywidth < 1 || myheight < 1) {
			return;
		}
		var ratio = ((double)mywidth / (double)myheight);
		var wcols = (int)Math.ceil(Math.sqrt(count() / ratio)) + 1;
		if(wcols > count()) {
			wcols = count();
		}
		if(wcols < 1) {
			return;
		}
		var hrows = count() / wcols;
		if(count() % wcols != 0) {
			hrows ++;
		}
		if(hrows < 1) {
			return;
		}
		if(wcols > 1) {
			mywidth -= (wcols-1) * spacing;
		}
		var cellwidth = (double)mywidth / (double)wcols;
		if(hrows > 1) {
			myheight -= (hrows-1) * spacing;
		}
		var cellheight = (double)myheight / (double)hrows;
		int y, x;
		var it = iterate_children();
		if(it == null) {
			return;
		}
		int sub_first = 0;
		int sub_last = count() - (hrows-1)*wcols;
		if(sub_last > 1 && hrows > 1) {
			sub_first = sub_last / 2;
			sub_last -= sub_first;
		}
		double cy = margin_top;
		for(y=0 ;y<hrows; y++) {
			int wc = wcols;
			if(y == 0) {
				wc = wc - sub_first;
			}
			else if(y == hrows-1) {
				wc = wc - sub_last;
			}
			double cx = margin_left;
			if(align_center && wc < wcols) {
				var needed = (double)wc * cellwidth;
				if(wc > 1) {
					needed += (wc-1) * spacing;
				}
				cx = margin_left + ((get_width() - margin_left - margin_right) - needed) / 2;
			}
			for(x=0; x<wc; x++) {
				var c = it.next() as Widget;
				if(c != null) {
					c.resize(cellwidth, cellheight);
					c.move(get_x() + cx, get_y() + cy);
				}
				cx += cellwidth + spacing;
			}
			cy += cellheight + spacing;
		}
	}
}

