
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
		#include <stdlib.h>
		#include <unistd.h>
		#include <sys/types.h>
		extern char ** environ;
	}}}

	IFDEF("target_darwin") {
		embed "c" {{{
			#include <stdint.h>
			#include <sys/syslimits.h>
			#include <mach-o/dyld.h>
		}}}
	}

	public bool is_os(String id) {
		if("windows".equals(id)) {
			return(false);
		}
		if("macosx".equals(id)) {
			if(File.for_native_path("/Applications").is_directory()) {
				return(true);
			}
			return(false);
		}
		if("posix".equals(id) || "linux".equals(id) || "unix".equals(id)) {
			return(true);
		}
		return(false);
	}

	public HashTable get_env_vars() {
		var v = HashTable.create();
		int n = 0;
		while(true) {
			embed "c" {{{
				if(environ[n] == (void*)0) {
					break;
				}
			}}}
			strptr ep;
			embed "c" {{{
				ep = environ[n];
			}}}
			var t = String.for_strptr(ep).dup();
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
		}
		return(v);
	}

	public String get_env_var(String key) {
		if(key == null) {
			return(null);
		}
		strptr ep = null;
		var ks = key.to_strptr();
		embed "c" {{{
			ep = getenv(ks);
		}}}
		return(String.for_strptr(ep).dup());
	}

	public String get_current_directory() {
		strptr dp = null;
		embed "c" {{{
			char t[1024];
			dp = getcwd(t, 1024);
		}}}
		return("/native".append(String.for_strptr(dp)));
	}

	private String get_home_directory() {
		var v = get_env_var("HOME");
		if(v == null || v.get_length() < 1) {
			v = "/";
		}
		return(v);
	}

	public void set_current_directory(String d) {
		if(d != null) {
			var dp = d.to_strptr();
			embed "c" {{{
				chdir(dp);
			}}}
		}
		else {
			embed "c" {{{
				chdir("/tmp");
			}}}
		}
	}

	public bool unset_env_var(String key) {
		if(key != null) {
			strptr ks = key.to_strptr();
			embed "c" {{{
				unsetenv(ks);
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
				setenv(ks, vs, 1);
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
			sleep(sec);
		}}}
	}

	public void usleep(int usec) {
		embed "c" {{{
			usleep(usec);
		}}}
	}

	public String convert_native_path(String path) {
		if(path == null) {
			return(null);
		}
		if(path.has_prefix("/")) {
			return("/native".append(path));
		}
		return(Path.absolute_path(path));
	}

	public File find_command(String cmd) {
		var path = get_env_var("PATH");
		if(String.is_empty(path)) {
			return(null);
		}
		foreach(String comp in StringSplitter.split(path, ':')) {
			var c = File.for_eqela_path("/native".append(comp)).entry(cmd);
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
		return(File.for_eqela_path("/my/Photos"));
	}

	public File get_documents_dir() {
		return(File.for_eqela_path("/my/Documents"));
	}

	public File get_music_dir() {
		return(File.for_eqela_path("/my/Music"));
	}

	public File get_download_dir() {
		return(File.for_eqela_path("/my/Downloads"));
	}

	public File get_home_dir() {
		String v = get_env_var("HOME");
		if(String.is_empty(v) == false) {
			return(File.for_native_path(v));
		}
		return(null);
	}

	public File get_temporary_dir() {
		return(File.for_native_path("/tmp"));
	}

	public File get_current_dir() {
		return(File.for_eqela_path(get_current_directory()));
	}

	public File find_self() {
		File v = null;
		IFDEF("target_linux") {
			strptr filepath;
			embed "c" {{{
				char file[4096];
				int r = readlink("/proc/self/exe", file, 4096);
				if(r > 0) {
					if(r == 4096) {
						r--;
					}
					file[r] = 0;
					filepath = file;
				}
			}}}
			if(filepath != null) {
				v = File.for_native_path(String.for_strptr(filepath).dup());
			}
		}
		IFDEF("target_darwin") {
			int r;
			embed "c" {{{
				char buffer[PATH_MAX];
				uint32_t bs = PATH_MAX;
				r = _NSGetExecutablePath(buffer, &bs);
			}}}
			if(r == 0) {
				strptr pp;
				embed "c" {{{
					char rp[PATH_MAX];
					pp = realpath(buffer, rp);
					if(pp == NULL) {
						pp = buffer;
					}
				}}}
				if(pp != null) {
					v = File.for_native_path(String.for_strptr(pp));
				}
			}
		}
		if(v == null) {
			var av0 = get_env_var("_EQ_ARGV0");
			if(av0 != null && av0.get_length() > 0 && av0.chr('/') >= 0) {
				var dn = Path.dirname(Path.absolute_path(av0));
				if(dn != null && dn.has_prefix("/native")) {
					dn = dn.substring(7);
				}
				v = File.for_native_path(dn);
			}
		}
		return(v);
	}

	public String get_current_user_id() {
		int u;
		embed "c" {{{
			u = getuid();
		}}}
		return(String.for_integer(u));
	}

	public String get_current_process_id() {
		int p;
		embed "c" {{{
			p = getpid();
		}}}
		return(String.for_integer(p));
	}

	public File get_program_files_dir() {
		return(null);
	}

	public File get_program_files_x86_dir() {
		return(null);
	}
}
