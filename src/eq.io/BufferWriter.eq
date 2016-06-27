
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

public class BufferWriter : Writer
{
	public static BufferWriter create() {
		return(BufferWriter.for_buffer(null));
	}

	public static BufferWriter for_buffer(Buffer buf) {
		var v = new BufferWriter();
		v.buffer = buf;
		if(v.buffer == null) {
			v.buffer = DynamicBuffer.create();
		}
		v.pos = 0;
		return(v);
	}

	Buffer buffer = null;
	int pos = 0;

	public int get_buffer_size() {
		if(buffer != null) {
			return(buffer.get_size());
		}
		return(0);
	}

	public int get_buffer_pos() {
		return(pos);
	}

	public Buffer get_buffer() {
		return(buffer);
	}

	public int write(Buffer src, int ssize) {
		if(buffer == null || src == null) {
			return(0);
		}
		var size = ssize;
		if(size < 0) {
			size = src.get_size();
		}
		if(buffer is DynamicBuffer) {
			if(pos + size > buffer.get_size()) {
				int appended_size = (size + pos) - buffer.get_size();
				var appended_buf = ((DynamicBuffer)buffer).append(appended_size);
				if(appended_buf == false) {
					return(0);
				}
			}
			var srcptr = src.get_pointer();
			var dstptr = buffer.get_pointer();
			if(srcptr!=null && dstptr!=null) {
				dstptr.cpyfrom(srcptr, 0, pos, size);
			}
			pos += size;
			return(size);
		}
		if(buffer.get_size() > pos) {
			if(buffer.get_size() < size + pos) {
				size = buffer.get_size() - pos;
				var srcptr = src.get_pointer();
				var dstptr = buffer.get_pointer();
				if(srcptr!=null && dstptr!=null) {
					dstptr.cpyfrom(srcptr, 0, pos, size);
				}
				pos += size;
				return(0);
			}
			else {
				var srcptr = src.get_pointer();
				var dstptr = buffer.get_pointer();
				if(srcptr!=null && dstptr!=null) {
					dstptr.cpyfrom(srcptr, 0, pos, size);
				}
				pos += size;
				return(size);
			}
		}
		return(0);
	}
}

