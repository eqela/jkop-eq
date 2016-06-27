
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

public class ShellInputWidget : CustomTextInputWidget
{
	property ShellEngine shell_engine;

	public ShellInputWidget() {
		set_font(Theme.font().modify("monospace"));
	}

	public Widget get_default_focus_widget() {
		return(this);
	}

	public bool on_shortcut_key_pressed(String kstr, KeyEvent e) {
		if("a".equals(kstr)) {
			go_to_beginning(e);
			return(true);
		}
		if("y".equals(kstr)) {
			clipboard_paste();
			return(true);
		}
		return(base.on_shortcut_key_pressed(kstr, e));
	}

	String get_last_word() {
		var tt = get_text();
		if(tt == null) {
			return(null);
		}
		var it = tt.iterate_reverse();
		if(it == null) {
			return(null);
		}
		var sb = StringBuffer.create();
		int pc = 0;
		int c;
		bool dquote = false;
		bool squote = false;
		while((c = it.next_char()) > 0) {
			if(c == '\'') {
				squote = !squote;
				pc = c;
				sb.append_c(c);
				continue;
			}
			if(c == '"') {
				dquote = !dquote;
				pc = c;
				sb.append_c(c);
				continue;
			}
			if(c == ' ' || c == '\t') {
				if(dquote == false && squote == false) {
					break;
				}
			}
			sb.append_c(c);
			pc = c;
		}
		var r = sb.to_string();
		if(r == null) {
			return(null);
		}
		return(r.reverse());
	}

	String remove_quotes(String str) {
		if(str == null) {
			return(null);
		}
		var it = str.iterate();
		var sb = StringBuffer.create();
		int c;
		while((c = it.next_char()) > 0) {
			if(c == '\'' || c == '"') {
				continue;
			}
			sb.append_c(c);
		}
		return(sb.to_string());
	}

	String legitimize(String str) {
		if(str == null) {
			return(str);
		}
		if(str.chr((int)' ') < 0) {
			return(str);
		}
		var sb = StringBuffer.create();
		var it = str.iterate();
		int c;
		while((c = it.next_char()) > 0) {
			if(c == ' ' || c == '\t') {
				sb.append_c((int)'"');
				sb.append_c(c);
				sb.append_c((int)'"');
			}
			else {
				sb.append_c(c);
			}
		}
		return(sb.to_string());
	}

	bool try_expand_wildcards(String word, File cwd) {
		var xx = Glob.expand_wildcards_for_word(word, cwd);
		if(xx == null || xx.equals(word)) {
			return(false);
		}
		remove_characters(word.get_length());
		append_str(xx);
		return(true);
	}

	public void autocomplete() {
		if(shell_engine == null) {
			return;
		}
		var cwd = shell_engine.get_cwd();
		if(cwd == null) {
			return;
		}
		var lw = get_last_word();
		if(lw == null) {
			lw = "";
		}
		if(try_expand_wildcards(lw, cwd)) {
			return;
		}
		lw = remove_quotes(lw);
		var dir = cwd;
		String txt;
		String delim = "/";
		if(Path.get_path_delimiter() == '\\' && Path.is_windows_absolute_path(lw)) {
			if(lw.has_suffix("\\")) {
				dir = File.for_native_path(lw);
				txt = "";
			}
			else {
				dir = File.for_native_path(lw);
				txt = dir.basename();
				dir = dir.get_parent();
			}
			delim = "\\";
		}
		else if(lw.has_prefix("/")) {
			if(lw.has_suffix("/")) {
				dir = File.for_native_path(lw);
				txt = "";
			}
			else {
				dir = File.for_native_path(lw);
				txt = dir.basename();
				dir = dir.get_parent();
			}
		}
		else {
			foreach(String comp in StringSplitter.split(lw, (int)'/')) {
				if(txt != null) {
					dir = dir.entry(txt);
				}
				txt = comp;
			}
		}
		var results = LinkedList.create();
		foreach(File f in dir.entries()) {
			var bn = f.basename();
			if(String.is_empty(txt) || (bn != null && bn.has_prefix(txt))) {
				results.add(f);
			}
		}
		if(results.count() < 1) {
			return;
		}
		if(results.count() == 1) {
			var r = results.get(0) as File;
			var bn = r.basename();
			if(bn == null) {
				return;
			}
			append_str(legitimize(bn.substring(txt.get_length())));
			if(r.is_directory()) {
				append_str(delim);
			}
			else if(r.is_file()) {
				append_str(" ");
			}
			return;
		}
		String cp;
		foreach(File result in results) {
			var s = result.basename();
			if(s == null) {
				continue;
			}
			if(cp == null) {
				cp = s;
				continue;
			}
			int n = 0;
			var it1 = cp.iterate();
			var it2 = s.iterate();
			while(true) {
				var c1 = it1.next_char();
				var c2 = it2.next_char();
				if(c1 < 1 || c2 < 1) {
					break;
				}
				if(c1 != c2) {
					break;
				}
				n++;
			}
			cp = s.substring(0,n);
		}
		if(String.is_empty(cp) == false && cp.equals(txt) == false) {
			append_str(legitimize(cp.substring(txt.get_length())));
			return;
		}
		shell_engine.println("%s/%s*:".printf().add(dir).add(txt).to_string());
		foreach(File result in results) {
			var s = result.basename();
			if(s == null) {
				continue;
			}
			if(result.is_directory()) {
				s = s.append("/");
			}
			shell_engine.println(s);
		}
	}

	public bool on_key_pressed(String kname, String kstr, KeyEvent e) {
		if("up".equals(kname) || "down".equals(kname) || "pageup".equals(kname) || "pagedown".equals(kname)) {
			forward_event(e);
			return(true);
		}
		if("tab".equals(kname)) {
			autocomplete();
			return(true);
		}
		return(base.on_key_pressed(kname, kstr, e));
	}
}
