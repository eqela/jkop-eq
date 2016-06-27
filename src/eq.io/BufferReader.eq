
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

public class BufferReader : Reader, SizedReader, Seekable
{
	public static BufferReader for_buffer(Buffer buf) {
		return(new BufferReader().set_buffer(buf));
	}

	Buffer buffer = null;
	property int pos = 0;

	public bool seek_set(int n) {
		pos = n;
		return(true);
	}

	public int seek_current() {
		return(pos);
	}

	public Buffer get_buffer() {
		return(buffer);
	}

	public BufferReader set_buffer(Buffer buf) {
		this.buffer = buf;
		pos = 0;
		return(this);
	}

	public void rewind() {
		pos = 0;
	}

	public int get_size() {
		if(buffer == null) {
			return(0);
		}
		return(buffer.get_size());
	}

	public int read(Buffer buf) {
		int v = 0;
		if(buffer != null && buf != null) {
			var srcptr = buffer.get_pointer();
			var dstptr = buf.get_pointer();
			if(srcptr != null && dstptr != null && pos < buffer.get_size()){
				int size = buf.get_size();
				if(size > buffer.get_size() - pos) {
					size = buffer.get_size() - pos;
				}
				dstptr.cpyfrom(srcptr, pos, 0, size);
				pos += size;
				v = size;
			}
		}
		return(v);
	}
}
