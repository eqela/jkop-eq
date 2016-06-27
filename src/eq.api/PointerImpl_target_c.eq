
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

class PointerImpl : Pointer
{
	embed "c" {{{
		#include <string.h>
	}}}

	public ptr pointer;
	int idx;

	public static PointerImpl create(ptr pointer) {
		var r = new PointerImpl();
		r.pointer = pointer;
		return(r);
	}

	public Pointer move(int n) {
		ptr pp = pointer;
		embed "c" {{{
			pp = (void*)(pp + n);
		}}}
		var v = PointerImpl.create(pp);
		v.idx = idx + n;
		return(v);
	}

	public int get_current_index() {
		return(idx);
	}

	public void set_range(int val, int size) {
		var pointer = this.pointer;
		embed "c" {{{
			memset(pointer, val, size);
		}}}
	}

	public bool cpyfrom(Pointer src, int soffset, int doffset, int size) {
		var pointer = this.pointer;
		var sp = src.get_native_pointer();
		embed "c" {{{
			memcpy((void*)(pointer+doffset), (void*)(sp+soffset), size);
		}}}
		return(true);
	}

	public void set_byte(int n, uint8 byte) {
		var pointer = this.pointer;
		embed "c" {{{
			*((unsigned char*)(pointer+n)) = byte;
		}}}
	}

	public uint8 get_byte(int n) {
		uint8 v = 0;
		var p = pointer;
		embed "c" {{{
			v = *((unsigned char*)(p + n));
		}}}
		return(v);
	}

	public ptr get_native_pointer() {
		return(pointer);
	}
}

