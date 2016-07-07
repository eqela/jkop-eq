
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

class HashTableBase : HashTable, Iterateable
{
	public virtual HashTable dup() {
		var v = new HashTableBackend();
		foreach(String key in this) {
			v.set(key, get(key));
		}
		return(v);
	}

	public virtual bool allocate(int size) {
		return(false);
	}

	public virtual HashTable set(String k, Object v) {
		return(null);
	}

	public virtual HashTable set_strptr(strptr k, strptr v) {
		return(set(String.for_strptr(k), String.for_strptr(v)));
	}

	public virtual HashTable set_int(String k, int v) {
		return(set(k, Primitive.for_integer(v)));
	}

	public virtual HashTable set_bool(String k, bool v) {
		return(set(k, Primitive.for_boolean(v)));
	}

	public virtual HashTable set_double(String k, double v) {
		return(set(k, Primitive.for_double(v)));
	}

	public virtual Object get(String k) {
		return(null);
	}

	public virtual String get_string(String k, String def = null) {
		String v = null;
		var vo = get(k);
		if(vo != null) {
			var vos = vo as String;
			if(vos != null) {
				v = vos;
			}
			else {
				var voss = vo as Stringable;
				if(voss != null) {
					v = voss.to_string();
				}
			}
		}
		if(v == null) {
			v = def;
		}
		return(v);
	}

	public virtual int get_int(String k, int def = 0) {
		int v = def;
		var vo = get(k) as Integer;
		if(vo != null && vo is String) {
			if(String.is_empty(vo)) {
				return(def);
			}
		}
		if(vo != null) {
			v = vo.to_integer();
		}
		return(v);
	}

	public virtual bool get_bool(String k, bool def = false) {
		bool v = def;
		var vo = get(k) as Boolean;
		if(vo != null && vo is String) {
			if(String.is_empty(vo)) {
				return(def);
			}
		}
		if(vo != null) {
			v = vo.to_boolean();
		}
		return(v);
	}

	public virtual double get_double(String k, double def = 0.0) {
		double v = def;
		var vo = get(k) as Double;
		if(vo != null && vo is String) {
			if(String.is_empty(vo)) {
				return(def);
			}
		}
		if(vo != null) {
			v = vo.to_double();
		}
		return(v);
	}

	public virtual Iterator iterate_values() {
		return(null);
	}

	public virtual Iterator iterate_keys() {
		return(null);
	}

	public virtual Iterator iterate() {
		return(iterate_keys());
	}

	public virtual void remove(String k) {
	}

	public virtual void clear() {
	}

	public virtual int count() {
		return(0);
	}
}
