
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

public class KeyEvent
{
	property String name;
	property String str;
	property int keycode;
	property bool shift;
	property bool alt;
	property bool ctrl;
	property bool command;

	public void set_str_char(int char) {
		str = String.for_character(char);
	}

	public bool has_name(String v) {
		if(v == null && name == null) {
			return(true);
		}
		if(name != null && name.equals(v)) {
			return(true);
		}
		return(false);
	}

	public bool has_str(String v) {
		if(v == null && str == null) {
			return(true);
		}
		if(str != null && str.equals(v)) {
			return(true);
		}
		return(false);
	}

	public bool has_modifiers() {
		return(shift || alt || ctrl || command);
	}

	public bool is_shortcut(String key = null) {
		if(ctrl || command) {
			if(key == null) {
				return(true);
			}
			if(key.equals(str)) {
				return(true);
			}
		}
		return(false);
	}
}
