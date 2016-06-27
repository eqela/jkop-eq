
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

public class FixedGridWidget : ContainerWidget
{
	public static FixedGridWidget instance(int cw, int rh = -1) {
		var v = new FixedGridWidget();
		v.col_width = cw;
		v.row_height = rh;
		return(v);
	}

	int margin_left = 0;
	int margin_right = 0;
	int margin_top = 0;
	int margin_bottom = 0;
	double spacing = 0;
	int col_width = 0;
	int row_height = 0;

	public FixedGridWidget set_col_width(int n) {
		if(col_width < 1) {
			col_width = n;
		}
		return(this);
	}

	public FixedGridWidget set_row_height(int n) {
		if(row_height < 1) {
			row_height = n;
		}
		return(this);
	}

	public FixedGridWidget set_spacing(double n) {
		spacing = n;
		if(is_initialized()) {
			update_size_request();
		}
		return(this);
	}

	public FixedGridWidget set_margin(int n) {
		margin_left = n;
		margin_right = n;
		margin_top = n;
		margin_bottom = n;
		if(is_initialized()) {
			update_size_request();
		}
		return(this);
	}

	public FixedGridWidget set_margins(int left, int right, int top, int bottom) {
		margin_left = left;
		margin_right = right;
		margin_top = top;
		margin_bottom = bottom;
		if(is_initialized()) {
			update_size_request();
		}
		return(this);
	}

	public override void initialize() {
		base.initialize();
		update_size_request();
	}

	public override void arrange_children() {
		double cw = (get_width() - margin_left - margin_right - (col_width-1)*spacing) / col_width;
		double rh = cw;
		if(row_height > 0) {
			rh = (get_height() - margin_top - margin_bottom - (row_height-1)*spacing) / row_height;
		}
		double x = margin_left;
		double y = margin_top;
		int n = 0;
		var it = iterate_children();
		while(it != null) {
			var c = it.next() as Widget;
			if(c == null) {
				break;
			}
			c.resize(cw, rh);
			c.move(get_x() + x, get_y() + y);
			n ++;
			if(n % col_width == 0) {
				x = margin_left;
				y += rh + spacing;
			}
			else {
				x += cw + spacing;
			}
		}
	}

	private void update_size_request() {
		int rw = 0, rh = 0;
		var it = iterate_children();
		while(it != null) {
			var c = it.next() as Widget;
			if(c == null) {
				break;
			}
			var cwr = c.get_width_request();
			var chr = c.get_height_request();
			if(cwr > rw) {
				rw = cwr;
			}
			if(chr > rh) {
				rh = chr;
			}
		}
		set_size_request(
			(int)(rw*col_width + (col_width-1)*spacing + margin_left + margin_right),
			(int)(rh*row_height + (row_height-1)*spacing + margin_top + margin_bottom));
	}

	public override void on_child_added(Widget child) {
		if(is_initialized()) {
			update_size_request();
		}
	}

	public override void on_child_removed(Widget child) {
		if(is_initialized()) {
			update_size_request();
		}
	}

	public override void on_new_child_size_params(Widget w) {
		if(is_initialized()) {
			update_size_request();
		}
	}
}
