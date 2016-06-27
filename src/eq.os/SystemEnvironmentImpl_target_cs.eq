
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
	public HashTable get_env_vars() {
		return(HashTable.create());
	}

	public bool is_os(String id) {
		bool v = false;
		IFDEF("target_netcore") {
			if("windows".equals(id)) {
				int c;
				embed {{{
					c = System.IO.Path.DirectorySeparatorChar;
				}}}
				if(c == '\\') {
					return(true);
				}
				return(false);
			}
			if("macosx".equals(id)) {
				if(File.for_native_path("/Applications").is_directory()) {
					return(true);
				}
				return(false);
			}
			if("posix".equals(id) || "linux".equals(id) || "unix".equals(id)) {
				if(File.for_native_path("/bin/sh").is_file()) {
					return(true);
				}
				return(false);
			}
		}
		ELSE {
			if("windows".equals(id)) {
				embed "cs" {{{
					if(System.Environment.OSVersion.Platform == System.PlatformID.Win32NT ||
						System.Environment.OSVersion.Platform == System.PlatformID.Win32S ||
						System.Environment.OSVersion.Platform == System.PlatformID.Win32Windows ||
						System.Environment.OSVersion.Platform == System.PlatformID.WinCE ||
						System.Environment.OSVersion.Platform == System.PlatformID.Xbox) {
							v = true;
					}
				}}}
				return(v);
			}
			if("macosx".equals(id)) {
				int x = 0;
				embed "cs" {{{
					x = (int)System.Environment.OSVersion.Platform;
					if(System.Environment.OSVersion.Platform == System.PlatformID.MacOSX) {
						v = true;
					}
				}}}
				if(v) {
					return(v);
				}
				if(is_os("posix") == false) {
					return(false);
				}
				if(File.for_native_path("/Applications").is_directory()) {
					return(true);
				}
				return(false);
			}
			if("posix".equals(id) || "linux".equals(id) || "unix".equals(id)) {
				embed "cs" {{{
					if(System.Environment.OSVersion.Platform == System.PlatformID.Unix) {
						v = true;
					}
				}}}
				return(v);
			}
		}
		return(false);
	}

	public String get_env_var(String key) {
		if(key == null) {
			return(null);
		}
		var kp = key.to_strptr();
		strptr v = null;
		IFNDEF("target_winrtcs") {
			embed {{{
				v = System.Environment.GetEnvironmentVariable(kp);
			}}}
		}
		if(v == null) {
			return(null);
		}
		return(String.for_strptr(v));
	}

	public bool set_env_var(String key, String val) {
		return(false);
	}

	public bool unset_env_var(String key) {
		return(false);
	}

	public String get_current_directory() {
		return(null);
	}

	private String get_home_directory() {
		strptr homepath;
		if(is_os("unix") || is_os("macosx")) {
			embed "cs" {{{
				homepath = System.Environment.GetEnvironmentVariable("HOME");
			}}}
		}
		else if(is_os("windows")) {
			embed "cs" {{{
				homepath = System.Environment.ExpandEnvironmentVariables("%HOMEDRIVE%%HOMEPATH%");
			}}}
		}
		return(String.for_strptr(homepath));
	}

	public void set_current_directory(String d) {
	}

	public void terminate(int rv) {
		IFDEF("target_uwpcs") {
			embed {{{
				Windows.UI.Xaml.Application.Current.Exit();
			}}}
		}
		ELSE IFDEF("target_wpcs") {
			embed "cs" {{{
				System.Windows.Application.Current.Terminate();
			}}}
		}
	}

	public void sleep(int sec) {
		IFDEF("target_wpcs") {
			embed "cs" {{{
				System.Threading.Thread.Sleep(sec * 1000);
			}}}
		}
		ELSE {
			embed "cs" {{{
				var v = System.Threading.Tasks.Task.Delay(sec * 1000);
				v.RunSynchronously();
			}}}
		}
	}

	public void usleep(int usec) {
		IFDEF("target_wpcs") {
			embed "cs" {{{
				System.Threading.Thread.Sleep(usec / 1000);
			}}}
		}
		ELSE {
			embed {{{
				var v = System.Threading.Tasks.Task.Delay(usec / 1000);
				v.RunSynchronously();
			}}}
		}
	}

	public String convert_native_path(String path) {
		return(null);
	}

	public File find_command(String cmd) {
		if(cmd == null) {
			return(null);
		}
		var cmdp = cmd.to_strptr();
		if(cmdp == null) {
			return(null);
		}
		var pd = Path.get_path_delimiter();
		strptr v = null;
		IFNDEF("target_winrtcs") {
		embed "cs" {{{
			var path = System.Environment.GetEnvironmentVariable("PATH");
			if(path != null) {
				char path_splitter = ';';
				if(pd == '/') {
					path_splitter = ':';
				}
				foreach(var dir in path.Split(path_splitter)) {
					var fullpath = System.IO.Path.Combine(dir, cmdp);
					if(System.IO.File.Exists(fullpath)) {
						v = fullpath;
						break;
					}
				}
			}
		}}}
		}
		if(v == null) {
			return(null);
		}
		return(File.for_native_path(String.for_strptr(v)));
	}

	public File get_temporary_dir() {
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
		var hd = get_home_directory();
		if(hd == null) {
			return(null);
		}
		return(File.for_native_path(hd));
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
		strptr v;
		IFDEF("target_winrtcs") {
		}
		ELSE IFDEF("target_netcore") {
		}
		ELSE {
			embed "cs" {{{
				v = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ProgramFiles);
			}}}
		}
		if(v == null) {
			return(null);
		}
		return(File.for_native_path(String.for_strptr(v)));
	}

	public File get_program_files_x86_dir() {
		strptr v;
		IFDEF("target_winrtcs") {
		}
		ELSE IFDEF("target_netcore") {
		}
		ELSE {
			embed "cs" {{{
				v = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ProgramFilesX86);
			}}}
		}
		if(v == null) {
			return(null);
		}
		return(File.for_native_path(String.for_strptr(v)));
	}
}
