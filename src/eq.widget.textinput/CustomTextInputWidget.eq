
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

public class CustomTextInputWidget : TextInputWidgetAdapter, EventReceiver
{
	Clipboard clipboard;
	int highlight_start = -1;
	int cursor_pos = 0;
	TextLayout layout;
	bool is_pressed = false;
	bool focus = false;
	int max_length = 100000;
	Font font;
	int fontheight;
	int scrollx = 0;
	int cursorwidth;
	property String minimum_height;
	property bool consume_arrow_keys = true;
	int lines = 1;
	bool gain_from_ctx = false;
	property int pointer_press_count = 0;
	BackgroundTask press_timer_task;
	int first_cursor_pos_in_mutiple_pressed = 0;

	public CustomTextInputWidget() {
		clipboard = Clipboard.default();
		minimum_height = "0mm";
	}

	public bool is_focusable() {
		return(true);
	}

	public void initialize() {
		base.initialize();
		cursorwidth = px("500um");
		if(font == null) {
			font = Theme.font();
		}
		if(font != null) {
			var tll = TextLayout.for_properties(TextProperties.for_string("XtlgjpqK")
				.set_font(font), get_frame(), get_dpi());
			fontheight = px(font.get_size());
			if(tll != null) {
				fontheight = tll.get_height();
			}
			var fmm = px(minimum_height);
			var hr = fontheight;
			if(fmm > hr) {
				hr = fmm;
			}
			set_size_request(px("50mm"), hr);
		}
	}

	public void on_visual_change() {
		update_view();
	}

	void end_highlight() {
		if(highlight_start >= 0) {
			highlight_start = -1;
			on_visual_change();
		}
	}

	void update_highlight(KeyEvent e) {
		if(e == null || e.get_shift() == false) {
			end_highlight();
			return;
		}
		if(highlight_start >= 0) {
			return;
		}
		highlight_start = cursor_pos;
	}

	public TextInputWidget set_lines(int nlines) {
		lines = nlines;
		return(this);
	}

	public TextInputWidget set_font(Font font) {
		this.font = font;
		return(this);
	}

	public int get_lines() {
		return(lines);
	}

	public TextInputWidget set_text(String text) {
		base.set_text(text);
		layout = null;
		cursor_pos = 0;
		if(text != null) {
			cursor_pos = text.get_length();
		}
		return(this);
	}

	void set_text_internal(String text) {
		base.set_text(text);
		layout = null;
	}

	public TextInputWidget add_text(String text) {
		if(String.is_empty(text)) {
			return(this);
		}
		var tt = get_text();
		if(tt == null) {
			tt = "";
		}
		return(set_text(tt.append(text)));
	}

	public int get_cursor_pos() {
		return(cursor_pos);
	}

	public void on_gain_focus() {
		base.on_gain_focus();
		focus = true;
		layout = null;
		var tt = get_text();
		if(String.is_empty(tt) == false && gain_from_ctx == false) {
			highlight_start = 0;
			cursor_pos = tt.get_length();
		}
		on_visual_change();
		gain_from_ctx = false;
	}

	public void on_lose_focus() {
		base.on_lose_focus();
		focus = false;
		layout = null;
		is_pressed = false;
		on_visual_change();
	}

	public String get_display_text(String text) {
		if(get_input_type() == TextInputWidget.INPUT_TYPE_PASSWORD) {
			var t = StringBuffer.create();
			int n;
			for(n = 0; text != null && n < text.get_length();n++) {
				t.append_c((int)'*');
			}
			return(t.to_string());
		}
		return(text);
	}

	void move_up() {
		if(cursor_pos != 0) {
			cursor_pos = 0;
			on_visual_change();
		}
	}

	void move_down() {
		var text = get_text();
		if(text == null) {
			cursor_pos = 0;
			on_visual_change();
		}
		else {
			cursor_pos = text.get_length();
			on_visual_change();
		}
	}

	void move_left() {
		if(cursor_pos > 0) {
			cursor_pos--;
			on_visual_change();
		}
	}

	void move_right() {
		var text = get_text();
		if(text == null) {
			cursor_pos = 0;
			on_visual_change();
		}
		else if(cursor_pos < text.get_length()) {
			cursor_pos++;
			on_visual_change();
		}
	}

	public virtual bool on_enter_pressed() {
		var ll = get_listener();
		if(ll != null) {
			EventReceiver.event(ll, new TextInputWidgetEvent()
				.set_widget(this).set_changed(false).set_selected(true));
		}
		else {
			var en = get_engine();
			if(en != null) {
				en.focus_next();
			}
		}
		return(true);
	}

	public void on_changed() {
		var ll = get_listener();
		if(ll != null) {
			EventReceiver.event(ll, new TextInputWidgetEvent()
				.set_widget(this).set_changed(true).set_selected(false));
		}
		layout = null;
		on_visual_change();
	}

	public void clipboard_cut() {
		if(highlight_start >= 0) {
			clipboard_copy();
			delete_highlighted_area();
		}
	}

	String get_highlighted_text() {
		if(highlight_start < 0) {
			return(null);
		}
		var tt = get_display_text(get_text());
		if(String.is_empty(tt)) {
			return(null);
		}
		int c1, c2;
		if(highlight_start < cursor_pos) {
			c1 = highlight_start;
			c2 = cursor_pos;
		}
		else {
			c1 = cursor_pos;
			c2 = highlight_start;
		}
		return(tt.substring(c1,c2-c1));
	}

	public void clipboard_copy() {
		if(highlight_start >= 0 && clipboard != null) {
			clipboard.set_data(ClipboardData.for_string(get_highlighted_text()));
		}
	}

	class ClipboardDataReceiver : EventReceiver
	{
		property CustomTextInputWidget widget;
		public void on_event(Object o) {
			if(o != null && o is ClipboardData && widget != null) {
				widget.delete_highlighted_area();
				widget.append_str(((ClipboardData)o).to_string());
			}
		}
	}

	public void clipboard_paste() {
		if(clipboard != null) {
			clipboard.get_data(new ClipboardDataReceiver().set_widget(this));
		}
	}

	public void select_all() {
		var text = get_text();
		highlight_start = 0;
		if(text != null) {
			cursor_pos = text.get_length();
		}
		else {
			cursor_pos = 0;
		}
		if(highlight_start == cursor_pos) {
			highlight_start = -1;
		}
		on_visual_change();
	}

	public void select_none() {
		end_highlight();
	}

	public bool delete_highlighted_area() {
		var text = get_text();
		if(highlight_start < 0 || highlight_start == cursor_pos || text == null) {
			return(false);
		}
		int c1, c2;
		if(highlight_start < cursor_pos) {
			c1 = highlight_start;
			c2 = cursor_pos;
		}
		else {
			c1 = cursor_pos;
			c2 = highlight_start;
		}
		var tt = "";
		if(c1 > 0) {
			tt = text.substring(0,c1);
		}
		tt = tt.append(text.substring(c2));
		set_text_internal(tt);
		highlight_start = -1;
		cursor_pos = c1;
		scrollx = 0;
		on_visual_change();
		on_changed();
		return(true);
	}

	void delete_char() {
		var text = get_text();
		if(cursor_pos >= 0 && text != null) {
			set_text_internal(text.remove(cursor_pos, 1));
			on_changed();
		}
	}

	public virtual void on_key_press_up(KeyEvent e) {
		update_highlight(e);
		move_up();
	}

	public virtual void on_key_press_down(KeyEvent e) {
		update_highlight(e);
		move_down();
	}

	public virtual void on_key_press_right(KeyEvent e) {
		update_highlight(e);
		move_right();
	}

	public virtual void on_key_press_left(KeyEvent e) {
		update_highlight(e);
		move_left();
	}

	bool is_shortcut(KeyEvent e, String key) {
		if(e != null && (e.get_ctrl() || e.get_command())) {
			if(key == null) {
				return(true);
			}
			if(key.equals_ignore_case(e.get_str())) {
				return(true);
			}
		}
		return(false);
	}

	public void remove_characters(int n) {
		var nx = n;
		if(nx > cursor_pos) {
			nx = cursor_pos;
		}
		if(nx < 1) {
			return;
		}
		var text = get_text();
		if(text != null) {
			set_text_internal(text.remove(cursor_pos - nx, nx));
			cursor_pos -= nx;
			on_changed();
		}
	}

	public void go_to_beginning(KeyEvent e = null) {
		update_highlight(e);
		cursor_pos = 0;
		on_visual_change();
	}

	public void go_to_end(KeyEvent e = null) {
		update_highlight(e);
		var text = get_text();
		if(text != null) {
			cursor_pos = text.get_length();
		}
		on_visual_change();
	}

	public virtual bool on_shortcut_key_pressed(String kstr, KeyEvent e) {
		if("a".equals(kstr)) {
			select_all();
			return(true);
		}
		if("e".equals(kstr)) {
			go_to_end(e);
			return(true);
		}
		if("d".equals(kstr)) {
			if(delete_highlighted_area() == false) {
				delete_char();
			}
			return(true);
		}
		if("k".equals(kstr)) {
			var text = get_text();
			if(cursor_pos >= 0 && text != null) {
				clipboard.set_data(ClipboardData.for_string(text.substring(cursor_pos)));
				set_text_internal(text.substring(0,cursor_pos));
				on_changed();
			}
			return(true);
		}
		if("u".equals(kstr)) {
			var text = get_text();
			if(cursor_pos >= 0 && text != null) {
				clipboard.set_data(ClipboardData.for_string(text.substring(0,cursor_pos)));
				set_text_internal(text.substring(cursor_pos));
				cursor_pos = 0;
				on_changed();
			}
			return(true);
		}
		if("c".equals(kstr)) {
			clipboard_copy();
			return(true);
		}
		if("x".equals(kstr)) {
			clipboard_cut();
			return(true);
		}
		if("v".equals(kstr)) {
			clipboard_paste();
			return(true);
		}
		return(false);
	}

	public virtual bool on_key_pressed(String kname, String kstr, KeyEvent e) {
		bool v = true;
		if(e == null) {
			v = false;
		}
		else if(e.get_ctrl() || e.get_command()) {
			var ss = e.get_str();
			if(ss != null) {
				v = on_shortcut_key_pressed(ss.lowercase(), e);
			}
			else {
				v = false;
			}
		}
		else if(e.get_alt()) {
			v = false;
		}
		else if("end".equals(kname)) {
			go_to_end(e);
		}
		else if("home".equals(kname)) {
			go_to_beginning(e);
		}
		else if("delete".equals(kname)) {
			if(delete_highlighted_area() == false) {
				delete_char();
			}
		}
		else if("backspace".equals(kname)) {
			if(delete_highlighted_area() == false) {
				var text = get_text();
				if(cursor_pos > 0 && text != null) {
					set_text_internal(text.remove(cursor_pos - 1, 1));
					cursor_pos--;
					on_changed();
				}
			}
		}
		else if("enter".equals(kname) || "return".equals(kname)) {
			v = on_enter_pressed();
		}
		else if(consume_arrow_keys && "left".equals(kname)) {
			on_key_press_left(e);
		}
		else if(consume_arrow_keys && "right".equals(kname)) {
			on_key_press_right(e);
		}
		else if(consume_arrow_keys && "up".equals(kname)) {
			on_key_press_up(e);
		}
		else if(consume_arrow_keys && "down".equals(kname)) {
			on_key_press_down(e);
		}
		else if("tab".equals(kname)) {
			v = false;
		}
		else if(get_input_type() == TextInputWidget.INPUT_TYPE_INTEGER) {
			delete_highlighted_area();
			if(kstr != null && kstr.get_length() == 1) {
				var c = kstr.get_char(0);
				if((c >= '0' && c <= '9') || c == '-' || c == '+') {
					append_str(kstr);
				}
				else {
					v = false;
				}
			}
			else {
				v = false;
			}
		}
		else if(get_input_type() == TextInputWidget.INPUT_TYPE_FLOAT) {
			delete_highlighted_area();
			if(kstr != null && kstr.get_length() == 1) {
				var c = kstr.get_char(0);
				if((c >= '0' && c <= '9') || c == '-' || c == '+' || c == '.') {
					append_str(kstr);
				}
				else {
					v = false;
				}
			}
			else {
				v = false;
			}
		}
		else if(kstr != null && kstr.get_length() > 0) {
			var ast = filter_string(kstr);
			if(String.is_empty(ast) == false) {
				delete_highlighted_area();
				append_str(ast);
			}
			else {
				v = false;
			}
		}
		else {
			v = false;
		}
		return(v);
	}

	String filter_string(String str) {
		var sb = StringBuffer.create();
		foreach(Integer i in str) {
			var c = i.to_integer();
			if(is_printable(c)) {
				sb.append_c(c);
			}
		}
		return(sb.to_string());
	}

	public static bool is_printable(int c) {
		if(c == 9) { // tab
			return(true);
		}
		if(c < 32) {
			return(false);
		}
		return(true);
	}

	public override bool on_key_press(KeyEvent e) {
		if(has_focus() == false || e == null) {
			return(false);
		}
		var kname = e.get_name();
		var kstr = e.get_str();
		return(on_key_pressed(kname, kstr, e));
	}

	public virtual void append_str(String kstr) {
		if(kstr == null) {
			return;
		}
		var text = get_text();
		if(text == null) {
			text = "";
		}
		if(max_length > 0 && kstr.get_length() + text.get_length() > max_length) {
			return;
		}
		set_text_internal(text.insert(kstr, cursor_pos));
		cursor_pos += kstr.get_length();
		on_changed();
	}

	void update_cursor(int ax, int y, bool clear_highlight = true) {
		if(layout != null) {
			int x = ax - scrollx;
			int length = 0;
			var text = get_text();
			if(text != null) {
				length = text.get_length();
			}
			int idx = 0, w = get_width(), layw = layout.get_width(), adjust = 0;
			if(layw < w) {
				if(get_text_align() == 1) {
					adjust = (w-layw) / 2;
				}
				else if(get_text_align() == 2) {
					adjust = (w-layw-cursorwidth);
				}
			}
			idx = layout.xy_to_index(x - adjust, y);
			if(idx < 0) {
				idx = length;
			}
			if(idx >= 0) {
				if(idx > length) {
					idx = length;
				}
				cursor_pos = idx;
				if(clear_highlight) {
					highlight_start = -1;
				}
				on_visual_change();
			}
		}
	}

	public override void on_pointer_leave(int id) {
		base.on_pointer_leave(id);
		is_pressed = false;
	}

	class PointerPressTimerHandler : TimerHandler
	{
		property CustomTextInputWidget widget;

		public bool on_timer(Object arg) {
			widget.set_pointer_press_count(0);
			return(false);
		}
	}

	public void on_double_pressed() {
		select_word();
	}

	public void on_triple_pressed() {
		pointer_press_count = 0;
		select_all();
	}

	bool is_alphanumeric(int c)
	{
		if((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')) {
			return(true);
		}
		return(false);
	}

	public void select_word() {
		var text = get_text();
		int last_cursor_pos = cursor_pos;
		highlight_start = cursor_pos;
		if(text != null) {
			bool is_whitespaces_left_str = false;
			if(text.get_char(last_cursor_pos - 1) == ' ') {
				is_whitespaces_left_str = true;
			}
			int x = 1;
			while(true) {
				var c = text.get_char(last_cursor_pos - x);
				if(c < 1) {
					break;
				}
				if(((is_alphanumeric(c) || c == '_') && is_whitespaces_left_str == false) ||
					(c == ' ' && is_whitespaces_left_str)) {
					highlight_start--;
				}
				else {
					break;
				}
				x++;
			}
			bool is_whitespaces_right_string = false;
			if(text.get_char(last_cursor_pos) == ' ') {
				is_whitespaces_right_string = true;
			}
			x = 0;
			while(true) {
				var c = text.get_char(last_cursor_pos + x);
				if(c < 1) {
					break;
				}
				if(((is_alphanumeric(c) || c == '_') && is_whitespaces_right_string == false) ||
					(c == ' ' && is_whitespaces_right_string)) {
					cursor_pos++;
				}
				else {
					break;
				}
				x++;
			}
			if(is_whitespaces_left_str != is_whitespaces_right_string) {
				if(is_whitespaces_left_str) {
					highlight_start = last_cursor_pos;
				}
				else {
					cursor_pos = last_cursor_pos;
				}
			}
		}
		else {
			cursor_pos = 0;
		}
		if(highlight_start == cursor_pos) {
			highlight_start = -1;
		}
		on_visual_change();
	}

	public override bool on_pointer_press(int x, int y, int button, int id) {
		is_pressed = true;
		if(pointer_press_count == 1) {
			first_cursor_pos_in_mutiple_pressed = cursor_pos;
		}
		update_cursor((int)(x-get_x()), (int)(y-get_y()));
		if(first_cursor_pos_in_mutiple_pressed == cursor_pos || pointer_press_count == 0)
		{
			pointer_press_count++;
		}
		if(pointer_press_count == 2) {
			on_double_pressed();
		}
		if(pointer_press_count > 2) {
			on_triple_pressed();
		}
		if(press_timer_task != null) {
			press_timer_task.abort();
		}
		press_timer_task = start_timer(500000, new PointerPressTimerHandler().set_widget(this), null);
		return(true);
	}

	public override bool on_pointer_release(int x, int y, int button, int id) {
		if(is_pressed) {
			if(is_focusable()) {
				grab_focus();
			}
			is_pressed = false;
			return(true);
		}
		return(false);
	}

	public bool on_context(int x, int y) {
		var ctxmenu = MenuWidget.instance();
		ctxmenu.add_entry(null, "Select all", "Select all current text", "select_all");
		ctxmenu.add_entry(null, "Copy all", "Copy all text to clipboard", "copy_all");
		ctxmenu.add_entry(null, "Cut", "Cut selection to clipboard", "cut");
		ctxmenu.add_entry(null, "Copy", "Copy selection to clipboard", "copy");
		ctxmenu.add_entry(null, "Paste", "Paste from clipboard", "paste");
		ctxmenu.set_event_handler(this);
		ctxmenu.popup(this);
		return(true);
	}

	void focus_from_ctxmenu() {
		grab_focus();
		var text = get_text();
		if(text != null) {
			highlight_start = -1;
			cursor_pos = text.get_length();
			on_visual_change();
		}
	}

	public void on_event(Object o) {
		if("select_all".equals(o)) {
			grab_focus();
		}
		else if("copy_all".equals(o)) {
			select_all();
			clipboard_copy();
			grab_focus();
		}
		else if("cut".equals(o)) {
			clipboard_cut();
			gain_from_ctx = true;
			grab_focus();
		}
		else if("copy".equals(o)) {
			clipboard_copy();
			gain_from_ctx = true;
			grab_focus();
		}
		else if("paste".equals(o)) {
			clipboard_paste();
			gain_from_ctx = true;
			grab_focus();
		}
		else {
			forward_event(o);
		}
	}

	public override bool on_pointer_drag(int x, int y, int dx, int dy, int button, bool drop, int id) {
		if(drop) {
			return(true);
		}
		if(has_focus() == false) {
			gain_from_ctx = true;
			grab_focus();
		}
		is_pressed = false;
		bool ch = true;
		if(layout != null) {
			int w = get_width(), layw = layout.get_width(), adjust = 0;
			if(layw < w) {
				if(get_text_align() == 1) {
					adjust = (w-layw) / 2;
				}
				else if(get_text_align() == 2) {
					adjust = (w-layw-cursorwidth);
				}
			}
			var hp = layout.xy_to_index(x-dx-adjust-scrollx-get_x(), 0);
			if(hp >= 0) {
				highlight_start = hp;
				ch = false;
			}
		}
		update_cursor((int)(x-get_x()), (int)(y-get_y()), ch);
		return(true);
	}

	public override bool on_pointer_cancel(int x, int y, int button, int id) {
		is_pressed = false;
		return(true);
	}

	public TextInputWidget set_placeholder(String text) {
		layout = null;
		return(base.set_placeholder(text));
	}

	public Collection render() {
		var v = LinkedList.create();
		if(layout == null) {
			var text = get_display_text(get_text());
			var color = get_text_color();
			if(color == null) {
				color = get_draw_color();
			}
			if(String.is_empty(text) && focus == false) {
				text = get_placeholder();
				color = color.dup().set_a(0.6);
			}
			if(text == null) {
				text = "";
			}
			layout = TextLayout.for_properties(TextProperties.for_string(text)
				.set_font(font)
				.set_color(color), get_frame(), get_dpi()
			);
		}
		int csp = 0;
		var y = (get_height() - fontheight) / 2;
		int adjust = 0;
		if(layout != null) {
			int w = get_width(), layw = layout.get_width();
			if(layw < w) {
				if(get_text_align() == 1) {
					adjust = (w-layw) / 2;
				}
				else if(get_text_align() == 2) {
					adjust = (w-layw-cursorwidth);
				}
			}
			int hsp = -1;
			if(focus) {
				var cursor = layout.get_cursor_position(cursor_pos);
				if(cursor != null) {
					csp = cursor.get_x();
				}
				if(highlight_start >= 0) {
					var hc = layout.get_cursor_position(highlight_start);
					if(hc != null) {
						hsp = hc.get_x();
					}
				}
			}
			if(hsp >= 0) {
				int x1, x2;
				if(hsp > csp) {
					x1 = csp;
					x2 = hsp;
				}
				else {
					x1 = hsp;
					x2 = csp;
				}
				v.append(new FillColorOperation().set_x(adjust + x1 + scrollx).set_y(y)
					.set_shape(RectangleShape.create(0,0,x2-x1,fontheight))
					.set_color(Theme.get_highlight_color()));
			}
			if(focus && csp >= 0) {
				if(csp + scrollx < 0) {
					scrollx = -csp;
				}
				else if(csp + scrollx + cursorwidth >= get_width()) {
					scrollx = get_width() - csp - cursorwidth;
				}
				var cursorop = new FillColorOperation().set_x(adjust + csp + scrollx).set_y(y)
					.set_shape(RectangleShape.create(0,0,cursorwidth,fontheight))
					.set_color(Theme.get_highlight_color());
				v.append(cursorop);
			}
			v.append(new DrawObjectOperation().set_object(layout).set_x(adjust + scrollx).set_y(y));
		}
		return(v);
	}
}
