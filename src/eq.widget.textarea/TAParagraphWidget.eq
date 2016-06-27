
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

public class TAParagraphWidget : Widget
{
	property bool wrap = true;
	EditableString text;
	property TADocument document;
	property Font font;
	bool enabled = true;
	double initial_height;
	double last_width;
	double last_height;
	property int tab_spaces = -1;
	property int offset = 0;
	property Color text_color;
	Object click_event;
	bool pointer_pressed = false;

	public void set_click_event(Object event) {
		this.click_event = event;
		set_cursor(Cursor.for_stock_cursor(Cursor.STOCK_POINT));
	}

	public bool on_pointer_press(int x, int y, int button, int id) {
		pointer_pressed = true;
		return(true);
	}

	public bool on_pointer_release(int x, int y, int button, int id) {
		var pp = pointer_pressed;
		pointer_pressed = false;
		if(pp) {
			if(click_event != null) {
				raise_event(click_event);
			}
			return(true);
		}
		return(false);
	}

	public void on_pointer_enter(int id) {
		base.on_pointer_enter(id);
		if(click_event != null) {
			set_alpha(0.75);
		}
	}

	public void on_pointer_leave(int id) {
		base.on_pointer_leave(id);
		pointer_pressed = false;
		if(click_event != null) {
			set_alpha(1.0);
		}
	}

	public EditableString get_text() {
		return(text);
	}

	public String get_text_as_string() {
		if(text == null) {
			return(null);
		}
		return(text.to_string());
	}

	public TAParagraphWidget set_text(EditableString es) {
		text = es;
		if(is_initialized()) {
			var layout = create_layout();
			if(layout != null) {
				set_size_request(layout.get_width(), layout.get_height());
			}
			set_surface_content(layout.get_display_list());
		}
		return(this);
	}

	public void on_resize() {
		TAParagraphLayout layout;
		bool update = false;
		var width = get_width();
		if(last_width != width) {
			if(wrap && enabled && (get_height() > initial_height || get_width() < get_width_request())) {
				layout = create_layout();
				if(layout != null) {
					set_size_request(layout.get_width(), layout.get_height());
				}
				update = true;
			}
			width = last_width;
		}
		var height = get_height();
		if(height != last_height) {
			update = true;
			last_height = height;
		}
		if(get_surface() == null) {
			update = true;
		}
		if(update && enabled && get_width() > 0 && get_height() > 0) {
			if(layout == null) {
				layout = create_layout();
			}
			var ss = get_surface();
			if(ss != null) {
				ss.resize(get_width(), get_height());
			}
			set_surface_content(layout.get_display_list());
		}
		else if(update && (get_width() < 1 || get_height() < 1)) {
			set_surface_content(null);
		}
	}

	public void enable() {
		if(enabled == true) {
			return;
		}
		enabled = true;
		if(is_initialized()) {
			do_update_view();
		}
	}

	public void disable() {
		if(enabled == false) {
			return;
		}
		enabled = false;
		set_surface_content(null);
	}

	public void initialize() {
		base.initialize();
		var ll = create_layout();
		if(ll != null) {
			set_size_request(ll.get_width(), ll.get_height());
			initial_height = ll.get_height();
		}
	}

	String expand_tabs(String text, int n) {
		if(text.chr((int)'\t') < 0) {
			return(text);
		}
		var sb = StringBuffer.create();
		var it = text.iterate();
		int c;
		while((c = it.next_char()) > 0) {
			if(c == '\t') {
				int i;
				for(i=0; i<n; i++) {
					sb.append_c((int)' ');
				}
			}
			else {
				sb.append_c(c);
			}
		}
		return(sb.to_string());
	}

	public TAParagraphLayout create_layout() {
		var ll = new TASimpleParagraphLayout();
		String tt;
		if(text != null) {
			tt = text.to_string();
		}
		if(tt == null) {
			tt = "";
		}
		if(tab_spaces >= 0) {
			tt = expand_tabs(tt, tab_spaces);
		}
		if(offset > 0) {
			tt = tt.substring(offset);
		}
		ll.set_text(tt);
		var f = font;
		if(f == null) {
			f = Theme.font();
		}
		ll.set_font(f);
		var tc = text_color;
		if(tc == null) {
			tc = get_draw_color();
		}
		ll.set_color(tc);
		if(wrap) {
			ll.set_wrapwidth(get_width());
		}
		ll.set_frame(get_frame());
		ll.set_dpi(get_dpi());
		return(ll.initialize());
	}
}
