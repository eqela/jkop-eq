
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

class GridSelectorContainerWidget : ContainerWidget
{
	GridSelectorWidget selector;
	int item_widget_width;
	int row_items_height;
	int items_per_row;
	int nr;
	int first_row_shown = -1;
	int last_row_shown = -1;
	int last_row_count = -1;

	public void initialize() {
		base.initialize();
		selector = GridSelectorWidget.find_grid_widget(this);
		update_size_request();
	}

	public void update_size_request() {
		if(selector == null) {
			return;
		}
		if(item_widget_width == 0 || row_items_height == 0) {
			var ee = ActionItem.instance(null, "XghjplK", "XghjplK");;
			if(ee == null) {
				return;
			}
			items_per_row = 0;
			var gi = selector.get_widget_for_item(ee);
			add(gi);
			var cw = gi.get_width_request();
			var ch = gi.get_height_request();
			remove(gi);
			if(cw > 0) {
				int riw = 0;
				while(riw < get_width()) {
					riw += cw;
					items_per_row ++;
				}
				items_per_row--;
				int rem = get_width() - cw*items_per_row;
				if(rem > 0) {
					cw += rem/items_per_row;
				}
			}
			else {
				cw = px("10mm");
			}
			if(items_per_row < 1) {
				items_per_row = 1;
			}
			item_widget_width = cw;
			row_items_height = ch;
		}
		if(row_items_height > 0) {
			nr = Math.ceil(selector.get_item_count() / (double)items_per_row);
			var hr = row_items_height * nr;
			set_size_request(item_widget_width*items_per_row, hr);
		}
	}

	void initialize_values() {
		item_widget_width = 0;
		row_items_height = 0;
		last_row_count = -1;
		last_row_shown = -1;
		first_row_shown = -1;
	}

	public void reset() {
		remove_children();
		initialize_values();
		var ss = get_parent() as ScrollerContainerWidget;
		if(ss != null) {
			ss.scroll_to_top();
		}
	}

	public void update_children() {
		var ss = get_parent() as ScrollerContainerWidget;
		if(ss == null || selector == null) {
			return;
		}
		var sh = ss.get_height();
		if(sh < 1) {
			reset();
			return;
		}
		int y1 = 0 - (int)get_y();
		int y2 = y1 + (int)sh;
		int first_row_index = y1 / row_items_height;
		int last_row_index = (y2 + row_items_height) / row_items_height;
		if(last_row_index > nr-1) {
			last_row_index = nr-1;
		}
		if(first_row_shown < 0 && last_row_shown < 0) {
			int n;
			for(n=first_row_index;n<=last_row_index;n++) {
				int r;
				for(r=0;r<items_per_row;r++) {
					var ii = selector.get_selector_item((n*items_per_row)+r);
					if(ii == null) {
						break;
					}
					add(selector.get_item_widget(ii));
				}
			}
			first_row_shown = first_row_index;
			last_row_shown = n-1;
		}
		if(first_row_index < first_row_shown) {
			int n;
			for(n=first_row_shown-1;n>=first_row_index;n--) {
				int r;
				for(r=items_per_row-1;r>=0;r--) {
					var ii = selector.get_selector_item((n*items_per_row)+r);
					if(ii == null) {
						break;
					}
					prepend(selector.get_item_widget(ii));
				}
			}
			first_row_shown = n+1;
		}
		if(last_row_index > last_row_shown) {
			int n, r;
			for(n=last_row_shown+1;n<=last_row_index;n++) {
				for(r=0;r<items_per_row;r++) {
					var ii = selector.get_selector_item((n*items_per_row)+r);
					if(ii == null) {
						last_row_count = r;
						break;
					}
					add(selector.get_item_widget(ii));
				}
			}
			last_row_shown=n-1;
		}
		while(first_row_index > first_row_shown) {
			int r;
			for(r=0;r<items_per_row;r++) {
				remove_first_child();
			}
			first_row_shown++;
		}
		while(last_row_index < last_row_shown) {
			int ipr = last_row_count;
			if(ipr < 0) {
				ipr = items_per_row;
			}
			int r;
			for(r=0;r<ipr;r++) {
				remove_last_child();
			}
			last_row_count = -1;
			last_row_shown--;
		}
		int y = get_y() + first_row_index * row_items_height, x = 0, rx = 1;
		foreach(Widget w in iterate_children()) {
			w.move_resize(x, y, item_widget_width, row_items_height);
			x += item_widget_width;
			rx++;
			if(rx > items_per_row) {
				y += row_items_height;
				rx = 1;
				x = 0;
			}
		}
	}

	public void on_move() {
		base.on_move();
		update_children();
	}

	public void on_resize() {
		base.on_resize();
		initialize_values();
		remove_children();
		update_size_request();
		update_children();
	}
}
