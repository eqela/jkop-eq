
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

public class Glob
{
	class MatchState
	{
		public StringIterator si;
		public StringIterator pi;
		public int sc;
		public int sn;
		public int pc;
		public int pn;
	}

	public static bool match(String str, String pattern) {
		if(str == null) {
			return(false);
		}
		if(pattern == null) {
			return(true);
		}
		if(pattern.chr((int)'*') < 0) {
			return(pattern.equals(str));
		}
		bool v = false;
		var si = str.iterate(), pi = pattern.iterate();
		int sc = si.next_char();
		int pc = pi.next_char();
		int sn = si.next_char();
		int pn = pi.next_char();
		var routes = Stack.create();
		while(sc > 0 && pc > 0) {
			if(pc == '*') {
				int n = pn;
				if(sc == n) {
					var ms = new MatchState();
					ms.si = si.copy();
					ms.pi = pi.copy();
					ms.sc = sc;
					ms.sn = sn;
					ms.pc = pc;
					ms.pn = pn;
					routes.push(ms);
					pc = pn;
					pn = pi.next_char();
				}
				else {
					sc = sn;
					sn = si.next_char();
				}
			}
			else if(pc == sc) {
				pc = pn;
				pn = pi.next_char();
				sc = sn;
				sn = si.next_char();
			}
			else {
				var alt = routes.pop() as MatchState;
				if(alt != null) {
					si = alt.si;
					pi = alt.pi;
					sc = alt.sc;
					sn = alt.sn;
					pc = alt.pc;
					pn = alt.pn;
					sc = sn;
					sn = si.next_char();
					continue;
				}
				break;
			}
		}
		if(sc < 1 && (pc < 1 || (pc == '*' && pn < 1))) {
			v = true;
		}
		return(v);
	}

	static void add_matching_files(File dir, String pattern, int delim, Collection v) {
		if(pattern == null || dir == null || v == null) {
			return;
		}
		String next;
		var cp = pattern;
		var dd = cp.chr(delim);
		if(dd > 0) {
			next = cp.substring(dd+1);
			while(next != null && next.get_char(0) == delim) {
				next = next.substring(1);
			}
			cp = cp.substring(0,dd);
		}
		if(cp.chr((int)'*') < 0) {
			var ff = dir.entry(cp);
			if(String.is_empty(next)) {
				if(ff.exists()) {
					v.add(ff);
				}
			}
			else {
				add_matching_files(ff, next, delim, v);
			}
			return;
		}
		foreach(File f in dir.entries()) {
			if(match(f.basename(), cp)) {
				if(String.is_empty(next)) {
					v.add(f);
				}
				else {
					add_matching_files(f, next, delim, v);
				}
			}
			else {
			}
		}
	}

	public static Collection get_matching_files(String pattern, File cwd) {
		if(pattern == null || cwd == null) {
			return(LinkedList.create());
		}
		var odir = cwd;
		var pp = pattern;
		var delim = '/';
		if(Path.get_path_delimiter() == '\\' && Path.is_windows_absolute_path(pp)) {
			pp = pp.replace_char((int)'/', (int)'\\');
			delim = '\\';
			odir = File.for_native_path(pp.substring(0,3));
			pp = pp.substring(3);
			while(pp.has_prefix("\\")) {
				pp = pp.substring(1);
			}
		}
		else if(pp.has_prefix("/")) {
			odir = File.for_native_path("/");
			while(pp.has_prefix("/")) {
				pp = pp.substring(1);
			}
		}
		var v = LinkedList.create();
		add_matching_files(odir, pp, (int)delim, v);
		return(v);
	}

	static void escape_word(String word, StringBuffer sb) {
		if(word == null || sb == null) {
			return;
		}
		var it = word.iterate();
		int c;
		while((c = it.next_char()) > 0) {
			if(c == ' ') {
				sb.append("\" \"");
			}
			else if(c == '*') {
				sb.append("'*'");
			}
			else if(c == '\'') {
				sb.append("\"'\"");
			}
			else if(c == '"') {
				sb.append("'\"'");
			}
			else {
				sb.append_c(c);
			}
		}
	}

	public static Collection get_matching_strings(String word, File cwd) {
		if(word == null || cwd == null) {
			return(null);
		}
		bool found = false;
		{
			bool squote = false;
			var it = word.iterate();
			int c;
			while((c = it.next_char()) > 0) {
				if(c == '\'') {
					squote = !squote;
				}
				else if(c == '*' && squote == false) {
					found = true;
					break;
				}
			}
		}
		if(found == false) {
			return(null);
		}
		var matches = Glob.get_matching_files(word, cwd);
		if(matches.count() < 1) {
			return(null);
		}
		var v = LinkedList.create();
		var cwdname = cwd.get_native_path();
		foreach(File f in matches) {
			var fnp = f.get_native_path();
			if(fnp.has_prefix(cwdname)) {
				fnp = fnp.substring(cwdname.get_length());
				while(fnp.has_prefix("/")) {
					fnp = fnp.substring(1);
				}
			}
			v.add(fnp);
		}
		return(v);
	}

	public static String expand_wildcards_for_word(String word, File cwd) {
		var ss = get_matching_strings(word, cwd);
		if(ss == null || ss.count() < 1) {
			return(word);
		}
		var sb = StringBuffer.create();
		foreach(String fnp in ss) {
			if(sb.count() > 0) {
				sb.append_c((int)' ');
			}
			escape_word(fnp, sb);
		}
		return(sb.to_string());
	}
}
