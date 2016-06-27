
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

public class BoxWidget : ContainerWidget
{
	public static int VERTICAL = 0;
	public static int HORIZONTAL = 1;

	public static BoxWidget vertical() {
		return(new BoxWidget().set_direction(VERTICAL));
	}

	public static BoxWidget horizontal() {
		return(new BoxWidget().set_direction(HORIZONTAL));
	}

	int margin_left = 0;
	int margin_right = 0;
	int margin_top = 0;
	int margin_bottom = 0;
	int spacing = 0;
	int direction = VERTICAL;
	bool staging_mode = false;
	bool children_arranged = false;
	ScrollableWidget scroller;
	int _available_size_flag = 0;
	bool _initializing = false;
	bool arranging_children = false;
	bool update_size_request_request = false;
	property bool enable_size_request = true;
	property bool lazy_render = false;

	public BoxWidget set_staging_mode(bool v) {
		staging_mode = v;
		if(staging_mode == false) {
			children_arranged = false;
			update_size_request();
			if(children_arranged == false) {
				layout();
			}
		}
		return(this);
	}

	public BoxWidget set_direction(int d) {
		if(direction == d) {
			return(this);
		}
		direction = d;
		if(is_initialized()) {
			update_size_request();
			layout();
		}
		return(this);
	}

	public int get_direction() {
		return(direction);
	}

	public BoxWidget set_spacing(int n) {
		spacing = n;
		if(is_initialized()) {
			update_size_request();
			layout();
		}
		return(this);
	}

	public BoxWidget set_margin(int n) {
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

	public BoxWidget set_margins(int left, int right, int top, int bottom) {
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

	public BoxWidget set_margin_left(int n) {
		margin_left = n;
		if(is_initialized()) {
			update_size_request();
			layout();
		}
		return(this);
	}

	public BoxWidget set_margin_right(int n) {
		margin_right = n;
		if(is_initialized()) {
			update_size_request();
			layout();
		}
		return(this);
	}

	public BoxWidget set_margin_top(int n) {
		margin_top = n;
		if(is_initialized()) {
			update_size_request();
			layout();
		}
		return(this);
	}

	public BoxWidget set_margin_bottom(int n) {
		margin_bottom = n;
		if(is_initialized()) {
			update_size_request();
			layout();
		}
		return(this);
	}

	public BoxWidget add_box(int weight, Widget child) {
		if(child != null) {
			child.set_weight(weight);
			add(child);
		}
		return(this);
	}

	public BoxWidget add_hbox(int weight, Widget child) {
		return(add_box(weight, child));
	}

	public BoxWidget add_vbox(int weight, Widget child) {
		return(add_box(weight, child));
	}

	public void update_child_visibility() {
		if(scroller == null) {
			if(lazy_render) {
				Log.warning("Lazy render enabled but no scroller!");
			}
			return;
		}
		foreach(Widget child in iterate_children()) {
			if(direction == VERTICAL) {
				if(child.get_y() > scroller.get_height() && child.get_widget_shown() == false) {
					break;
				}
				if(child.get_y()+child.get_height() < 0 || child.get_y() > scroller.get_height()) {
					if(child.get_widget_shown()) {
						child.set_widget_shown(false);
					}
				}
				else {
					if(child.get_widget_shown() == false && child.get_width() > 0 && child.get_height() > 0) {
						child.set_widget_shown(true);
					}
				}
			}
		}
	}

	public void on_move() {
		base.on_move();
		update_child_visibility();
	}

	public void on_resize() {
		on_available_size(get_width(), get_height());
		base.on_resize();
		update_child_visibility();
	}

	public void initialize() {
		_initializing = true;
		base.initialize();
		if(lazy_render) {
			scroller = ScrollableWidget.find(this);
		}
		_initializing = false;
		update_size_request();
	}

	/* This arrange_children function here is ugly and long. It used to
	 * be composed of arrange_children() and arrange_children_vertical() 
	 * and arrange_children_horizontal(), but Android 2.3 has only 8kb of
	 * stack, and even with a medium complexity widget set the nested
	 * function calls fill the stack and crash the app. By putting all
	 * these things in one function here we conserve precious stack space
	 * and prevent our apps from crashing.
	 */

	public void arrange_children() {
		arranging_children = true;
		update_size_request_request = false;
		children_arranged = true;
		if(direction == VERTICAL) {
			int totalweight = 0;
			int totalheight = margin_top + margin_bottom;
			int n = 0;
			var count = count_enabled();
			foreach(Widget c in iterate_children()) {
				if(c.is_enabled() == false) {
					continue;
				}
				var w = c.get_weight();
				var hr = c.get_height_request();
				if(w > 0) {
					hr = 0;
				}
				totalweight += w;
				totalheight += hr;
				if((hr > 0 || w > 0) && n+1 < count) {
					totalheight += spacing;
				}
				n++;
			}
			int freespace = get_height() - totalheight;
			if(freespace < 0) {
				freespace = 0;
			}
			int y = margin_top;
			int fw = get_width() - margin_left - margin_right;
			if(fw < 0) {
				fw = 0;
			}
			foreach(Widget c in iterate_children()) {
				if(c.is_enabled() == false) {
					continue;
				}
				var w = c.get_weight();
				var hr = c.get_height_request();
				if(w > 0 && totalweight != 0) {
					hr = (int)(freespace * w / (double)totalweight);
				}
				if(y+hr > get_height()) {
					hr = get_height() - y;
				}
				if(hr < 0) {
					hr = 0;
				}
				c.resize(fw, hr);
				c.move(get_x() + margin_left, get_y() + y);
				y += hr;
				if(hr > 0) {
					y += spacing;
				}
			}
		}
		else if(direction == HORIZONTAL) {
			int totalweight = 0;
			int totalwidth = margin_left + margin_right;
			int n = 0;
			bool f = false;
			foreach(Widget c in iterate_children()) {
				if(c.is_enabled() == false) {
					continue;
				}
				var w = c.get_weight();
				var wr = c.get_width_request();
				if(w > 0) {
					wr = 0;
				}
				totalweight += w;
				totalwidth += wr;
				if(wr > 0 || w > 0) {
					if(f) {
						totalwidth += spacing;
					}
					f = true;
				}
				n++;
			}
			int freespace = get_width() - totalwidth;
			if(freespace < 0) {
				freespace = 0;
			}
			int x = margin_left;
			int fh = get_height() - margin_top - margin_bottom;
			if(fh < 0) {
				fh = 0;
			}
			f = false;
			foreach(Widget c in iterate_children()) {
				if(c.is_enabled() == false) {
					continue;
				}
				var w = c.get_weight();
				var wr = c.get_width_request();
				if(w > 0 && totalweight != 0) {
					wr = (int)(freespace * w / (double)totalweight);
				}
				if(x+wr > get_width()) {
					wr = get_width() - x;
				}
				if(wr < 0) {
					wr = 0;
				}
				if(wr > 0) {
					if(f) {
						x += spacing;
					}
					f = true;
				}
				c.resize(wr, fh);
				c.move(get_x() + x, get_y() + margin_top);
				x += wr;
			}
		}
		arranging_children = false;
		if(update_size_request_request) {
			update_size_request();
		}
	}

	void update_size_request() {
		if(_initializing) {
			return;
		}
		if(arranging_children) {
			update_size_request_request = true;
			return;
		}
		if(staging_mode || enable_size_request == false) {
			return;
		}
		if(direction == VERTICAL) {
			update_size_request_vertical();
		}
		else if(direction == HORIZONTAL) {
			update_size_request_horizontal();
		}
	}

	public void on_available_size(int w, int h) {
		_available_size_flag = 1;
		if(direction == VERTICAL) {
			if(w >= 0) {
				var ww = w - margin_left - margin_right;
				if(ww < 0) {
					ww = 0;
				}
				foreach(Widget c in iterate_children()) {
					c.on_available_size(ww, -1);
				}
			}
		}
		else if(direction == HORIZONTAL) {
			if(h >= 0) {
				var hh = h - margin_top - margin_bottom;
				if(hh < 0) {
					hh = 0;
				}
				foreach(Widget c in iterate_children()) {
					c.on_available_size(-1, hh);
				}
			}
		}
		if(_available_size_flag > 1) {
			update_size_request();
		}
		_available_size_flag = 0;
	}

	void update_size_request_vertical() {
		int rw = 0, rh = 0, n = 0;
		var count = count_enabled();
		foreach(Widget c in iterate_children()) {
			if(c.is_enabled() == false) {
				continue;
			}
			var cwr = c.get_width_request();
			var chr = c.get_height_request();
			if(cwr > rw) {
				rw = cwr;
			}
			if(chr > 0) {
				rh += chr;
			}
			if(chr > 0 && n+1 < count) {
				rh += spacing;
			}
			n++;
		}
		var wr = rw + margin_left + margin_right;
		var hr = rh + margin_top + margin_bottom;
		set_size_request(wr, hr);
	}

	void update_size_request_horizontal() {
		int rw = 0, rh = 0, n = 0;
		bool f = false;
		foreach(Widget c in iterate_children()) {
			if(c.is_enabled() == false) {
				continue;
			}
			var cwr = c.get_width_request();
			var chr = c.get_height_request();
			if(chr > rh) {
				rh = chr;
			}
			if(cwr > 0) {
				rw += cwr;
				if(f) {
					rw += spacing;
				}
				f = true;
			}
			n++;
		}
		set_size_request(rw + margin_left + margin_right, rh + margin_top + margin_bottom);
	}

	public void on_children_removed() {
		if(staging_mode) {
			return;
		}
		update_size_request();
	}

	public void on_child_added(Widget child) {
		if(lazy_render && child != null) {
			child.set_widget_shown(false, true);
		}
		if(staging_mode) {
			return;
		}
		base.on_child_added(child);
		if(is_initialized()) {
			update_size_request();
		}
	}

	public void on_child_removed(Widget child) {
		if(staging_mode) {
			return;
		}
		base.on_child_removed(child);
		if(is_initialized()) {
			update_size_request();
		}
	}

	public void on_new_child_size_params(Widget w) {
		if(staging_mode) {
			return;
		}
		if(_available_size_flag > 0) {
			_available_size_flag ++;
			return;
		}
		base.on_new_child_size_params(w);
		if(is_initialized()) {
			update_size_request();
		}
	}
}
