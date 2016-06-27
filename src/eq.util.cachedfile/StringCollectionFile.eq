
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

public class StringCollectionFile
{
	public static StringCollectionFile for_file(File file) {
		return(new StringCollectionFile().set_file(file).initialize());
	}

	property File file;
	CachedJSONFile jf;

	public StringCollectionFile initialize() {
		jf = CachedJSONFile.for_file(file);
		return(this);
	}

	public int count() {
		if(jf == null) {
			return(0);
		}
		var cc = jf.get_data() as Collection;
		if(cc == null) {
			return(0);
		}
		return(cc.count());
	}

	public bool add(String str) {
		if(file == null || jf == null || str == null) {
			return(false);
		}
		var cc = jf.get_data() as Collection;
		if(cc == null) {
			cc = LinkedList.create();
		}
		cc.add(str);
		return(file.set_contents_string(JSONEncoder.encode(cc)));
	}

	public bool remove(String str) {
		if(file == null || jf == null || str == null) {
			return(false);
		}
		var cc = jf.get_data() as Collection;
		var nn = LinkedList.create();
		foreach(String c in cc) {
			if(str.equals(c) == false) {
				nn.add(c);
			}
		}
		return(file.set_contents_string(JSONEncoder.encode(nn)));
	}

	public bool includes(String str) {
		if(jf == null || String.is_empty(str)) {
			return(false);
		}
		var strings = jf.get_data() as Collection;
		foreach(String string in strings) {
			if(str.equals(string)) {
				return(true);
			}
		}
		return(false);
	}

	public Collection get() {
		if(jf == null) {
			return(null);
		}
		return(jf.get_data() as Collection);
	}
}
