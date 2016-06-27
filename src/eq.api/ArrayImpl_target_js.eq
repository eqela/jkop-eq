
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

class ArrayImpl : ArrayBase
{
	public ArrayImpl() {
		embed "js" {{{
			this.array = new Array();
		}}}
	}

	public void clear() {
		embed "js" {{{
			this.array = new Array();
		}}}
	}

	public bool allocate(int size) {
		embed "js" {{{
			while(this.array.length < size) {
				this.array.push(null);
			}
		}}}
		return(true);
	}

	public int count() {
		int v;
		embed "js" {{{
			v = this.array.length;
		}}}
		return(v);
	}

	public Object get_index(int n) {
		Object v = null;
		embed "js" {{{
			if(n >= 0 && n < this.array.length) {
				v = this.array[n];
			}
		}}}
		return(v);
	}

	public bool set_index(int n, Object o) {
		bool v = false;
		embed "js" {{{
			if(n >= 0 && n < this.array.length) {
				this.array[n] = o;
			}
		}}}
		return(v);
	}

	public Collection add(Object o) {
		embed "js" {{{
			this.array.push(o);
		}}}
		return(this);
	}

	public Collection insert(Object o, int i) {
		if (i >= 0 && i <= count()) {
			embed "js" {{{
				this.array.splice(i, 0, o);
			}}}
		}
		return(this);
	}

	public bool remove(Object o) {
		bool v = false;
		int n = 0, idx = -1;
		for(n=0; n<count(); n++) {
			if(get_index(n) == o) {
				idx = n;
				break;
			}
		}
		if(idx >= 0) {
			embed "js" {{{
				this.array.splice(idx, 1);
			}}}
			v = true;
		}
		return(v);
	}

	public void remove_index(int index) {
		embed "js" {{{
			this.array.splice(index, 1);
		}}}
	}

	public void remove_range(int first, int last) {
		embed "js" {{{
			this.array.splice(first, last-first+1);
		}}}
	}
}
