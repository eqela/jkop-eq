
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

public class CharacterDecoder
{
	static int UTF8 = 0;
	static int ASCII = 1;
	static int UCS2 = 2;
	int encoding = UTF8;
	int current = -1;

	public virtual bool nextbyte() {
		return(false);
	}

	public virtual int getbyte() {
		return(0);
	}

	public CharacterDecoder set_encoding(String ee) {
		if("UTF8".equals_ignore_case(ee) || "UTF-8".equals_ignore_case(ee)) {
			encoding = UTF8;
			return(this);
		}
		if("ASCII".equals_ignore_case(ee)) {
			encoding = ASCII;
			return(this);
		}
		if("UCS2".equals_ignore_case(ee) || "UCS-2".equals_ignore_case(ee)) {
			encoding = UCS2;
			return(this);
		}
		return(null);
	}

	public bool nextcharacter() {
		if(encoding == UTF8) {
			if(nextbyte() == false) {
				return(false);
			}
			var b1 = getbyte();
			int v = -1;
			if ((b1 & 0xE0) == 0xE0) { // 3 bytes
				v = (int)((b1 & 0x0F) << 12);
				if(nextbyte() == false) {
					return(false);
				}
				var b2 = getbyte();
				if (b2 != 0) {
					v += (int)((b2 & 0x3F) << 6);
				}
				else {
					v = -1;
				}
				if(nextbyte() == false) {
					return(false);
				}
				var b3 = getbyte();
				if (b3 != 0) {
					v += (int)(b3 & 0x3F);
				}
				else {
					v = -1;
				}
			}
			else if ((b1 & 0xC0) == 0xC0) { // 2 bytes
				v = (int)((b1 & 0x1F) << 6);
				if(nextbyte() == false) {
					return(false);
				}
				var b2 = getbyte();
				if (b2 != 0) {
					v += (int)(b2 & 0x3F);
				}
				else {
					v = -1;
				}
			}
			else if (b1 <= 0x7F) { // 1 byte
				v = (int)b1;
			}
			else { // invalid byte
				return(false);
			}
			current = v;
			return(true);
		}
		if(encoding == ASCII) {
			if(nextbyte() == false) {
				return(false);
			}
			current = (int)getbyte();
			return(true);
		}
		if(encoding == UCS2) {
			int c0;
			int c1;
			if(nextbyte() == false) {
				return(false);
			}
			c0 = (int)getbyte();
			if(nextbyte() == false) {
				return(false);
			}
			c1 = (int)getbyte();
			current = c0 << 8 & c1;
			return(true);
		}
		return(false);
	}

	public int getcharacter() {
		return(current);
	}
}
