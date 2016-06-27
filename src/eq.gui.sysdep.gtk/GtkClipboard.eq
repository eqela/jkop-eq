
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

class GtkClipboard : Clipboard
{
	embed "c" {{{
		#include <gtk/gtk.h>
	}}}

	bool set_data_string(String text) {
		var tt = text;
		if(tt == null) {
			tt = "";
		}
		var tp = tt.to_strptr();
		embed "c" {{{
			GtkClipboard* cp = gtk_clipboard_get(GDK_SELECTION_CLIPBOARD);
			if(cp != NULL) {
				gtk_clipboard_set_text(cp, tp, -1);
				gtk_clipboard_store(cp);
			}
		}}}
		return(true);
	}

	public bool set_data(ClipboardData data) {
		var dt = data;
		if(dt == null) {
			dt = ClipboardData.for_string("");
		}
		if("text/plain".equals(dt.get_mimetype()) == false) {
			Log.error("GtkClipboard.set_data: Mime type `%s' is not supported".printf().add(dt.get_mimetype()));
			return(false);
		}
		return(set_data_string(dt.to_string()));
	}

	public bool set_data_provider(ClipboardDataProvider dp) {
		Log.error("GtkClipboard.set_data_provider: Not implemented");
		return(false);
	}

	String get_data_string() {
		strptr tp;
		embed "c" {{{
			GtkClipboard* cp = gtk_clipboard_get(GDK_SELECTION_CLIPBOARD);
			if(cp != NULL) {
				tp = gtk_clipboard_wait_for_text(cp);
			}
		}}}
		return(String.for_strptr(tp));
	}

	public bool get_data(EventReceiver listener) {
		if(listener == null) {
			return(false);
		}
		listener.on_event(ClipboardData.for_string(get_data_string()));
		return(true);
	}
}
