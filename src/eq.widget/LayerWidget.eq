
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

public class LayerWidget : ContainerWidget
{
	public static LayerWidget instance() {
		return(new LayerWidget());
	}

	public static LayerWidget for_widget(Widget widget, int margin = 0) {
		var v = new LayerWidget();
		v.add(widget);
		v.set_margin(margin);
		return(v);
	}

	int margin_left = 0;
	int margin_right = 0;
	int margin_top = 0;
	int margin_bottom = 0;
	bool margin_set = false;
	int width_request_padding = 0;
	int height_request_padding = 0;
	int _available_size_flag = 0;

	public LayerWidget set_size_request_padding(int wp, int hp) {
		width_request_padding = wp;
		height_request_padding = hp;
		update_size_request();
		return(this);
	}

	public bool is_margin_set() {
		return(margin_set);
	}

	public LayerWidget set_margin(int n) {
		margin_left = n;
		margin_right = n;
		margin_top = n;
		margin_bottom = n;
		margin_set = true;
		if(is_initialized()) {
			update_size_request();
			layout();
		}
		return(this);
	}

	public LayerWidget set_margins(int left, int right, int top, int bottom) {
		margin_left = left;
		margin_right = right;
		margin_top = top;
		margin_bottom = bottom;
		margin_set = true;
		if(is_initialized()) {
			update_size_request();
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

	public LayerWidget set_margin_left(int n) {
		margin_left = n;
		if(is_initialized()) {
			update_size_request();
			layout();
		}
		return(this);
	}

	public LayerWidget set_margin_right(int n) {
		margin_right = n;
		if(is_initialized()) {
			update_size_request();
			layout();
		}
		return(this);
	}

	public LayerWidget set_margin_top(int n) {
		margin_top = n;
		if(is_initialized()) {
			update_size_request();
			layout();
		}
		return(this);
	}

	public LayerWidget set_margin_bottom(int n) {
		margin_bottom = n;
		if(is_initialized()) {
			update_size_request();
			layout();
		}
		return(this);
	}

	public override void on_child_added(Widget child) {
		if(is_initialized() && child != null) {
			child.resize(get_width()-margin_left-margin_right, get_height()-margin_top-margin_bottom);
			child.move(get_child_relative_x(margin_left), get_child_relative_y(margin_top));
		}
		update_size_request();
	}

	public override void on_child_removed(Widget child) {
		update_size_request();
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

	public override void on_new_child_size_params(Widget w) {
		if(_available_size_flag > 0) {
			_available_size_flag ++;
			return;
		}
		arrange_child(w);
		update_size_request();
	}

	public virtual void arrange_child(Widget c) {
		if(c == null) {
			return;
		}
		c.resize(get_width()-margin_left-margin_right, get_height()-margin_top-margin_bottom);
		c.move(get_child_relative_x(margin_left), get_child_relative_y(margin_top));
	}

	public override void arrange_children() {
		foreach(Widget c in iterate_children()) {
			arrange_child(c);
		}
	}

	public void update_size_request() {
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
		if(rw > 0) {
			rw += margin_left;
			rw += margin_right;
		}
		if(rh > 0) {
			rh += margin_top;
			rh += margin_bottom;
		}
		rw += width_request_padding;
		rh += height_request_padding;
		set_size_request(rw, rh);
	}
}

