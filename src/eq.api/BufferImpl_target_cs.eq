
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
	embed "cs" {{{
		byte[] buffer = null;
	}}}
	private int sz = 0;
	Pointer _pointer;

	public BufferImpl() {
		_pointer = null;
	}

	public ptr get_ptr() {
		ptr v;
		embed "cs" {{{
			v = buffer;
		}}}
		return(v);
	}

	public Pointer get_pointer() {
		if(_pointer == null) {
			ptr p = null;
			embed "cs" {{{
				p = buffer;
			}}}
			_pointer = PointerImpl.create(p);
		}
		return(_pointer);
	}

	public int get_size() {
		int v = 0;
		embed "cs" {{{
			v = buffer.Length;
		}}}
		return(v);
	}

	public void free() {
		embed "cs" {{{ buffer = null; }}}
		_pointer = null;
		sz = 0;
	}

	public bool allocate(int size) {
		embed "cs" {{{ 
			if(buffer !=null) {
				int sz= this.sz;
				if(size < sz) {
					sz = size;
				}
				var nb = new byte[size];
				if(nb != null) {
					System.Array.Copy(buffer, nb, sz);
				}
				buffer = nb;
				this._pointer = null;
				this.sz = size;
				return(true);
			}
			else {
				buffer = new byte[size];
				if(buffer != null) {
					sz = size;
				}
				this._pointer = null;
			}
		}}}
		if (this.sz == size) {
			return(true);
		}
		return(false);
	}

	public bool append(int size) {
		embed "cs" {{{
			byte[] na = new byte[sz + size];
			if(na != null) {
				System.Array.Copy(buffer, na, sz);
				this.sz = this.sz + size;
				buffer = na;
				this._pointer = null;
				return(true);
			}
		}}}
		return(false);
	}
}

