
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

public class PropertyObject : Object
{
	HashTableBackend hash_table = null;

	private void init_hash_table() {
		hash_table = new HashTableBackend();
		hash_table.allocate(179);
	}

	public virtual bool set_property(String key, Object val) {
		return(false);
	}

	public virtual PropertyObject set(String k, Object v) {
		if(k == null) {
			return(this);
		}
		if(set_property(k, v)) {
			return(this);
		}
		if(hash_table == null) {
			init_hash_table();
		}
		hash_table.set(k, v);
		on_property_changed(k, v);
		return(this);
	}

	public virtual void on_property_changed(String key, Object val) {
	}

	public PropertyObject set_add(String k, Object o) {
		var c = get(k);
		if(c != null && c is Collection == false) {
			var col = LinkedList.create();
			col.add(c);
			col.add(o);
			set(k, col);
		}
		else {
			Collection col = (Collection)c;
			if(col == null) {
				col = LinkedList.create();
				set(k, col);
			}
			col.add(o);
		}
		return(this);
	}

	public PropertyObject set_int(String k, int v) {
		return(set(k, Primitive.for_integer(v)));
	}

	public PropertyObject set_bool(String k, bool v) {
		return(set(k, Primitive.for_boolean(v)));
	}

	public PropertyObject set_double(String k, double v) {
		return(set(k, Primitive.for_double(v)));
	}

	public virtual Object get_property(String key) {
		return(null);
	}

	public virtual Object get(String k, Object def = null) {
		if(k == null) {
			return(def);
		}
		Object v = null;
		var r = get_property(k);
		if(r !=  null) {
			return(r);
		}
		if(hash_table != null) {
			v = hash_table.get(k);
		}
		if(v == null) {
			v = def;
		}
		return(v);
	}

	public String get_string(String k, String def = null) {
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

	public int get_int(String k, int def = 0) {
		int v = def;
		var vo = get(k) as Integer;
		if(vo != null) {
			v = vo.to_integer();
		}
		return(v);
	}

	public bool get_bool(String k, bool def = false) {
		bool v = def;
		var vo = get(k) as Boolean;
		if(vo != null) {
			v = vo.to_boolean();
		}
		return(v);
	}

	public double get_double(String k, double def = 0.0) {
		double v = def;
		var vo = get(k) as Double;
		if(vo != null) {
			v = vo.to_double();
		}
		return(v);
	}

	public void clear_properties() {
		hash_table = null;
	}

	public int property_count() {
		if(hash_table == null) {
			return(0);
		}
		return(hash_table.count());
	}

	public void remove_property(String k) {
		if(k == null || hash_table == null) {
			return;
		}
		hash_table.remove(k);
	}

	public Iterator iterate_property_keys() {
		if(hash_table == null) {
			init_hash_table();
		}
		return(hash_table.iterate_keys());
	}

	public Iterator iterate_property_values() {
		if(hash_table == null) {
			init_hash_table();
		}
		return(hash_table.iterate_values());
	}

	public PropertyObject copy_properties_from(Object o) {
		if(o == null) {
			;
		}
		else if(o is PropertyObject) {
			var it = ((PropertyObject)o).iterate_property_keys();
			while(it != null) {
				var k = it.next() as String;
				if(k == null) {
					break;
				}
				set(k, ((PropertyObject)o).get(k));
			}
		}
		else if(o is HashTable) {
			var it = ((HashTable)o).iterate_keys();
			while(it != null) {
				var k = it.next() as String;
				if(k == null) {
					break;
				}
				set(k, ((HashTable)o).get(k));
			}
		}
		return(this);
	}
}

