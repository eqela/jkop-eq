
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

class SystemEnvironmentImpl : SystemEnvironmentInterface
{
	embed "c" {{{
		#include <windows.h>
		#include <stdlib.h>
		#include <io.h>
		#include <shlobj.h>
		#include <direct.h>
		#include <sys/types.h>
		#include <shlobj.h>
	}}}

	public bool is_os(String id) {
		if("windows".equals(id)) {
			return(true);
		}
		return(false);
	}

	public HashTable get_env_vars() {
		var v = HashTable.create();
		int n = 0;
		embed "c" {{{
			char* ev = (char*)GetEnvironmentStrings();
			if(ev == NULL) {
				return(v);
			}
		}}}
		strptr ep;
		embed "c" {{{
			ep = ev;
		}}}
		while(true) {
			var t = String.for_strptr(ep);
			if(t != null) {
				var comps = t.split('=', 2);
				String key, val;
				key = comps.next() as String;
				if(key != null) {
					val = comps.next() as String;
					if(val == null) {
						val = "";
					}
					v.set(key, val);
				}
			}
			n ++;
			embed "c" {{{
				ep += strlen(ep) + 1;
				if(*ep == 0) {
					break;
				}
			}}}
		}
		embed "c" {{{
			FreeEnvironmentStrings((LPTCH)ev);
		}}}
		return(v);
	}

	public String get_env_var(String key) {
		if(key == null) {
			return(null);
		}
		strptr ep = null;
		var ks = key.to_strptr();
		embed "c" {{{
			char buf[2048];
			ZeroMemory(buf, 2048);
			if(GetEnvironmentVariable(ks, buf, 2048) > 0) {
				ep = buf;
			}
		}}}
		if(ep == null) {
			return(null);
		}
		return(String.for_strptr(ep).dup());
	}

	public String get_current_directory() {
		strptr dp = null;
		embed "c" {{{
			char t[1024];
			dp = getcwd(t, 1024);
		}}}
		return("/native".append(Path.from_native_notation(String.for_strptr(dp))));
	}

	public void set_current_directory(String d) {
		if(d != null) {
			var dn = Path.to_native_notation(d);
			if(dn != null) {
				var dp = dn.to_strptr();
				embed "c" {{{
					chdir(dp);
				}}}
				return;
			}
		}
		else {
			embed "c" {{{
				chdir("C:\\");
			}}}
		}
	}

	public bool unset_env_var(String key) {
		if(key != null) {
			strptr ks = key.to_strptr();
			embed "c" {{{
				SetEnvironmentVariable(ks, NULL);
			}}}
		}
		return(true);
	}

	public bool set_env_var(String key, String val) {
		if(key != null) {
			String empty = "";
			strptr ks = key.to_strptr();
			strptr vs;
			if(val != null) {
				vs = val.to_strptr();
			}
			else {
				vs = empty.to_strptr();
			}
			embed "c" {{{
				SetEnvironmentVariable(ks, vs);
			}}}
		}
		return(true);
	}

	public void terminate(int rv) {
		Log.debug("Terminating with return value %d.".printf().add(Primitive.for_integer(rv)).to_string());
		embed "c" {{{
			exit(rv);
		}}}
	}

	public void sleep(int sec) {
		embed "c" {{{
			Sleep(sec * 1000);
		}}}
	}

	public void usleep(int usec) {
		embed "c" {{{
			Sleep(usec / 1000);
		}}}
	}

	public File find_command(String cmd) {
		var path = get_env_var("PATH");
		if(String.is_empty(path)) {
			return(null);
		}
		foreach(String comp in StringSplitter.split(path, ';')) {
			var pp = File.for_native_path(comp);
			var c = pp.entry(cmd.append(".exe"));
			if(c.is_file()) {
				return(c);
			}
			c = pp.entry(cmd.append(".com"));
			if(c.is_file()) {
				return(c);
			}
			c = pp.entry(cmd.append(".bat"));
			if(c.is_file()) {
				return(c);
			}
		}
		return(null);
	}

	public String get_current_url() {
		return(null);
	}

	public File get_photo_dir() {
		return(null); // FIXME
	}

	public File get_documents_dir() {
		return(null); // FIXME
	}

	public File get_music_dir() {
		return(null); // FIXME
	}

	public File get_download_dir() {
		return(null); // FIXME
	}

	public File get_home_dir() {
		strptr sp;
		embed "c" {{{
			char path[MAX_PATH];
			if(SHGetFolderPath(NULL, CSIDL_PERSONAL, NULL, 0, path) == S_OK) {
				sp = path;
			}
		}}}
		if(sp != null) {
			return(File.for_native_path(String.for_strptr(sp).dup()));
		}
		return(File.for_native_path("C:\\"));
	}

	public File get_temporary_dir() {
		return(File.for_native_path("C:\\Windows\\Temp"));
	}

	public File get_current_dir() {
		return(File.for_eqela_path(get_current_directory()));
	}

	public File find_self() {
		strptr p = null;
		embed "c" {{{
			char buffer[1024];
			if(GetModuleFileName(NULL, buffer, 1024) > 0) {
				p = buffer;
			}
		}}}
		if(p != null) {
			return(File.for_native_path(String.for_strptr(p).dup()));
		}
		return(null);
	}

	public String get_current_user_id() {
		return(null);
	}

	public String get_current_process_id() {
		return(null);
	}

	String get_program_files_dir_path(bool x86) {
		strptr sp = null;
		int r = 0;
		IFDEF("target_win32") {
			embed "c" {{{
				int csidl = CSIDL_PROGRAM_FILES;
				if(x86) {
					csidl = CSIDL_PROGRAM_FILESX86;
				}
				sp = new char[MAX_PATH];
				r = SHGetSpecialFolderPath(0, sp, csidl, false);
			}}}
		}
		String v;
		if(r != 0) {
			v = String.for_strptr(sp).dup();
		}
		IFDEF("target_win32") {
			embed {{{
				delete[] sp;
			}}}
		}
		return(v);
	}

	public File get_program_files_dir() {
		var v = get_program_files_dir_path(false);
		if(v != null) {
			return(File.for_native_path(v));
		}
		return(null);
	}

	public File get_program_files_x86_dir() {
		var v = get_program_files_dir_path(true);
		if(v != null) {
			return(File.for_native_path(v));
		}
		return(null);
	}
}
