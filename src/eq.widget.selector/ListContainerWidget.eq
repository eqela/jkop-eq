
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

class ListContainerWidget : ContainerWidget
{
	int row_count_request = 0;
	int item_widget_height = 0;
	ListSelectorWidget list;

	public void reset_item_widget_height() {
		item_widget_height = 0;
	}

	public void initialize() {
		base.initialize();
		list = ListSelectorWidget.find_list_widget(this);
		update_size_request();
	}

	public void cleanup() {
		base.cleanup();
		list = null;
	}

	public void set_row_count_request(int n) {
		row_count_request = n;
		update_size_request();
	}

	public void update_size_request() {
		if(list == null) {
			return;
		}
		if(item_widget_height == 0) {
			if(is_initialized()) {
				var li = ActionItem.instance(null, "XghjplK", "XghjplK");
				var ww = list.get_widget_for_item(li);
				if(ww != null) {
					add(ww);
					item_widget_height = ww.get_height_request();
					remove(ww);
				}
			}
		}
		if(item_widget_height > 0) {
			var rrs = row_count_request;
			if(rrs < 1) {
				rrs = list.get_item_count();
			}
			var hr = item_widget_height * rrs;
			set_size_request(px("60mm"), hr);
		}
	}

	public void on_move() {
		base.on_move();
		update_children();
	}

	public void on_resize() {
		base.on_resize();
		update_children();
	}

	ListItemWidget get_widget_for_list_index(int n) {
		if(n < first_shown) {
			return(null);
		}
		return(get_child(n - first_shown) as ListItemWidget);
	}

	public ListItemWidget get_kb_selected_widget() {
		return(get_widget_for_list_index(kb_selected));
	}

	int kb_selected = -1;

	public void set_kb_selected(int n) {
		if(kb_selected >= 0) {
			var cw = get_widget_for_list_index(kb_selected);
			if(cw != null) {
				cw.set_pressed(false);
				cw.set_kb_hover(false);
			}
		}
		kb_selected = n;
		if(n < 0) {
			return;
		}
		if(first_shown < 0 || last_shown < 0) {
			return;
		}
		var ss = ScrollableWidget.find(this);
		if(ss != null) {
			int a = 0;
			var w1 = get_child(0);
			if(w1 != null) {
				a = w1.get_y();
			}
			ss.scroll_to(0, (n - first_shown) * item_widget_height + a, get_width(), item_widget_height);
		}
		var ww = get_widget_for_list_index(kb_selected);
		if(ww != null) {
			ww.set_kb_hover(true);
		}
	}

	int first_shown = -1;
	int last_shown = -1;

	public void reset() {
		remove_children();
		first_shown = -1;
		last_shown = -1;
		var ss = get_parent() as ScrollerContainerWidget;
		if(ss != null) {
			ss.scroll_to_top();
		}
	}

	public void update_children() {
		var ss = get_parent() as ScrollerContainerWidget;
		if(ss == null || list == null) {
			return;
		}
		double sh = ss.get_height();
		if(sh < 1) {
			reset();
			return;
		}
		int y1 = 0 - (int)get_y();
		int y2 = y1 + (int)sh;
		int first_index = y1 / item_widget_height;
		int last_index = (y2+item_widget_height) / item_widget_height;
		if(first_shown < 0 && last_shown < 0) {
			int n;
			for(n=first_index; n<=last_index; n++) {
				var ii = list.get_item(n);
				if(ii == null) {
					break;
				}
				add(list.get_widget_for_item(ii));
			}
			first_shown = first_index;
			last_shown = n-1;
		}
		if(first_index < first_shown) {
			int n;
			for(n=first_shown-1; n>=first_index; n--) {
				var ii = list.get_item(n);
				if(ii == null) {
					break;
				}
				prepend(list.get_widget_for_item(ii));
			}
			first_shown = n+1;
		}
		if(last_index > last_shown) {
			int n;
			for(n=last_shown+1; n<=last_index; n++) {
				var ii = list.get_item(n);
				if(ii == null) {
					break;
				}
				add(list.get_widget_for_item(ii));
			}
			last_shown = n-1;
		}
		while(first_index > first_shown) {
			remove_first_child();
			first_shown ++;
		}
		while(last_index < last_shown) {
			remove_last_child();
			last_shown --;
		}
		int y = get_y() + first_index * item_widget_height;
		foreach(Widget w in iterate_children()) {
			w.move_resize(0, y, get_width(), item_widget_height);
			y += item_widget_height;
		}
		if(kb_selected >= 0) {
			var ww = get_widget_for_list_index(kb_selected);
			if(ww != null) {
				ww.set_kb_hover(true);
			}
		}
	}
}
