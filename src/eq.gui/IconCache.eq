
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

public class IconCache
{
	IFDEF("target_uwpcs") {
		embed "cs" {{{
			[System.ThreadStatic]
		}}}
	}

	private static HashTable iconcache;
	private static Mutex mutex;

	static Image cache_get(String id) {
		Image v;
		if(mutex != null) {
			mutex.lock();
		}
		if(iconcache != null) {
			v = iconcache.get(id) as Image;
		}
		if(mutex != null) {
			mutex.unlock();
		}
		return(v);
	}

	static void cache_set(String id, Image img) {
		if(mutex != null) {
			mutex.lock();
		}
		if(iconcache == null) {
			iconcache = HashTable.create();
		}
		iconcache.set(id, img);
		if(mutex != null) {
			mutex.unlock();
		}
	}

	public static Image get(Object ida, int sizewa = -1, int sizeha = -1, bool allow_null = false) {
		if(mutex == null) {
			mutex = Mutex.create();
		}
		if(ida == null) {
			return(null);
		}
		if(ida is Image) {
			return(ida as Image);
		}
		if(ida is String == false) {
			return(null);
		}
		var id = ida as String;
		Image v = cache_get(id);
		IFNDEF("target_html") {
			if(v == null) {
				Log.debug("IconCache: Loading `%s' ..".printf().add(id));
				v = Image.for_resource(id);
				if(v != null) {
					cache_set(id, v);
				}
			}
		}
		if(v == null) {
			if(allow_null == false) {
				if(id.equals("_missing_image") == false) {
					v = get("_missing_image", -1, -1);
				}
			}
		}
		int sizew = sizewa;
		int sizeh = sizeha;
		if(sizeh < 1) {
			sizeh = sizew;
		}
		if(v != null && sizew < 1 && sizeh > 0) {
			sizew = (int)((double)v.get_width() / ((double)v.get_height() / (double)sizeh));
		}
		if(v != null && sizew > 0 && sizeh > 0) {
			v = v.resize(sizew, sizeh);
		}
		return(v);
	}

	public static void load(String id) {
		if(mutex == null) {
			mutex = Mutex.create();
		}
		if(id == null || id.get_length() < 1) {
			return;
		}
		var v = cache_get(id);
		if(v == null) {
			Log.debug("IconCache: Loading `%s' ..".printf().add(id));
			v = Image.for_resource(id);
			if(v != null) {
				cache_set(id, v);
			}
		}
	}

	public static bool is_loaded() {
		bool v = true;
		if(mutex == null) {
			mutex = Mutex.create();
		}
		if(mutex != null) {
			mutex.lock();
		}
		if(iconcache != null) {
			foreach(String k in iconcache.iterate_keys()) {
				var img = iconcache.get(k) as AsyncImage;
				if(img != null && img.is_loaded() == false) {
					v = false;
					break;
				}
			}
		}
		if(mutex != null) {
			mutex.unlock();
		}
		return(v);
	}

	public static void remove_empty_images() {
		if(mutex == null) {
			mutex = Mutex.create();
		}
		if(mutex != null) {
			mutex.lock();
		}
		if(iconcache != null) {
			var toremove = LinkedList.create();
			foreach(String k in iconcache.iterate_keys()) {
				var img = iconcache.get(k) as Image;
				if(img != null && (img.get_width() < 1 || img.get_height() < 1)) {
					toremove.append(k);
				}
			}
			foreach(String key in toremove) {
				iconcache.remove(key);
			}
		}
		if(mutex != null) {
			mutex.unlock();
		}
	}
}

