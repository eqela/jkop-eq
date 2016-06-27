
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

public interface HashTable : Iterateable
{
	public static HashTable create() {
		return(new HashTableBackend());
	}

	public HashTable dup();
	public bool allocate(int size);
	public HashTable set(String k, Object v);
	public HashTable set_strptr(strptr k, strptr v);
	public HashTable set_int(String k, int v);
	public HashTable set_bool(String k, bool v);
	public HashTable set_double(String k, double v);
	public Object get(String k);
	public String get_string(String k, String def = null);
	public int get_int(String k, int def = 0);
	public bool get_bool(String k, bool def = false);
	public double get_double(String k, double def = 0.0);
	public Iterator iterate_values();
	public Iterator iterate_keys();
	public void remove(String k);
	public void clear();
	public int count();
}