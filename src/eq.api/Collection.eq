
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

public interface Collection : Iterateable
{
	public static bool is_empty(Collection cc) {
		if(cc == null || cc.count() < 1) {
			return(true);
		}
		return(false);
	}

	public int count();
	public bool remove(Object o);
	public void remove_first();
	public void remove_last();
	public Iterator iterate_from_index(int n);
	public Iterator iterate_reverse(int n = -1);
	public Collection append(Object o);
	public Collection prepend(Object o);
	public Collection insert(Object o, int n);
	public Object get(int n);
	public bool set(int n, Object o);
	public void clear();
	public Object get_first();
	public Object get_last();
	// deprecated
	public Collection add(Object o);
	public bool set_index(int n, Object o);
	public Object get_index(int n);
}
