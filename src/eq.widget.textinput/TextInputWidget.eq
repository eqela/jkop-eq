
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

public interface TextInputWidget : Widget, DataAwareObject
{
	// values for alignment
	public static int LEFT = 0;
	public static int CENTER = 1;
	public static int RIGHT = 2;

	// input types
	public static int INPUT_TYPE_DEFAULT = 0; // text input using whatever default settings on the current platform
	public static int INPUT_TYPE_NONASSISTED = 1; // text input with no input assistance (prediction, word completion, etc.)
	public static int INPUT_TYPE_NAME = 2; // name text input (capitalized words)
	public static int INPUT_TYPE_EMAIL = 3;
	public static int INPUT_TYPE_URL = 4;
	public static int INPUT_TYPE_PHONE_NUMBER = 5;
	public static int INPUT_TYPE_PASSWORD = 6;
	public static int INPUT_TYPE_INTEGER = 7;
	public static int INPUT_TYPE_FLOAT = 8;

	public static TextInputWidget for_single_line(bool decorated = true) {
		return(new TextInputWidgetFrame().set_draw_frame(decorated));
	}

	public static TextInputWidget for_multiple_lines(int nlines = 4, bool decorated = true) {
		return(new TextInputWidgetFrame().set_draw_frame(decorated).set_lines(nlines));
	}

	public static TextInputWidget instance(bool decorated = true) {
		return(new TextInputWidgetFrame().set_draw_frame(decorated));
	}

	public static TextInputWidget for_string(String str) {
		return(TextInputWidget.instance().set_text(str));
	}

	public TextInputWidget set_lines(int n);
	public int get_lines();
	public TextInputWidget set_input_type(int type);
	public int get_input_type();
	public TextInputWidget set_text_align(int align);
	public int get_text_align();
	public TextInputWidget set_icon(Image icon);
	public Image get_icon();
	public TextInputWidget set_listener(EventReceiver listener);
	public EventReceiver get_listener();
	public TextInputWidget set_placeholder(String text);
	public String get_placeholder();
	public TextInputWidget set_text_color(Color c);
	public Color get_text_color();
	public TextInputWidget set_text(String text);
	public TextInputWidget set_font(Font font);
	public String get_text();
	public void select_all();
	public void select_none();
	public TextInputWidget set_max_length(int length);
}
