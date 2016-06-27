
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
class HashTableBackend : HashTableBase
{
	embed {{{
		java.util.HashMap<java.lang.String, eq.api.Object> table = new java.util.HashMap<java.lang.String, eq.api.Object>();
	}}}

	public HashTable set(String k, Object v) {
		if(k == null) {
			return(this);
		}
		var ks = k.to_strptr();
		if(ks == null) {
			return(this);
		}
		embed {{{
			table.put(ks, v);
		}}}
		return(this);
	}

	public Object get(String k) {
		if(k == null) {
			return(null);
		}
		var ks = k.to_strptr();
		if(ks == null) {
			return(null);
		}
		Object v;
		embed {{{
			v = table.get(ks);
		}}}
		return(v);
	}

	class ObjectIteratorWrapper : Iterator
	{
		embed {{{
			public java.util.Iterator<eq.api.Object> jit;
		}}}
		public Object next() {
			Object v;
			embed {{{
				try {
					v = jit.next();
				}
				catch(Exception e) {
					v = null;
				}
			}}}
			return(v);
		}
	}

	public Iterator iterate_values() {
		var v = new ObjectIteratorWrapper();
		embed {{{
			java.util.Collection<eq.api.Object> values = table.values();
			if(values == null) {
				return(null);
			}
			v.jit = values.iterator();
		}}}
		return(v);
	}

	class StringIteratorWrapper : Iterator
	{
		embed {{{
			public java.util.Iterator<java.lang.String> jit;
		}}}
		public Object next() {
			strptr v;
			embed {{{
				try {
					v = jit.next();
				}
				catch(Exception e) {
					v = null;
				}
			}}}
			if(v != null) {
				return(String.for_strptr(v));
			}
			return(null);
		}
	}

	public Iterator iterate_keys() {
		var v = new StringIteratorWrapper();
		embed {{{
			java.util.Set<java.lang.String> keys = table.keySet();
			if(keys == null) {
				return(null);
			}
			v.jit = keys.iterator();
		}}}
		return(v);
	}

	public void remove(String k) {
		if(k == null) {
			return;
		}
		var ks = k.to_strptr();
		if(ks == null) {
			return;
		}
		embed {{{
			table.remove(ks);
		}}}
	}

	public void clear() {
		embed {{{
			table.clear();
		}}}
	}

	public int count() {
		int v = 0;
		embed {{{
			v = table.size();
		}}}
		return(v);
	}
}
}
