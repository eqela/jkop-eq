
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

public class RichTextSegment
{
	property String text;
	property bool bold;
	property bool italic;
	property bool underline;
	property String color;
	property String link;
	property String reference;
	property bool is_inline = false;
	property bool link_popup = false;

	void add_markup_modifiers(StringBuffer sb) {
		if(bold) {
			sb.append("**");
		}
		if(italic) {
			sb.append("''");
		}
		if(underline) {
			sb.append("__");
		}
	}

	public String to_markup() {
		var sb = StringBuffer.create();
		add_markup_modifiers(sb);
		if(String.is_empty(link) == false) {
			sb.append_c((int)'[');
			if(is_inline) {
				sb.append_c((int)'>');
			}
			sb.append(link);
			if(String.is_empty(text) == false) {
				sb.append_c((int)'|');
				sb.append(text);
			}
			sb.append_c((int)']');
		}
		else if(String.is_empty(reference) == false) {
			sb.append_c((int)'{');
			if(is_inline) {
				sb.append_c((int)'>');
			}
			sb.append(reference);
			if(String.is_empty(text) == false) {
				sb.append_c((int)'|');
				sb.append(text);
			}
			sb.append_c((int)'}');
		}
		else {
			sb.append(text);
		}
		add_markup_modifiers(sb);
		return(sb.to_string());
	}

	public HashTable to_json() {
		var v = HashTable.create();
		v.set("text", text);
		if(is_inline) {
			v.set_bool("inline", is_inline);
		}
		if(bold) {
			v.set_bool("bold", bold);
		}
		if(italic) {
			v.set_bool("italic", italic);
		}
		if(underline) {
			v.set_bool("underline", underline);
		}
		if(String.is_empty(color) == false) {
			v.set("color", color);
		}
		if(String.is_empty(link) == false) {
			v.set("link", link);
		}
		if(String.is_empty(reference) == false) {
			v.set("reference", reference);
		}
		return(v);
	}
}
