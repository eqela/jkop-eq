
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

class SimpleEditableString : EditableString, Stringable
{
	public static SimpleEditableString for_string(String s) {
		return(new SimpleEditableString().set_string(s));
	}

	property String string;

	public int get_length() {
		if(string == null) {
			return(0);
		}
		return(string.get_length());
	}

	public int get_char(int pos) {
		if(string == null) {
			return(0);
		}
		return(string.get_char(pos));
	}

	public void append_char(int c) {
		if(string == null) {
			string = String.for_character(c);
			return;
		}
		string = string.append(String.for_character(c));
	}

	public void append(String s) {
		if(string == null) {
			string = s;
			return;
		}
		string = string.append(s);
	}

	public void prepend_char(int c) {
		insert_char(c, 0);
	}

	public void prepend(String s) {
		insert(s, 0);
	}

	public void insert_char(int c, int pos) {
		if(string == null) {
			string = String.for_character(c);
			return;
		}
		string = string.insert(String.for_character(c), pos);
	}

	public void insert(String s, int pos) {
		if(string == null) {
			string = s;
			return;
		}
		string = string.insert(s, pos);
	}

	public void remove_char(int pos) {
		remove(pos, 1);
	}

	public void remove(int pos, int len) {
		if(string == null) {
			return;
		}
		string = string.remove(pos, len);
	}

	public String to_string_range(int start, int len) {
		if(string == null) {
			return(null);
		}
		return(string.substring(start, len));
	}

	public StringIterator iterate() {
		if(string == null) {
			return(null);
		}
		return(string.iterate());
	}

	public String to_string() {
		return(string);
	}
}
