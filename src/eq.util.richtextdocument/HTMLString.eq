
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

class HTMLString
{
	public static String sanitize(String str) {
		if(str == null) {
			return(null);
		}
		if(str.chr('<') < 0 && str.chr('>') < 0 && str.chr('&') < 0) {
			return(str);
		}
		var it = str.iterate();
		if(it == null) {
			return(null);
		}
		var sb = StringBuffer.for_initial_size(str.get_length());
		int c;
		while((c = it.next_char()) > 0) {
			if(c == '<') {
				sb.append("&lt;");
			}
			else if(c == '>') {
				sb.append("&gt;");
			}
			else if(c == '&') {
				sb.append("&amp;");
			}
			else {
				sb.append_c(c);
			}
		}
		return(sb.to_string());
	}
}