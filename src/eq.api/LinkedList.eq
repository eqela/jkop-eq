
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

public class LinkedList : Collection, Iterateable
{
	public static LinkedList for_iterator(Iterator it) {
		var v = LinkedList.create();
		foreach(var o in it) {
			v.add(o);
		}
		return(v);
	}

	class LinkedListIterator : Iterator, Duplicateable
	{
		LinkedList l = null;
		LinkedListNode current = null;

		public Object duplicate() {
			var v = new LinkedListIterator();
			v.l = l;
			v.current = current;
			return(v);
		}

		public static LinkedListIterator create(LinkedList l, int n) {
			var v = new LinkedListIterator();
			v.l = l;
			if(l != null) {
				v.current = l.get_first_node();
			}
			int i;
			for(i = 0; i<n; i++) {
				if(v.next() == null) {
					break;
				}
			}
			return(v);
		}

		public Object next() {
			Object v = null;
			if(current != null) {
				v = current.get_node_value();
				current = current.next;
			}
			return(v);
		}
	}

	class ReverseIterator : Iterator, Duplicateable
	{
		LinkedList l = null;
		LinkedListNode current = null;

		public Object duplicate() {
			var v = new ReverseIterator();
			v.l = l;
			v.current = current;
			return(v);
		}

		public static ReverseIterator create(LinkedList l, int n) {
			var v = new ReverseIterator();
			v.l = l;
			if(l != null) {
				v.current = l.get_last_node();
			}
			int i;
			for(i = 0; i<n; i++) {
				if(v.next() == null) {
					break;
				}
			}
			return(v);
		}

		public Object next() {
			Object v = null;
			if(current != null) {
				v = current.get_node_value();
				current = current.prev;
			}
			return(v);
		}
	}

	public static LinkedList create() {
		return(new LinkedList());
	}

	public static LinkedList dup(Collection a) {
		var v = new LinkedList();
		foreach(var o in a) {
			v.add(o);
		}
		return(v);
	}

	LinkedListNode first = null;
	LinkedListNode last = null;
	int _count = 0;

	public LinkedList() {
	}

	~LinkedList() {
		clear();
	}

	public void clear() {
		while(first != null) {
			first.prev = null;
			var cc = first;
			first = first.next;
			cc.next = null;
			_count --;
		}
		last = null;
		_count = 0;
	}

	public LinkedListNode get_first_node() {
		return(first);
	}

	public LinkedListNode get_last_node() {
		return(last);
	}

	public Object get_first() {
		var lln = get_first_node();
		if(lln == null) {
			return(null);
		}
		return(lln.get_node_value());
	}

	public Object get_last() {
		var lln = get_last_node();
		if(lln == null) {
			return(null);
		}
		return(lln.get_node_value());
	}

	public int count() {
		return(_count);
	}

	public LinkedListNode get_node(int n) {
		LinkedListNode v = null;
		if(n >= 0 && n < _count) {
			int c = 0;
			LinkedListNode node = first;
			while(node != null) {
				if(c == n) {
					v = node;
					break;
				}
				node = node.next;
				c++;
			}
		}
		return(v);
	}

	public Object get(int n) {
		return(get_index(n));
	}

	public Object get_index(int n) {
		var node = get_node(n);
		if(node != null) {
			return(node.get_node_value());
		}
		return(null);
	}

	public bool set(int n, Object o) {
		return(set_index(n, o));
	}

	public bool set_index(int n, Object o) {
		bool v = false;
		if(n >= 0 && n < _count) {
			int c = 0;
			LinkedListNode node = first;
			LinkedListNode prev = null;
			while(node != null) {
				if(c == n) {
					node.value = o;
					v = true;
					break;
				}
				prev = node;
				node = node.next;
				c++;
			}
		}
		return(v);
	}

	public Collection add_node(LinkedListNode tba) {
		if(tba == null) {
			return(this);
		}
		tba.next = null;
		if(last != null) {
			tba.prev = last;
			last.next = tba;
			last = tba;
		}
		else {
			first = tba;
			last = tba;
			tba.next = null;
			tba.prev = null;
		}
		_count ++;
		return(this);
	}

	public Collection add(Object o) {
		return(add_node(LinkedListNode.create(o)));
	}

	public Collection append(Object o) {
		return(add(o));
	}

	public Collection prepend(Object o) {
		insert(o, 0);
		return(this);
	}

	public Collection insert_node(LinkedListNode tba, int n) {
		if(tba == null) {
			return(this);
		}
		if(first == null) {
			add_node(tba);
		}
		else if(n == 0) {
			if(first != null) {
				first.prev = tba;
			}
			tba.next = first;
			tba.prev = null;
			first = tba;
			_count ++;
		}
		else {
			var node = get_node(n-1);
			if(node == null) {
				add_node(tba);
			}
			else {
				tba.next = node.next;
				if(tba.next != null) {
					tba.next.prev = tba;
				}
				tba.prev = node;
				node.next = tba;
				if(last == node) {
					last = tba;
				}
				_count ++;
			}
		}
		return(this);
	}

	public Collection insert(Object o, int n) {
		return(insert_node(LinkedListNode.create(o), n));
	}

	public bool insert_node_before(LinkedListNode orig, LinkedListNode nn) {
		if(orig == null || nn == null) {
			return(false);
		}
		nn.prev = orig.prev;
		nn.next = orig;
		if(orig.prev != null) {
			orig.prev.next = nn;
		}
		orig.prev = nn;
		if(first == orig) {
			first = nn;
		}
		_count ++;
		return(true);
	}

	public bool insert_before(LinkedListNode orig, Object o) {
		return(insert_node_before(orig, LinkedListNode.create(o)));
	}

	public bool insert_node_after(LinkedListNode orig, LinkedListNode nn) {
		if(orig == null || nn == null) {
			return(false);
		}
		nn.prev = orig;
		nn.next = orig.next;
		if(orig.next != null) {
			orig.next.prev = nn;
		}
		orig.next = nn;
		if(last == orig) {
			last = nn;
		}
		_count ++;
		return(true);
	}

	public bool insert_after(LinkedListNode orig, Object o) {
		return(insert_node_after(orig, LinkedListNode.create(o)));
	}

	public bool remove_node(LinkedListNode nn) {
		if(nn == null) {
			return(false);
		}
		if(nn.prev != null) {
			nn.prev.next = nn.next;
		}
		if(nn.next != null) {
			nn.next.prev = nn.prev;
		}
		if(nn == first) {
			first = nn.next;
		}
		if(nn == last) {
			last = nn.prev;
		}
		nn.prev = null;
		nn.next = null;
		_count --;
		return(true);
	}

	public LinkedListNode find_node(Object o) {
		var cc = first;
		while(cc != null) {
			if(cc.value == o) {
				return(cc);
			}
			cc = cc.next;
		}
		return(null);
	}

	public bool remove(Object o) {
		var nn = find_node(o);
		if(nn == null) {
			return(false);
		}
		return(remove_node(nn));
	}

	public void remove_first() {
		remove_node(get_first_node());
	}

	public void remove_last() {
		remove_node(get_last_node());
	}

	public Iterator iterate_from_index(int n) {
		return(LinkedListIterator.create(this, n));
	}

	public Iterator iterate() {
		return(iterate_from_index(0));
	}

	public Iterator iterate_reverse(int n = -1) {
		return(ReverseIterator.create(this, n));
	}
}
