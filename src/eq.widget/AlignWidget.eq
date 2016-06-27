
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

public class AlignWidget : ContainerWidget
{
	public static AlignWidget for_widget(Widget widget, double ax = 0.0, double ay = 0.0) {
		return(AlignWidget.instance().add_align(ax, ay, widget));
	}

	public static AlignWidget instance() {
		return(new AlignWidget());
	}

	int margin_left = 0;
	int margin_right = 0;
	int margin_top = 0;
	int margin_bottom = 0;
	bool maximize_width = false;
	bool maximize_height = false;
	int _available_size_flag = 0;
	property bool maximize_empty = true;

	public AlignWidget set_maximize_width(bool v) {
		maximize_width = v;
		layout();
		return(this);
	}

	public AlignWidget set_maximize_height(bool v) {
		maximize_height = v;
		layout();
		return(this);
	}

	public AlignWidget set_margin(int n) {
		margin_left = n;
		margin_right = n;
		margin_top = n;
		margin_bottom = n;
		update_size_request();
		layout();
		return(this);
	}

	public AlignWidget set_margins(int left, int right, int top, int bottom) {
		margin_left = left;
		margin_right = right;
		margin_top = top;
		margin_bottom = bottom;
		update_size_request();
		layout();
		return(this);
	}

	public AlignWidget set_margin_left(int n) {
		margin_left = n;
		update_size_request();
		layout();
		return(this);
	}

	public AlignWidget set_margin_right(int n) {
		margin_right = n;
		update_size_request();
		layout();
		return(this);
	}

	public AlignWidget set_margin_top(int n) {
		margin_top = n;
		update_size_request();
		layout();
		return(this);
	}

	public AlignWidget set_margin_bottom(int n) {
		margin_bottom = n;
		update_size_request();
		layout();
		return(this);
	}

	public AlignWidget add_align(double x, double y, Widget child) {
		if(child != null) {
			child.set_align(x, y);
			add(child);
		}
		return(this);
	}

	public override void arrange_children() {
		foreach(Widget c in iterate_children()) {
			if(c.is_enabled() == false) {
				continue;
			}
			arrange_child(c);
		}
	}

	public void on_available_size(int w, int h) {
		int ww = w, hh = h;
		if(ww >= 0) {
			ww = ww - margin_left - margin_right;
			if(ww < 0) {
				ww = 0;
			}
		}
		if(hh >= 0) {
			hh = hh - margin_top - margin_bottom;
			if(hh < 0) {
				hh = 0;
			}
		}
		_available_size_flag = 1;
		foreach(Widget c in iterate_children()) {
			c.on_available_size(ww, hh);
		}
		if(_available_size_flag > 1) {
			update_size_request();
		}
		_available_size_flag = 0;
	}

	public void on_resize() {
		on_available_size(get_width(), get_height());
		base.on_resize();
	}

	public void arrange_child(Widget child) {
		if(child == null) {
			return;
		}
		var xf = child.get_align_x();
		var yf = child.get_align_y();
		int mw = get_width() - margin_left - margin_right;
		int mh = get_height() - margin_top - margin_bottom;
		int wr = child.get_width_request();
		int hr = child.get_height_request();
		if(maximize_empty) {
			if(wr < 1) {
				wr = mw;
			}
		}
		else {
			if(wr < 0) {
				wr = mw;
			}
		}
		if(maximize_empty) {
			if(hr < 1) {
				hr = mh;
			}
		}
		else {
			if(hr < 0) {
				hr = mh;
			}
		}
		if(wr > mw) {
			wr = mw;
		}
		if(hr > mh) {
			hr = mh;
		}
		if(maximize_width) {
			wr = mw;
		}
		if(maximize_height) {
			hr = mh;
		}
		int x, y;
		if(xf < -1.0) {
			x = (2.0 + xf) * margin_left + (xf + 1.0) * wr;
		}
		else if(xf > 1.0) {
			x = get_width() + (xf - 2.0) * (margin_right + wr);
		}
		else {
			x = margin_left + (int)((1.0 + xf) * (mw - wr) / 2.0);
		}
		if(yf < -1.0) {
			y = (2.0 + yf) * margin_top + (yf + 1.0) * hr;
		}
		else if(yf > 1.0) {
			y = get_height() + (yf - 2.0) * (margin_bottom + hr);
		}
		else {
			y = margin_top + (int)((1.0 + yf) * ((mh - hr) / 2.0));
		}
		child.resize(wr, hr);
		child.move(get_x() + x, get_y() + y);
	}

	public override void on_child_added(Widget child) {
		update_size_request();
		base.on_child_added(child);
	}

	public override void on_child_removed(Widget child) {
		update_size_request();
		base.on_child_removed(child);
	}

	public override void on_new_child_size_params(Widget w) {
		if(_available_size_flag > 0) {
			_available_size_flag ++;
			return;
		}
		update_size_request();
		base.on_new_child_size_params(w);
	}

	private void update_size_request() {
		int rw = 0, rh = 0;
		foreach(Widget c in iterate_children()) {
			var cwr = c.get_width_request();
			var chr = c.get_height_request();
			if(cwr > rw) {
				rw = cwr;
			}
			if(chr > rh) {
				rh = chr;
			}
		}
		set_size_request(rw + margin_left + margin_right, rh + margin_top + margin_bottom);
	}
}

