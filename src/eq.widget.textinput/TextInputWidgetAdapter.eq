
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

public class TextInputWidgetAdapter : Widget, TextInputWidget, DataAwareObject
{
	int input_type;
	int text_align;
	int max_length = -1;
	Image icon;
	EventReceiver listener;
	String placeholder;
	Color text_color;
	String text;
	int lines;

	public TextInputWidgetAdapter() {
		set_cursor(Cursor.for_stock_cursor(Cursor.STOCK_EDITTEXT));
	}

	public void set_data(Object o) {
		set_text(String.as_string(o));
	}

	public Object get_data() {
		return(get_text());
	}

	public TextInputWidget set_lines(int nlines) {
		lines = nlines;
		return(this);
	}

	public int get_lines() {
		return(lines);
	}

	public TextInputWidget set_input_type(int type) {
		if(input_type != type) {
			input_type = type;
			on_visual_change();
		}
		return(this);
	}

	public int get_input_type() {
		return(input_type);
	}

	public void select_all() {
	}

	public void select_none() {
	}

	public virtual void on_visual_change() {
	}

	public TextInputWidget set_text_align(int align) {
		if(text_align != align) {
			text_align = align;
			on_visual_change();
		}
		return(this);
	}

	public int get_text_align() {
		return(text_align);
	}

	public TextInputWidget set_icon(Image i) {
		icon = i;
		on_visual_change();
		return(this);
	}

	public Image get_icon() {
		return(icon);
	}

	public TextInputWidget set_listener(EventReceiver ll) {
		listener = ll;
		return(this);
	}

	public EventReceiver get_listener() {
		return(listener);
	}

	public TextInputWidget set_placeholder(String text) {
		placeholder = text;
		on_visual_change();
		return(this);
	}

	public String get_placeholder() {
		return(placeholder);
	}

	public TextInputWidget set_text_color(Color c) {
		text_color = c;
		on_visual_change();
		return(this);
	}

	public Color get_text_color() {
		return(text_color);
	}

	public TextInputWidget set_text(String t) {
		text = t;
		on_visual_change();
		return(this);
	}

	public String get_text() {
		return(text);
	}

	public TextInputWidget set_font(Font font) {
		return(this);
	}

	public int get_max_length() {
		return(max_length);
	}

	public TextInputWidget set_max_length(int length) {
		max_length = length;
		on_visual_change();
		return(this);
	}
}
