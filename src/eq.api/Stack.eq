
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

public class Stack : Iterateable
{
	public static Stack instance() {
		return(new Stack());
	}

	public static Stack create() {
		return(new Stack());
	}

	LinkedList data = null;

	public Stack() {
		data = LinkedList.create();
	}

	public void push(Object o) {
		data.insert(o, 0);
	}

	public Object pop() {
		var v = data.get_index(0);
		if(v != null) {
			data.remove(v);
		}
		return(v);
	}

	public Object pop_under() {
		Object v = null;
		var lastnode = data.get_last_node();
		if(lastnode != null) {
			v = lastnode.value;
			data.remove_node(lastnode);
		}
		return(v);
	}

	public Object peek() {
		return(data.get_index(0));
	}

	public int count() {
		return(data.count());
	}

	public void clear() {
		data = LinkedList.create();
	}

	public Iterator iterate() {
		return(data.iterate_reverse());
	}
}

