
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

class StringFormatterBase : StringFormatter, Stringable
{
	Collection data;
	property String format;

	public StringFormatter add(Object o) {
		if(o != null) {
			if(data == null) {
				data = LinkedList.create();
			}
			data.append(o);
		}
		return(this);
	}

	public virtual void format_string(StringBuffer result, String aformat, String value) {
		if(value == null || aformat == null) {
			return;
		}
		if(aformat.get_length() == 2) {
			result.append(value);
			return;
		}
		bool align_left = false;
		int min_length = 0;
		int max_length = 0;
		var it = aformat.iterate();
		it.next_char();
		var sb = StringBuffer.create();
		var c = it.next_char();
		if(c == '-') {
			align_left = true;
		}
		else {
			sb.append_c(c);
		}
		while(true) {
			c = it.next_char();
			if(c == 's' ) {
				break;
			}
			sb.append_c(c);
		}
		var lls = sb.to_string();
		if(lls.chr((int)'.') >= 0) {
			var it2 = lls.split((int)'.', 2);
			var s1 = String.as_string(it2.next());
			var s2 = String.as_string(it2.next());
			if(s1 != null) {
				min_length = s1.to_integer();
			}
			if(s2 != null) {
				max_length = s2.to_integer();
			}
		}
		else {
			min_length = lls.to_integer();
		}
		if(max_length > 0 && value.get_length() >= max_length) {
			result.append(value.substring(0, max_length));
			return;
		}
		if(value.get_length() >= min_length) {
			result.append(value);
			return;
		}
		var sb2 = StringBuffer.create();
		if(align_left) {
			sb2.append(value);
			while(sb2.count() < min_length) {
				sb2.append_c((int)' ');
			}
		}
		else {
			int n, m = min_length - value.get_length();
			for(n=0; n<m; n++) {
				sb2.append_c((int)' ');
			}
			sb2.append(value);
		}
		result.append(sb2.to_string());
	}

	public virtual void format_integer(StringBuffer result, String format, int value) {
	}

	public virtual void format_double(StringBuffer result, String format, double value) {
	}

	public String to_string() {
		if(format == null) {
			return("");
		}
		var it = format.iterate();
		if(it == null) {
			return("");
		}
		Iterator dit;
		if(data != null) {
			dit = data.iterate();
		}
		var sb = StringBuffer.create();
		Object nn;
		int c;
		while((c = it.next_char()) > 0) {
			if(nn == null && dit != null) {
				nn = dit.next();
			}
			if(c != '%') {
				sb.append_c(c);
				continue;
			}
			var fsb = StringBuffer.create();
			fsb.append_c(c);
			while((c = it.next_char()) > 0) {
				fsb.append_c(c);
				if(c == 's') {
					format_string(sb, fsb.to_string(), String.as_string(nn));
					nn = null;
					break;
				}
				if(c == 'd' || c == 'i' || c == 'u' || c == 'o' || c == 'x' || c == 'X' || c == 'c') {
					format_integer(sb, fsb.to_string(), Integer.as_integer(nn));
					nn = null;
					break;
				}
				if(c == 'f' || c == 'F' || c == 'e' || c == 'E') {
					format_double(sb, fsb.to_string(), Double.as_double(nn));
					nn = null;
					break;
				}
				if(c == '%') {
					sb.append_c((int)'%');
					break;
				}
			}
		}
		return(sb.to_string());
	}
}
