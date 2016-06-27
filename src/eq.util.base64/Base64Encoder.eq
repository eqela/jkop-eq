
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

public class Base64Encoder
{
	public static String encode_string(String str) {
		if(str == null) {
			return(null);
		}
		return(encode(str.to_utf8_buffer(false)));
	}

	public static String encode(Buffer buffer) {
		if(buffer == null) {
			return(null);
		}
		Pointer ptr = buffer.get_pointer();
		StringBuffer sb = null;
		if (ptr != null) {
			sb = StringBuffer.create();
			int i = 0, append = 0, size = buffer.get_size();
			while (i < size) {
				// get the 3 bytes
				int a6 = 0, b6 = 0, c6 = 0, d6 = 0;
				int byte1 = ptr.get_byte(i++) & 0xFF;
				int byte2 = ptr.get_byte(i++) & 0xFF;
				int byte3 = ptr.get_byte(i++) & 0xFF;
				a6 = (int)(byte1 >> 2);
				b6 = ((int)((byte1 & 0x03) << 4) + (int)(byte2 >> 4));
				sb.append_c(to_ascii_char(a6));
				sb.append_c(to_ascii_char(b6));
				append = i - size;
				if (append <= 0) {
					c6 = ((int)((byte2 & 0x0F) << 2) + (int)(byte3 >> 6));
					d6 = (int)(byte3 & 0x3F);
					sb.append_c(to_ascii_char(c6));
					sb.append_c(to_ascii_char(d6));
				}
				else {
					if (append > 1) {
						sb.append_c((int)'=');
					}
					else {
						c6 = ((int)((byte2 & 0x0F) << 2) + (int)(byte3 >> 6));
						sb.append_c(to_ascii_char(c6));
					}
					sb.append_c((int)'=');
				}
			}
		}
		if (sb != null) {
			return(sb.to_string());
		}
		return(null);
	}

	static int to_ascii_char(int lookup) {
		if (lookup < 0 || lookup > 63) {
			return(0);
		}
		int c = 0;
		if (lookup <= 25) {
			c = lookup + 65;
		}
		else if (lookup <= 51) {
			c = lookup + 71;
		}
		else if (lookup <= 61) {
			c = lookup - 4;
		}
		else if (lookup == 62) {
			c = (int)'+';
		}
		else if (lookup == 63) {
			c = (int)'/';
		}
		return(c);
	}
}

