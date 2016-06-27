
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

public class GtkUrlHandler
{
	embed "c" {{{
		#include <gtk/gtk.h>
	}}}

	public static bool open(String url) {
	Log.debug("GTK opening URL: `%s' ..".printf().add(url));
		if(open_env_browser(url)) {
			return(true);
		}
		if(open_default_browser(url)) {
			return(true);
		}
		if(open_browser("firefox", url)) {
			return(true);
		}
		if(open_browser("chrome", url)) {
			return(true);
		}
		if(open_browser("opera", url)) {
			return(true);
		}
		Log.error("Unable to find a working browser to open the URL with.");
		return(false);
	}

	static bool open_browser(String browser, String url) {
		if(String.is_empty(browser)) {
			return(false);
		}
		File bf;
		if(browser.has_prefix("/")) {
			bf = File.for_native_path(browser);
		}
		else {
			bf = SystemEnvironment.find_command(browser);
		}
		if(bf.is_file() == false) {
			return(false);
		}
		Log.debug("Opening URL with browser `%s' ..".printf().add(bf));
		var pp = ProcessLauncher.for_file(bf).add_param(url).start();
		if(pp != null) {
			return(true);
		}
		return(false);
	}

	static bool open_env_browser(String url) {
		var bb = SystemEnvironment.get_env_var("BROWSER");
		if(String.is_empty(bb)) {
			return(false);
		}
		Log.debug("Trying to open URL with BROWSER `%s' ..".printf().add(bb));
		return(open_browser(bb, url));
	}

	static bool open_default_browser(String url) {
		bool v = true;
		if(url != null) {
			String strurl = null;
			if(url.has_prefix("http://")) {
				strurl = url;
			}
			else {
				strurl = "http://%s".printf().add(url).to_string();
			}
			strptr new_url = strurl.to_strptr();
			Gtk.init();
			strptr eptr;
			embed "c" {{{
				GError *error = NULL;
				gtk_show_uri(NULL, new_url, gtk_get_current_event_time(), &error);
				if(error != NULL) {
					eptr = error->message;
				}
			}}}
			if(eptr != null) {
				Log.debug("Error when opening URL through GTK: `%s'".printf().add(String.for_strptr(eptr)));
				v = false;
			}
			embed "c" {{{
				if(error != NULL) {
					g_error_free(error);
				}
			}}}
		}
		return(v);
	}
}

