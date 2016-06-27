
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

public class HTMLTemplateProcessor : TemplateProcessor
{
	property PathVerifier path_verifier;
	property String query_path;
	HashTable cache;

	public HTMLTemplateProcessor() {
		cache = HashTable.create();
	}

	public void on_custom_tag(HashTable vars, StringBuffer result, Collection include_dirs, String tagname, Collection words) {
		if("link?".equals(tagname)) {
			var path = substitute_variables(words.get(1) as String, vars);
			var text = substitute_variables(words.get(2) as String, vars);
			if(String.is_empty(text)) {
				text = Path.basename(path);
			}
			if(String.is_empty(text)) {
				return;
			}
			var pp = cache.get(path) as String;
			if(pp == null) {
				if(path_verifier != null && query_path != null) {
					var qp = query_path;
					while(qp.has_suffix("/")) {
						qp = qp.substring(0, qp.get_length()-1);
					}
					var rc = qp.rchr((int)'/');
					if(rc > 0) {
						qp = qp.substring(0, rc);
					}
					if(path_verifier.path_exists("%s/%s".printf().add(qp).add(path).to_string())) {
			 			pp = path;
					}
				}
				if(pp == null) {
					pp = "";
				}
				cache.set(path, pp);
			}
			if(String.is_empty(pp) == false) {
				result.append("<a href=\"%s\"><span>%s</span></a>".printf()
					.add(pp).add(text).to_string());
			}
			else {
				result.append(text);
			}
			return;
		}
		if("link".equals(tagname)) {
			var path = substitute_variables(words.get(1) as String, vars);
			var text = substitute_variables(words.get(2) as String, vars);
			if(String.is_empty(text)) {
				text = Path.basename(path);
			}
			if(String.is_empty(text)) {
				return;
			}
			result.append("<a href=\"%s\"><span>%s</span></a>".printf()
				.add(path).add(text).to_string());
			return;
		}
		base.on_custom_tag(vars, result, include_dirs, tagname, words);
	}
}
