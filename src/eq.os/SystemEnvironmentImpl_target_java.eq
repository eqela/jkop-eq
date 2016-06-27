
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
	private String to_string(strptr ptr) {
		return(String.for_strptr(ptr));
	}

	public bool is_os(String id) {
		return(false); // FIXME
	}

	public HashTable get_env_vars() {
		var v = HashTable.create();
		IFDEF("target_j2me") {
			v = null;
		}
		ELSE {
			embed "Java" {{{
				java.util.Map<java.lang.String, java.lang.String> env = java.lang.System.getenv();
				for(java.lang.String envName : env.keySet()) {
					v.set(to_string(envName), (eq.api.Object)to_string(env.get(envName)));
				}
			}}}
		}
		return(v);
	}

	public String get_env_var(String key) {
		IFDEF("target_j2me") {
			return(null);
		}
		ELSE {
			strptr val = null;
			embed "Java" {{{
				val = java.lang.System.getenv(key.to_strptr());
			}}}
			if(val != null) {
				return(String.for_strptr(val));
			}
			return(null);
		}
	}

	public String get_current_directory() {
		strptr v;
		embed "Java" {{{
			v = java.lang.System.getProperty("user.dir");
		}}}
		return("/native".append(String.for_strptr(v)));
	}

	private String get_home_directory() {
		strptr v;
		embed "Java" {{{
			v = java.lang.System.getProperty("user.home");
		}}}
		return(String.for_strptr(v));
	}

	public void set_current_directory(String d) {
		IFNDEF("target_j2me") {
			embed "Java" {{{
				java.lang.System.setProperty("user.dir", d.to_strptr());
			}}}
		}
	}

	public bool set_env_var(String key, String val) {
		// not supported on Java
		return(false);
	}

	public bool unset_env_var(String key) {
		// not supported on Java
		return(false);
	}

	public void terminate(int rv) {
		embed "Java" {{{
			java.lang.System.exit(rv);
		}}}
	}

	public void sleep(int sec) {
		embed "Java" {{{
			try {
				java.lang.Thread.sleep(sec * 1000);
			}
			catch(Exception e) {
			}
		}}}
	}

	public void usleep(int usec) {
		int msec = usec / 1000;
		IFNDEF("target_j2me") {
		int nsec = (usec - msec*1000) * 1000;
		embed "Java" {{{
			try {
				java.lang.Thread.sleep(msec, nsec);
			}
			catch(Exception e) {
			}
		}}}
		}
		ELSE {
		embed "Java" {{{
			try {
				java.lang.Thread.sleep(msec);
			}
			catch(Exception e) {
			}
		}}}
		}
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
		return(null);
	}

	public String get_current_url() {
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
