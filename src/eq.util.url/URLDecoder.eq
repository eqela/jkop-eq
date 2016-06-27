
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

public class URLDecoder
{
	private static int xchar_to_integer(int c) {
		if(c >= '0' && c <= '9') {
			return(c - '0');
		}
		else if(c >= 'a' && c <= 'f') {
			return(10 + c - 'a');
		}
		else if(c >= 'A' && c <= 'F') {
			return(10 + c - 'A');
		}
		return(0);
	}

	public static String decode(String astr) {
		if(astr == null) {
			return(null);
		}
		var sb = StringBuffer.create();
		var str = astr.strip();
		var it = str.iterate();
		while(it != null) {
			var x = it.next_char();
			if(x < 1) {
				break;
			}
			if(x == '%') {
				var x1 = it.next_char();
				var x2 = it.next_char();
				if(x1 > 0 && x2 > 0) {
					sb.append_c(xchar_to_integer(x1) * 16 + xchar_to_integer(x2));
				}
				else {
					break;
				}
			}
			else if(x == '+') {
				sb.append_c((int)' ');
			}
			else {
				sb.append_c(x);
			}
		}
		return(sb.to_string());
	}
}

