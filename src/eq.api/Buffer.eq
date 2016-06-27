
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

public interface Buffer
{
	public static bool is_empty(Buffer buffer) {
		if(buffer == null) {
			return(true);
		}
		if(buffer.get_size() < 1) {
			return(true);
		}
		return(false);
	}

	public static Buffer dup(Buffer buf) {
		if(buf == null || buf.get_size() < 1) {
			return(null);
		}
		var v = DynamicBuffer.create(buf.get_size());
		if(v != null) {
			var sp = buf.get_pointer();
			var dp = v.get_pointer();
			if(sp != null && dp != null) {
				dp.cpyfrom(sp, 0, 0, buf.get_size());
			}
		}
		return(v);
	}

	public static Buffer for_pointer(Pointer pointer, int size) {
		var v = new PointerBuffer();
		if(v != null) {
			v.set_pointer(pointer, size);
		}
		return(v);
	}

	public static Buffer for_owned_pointer(Pointer pointer, int size) {
		if(pointer == null || size < 1) {
			return(null);
		}
		IFDEF("target_c") {
			var v = new BufferImpl();
			v.set_buffer(pointer.get_native_pointer(), size);
			return(v);
		}
		ELSE {
			return(Buffer.for_pointer(pointer, size));
		}
	}

	public static Buffer for_hex_string(String str) {
		if(str == null || str.get_length() % 2 != 0) {
			return(null);
		}
		StringBuffer sb;
		var b = DynamicBuffer.create(str.get_length() / 2);
		var bp = b.get_pointer();
		int n;
		var it = str.iterate();
		while(it != null) {
			var c = it.next_char();
			if(c < 1) {
				break;
			}
			if(sb == null) {
				sb = StringBuffer.create();
			}
			if((c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F') || (c >= '0' && c <= '9')) {
				sb.append_c(c);
				if(sb.count() == 2) {
					bp.set_byte(n++, sb.to_string().to_integer_base(16));
					sb = null;
				}
			}
			else {
				return(null);
			}
		}
		return(b);
	}

	public Pointer get_pointer();
	public ptr get_ptr();
	public int get_size();
}

