
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

public class Length
{
	public static int to_pixels(String s, int dpi) {
		if(s == null) {
			return(0);
		}
		int v = 0, i = 0;
		var it = s.iterate();
		int c;
		while(true) {
			c = it.next_char();
			if(c >= '0' && c <= '9') {
				if(i > 0) {
					i *= 10;
				}
				i += c - '0';
			}
			else {
				if(c < 1) {
					v = i;
					break;
				}
				else if(c == 'p') {
					if(it.next_char() == 'x') {
						v = i;
						break;
					}
				}
				else if(c == 'm') {
					if(it.next_char() == 'm') {
						v = i * dpi / 25;
						if(i > 0 && v < 1) {
							v = 1;
						}
						break;
					}
				}
				else if(c == 'u') {
					if(it.next_char() == 'm') {
						v = i * dpi / (25 * 1000);
						if(i > 0 && v < 1) {
							v = 1;
						}
						break;
					}
				}
				else if(c == 'n') {
					if(it.next_char() == 'm') {
						v = i * dpi / (25 * 1000 * 1000);
						if(i > 0 && v < 1) {
							v = 1;
						}
						break;
					}
				}
				else if(c == 'i') {
					if(it.next_char() == 'n') {
						v = i * dpi;
						if(i > 0 && v < 1) {
							v = 1;
						}
						break;
					}
				}
			}
		}
		return(v);
	}
}

