
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

public class VariableSubstitutor
{
	public static String substitute(String orig, VariableProvider vars) {
		if(orig == null) {
			return(orig);
		}
		if(orig.str("${") < 0) {
			return(orig);
		}
		var sb = StringBuffer.create();
		StringBuffer varbuf;
		bool flag = false;
		foreach(Integer i in orig) {
			var c = i.to_integer();
			if(varbuf != null) {
				if(c == '}') {
					var varname = varbuf.to_string();
					if(vars != null) {
						String varcut;
						if(varname.chr((int)'!') > 0) {
							var sp = varname.split((int)'!', 2);
							varname = sp.next() as String;
							varcut = sp.next() as String;
						}
						var r = vars.get_variable_value(varname);
						if(String.is_empty(varcut) == false) {
							var it = varcut.iterate();
							int cx;
							while((cx = it.next_char()) > 0) {
								var n = r.rchr(cx);
								if(n < 0) {
									break;
								}
								r = r.substring(0, n);
							}
						}
						sb.append(r);
					}
					varbuf = null;
				}
				else {
					varbuf.append_c(c);
				}
				continue;
			}
			if(flag == true) {
				flag = false;
				if(c == '{') {
					varbuf = StringBuffer.create();
				}
				else {
					sb.append_c((int)'$');
					sb.append_c(c);
				}
				continue;
			}
			if(c == '$') {
				flag = true;
				continue;
			}
			sb.append_c(c);
		}
		return(sb.to_string());
	}
}
