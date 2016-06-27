
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
	public static PointerImpl create(ptr pointer) {
		var v = new PointerImpl();
		v.pointer = pointer;
		v.idx = 0;
		return(v);
	}

	public ptr pointer = null;
	public int idx = 0;

	public Pointer move(int n) {
		var v = new PointerImpl();
		v.pointer = pointer;
		v.idx = idx + n;
		return(v);
	}

	public bool cpyfrom(Pointer src, int soffset, int doffset, int size) {
		if(src == null) {
			return(false);
		}
		var sptr = src.get_native_pointer();
		if(sptr == null) {
			return(false);
		}
		bool v = true;
		int sn = ((PointerImpl)src).idx + soffset, dn = idx + doffset, n = 0;
		while(n < size) {
			embed "Java" {{{
				try {
					pointer[dn] = sptr[sn];
				}
				catch(Exception e) {
					v = false;
				}
			}}}
			sn ++;
			dn ++;
			n ++;
		}
		return(v);
	}

	public void set_byte(int n, uint8 bt) {
		embed "Java" {{{
			try {
				pointer[n] = bt;
			}
			catch(Exception e) {
			}
		}}}
	}

	public void set_range(int val, int size) {
		//FIXME: TBI
	}

	public uint8 get_byte(int n) {
		uint8 v = 0;
		embed "Java" {{{
			try {
				v = pointer[n];
			}
			catch(Exception e) {
			}
		}}}
		return(v);
	}

	public int get_current_index() {
		return(idx);
	}

	public ptr get_native_pointer() {
		return(pointer);
	}
}

