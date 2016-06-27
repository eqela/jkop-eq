
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
	embed "Java" {{{
		private byte[] buffer = null;
	}}}
	private int sz = 0;
	Pointer _pointer;

	public BufferImpl() {
		_pointer = null;
	}

	public ptr get_ptr() {
		if(_pointer == null) {
			return(null);
		}
		return(_pointer.get_native_pointer());
	}

	public Pointer get_pointer() {
		if(_pointer == null) {
			ptr p = null;
			embed "Java" {{{
				p = buffer;
			}}}
			_pointer = PointerImpl.create(p);
		}
		return(_pointer);
	}

	public int get_size() {
		return(sz);
	}

	public void free() {
		embed "Java" {{{
			buffer = null;
		}}}
		_pointer = null;
		sz = 0;
	}

	public bool allocate(int size) {
		embed "Java" {{{
			if(buffer != null) {
				int sz = this.sz;
				if(size < sz) {
					sz = size;
				}
				byte[] nb = new byte[size];
				if(nb != null) {
					java.lang.System.arraycopy(buffer, 0, nb, 0, sz);
				}
				this.buffer = nb;
				this.sz = size;
				if(this._pointer != null) {
					((PointerImpl)this._pointer).pointer = this.buffer;
				}
				return(true);
			}
			else {
				buffer = new byte[size];
				if(buffer != null) {
					sz = size;
				}
				if(this._pointer != null) {
					((PointerImpl)this._pointer).pointer = this.buffer;
				}
			}
		}}}
		if(this.sz == size) {
			return(true);
		}
		return(false);
	}

	public bool append(int size) {
		embed "Java" {{{
			byte[] na = new byte[this.sz + size];
			if(na != null) {
				java.lang.System.arraycopy(buffer, 0, na, 0, this.sz);
				this.sz = this.sz + size;
				this.buffer = na;
				if(this._pointer != null) {
					((PointerImpl)this._pointer).pointer = this.buffer;
				}
				return(true);
			}
		}}}
		return(false);
	}
}

