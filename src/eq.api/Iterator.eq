
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

public interface Iterator
{
	public static Iterator duplicate(Iterator i) {
		if(i == null) {
			return(null);
		}
		if(i is Duplicateable) {
			return(((Duplicateable)i).duplicate() as Iterator);
		}
		return(null);
	}

	public static Iterator for_object(Object o) {
		Iterator v = null;
		if(o != null) {
			if(o is Collection) {
				v = ((Collection)o).iterate();
			}
			else if(o is Iterateable) {
				v = ((Iterateable)o).iterate();
			}
			else if(o is String) {
				v = ((String)o).iterate();
			}
			else if(o is Iterator) {
				v = (Iterator)o;
			}
		}
		return(v);
	}

	public Object next();
}

