
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

class SystemEnvironmentImpl : PropertyObject, SystemEnvironmentInterface
{
	HashTable env;

	public bool is_os(String id) {
		return(false);
	}

	int xchar_to_integer(int c) {
		if(c >= '0' && c <= '9') {
			return(c - '0');
		}
		else if(c >= 'a' && c <= 'f') {
			return(10 + c - 'a');
		}
		else if(c >= 'A' && c <= 'F') {
			return(10 + c - 'A');
		}
		return(0);
	}

	String urldecode(String astr) {
		if(astr == null) {
			return(null);
		}
		var sb = StringBuffer.create();
		var str = astr.strip();
		var it = str.iterate();
		while(it != null) {
			var x = it.next_char();
			if(x < 1) {
				break;
			}
			if(x == '%') {
				var x1 = it.next_char();
				var x2 = it.next_char();
				if(x1 > 0 && x2 > 0) {
					sb.append_c(xchar_to_integer(x1) * 16 + xchar_to_integer(x2));
				}
				else {
					break;
				}
			}
			else if(x == '+') {
				sb.append_c(' ');
			}
			else {
				sb.append_c(x);
			}
		}
		return(sb.to_string());
	}

	void init_env_vars() {
		var url = get_current_url();
		if(String.is_empty(url)) {
			return;
		}
		var qm = url.chr('?');
		if(qm < 0) {
			return;
		}
		var qrs = url.substring(qm+1);
		if(String.is_empty(qrs)) {
			return;
		}
		foreach(String comp in StringSplitter.split(qrs, '&')) {
			var it = StringSplitter.split(comp, '=', 2);
			var key = it.next() as String;
			var val = it.next() as String;
			if(String.is_empty(key)) {
				continue;
			}
			if(val == null) {
				val = "";
			}
			var vald = urldecode(val);
			env.set(key, vald);
		}
	}

	public HashTable get_env_vars() {
		if(env == null) {
			env = HashTable.create();
			init_env_vars();
		}
		return(env);
	}

	public String get_env_var(String key) {
		var e = get_env_vars();
		if(e == null) {
			return(null);
		}
		return(e.get_string(key));
	}

	public bool set_env_var(String key, String val) {
		var e = get_env_vars();
		if(e != null) {
			e.set(key, val);
		}
		return(true);
	}

	public bool unset_env_var(String key) {
		return(false);
	}

	public String get_current_directory() {
		return(null);
	}

	private String get_home_directory() {
		return(null);
	}

	public void set_current_directory(String d) {
	}

	public void terminate(int rv) {
		embed "js" {{{
			window.close();
		}}}
	}

	public void sleep(int sec) {
		embed "js" {{{
			var start = new Date().getTime();
			while(new Date().getTime() < start + sec * 1000);
		}}}
	}

	public void usleep(int usec) {
		embed "js" {{{
			var start = new Date().getTime();
			while(new Date().getTime() < start + usec / 1000);
		}}}
	}

	public String convert_native_path(String path) {
		return(null);
	}

	public File find_command(String cmd) {
		return(null);
	}

	public String get_current_url() {
		strptr pp;
		embed "js" {{{
			pp = document.location.toString();
		}}}
		if(pp != null) {
			return(String.for_strptr(pp));
		}
		return(null);
	}

	public File get_photo_dir() {
		return(null);
	}

	public File get_documents_dir() {
		return(null);
	}

	public File get_music_dir() {
		return(null);
	}

	public File get_download_dir() {
		return(null);
	}

	public File get_home_dir() {
		return(null);
	}

	public File get_temporary_dir() {
		return(null);
	}

	public File get_current_dir() {
		return(File.for_eqela_path(get_current_directory()));
	}

	public File find_self() {
		return(null);
	}

	public String get_current_user_id() {
		return(null);
	}

	public String get_current_process_id() {
		return(null);
	}

	public File get_program_files_dir() {
		return(null);
	}

	public File get_program_files_x86_dir() {
		return(null);
	}
}
