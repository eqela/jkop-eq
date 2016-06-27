
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
	class HashLinkedList {
		public String key = null;
		public Object v = null;
		public HashLinkedList next = null;
		public static HashLinkedList create(String key, Object v) {
			var r = new HashLinkedList();
			r.key = key;
			r.v = v;
			r.next = null;
			return(r);
		}
	}

	fundamental class IndexList {
		public IndexList next = null;
		public int index = -1;
		public static IndexList create(int i) {
			var r = new IndexList();
			r.index = i;
			return(r);
		}
	}

	private int _count = 0;
	private int _htsize = 0;
	private Array hash_table = null;
	private IndexList indexlist = null;

	public bool allocate(int size) {
		hash_table = new ArrayImpl();
		hash_table.allocate(size);
		_htsize = size;
		return(true);
	}

	public HashTable set(String k, Object v) {
		if(k == null) {
			return(null);
		}
		if(hash_table == null) {
			allocate(1439);
		}
		int hash = (int)(k.hash() % _htsize);
		if(hash < 0) {
			hash *= -1;
		}
		var hll = hash_table.get_index(hash) as HashLinkedList;
		if(hll == null) {
			hash_table.set_index(hash, HashLinkedList.create(k, v));
			var nnil = IndexList.create(hash);
			nnil.next = indexlist;
			indexlist = nnil;
			_count ++;
		}
		else {
			HashLinkedList list = hll;
			while(list != null) {
				if(k.equals(list.key)) {
					list.v = v;
					break;
				}
				else if(list.next == null) {
					list.next = HashLinkedList.create(k, v);
					_count ++;
					break;
				}
				list = list.next;
			}
		}
		return(this);
	}

	public Object get(String k) {
		if(k == null) {
			return(null);
		}
		if(hash_table == null) {
			return(null);
		}
		Object v = null;
		int hash = k.hash() % _htsize;
		if(hash < 0) {
			hash *= -1;
		}
		var list = hash_table.get_index(hash) as HashLinkedList;
		if(list == null) {
			v = null;
		}
		else {
			while(list != null && k.equals(list.key) == false) {
				list = list.next;
			}
			if(list == null) {
				v = null;
			}
			else {
				v = list.v;
			}
		}
		return(v);
	}

	public void clear() {
		hash_table = null;
		indexlist = null;
		_count = 0;
		_htsize = 0;
	}

	// FIXME: This should be optimized
	void remove_indexlist_entry(int hash) {
		IndexList prev;
		var il = indexlist;
		while(il != null) {
			if(il.index == hash) {
				if(prev == null) {
					indexlist = il.next;
				}
				else {
					prev.next = il.next;
				}
				break;
			}
			prev = il;
			il = il.next;
		}
	}

	public void remove(String k) {
		if(k == null || hash_table == null) {
			return;
		}
		int hash = k.hash() % _htsize;
		if(hash < 0) {
			hash *= -1;
		}
		var list = hash_table.get_index(hash) as HashLinkedList;
		HashLinkedList previous_link = null;
		while(list != null) {
			if(k.equals(list.key)) {
				if(previous_link == null) {
					hash_table.set_index(hash, list.next);
					if(list.next == null) {
						remove_indexlist_entry(hash);
					}
				}
				else {
					previous_link.next = list.next;
				}
				_count --;
				break;
			}
			previous_link = list;
			list = list.next;
		}
	}

	class PropertyIterator : Iterator
	{
		private bool values = false;
		private int htindex = -1;
		private int htcount = 0;
		private HashLinkedList list = null;
		private Array hash_table = null;
		private IndexList il = null;

		public static PropertyIterator create(Array hash_table, IndexList indexlist, bool values) {
			var r = new PropertyIterator();
			r.hash_table = hash_table;
			r.values = values;
			if(r.hash_table != null) {
				r.htcount = r.hash_table.count();
			}
			r.il = indexlist;
			r.htindex = -1;
			return(r);
		}

		public Object next() {
			if(hash_table == null) {
				return(null);
			}
			Object v = null;
			while(v == null) {
				if(list != null) {
					if(values) {
						v = list.v;
					}
					else {
						v = list.key;
					}
					list = list.next;
				}
				else {
					if(il != null) {
						htindex = il.index;
						il = il.next;
					}
					else {
						htindex = -1;
					}
					if(htindex >= 0 && htindex < htcount) {
						list = hash_table.get_index(htindex) as HashLinkedList;
					}
					else {
						break;
					}
				}
			}
			return(v);
		}
	}

	public Iterator iterate_keys() {
		return(PropertyIterator.create(hash_table, indexlist, false));
	}

	public Iterator iterate_values() {
		return(PropertyIterator.create(hash_table, indexlist, true));
	}

	public int count() {
		return(_count);
	}
}

