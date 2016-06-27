
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

public class Win32FileHandler
{
	embed "c" {{{
		#include <windows.h>
		#include <shellapi.h>
	}}}

	public static bool open(File file) {
		if(file == null) {
			return(false);
		}
		var fn = file.get_native_path();
		if(fn == null) {
			return(false);
		}
		var sp = fn.to_strptr();
		if(sp == null) {
			return(false);
		}
		bool v = false;
		embed "c" {{{
			SHELLEXECUTEINFO info;
			ZeroMemory(&info, sizeof(SHELLEXECUTEINFO));
			info.cbSize = sizeof(SHELLEXECUTEINFO);
			info.fMask = 0;
			info.lpFile = sp;
			info.lpVerb = "open";
			info.nShow = SW_SHOWNORMAL;
			ShellExecuteEx(&info);
		}}}
		return(v);
	}
}

