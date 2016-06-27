
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

public class AbsoluteAlignWidget : ContainerWidget
{
	public static ContainerWidget for_location(int x, int y) {
		var v = new AbsoluteAlignWidget();
		v.set_child_x(x);
		v.set_child_y(y);
		return(v);
	}

	property int child_x;
	property int child_y;

	public override void arrange_children() {
		foreach(Widget c in iterate_children()) {
			if(c.is_enabled() == false) {
				continue;
			}
			arrange_child(c);
		}
	}

	public void arrange_child(Widget child) {
		if(child == null) {
			return;
		}
		int x = this.get_child_x();
		int y = this.get_child_y();
		if(x < 0) {
			x = 0;
		}
		if(y < 0) {
			y = 0;
		}
		int w = child.get_width_request();
		int h = child.get_height_request();
		if(x+w > get_width()) {
			x = get_width() - w;
			if(x < 0) {
				x = 0;
			}
		}
		if(x+w > get_width()) {
			w = get_width() - x;
		}
		if(y+h > get_height()) {
			y = get_height() - h;
			if(y < 0) {
				y = 0;
			}
		}
		if(y+h > get_height()) {
			h = get_height() - y;
		}
		child.resize(w, h);
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
		set_size_request(rw, rh);
	}
}

