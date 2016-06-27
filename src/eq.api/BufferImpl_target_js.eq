
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
	private ptr buf = null;

	public BufferImpl() {
		ptr buf;
		embed "js" {{{
			buf = [];
		}}}
		this.buf = buf;
	}

	public Pointer get_pointer() {
		return(PointerImpl.create(buf));
	}

	public int get_size() {
		int v;
		var buf = this.buf;
		embed "js" {{{
			v = buf.length;
		}}}
		return(v);
	}

	public void free() {
		ptr buf;
		embed "js" {{{
			buf = [];
		}}}
		this.buf = buf;
	}

	public bool allocate(int sz) {
		var buf = this.buf;
		embed "js" {{{
			if(buf.length < sz) {
				buf[sz-1] = 0;
			}
			else if(buf.length > sz) {
				buf.splice(sz, buf.length - sz);
			}
		}}}
		return(true);
	}

	public bool append(int size) {
		var buf = this.buf;
		embed "js" {{{
			this.allocate(buf.length + size);
		}}}
		return(true);
	}
}

