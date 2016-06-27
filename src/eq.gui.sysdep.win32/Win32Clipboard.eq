
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

public class Win32Clipboard : Clipboard
{
	embed "c++" {{{
		#include <windows.h>
	}}}

	bool set_string_data(String str) {
		var s = str;
		if(s == null) {
			s = "";
		}
		var sp = s.to_strptr();
		int len = s.get_length();
		embed "c++" {{{
			if(OpenClipboard(NULL) == false) {
				return(false);
			}
			EmptyClipboard();
			HGLOBAL clipboarddata = GlobalAlloc(GMEM_FIXED, len+1);
			char* strdata = (char*)GlobalLock(clipboarddata);
			strcpy(strdata, sp);
			GlobalUnlock(clipboarddata);
			SetClipboardData(CF_TEXT, clipboarddata);
			CloseClipboard();
		}}}
		return(true);
	}

	public bool set_data(ClipboardData data) {
		var dt = data;
		if(dt == null) {
			dt = ClipboardData.for_string("");
		}
		if("text/plain".equals(dt.get_mimetype()) == false) {
			Log.error("Win32Clipboard.set_data: Mime type `%s' is not supported".printf().add(dt.get_mimetype()));
			return(false);
		}
		return(set_string_data(dt.to_string()));
	}

	public bool set_data_provider(ClipboardDataProvider dp) {
		//FIXME
		return(false);
	}

	String get_string_data() {
		strptr v = null;
		embed "c++" {{{
			if(OpenClipboard(NULL)) {
				HANDLE clipboarddata = GetClipboardData(CF_TEXT);
				char* strdata = (char*)GlobalLock(clipboarddata);
				v = strdata;
				GlobalUnlock(clipboarddata);
				CloseClipboard();
			}
		}}}
		if(v == null) {
			return(null);
		}
		return(String.for_strptr(v));
	}

	public bool get_data(EventReceiver listener) {
		if(listener == null) {
			return(false);
		}
		listener.on_event(ClipboardData.for_string(get_string_data()));
		return(true);
	}
}
