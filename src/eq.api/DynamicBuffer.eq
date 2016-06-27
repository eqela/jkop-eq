
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

public interface DynamicBuffer : Buffer
{
	public static DynamicBuffer create(int size = 0) {
		var v = new BufferImpl();
		if(v.allocate(size) == false) {
			v = null;
		}
		return(v);
	}

	public static DynamicBuffer for_size(int size) {
		return(DynamicBuffer.create(size));
	}

	public static DynamicBuffer for_buffer(Buffer src) {
		var v = new BufferImpl();
		if(DynamicBuffer.cat(v, src) == false) {
			v = null;
		}
		return(v);
	}

	public static bool cat(DynamicBuffer dest, Buffer src, int asz = -1) {
		if(dest == null || src == null) {
			return(false);
		}
		var sz = asz;
		var srcsz = src.get_size();
		if(srcsz < 1) {
			return(true);
		}
		if(sz < 0 || sz > srcsz) {
			sz = srcsz;
		}
		var sptr = src.get_pointer();
		if(sptr == null) {
			return(false);
		}
		int ord = dest.get_size();
		if(dest.append(sz) == false) {
			return(false);
		}
		var dptr = dest.get_pointer();
		if(dptr == null) {
			return(false);
		}
		return(dptr.cpyfrom(sptr, 0, ord, sz));
	}

	public static bool cat_byte(DynamicBuffer dest, int bb) {
		if(dest == null) {
			return(false);
		}
		int ord = dest.get_size();
		if(dest.append(1) == false) {
			return(false);
		}
		var dptr = dest.get_pointer();
		if(dptr == null) {
			return(false);
		}
		dptr.set_byte(ord, bb);
		return(true);
	}

	public void free();
	public bool append(int size);
	public bool allocate(int size);
}

