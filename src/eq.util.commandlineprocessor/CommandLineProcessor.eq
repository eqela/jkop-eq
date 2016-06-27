
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

public class CommandLineProcessor
{
	public static String expand_backticks(String str) {
		if(str == null) {
			return(null);
		}
		int c = str.chr((int)'`');
		if(c < 0) {
			return(str);
		}
		var sb = StringBuffer.create();
		StringBuffer cmdb;
		foreach(Integer i in str) {
			// FIXME: Handle escaping of backticks
			c = i.to_integer();
			if(c == '`') {
				if(cmdb == null) {
					cmdb = StringBuffer.create();
				}
				else {
					var cmd = cmdb.to_string();
					var rr = ProcessLauncher.for_string(cmd).execute_pipe_string();
					if(String.is_empty(rr) == false) {
						sb.append(rr.strip());
					}
					cmdb = null;
				}
			}
			else {
				if(cmdb != null) {
					cmdb.append_c(c);
				}
				else {
					sb.append_c(c);
				}
			}
		}
		return(sb.to_string());
	}

	public static String expand_variables(String str, HashTable env) {
		return(VariableSubstitutor.substitute(str, HashTableVariableProvider.for_hashtable(env)));
	}

	static void split_word_end(StringBuffer sb, Collection v, File cwd) {
		if(sb == null || v == null) {
			return;
		}
		var r = sb.to_string();
		if(r == null) {
			r = "";
		}
		if(r.chr((int)'*') >= 0) {
			var gr = Glob.get_matching_strings(r, cwd);
			if(gr != null) {
				foreach(var o in gr) {
					v.add(o);
				}
				return;
			}
		}
		v.add(r);
	}

	static Collection split_to_words_and_expand(String str, File cwd) {
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
			else if(quote == false && dquote == false && c == ' ') {
				split_word_end(sb, v, cwd);
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
		split_word_end(sb, v, cwd);
		return(v);
	}

	public static Collection process(String str, File cwd, HashTable env) {
		var v = str;
		v = expand_backticks(v);
		v = expand_variables(v, env);
		return(split_to_words_and_expand(v, cwd));
	}
}
