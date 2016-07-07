
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
	embed "cs" {{{
		System.Collections.Generic.List<object> list = null;
	}}}

	public ArrayImpl() {
		embed "cs" {{{
			list = new System.Collections.Generic.List<object>();
		}}}
	}

	public override void clear() {
		embed "cs" {{{
			list.Clear();
		}}}
	}

	public override bool allocate(int size) {
		embed "cs" {{{
			if(list.Count < size) {
				while(list.Count < size) {
					list.Add(null);
				}
			}
			else {
				list = list.GetRange(0, size);
			}
		}}}
		return(true);
	}

	public override int count() {
		int v = 0;
		embed "cs" {{{ v = list.Count; }}}
		return(v);
	}

	public override Object get_index(int n) {
		if(n >= 0 && n < count()) {
			embed "cs" {{{
				return(list[n] as eq.api.Object);
			}}}
		}
		return(null);
	}

	public override bool set_index(int n, Object o) {
		if(n >= 0 && n < count()) {
			embed "cs" {{{ list[n] = o; }}}
			return(true);
		}
		return(false);
	}

	public override Collection add(Object o) {
		embed "cs" {{{ list.Add(o); }}}
		return(this);
	}

	public override Collection insert(Object o, int i) {
		if(i >= 0 && i <= count()) {
			embed "cs" {{{ list.Insert(i, o); }}}
		}
		return(this);
	}

	public override void remove_index(int n) {
		if(n < 0 || n >= count()) {
			return;
		}
		embed "cs" {{{ list.RemoveAt(n); }}}
	}

	public override void remove_range(int first, int last) {
		if(last < first || last < 0 || first >= count()) {
			return;
		}
		var c = last - first +1;
		embed "cs" {{{ list.RemoveRange(first, c); }}}
	}

	public override bool remove(Object o) {
		bool v = false;
		embed "cs" {{{ v = list.Remove(o); }}}
		return(v);
	}
}

