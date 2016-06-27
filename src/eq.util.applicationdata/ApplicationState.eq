
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

public class ApplicationState
{
	static File get_state_file(String id) {
		var ad = ApplicationData.for_this_application();
		if(ad == null) {
			return(null);
		}
		var ii = id;
		if(String.is_empty(ii)) {
			ii = "app";
		}
		return(ad.entry(ii.append(".state")));
	}

	public static bool save(HashTable data, String id = null) {
		var f = get_state_file(id);
		if(f == null) {
			return(false);
		}
		var pp = f.get_parent();
		if(pp != null && pp.is_directory() == false) {
			pp.mkdir_recursive();
		}
		return(f.set_contents_string(JSONEncoder.encode(data)));
	}

	public static HashTable restore(String id = null) {
		var f = get_state_file(id);
		if(f == null) {
			return(null);
		}
		return(JSONParser.parse_file(f) as HashTable);
	}

	public static bool remove(String id = null) {
		var f = get_state_file(id);
		if(f == null) {
			return(false);
		}
		return(f.remove());
	}
}
