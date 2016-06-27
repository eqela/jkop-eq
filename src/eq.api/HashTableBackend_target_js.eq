
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

class HashTableBackend : HashTableBase
{
	int _count = 0;

	public HashTableBackend() {
		embed "js" {{{
			this.data = {};
		}}}
	}

	public HashTable set(String k, Object v) {
		if(k == null) {
			return(null);
		}
		int c = 0;
		embed "js" {{{
			if(this.data[k.to_strptr()] === undefined) {
				c = 1;
			}
			this.data[k.to_strptr()] = v;
		}}}
		_count = _count + c;
		return(this);
	}

	public Object get(String k) {
		if(k == null) {
			return(null);
		}
		Object v;
		embed "js" {{{
			v = this.data[k.to_strptr()];
			if(v === undefined) {
				v = null;
			}
		}}}
		return(v);
	}

	public void clear() {
		embed "js" {{{
			this.data = {};
		}}}
	}

	public void remove(String k) {
		if(k == null) {
			return;
		}
		int c = 0;
		embed "js" {{{
			if(this.data[k.to_strptr()] !== undefined) {
				c = 1;
			}
			this.data[k.to_strptr()] = null;
		}}}
		_count = _count - c;
	}

	public Iterator iterate_keys() {
		var v = LinkedList.create();
		embed "js" {{{
			for(var i in this.data) {
				v.add(eq.api.StringStatic.for_strptr(i));
			}
		}}}
		return(v.iterate());
	}

	public Iterator iterate_values() {
		var v = LinkedList.create();
		embed "js" {{{
			for(var i in this.data) {
				v.add(this.data[i]);
			}
		}}}
		return(v.iterate());
	}

	public int count() {
		return(_count);
	}

	public bool allocate(int sz) {
		// not supported
		clear();
		return(true);
	}
}

