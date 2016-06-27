
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

public class JSONTemplateProcessor : TemplateProcessor
{
	void encode_string(String s, StringBuffer sb) {
		if(s == null) {
			return;
		}
		var it = s.iterate();
		if(it == null) {
			return;
		}
		int c;
		while((c = it.next_char()) > 0) {
			if(c == '"') {
				sb.append_c((int)'\\');
			}
			else if(c == '\\') {
				sb.append_c((int)'\\');
			}
			sb.append_c(c);
		}
	}

	public void on_custom_tag(HashTable vars, StringBuffer result, Collection include_dirs, String tagname, Collection words) {
		if("quotedstring".equals(tagname)) {
			var string = substitute_variables(words.get(1) as String, vars);
			encode_string(string, result);
		}
	}
}