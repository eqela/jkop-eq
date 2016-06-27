
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

public interface Array : Collection
{
	public static bool is_empty(Array array) {
		if(array == null || array.count() < 1) {
			return(true);
		}
		return(false);
	}

	public static Array for_iterator(Iterator it) {
		Array v = Array.create();
		foreach(var o in it) {
			v.add(o);
		}
		return(v);
	}

	public static Array create(int n = 0) {
		ArrayImpl v = new ArrayImpl();
		if(n > 0) {
			if(v.allocate(n) == false) {
				v = null;
			}
		}
		return(v);
	}

	public static Array dup(Collection a) {
		var v = new ArrayImpl();
		if(a != null) {
			int n;
			int m = a.count();
			for(n=0; n<m; n++) {
				v.append(a.get(n));
			}
		}
		return(v);
	}

	/*
		public Array add($string str);
	*/

	public bool allocate(int size);
	public void remove_index(int index);
	public void remove_range(int first, int last);
}