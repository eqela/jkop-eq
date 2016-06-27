
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

public class IntegerArray
{
	public static IntegerArray create() {
		return(new IntegerArray());
	}

	Array array;

	public IntegerArray() {
		clear();
	}

	public void clear() {
		array = Array.create();
	}

	public int get_index(int n, int def = 0) {
		var o = array.get_index(n) as Integer;
		if(o == null) {
			return(def);
		}
		return(o.to_integer());
	}

	public IntegerArray set_index(int n, int v) {
		array.set_index(n, v);
		return(this);
	}

	public IntegerArray add(int v) {
		array.add(v);
		return(this);
	}

	public int count() {
		return(array.count());
	}

	public IntegerArray set_size(int n) {
		array.allocate(n);
		return(this);
	}
}
