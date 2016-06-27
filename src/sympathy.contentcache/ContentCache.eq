
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

public class ContentCache : LoggerObject
{
	class CacheEntry
	{
		property Object data;
		property int ttl;
		property int timestamp;
	}

	HashTable cache;
	property int cache_ttl = 3600;

	public void on_maintenance() {
		if(cache == null) {
			return;
		}
		var expired = LinkedList.create();
		var now = SystemClock.seconds();
		foreach(String key in cache.iterate_keys()) {
			var ce = cache.get(key) as CacheEntry;
			if(ce == null) {
				expired.add(key);
				continue;
			}
			var diff = now - ce.get_timestamp();
			if(diff >= ce.get_ttl()) {
				expired.add(key);
			}
		}
		if(expired.count() > 0) {
			log_debug("Removing %d expired content cache items.".printf().add(expired.count()));
			foreach(String key in expired) {
				cache.remove(key);
			}
		}
	}

	public void clear() {
		cache = null;
	}

	public void invalidate(String cacheid) {
		if(cache != null) {
			cache.set(cacheid, null);
		}
	}

	public void set(String cacheid, Object content, int ttl = -1) {
		if(cacheid == null) {
			return;
		}
		var ee = new CacheEntry();
		ee.set_data(content);
		if(ttl >= 0) {
			ee.set_ttl(ttl);
		}
		else {
			ee.set_ttl(cache_ttl);
		}
		if(ee.get_ttl() < 1) {
			return;
		}
		ee.set_timestamp(SystemClock.seconds());
		if(cache == null) {
			 cache = HashTable.create();
		}
		log_debug("Set cache item: `%s' (ttl %d)".printf().add(cacheid).add(ee.get_ttl()));
		cache.set(cacheid, ee);
	}

	public Object get(String cacheid) {
		if(cache == null) {
			return(null);
		}
		var ee = cache.get(cacheid) as CacheEntry;
		if(ee != null) {
			log_debug("`%s': Content cached".printf().add(cacheid));
			var diff = SystemClock.seconds() - ee.get_timestamp();
			if(diff >= ee.get_ttl()) {
				log_debug("`%s': Cache entry expired".printf().add(cacheid));
				cache.remove(cacheid);
				ee = null;
			}
		}
		if(ee != null) {
			return(ee.get_data());
		}
		return(null);
	}

	public void remove(String cacheid) {
		if(cache != null && cacheid != null) {
			cache.remove(cacheid);
		}
	}
}
