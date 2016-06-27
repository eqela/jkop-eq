
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

public class FileFinder : Iterator
 {
	public static FileFinder for_root(File root) {
		return(new FileFinder().set_root(root));
	}

	class Pattern
	{
		String str;
		String suffix;
		String prefix;
		public Pattern set_str(String str) {
			this.str = str;
			if(str != null) {
				if(str.has_prefix("*")) {
					suffix = str.substring(1);
				}
				if(str.has_suffix("*")) {
					prefix = str.substring(0, str.get_length()-1);
				}
			}
			return(this);
		}
		public bool match(String check) {
			if(check == null) {
				return(false);
			}
			if(str.equals(check)) {
				return(true);
			}
			if(suffix != null && check.has_suffix(suffix)) {
				return(true);
			}
			if(prefix != null && check.has_prefix(prefix)) {
				return(true);
			}
			return(false);
		}
	}

	File root;
	Collection patterns;
	Collection exclude_patterns;
	Stack stack;
	property bool include_matching_directories = false;
	property bool include_directories = false;

	public FileFinder() {
		patterns = LinkedList.create();
		exclude_patterns = LinkedList.create();
	}

	public FileFinder set_root(File root) {
		this.root = root;
		stack = null;
		return(this);
	}

	public FileFinder add_pattern(String pattern) {
		patterns.add(new Pattern().set_str(pattern));
		return(this);
	}

	public FileFinder add_exclude_pattern(String pattern) {
		exclude_patterns.add(new Pattern().set_str(pattern));
		return(this);
	}

	bool match_pattern(File file) {
		if(file == null) {
			return(false);
		}
		if(patterns.count() < 1) {
			return(true);
		}
		var filename = file.basename();
		foreach(Pattern pattern in patterns) {
			if(pattern.match(filename)) {
				return(true);
			}
		}
		return(false);
	}

	bool match_exclude_pattern(File file) {
		if(file == null) {
			return(false);
		}
		if(exclude_patterns.count() < 1) {
			return(false);
		}
		var filename = file.basename();
		foreach(Pattern pattern in exclude_patterns) {
			if(pattern.match(filename)) {
				return(true);
			}
		}
		return(false);
	}

	public Object next() {
		while(true) {
			if(stack == null) {
				if(root == null) {
					break;
				}
				var es = root.entries();
				root = null;
				if(es == null) {
					break;
				}
				stack = Stack.create();
				stack.push(es);
			}
			var entries = (Iterator)stack.peek();
			if(entries == null) {
				stack = null;
				break;
			}
			var e = entries.next() as File;
			if(e == null) {
				stack.pop();
			}
			else if(match_exclude_pattern(e)) {
				; // skip
			}
			else if(e.is_file()) {
				if(match_pattern(e)) {
					return(e);
				}
			}
			else if(include_matching_directories && e.is_directory() && match_pattern(e)) {
				return(e);
			}
			else if(e.is_directory() && e.is_link() == false) {
				stack.push(e.entries());
				if(include_directories) {
					return(e);
				}
			}
		}
		return(null);
	}
}

