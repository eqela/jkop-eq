
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

IFNDEF("target_j2me") {
	class ArrayImpl : ArrayBase
	{
		embed "Java" {{{
			private java.util.Vector<java.lang.Object> vector = null;
		}}}

		public ArrayImpl() {
			embed "Java" {{{ vector = new java.util.Vector<java.lang.Object>(); }}}
		}

		public void clear() {
			embed "Java" {{{ vector.clear(); }}}
		}

		public bool allocate(int size) {
			embed "Java" {{{ vector.setSize(size); }}}
			return(true);
		}

		public int count() {
			int v = 0;
			embed "Java" {{{ v = vector.size(); }}}
			return(v);
		}

		public Object get_index(int n) {
			if(n >= 0 && n < count()) {
				embed "Java" {{{
					java.lang.Object o = vector.elementAt(n);
					if(o != null && o instanceof eq.api.Object) {
						return((eq.api.Object)o);
					}
				}}}
			}
			return(null);
		}

		public bool set_index(int n, Object o) {
			if(n >= 0 && n < count()) {
				embed "Java" {{{
					vector.setElementAt(o, n);
				}}}
				return(true);
			}
			return(false);
		}

		public Collection add(Object o) {
			embed "Java" {{{ vector.add(o); }}}
			return(this);
		}

		public Collection insert(Object o, int i) {
			if (i >= 0 && i <= count()) {
				embed "Java" {{{ vector.insertElementAt(o, i); }}}
			}
			return(this);
		}

		public bool remove(Object o) {
			bool v = false;
			embed "Java" {{{ v = vector.remove(o); }}}
			return(v);
		}

		public void remove_index(int index) {
			embed "java" {{{
				vector.removeElementAt(index);
			}}}
		}

		public void remove_range(int first, int last) {
			int n = last-first+1, x;
			for(x=0; x<n; x++) {
				embed "java" {{{
					vector.removeElementAt(first);
				}}}
			}
		}
	}
}

