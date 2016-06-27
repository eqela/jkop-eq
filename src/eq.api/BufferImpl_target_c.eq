
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

class BufferImpl : Buffer, DynamicBuffer
{
	embed "c" {{{
		#include <stdlib.h>
	}}}

	private ptr _buffer = null;
	private int _size = 0;
	private Pointer ptr = null;

	public BufferImpl() {
	}

	~BufferImpl() {
		free();
	}

	public ptr get_ptr() {
		return(_buffer);
	}

	public void set_buffer(ptr buffer, int size) {
		free();
		_buffer = buffer;
		_size = size;
	}

	public Pointer get_pointer() {
		if(ptr == null) {
			ptr = Pointer.create(_buffer);
		}
		return(ptr);
	}

	public int get_size() {
		return(_size);
	}

	public void free() {
		ptr = null;
		if(_buffer != null) {
			var _b = _buffer;
			embed "c" {{{
				free(_b);
			}}}
		}
		_buffer = null;
		_size = 0;
	}

	public bool allocate(int sz) {
		if(sz > 0) {
			var _b = _buffer;
			embed "c" {{{
				_b = realloc(_b, sz);
			}}}
			_buffer = _b;
			if(_b != null) {
				_size = sz;
			}
			else {
				_size = 0;
			}
		}
		else {
			free();
		}
		ptr = null;
		if(_buffer != null || sz < 1) {
			return(true);
		}
		return(false);
	}

	public bool append(int size) {
		int os = _size;
		return(allocate(os + size));
	}
}

