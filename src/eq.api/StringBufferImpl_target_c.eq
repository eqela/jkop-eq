
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

class StringBufferImpl : Stringable, StringBuffer
{
	private DynamicBuffer buffer = null;
	private int pos = 0;

	public StringBufferImpl() {
		buffer = null;
		pos = 0;
	}

	public Buffer get_buffer() {
		if(buffer == null) {
			return(null);
		}
		return(SubBuffer.create(buffer, 0, pos));
	}

	public StringBuffer dup() {
		var v = new StringBufferImpl();
		v.buffer = Buffer.dup(buffer) as DynamicBuffer;
		v.pos = pos;
		return(v);
	}

	public void grow(int sz) {
		int rsz = sz;
		if(buffer == null) {
			buffer = DynamicBuffer.create(rsz);
		}
		else {
			if(buffer.append(rsz) == false) {
				buffer = null;
			}
		}
	}

	public int count() {
		return(pos);
	}

	public void clear() {
		buffer = null;
		pos = 0;
	}

	public void append(String c) {
		if(c == null) {
			return;
		}
		var bb = c.to_utf8_buffer();
		if(bb == null) {
			return;
		}
		int bs = bb.get_size();
		if(bs < 2) {
			return;
		}
		bs --;
		if(buffer == null || pos+bs > buffer.get_size()) {
			grow(bs);
		}
		if(buffer != null) {
			var buffer_ptr = buffer.get_pointer();
			var str_ptr = bb.get_pointer();
			if(buffer_ptr != null && str_ptr != null) {
				buffer_ptr.cpyfrom(str_ptr, 0, pos, bs);
				pos += bs;
			}
		}
	}

	public void append_c(int c) {
		if(c < 0x80) {
			if(buffer == null || pos+1 > buffer.get_size()) {
				grow(1);
			}
			if(buffer != null) {
				var buffer_ptr = buffer.get_pointer();
				if(buffer_ptr != null) {
					buffer_ptr.set_byte(pos, (uint8)c);
					pos ++;
				}
			}
		}
		else if(c >= 0x80 && c < 0x800) {
			if(buffer == null || pos+2 > buffer.get_size()) {
				grow(2);
			}
			if(buffer != null) {
				var buffer_ptr = buffer.get_pointer();
				if(buffer_ptr != null) {
					buffer_ptr.set_byte(pos, (uint8)((c >> 6) | 0xC0));
					buffer_ptr.set_byte(pos+1, (uint8)((c & 0x3F) | 0x80));
					pos += 2;
				}
			}
		}
		else if(c >= 0x800 && c < 0xFFFF) {
			if(buffer == null || pos+3 > buffer.get_size()) {
				grow(3);
			}
			if(buffer != null) {
				var buffer_ptr = buffer.get_pointer();
				if(buffer_ptr != null) {
					buffer_ptr.set_byte(pos,(uint8)((c >>12) | 0xE0));
					buffer_ptr.set_byte(pos+1,(uint8)(((c >> 6) & 0x3F) | 0x80));
					buffer_ptr.set_byte(pos+2,(uint8)((c & 0x3F) | 0x80));
					pos += 3;
				}
			}
		}
	}

	public String dup_string() {
		var ds = dup() as Stringable;
		return(ds.to_string());
	}

	public String to_string() {
		append_c(0);
		if(buffer != null && buffer.get_size() > pos) {
			buffer.allocate(pos); // shrink to actual size
		}
		var v = String.for_utf8_buffer(buffer);
		((StringImpl)v).set_length(pos - 1);
		clear();
		return(v);
	}
}

