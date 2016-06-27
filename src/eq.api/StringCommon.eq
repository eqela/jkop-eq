
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

class StringCommon
{
	class SplitIterator : Iterator
	{
		int delim = 0;
		int max = 0;
		int counter = 0;
		StringIterator it = null;

		public static SplitIterator create(String str, int delim, int max) {
			var r = new SplitIterator();
			r.delim = delim;
			r.max = max;
			if(str != null) {
				r.it = str.iterate();
			}
			return(r);
		}

		public Object next() {
			if(it == null) {
				return(null);
			}
			var sb = StringBuffer.create();
			int c = 0;
			while((c = it.next_char()) > 0) {
				if(c == delim) {
					if(max < 1 || counter+1 < max) {
						break;
					}
				}
				sb.append_c(c);
			}
			if(c <= 0) {
				it = null;
			}
			counter ++;
			if(sb.count() < 1) {
				return("");
			}
			return(sb.to_string());
		}
	}

	public static Iterator split(String string, int delim, int max = -1) {
		return(SplitIterator.create(string, delim, max));
	}

	public static String replace_string(String asrc, String from, String to) {
		var src = asrc;
		if(String.is_empty(src) || String.is_empty(from)) {
			return(src);
		}
		var sb = StringBuffer.create();
		int n;
		while((n = src.str(from)) >= 0) {
			if(n > 0) {
				sb.append(src.substring(0, n));
			}
			if(String.is_empty(to) == false) {
				sb.append(to);
			}
			src = src.substring(n+from.get_length());
		}
		if(src.get_length() > 0) {
			sb.append(src);
		}
		return(sb.to_string());
	}
}

