
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

public class QuotedString
{
	public static Collection to_collection(String str, int delim) {
		if(str == null) {
			return(LinkedList.create());
		}
		bool dquote = false, quote = false;
		StringBuffer sb = null;
		var v = LinkedList.create();
		int c = 0;
		var it = str.iterate();
		while((c = it.next_char()) > 0) {
			if(c == '"' && quote == false) {
				dquote = !dquote;
			}
			else if(c == '\'' && dquote == false) {
				quote = !quote;
			}
			else if(quote == false && dquote == false && c == delim) {
				if(sb!=null) {
					var r = sb.to_string();
					if(r == null) {
						r = "";
					}
					v.add(r);
				}
				sb = null;
			}
			else {
				if(sb == null) {
					sb = StringBuffer.create();
				}
				sb.append_c(c);
			}
			if((quote == true || dquote == true) && sb == null) {
				sb = StringBuffer.create();
			}
		}
		if(sb!=null) {
			var r = sb.to_string();
			if(r == null) {
				r = "";
			}
			v.add(r);
		}
		return(v);
	}

	public static HashTable to_hashtable(String str, int delim) {
		var v = HashTable.create();
		foreach(String c in to_collection(str, delim)) {
			var sp = c.split((int)'=', 2);
			var key = sp.next() as String;
			var val = sp.next() as String;
			if(String.is_empty(key) == false) {
				v.set(key, val);
			}
		}
		return(v);
	}
}
