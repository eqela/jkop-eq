
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

public class XMLKeyValueParser
{
	class MyParser : XMLParser
	{
		HashTable result;
		Stack elements;

		public MyParser() {
			result = HashTable.create();
			elements = Stack.create();
		}

		public HashTable get_result() {
			return(result);
		}

		public void on_cdata(String cdata) {
			var sb = elements.peek() as StringBuffer;
			if(sb != null) {
				sb.append(cdata);
			}
		}

		public void on_comment(String comment) {
		}

		public void on_start_element(String element, HashTable params) {
			elements.push(StringBuffer.create());
		}

		public void on_end_element(String element) {
			var sb = elements.pop() as StringBuffer;
			if(sb != null && element != null) {
				var e = result.get(element);
				if(e == null) {
					result.set(element, sb.to_string());
				}
				else if(e is Collection) {
					((Collection)e).add(sb.to_string());
				}
				else {
					var c = LinkedList.create();
					c.add(e);
					c.add(sb.to_string());
					result.set(element, c);
				}
			}
		}
	}

	public static HashTable parse_string(String str) {
		if(str == null) {
			return(null);
		}
		var rp = new MyParser();
		if(((XMLParser)rp).parse_string(str) == false) {
			return(null);
		}
		return(rp.get_result());
	}
}
