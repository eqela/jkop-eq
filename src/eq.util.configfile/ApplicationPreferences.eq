
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

public interface ApplicationPreferences
{
	public static ApplicationPreferences for_this_application() {
		return(ApplicationPreferences.for_application(null));
	}

	public static ApplicationPreferences for_application(String aname = null) {
		ApplicationPreferences v = null;
		IFDEF("target_html") {
			if(aname != null) {
				return(null);
			}
			Log.warning("ApplicationPreferences / HTML: Not implemented"); // FIXME
		}
		ELSE IFDEF("target_j2me") {
			if(aname != null) {
				return(null);
			}
			Log.warning("ApplicationPreferences / J2ME: Not implemented"); // FIXME
		}
		ELSE {
			var ad = ApplicationData.for_application(aname);
			if(ad == null) {
				return(null);
			}
			v = new ApplicationPreferencesFile().set_file(ad.entry("preferences"));
		}
		return(v);
	}

	public void set(String key, String value);
	public String get(String key);
	public HashTable as_hash_table();
	public bool save();
}
