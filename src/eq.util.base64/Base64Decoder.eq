
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

public class Base64Decoder
{
	IFDEF("target_android") {
		public static Buffer decode(String text) {
			if(text == null) {
				return(null);
			}
			var tp = text.to_strptr();
			if(tp == null) {
				return(null);
			}
			ptr bytes;
			int blen = 0;
			embed "java" {{{
				bytes = android.util.Base64.decode(tp, android.util.Base64.DEFAULT);
				if(bytes != null) {
					blen = bytes.length;
				}
			}}}
			if(bytes == null || blen < 1) {
				return(null);
			}
			return(Buffer.for_pointer(Pointer.create(bytes), blen));
		}
	}

	ELSE {

	static void appendbyte(DynamicBuffer buffer, uint8 byte) {
		int pos = buffer.get_size();
		if(buffer.append(1)) {
			var ptr = buffer.get_pointer();
			if(ptr != null) {
				ptr.set_byte(pos, byte);
			}
		}
	}

	public static Buffer decode(String text) {
		if(text == null) {
			return(null);
		}
		var data = DynamicBuffer.create(0);
		var iter = text.iterate();
		bool done = false;
		if (iter != null) {
			int ch = -1;
			while ((ch = iter.next_char()) > 0) {
				int c1 = 0, c2 = 0, c3 = 0, c4 = 0;
				uint8 byte1 = 0, byte2 = 0, byte3 = 0;
				c1 = from_lookup_char(ch);
				c2 = from_lookup_char(ch = iter.next_char());
				byte1 = (uint8)((c1 << 2) + (c2 >> 4));
				appendbyte(data, byte1);
				ch = iter.next_char();
				if (ch == '=') {
					done = true;
				}
				else {
					c3 = from_lookup_char(ch);
				}
				byte2 = (uint8)(((c2 & 0x0F) << 4) + (c3 >> 2));
				appendbyte(data, byte2);
				if (!done) {
					ch = iter.next_char();
					if (ch == '=') {
						done = true;
					}
					else {
						c4 = from_lookup_char(ch);
					}
					byte3 = (uint8)(((c3 & 0x03) << 6) + c4);
					appendbyte(data, byte3);
				}
				if (done) {
					break;
				}
			}
		}
		return(data);
	}

	static int from_lookup_char(int ascii) {
		int c = 0;
		if (ascii == 43) {
			c = 62;
		}
		else if (ascii == 47) {
			c = 63;
		}
		else if (ascii >= 48 && ascii <= 57) {
			c = ascii + 4;
		}
		else if (ascii >= 65 && ascii <= 90) {
			c = ascii - 65;
		}
		else if (ascii >= 97 && ascii <= 122) {
			c = ascii - 71;
		}
		return(c);
	}

	}
}

