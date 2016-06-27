
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

public class ApplicationData
{
	IFDEF("target_win32") {
		embed "c" {{{
			#include <windows.h>
			#include <shlobj.h>
		}}}
	}

	public static File for_this_application() {
		return(ApplicationData.for_application(null));
	}

	public static File for_application(String aname = null) {
		var name = aname;
		if(String.is_empty(name)) {
			name = Application.get_name();
		}
		if(String.is_empty(name)) {
			name = "EqelaApplication";
		}
		File v;
		IFDEF("target_ios") {
			v = File.for_eqela_path("/my/Documents");
		}
		ELSE IFDEF("target_posix") {
			v = File.for_eqela_path("/my/.".append(name));
		}
		ELSE IFDEF("target_win32") {
			strptr sp;
			embed "c" {{{
				char path[MAX_PATH];
				if(SHGetFolderPath(NULL, CSIDL_LOCAL_APPDATA, NULL, 0, path) == S_OK) {
					sp = path;
				}
			}}}
			if(sp != null) {
				v = File.for_native_path(String.for_strptr(sp).dup()).entry(name);
			}
			else {
				v = File.for_native_path("C:\\").entry(name);
			}
		}
		ELSE IFDEF("target_android") {
			if(aname != null) {
				return(null);
			}
			strptr jpath;
			embed "java" {{{
				if(eq.api.Android.context != null) {
					java.io.File filesdir = eq.api.Android.context.getFilesDir();
					if(filesdir != null) {
						jpath = filesdir.getPath();
					}
				}
			}}}
			if(jpath != null) {
				v = File.for_native_path(String.for_strptr(jpath));
			}
			if(v == null) {
				v = File.for_eqela_path("/my/".append(name));
			}
		}
		ELSE IFDEF("target_bbjava") {
			v = File.for_eqela_path("/my/".append(name));
		}
		ELSE IFDEF("target_j2me") {
			v = RecordStoreFile.for_name(name);
		}
		ELSE IFDEF("target_html") {
			v = LocalStorageFile.instance(name, null, null);
		}
		ELSE {
			v = File.for_eqela_path("/my/".append(name));
		}
		return(v);
	}
}
