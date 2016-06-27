
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

public class KeyValueList : Iterateable
{
	Collection list;

	public KeyValueList() {
		list = LinkedList.create();
	}

	public Iterator iterate() {
		return(list.iterate());
	}

	public KeyValueList prepend(String key, Object value) {
		list.prepend(new KeyValuePair().set_key(key).set_value(value));
		return(this);
	}

	public KeyValueList append(String key, Object value) {
		list.append(new KeyValuePair().set_key(key).set_value(value));
		return(this);
	}

	public KeyValueList append_pair(KeyValuePair pair) {
		if(pair == null) {
			return(this);
		}
		return(append(pair.get_key(), pair.get_value()));
	}

	public KeyValueList set(String key, Object value) {
		if(key == null) {
			return(null);
		}
		foreach(KeyValuePair kvp in iterate()) {
			if(key.equals(kvp.get_key())) {
				kvp.set_value(value);
				return(this);
			}
		}
		return(append(key, value));
	}

	public Object get(String key) {
		if(key == null) {
			return(null);
		}
		Object v;
		foreach(KeyValuePair kvp in iterate()) {
			if(key.equals(kvp.get_key())) {
				v = kvp.get_value();
			}
		}
		return(v);
	}

	public String get_string(String key) {
		return(String.as_string(get(key)));
	}

	public int get_int(String key, int def = 0) {
		return(Integer.as_integer(get(key), def));
	}

	public bool get_bool(String key, bool def = false) {
		return(Boolean.as_boolean(get(key), def));
	}

	public double get_double(String key, double def = 0.0) {
		return(Double.as_double(get(key), def));
	}

	public Collection get_values(String key) {
		var v = LinkedList.create();
		if(key == null) {
			return(v);
		}
		foreach(KeyValuePair kvp in iterate()) {
			if(key.equals(kvp.get_key())) {
				v.append(kvp.get_value());
			}
		}
		return(v);
	}

	public HashTable as_hash_table() {
		var v = HashTable.create();
		foreach(KeyValuePair kvp in iterate()) {
			var key = kvp.get_key();
			if(key != null) {
				v.set(key, kvp.get_value());
			}
		}
		return(v);
	}
}
