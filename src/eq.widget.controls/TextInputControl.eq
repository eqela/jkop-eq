
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

public interface TextInputControl : Widget, DataAwareObject
{
	public static TextInputControl instance() {
		return(ControlEngine.engine.create_text_input_control());
	}

	public static TextInputControl for_string(String str) {
		var v = TextInputControl.instance();
		if(v != null) {
			v.set_text(str);
		}
		return(v);
	}

	public static int INPUT_TYPE_DEFAULT = 0;
	public static int INPUT_TYPE_NONASSISTED = 1;
	public static int INPUT_TYPE_NAME = 2;
	public static int INPUT_TYPE_EMAIL = 3;
	public static int INPUT_TYPE_URL = 4;
	public static int INPUT_TYPE_PHONE_NUMBER = 5;
	public static int INPUT_TYPE_PASSWORD = 6;
	public static int INPUT_TYPE_INTEGER = 7;
	public static int INPUT_TYPE_FLOAT = 8;

	public TextInputControl set_has_frame(bool v);
	public bool get_has_frame();
	public TextInputControl set_input_type(int type);
	public int get_input_type();
	public TextInputControl set_text_align(int align);
	public int get_text_align();
	public TextInputControl set_listener(TextInputControlListener listener);
	public TextInputControlListener get_listener();
	public TextInputControl set_placeholder(String text);
	public String get_placeholder();
	public TextInputControl set_text_color(Color c);
	public Color get_text_color();
	public TextInputControl set_text(String text);
	public String get_text();
	public TextInputControl set_max_length(int length);
	public int get_max_length();
}
