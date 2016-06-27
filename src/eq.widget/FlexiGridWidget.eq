
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

public class FlexiGridWidget : ContainerWidget
{
	public static FlexiGridWidget instance() {
		return(new FlexiGridWidget());
	}

	int margin_left = 0;
	int margin_right = 0;
	int margin_top = 0;
	int margin_bottom = 0;
	int spacing = 0;
	int col_request = 3;
	int cw = 0;
	int rh = 0;

	public FlexiGridWidget set_column_request(int n) {
		col_request = n;
		if(is_initialized()) {
			update_size_request();
			layout();
		}
		return(this);
	}

	public FlexiGridWidget set_spacing(int n) {
		spacing = n;
		if(is_initialized()) {
			update_size_request();
			layout();
		}
		return(this);
	}

	public FlexiGridWidget set_margin(int n) {
		margin_left = n;
		margin_right = n;
		margin_top = n;
		margin_bottom = n;
		if(is_initialized()) {
			update_size_request();
			layout();
		}
		return(this);
	}

	public FlexiGridWidget set_margins(int left, int right, int top, int bottom) {
		margin_left = left;
		margin_right = right;
		margin_top = top;
		margin_bottom = bottom;
		if(is_initialized()) {
			update_size_request();
			layout();
		}
		return(this);
	}

	public override void initialize() {
		base.initialize();
		update_size_request();
	}

	public override void arrange_children() {
		int x = margin_left;
		int y = margin_top;
		int limit = get_width() - margin_right;
		foreach(Widget c in iterate_children()) {
			c.resize(cw, rh);
			c.move(get_x() + x, get_y() + y);
			x += cw + spacing;
			if(x+cw > limit) {
				x = margin_left;
				y += rh + spacing;
			}
		}
	}

	private void update_size_request() {
		cw = 0;
		rh = 0;
		foreach(Widget c in iterate_children()) {
			var cwr = c.get_width_request();
			var chr = c.get_height_request();
			if(cwr > cw) {
				cw = cwr;
			}
			if(chr > rh) {
				rh = chr;
			}
		}
		if(cw < 1) {
			cw = px("10mm");
		}
		if(rh < 1) {
			rh = px("10mm");
		}
		int cr;
		if(get_width() > 0) {
			int limit = get_width() - margin_left - margin_right;
			int x = 0;
			cr = 0;
			while(true) {
				if(x + cw <= limit) {
					x += cw + spacing;
					cr ++;
				}
				else {
					break;
				}
			}
			if(cr < 1) {
				cr = 1;
			}
		}
		else {
			cr = col_request;
		}
		int c = this.count();
		int rows = c / cr;
		if(c % cr != 0) {
			rows ++;
		}
		set_size_request(
			cw*cr + (cr-1)*spacing + margin_left + margin_right,
			rh*rows + (rows-1)*spacing + margin_top + margin_bottom);
	}

	public override void on_resize() {
		update_size_request();
		base.on_resize();
	}

	public override void on_child_added(Widget child) {
		if(is_initialized()) {
			update_size_request();
			layout();
		}
	}

	public override void on_child_removed(Widget child) {
		if(is_initialized()) {
			update_size_request();
			layout();
		}
	}

	public override void on_new_child_size_params(Widget w) {
		if(is_initialized()) {
			update_size_request();
			layout();
		}
	}
}

