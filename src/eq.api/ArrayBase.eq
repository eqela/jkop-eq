
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

public class ArrayBase : Collection, Array, Iterateable
{
	public void clear() {
	}

	public bool allocate(int size) {
		return(false);
	}

	public int count() {
		return(0);
	}

	public Object get_index(int n) {
		return(null);
	}

	public Object get_first() {
		return(get_index(0));
	}

	public Object get_last() {
		var cc = count();
		if(cc < 1) {
			return(null);
		}
		return(get_index(cc-1));
	}

	public Object get(int n) {
		return(get_index(n));
	}

	public bool set_index(int n, Object o) {
		return(false);
	}

	public bool set(int n, Object o) {
		return(set_index(n, o));
	}

	/*
	#public Array add($string str) {
		return(add(String.for_strptr(str)));
	}
	*/

	public Collection add(Object o) {
		return(this);
	}

	public Collection insert(Object o, int i) {
		return(this);
	}

	public Collection append(Object o) {
		return(add(o));
	}

	public Collection prepend(Object o) {
		insert(o, 0);
		return(this);
	}

	public bool remove(Object o) {
		return(false);
	}

	public void remove_index(int index) {
	}

	public void remove_first() {
		remove_index(0);
	}

	public void remove_last() {
		remove_index(count()-1);
	}

	public void remove_range(int first, int last) {
	}

	public Iterator iterate_from_index(int n) {
		return(ArrayIterator.create(this, n));
	}

	public Iterator iterate() {
		return(iterate_from_index(0));
	}

	public Iterator iterate_reverse(int n) {
		return(ReverseArrayIterator.create(this, n));
	}
}
