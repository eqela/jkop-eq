
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

public class DNSCache
{
	class DNSCacheEntry
	{
		property String ip;
		property int timestamp;
		public static DNSCacheEntry create(String ip) {
			var v = new DNSCacheEntry();
			v.ip = ip;
			v.timestamp = SystemClock.seconds();
			return(v);
		}
	}

	class DNSCacheImpl
	{
		HashTable entries = null;
		Mutex mutex = null;

		public DNSCacheImpl() {
			entries = HashTable.create();
			mutex = Mutex.create();
		}

		void add(String hostname, String ip) {
			if(mutex != null) {
				mutex.lock();
			}
			entries.set(hostname, DNSCacheEntry.create(ip));
			if(mutex != null) {
				mutex.unlock();
			}
		}

		String get_cached_entry(String hostname) {
			DNSCacheEntry v = null;
			if(mutex != null) {
				mutex.lock();
			}
			v = entries.get(hostname) as DNSCacheEntry;
			if(mutex != null) {
				mutex.unlock();
			}
			if(v != null) {
				// expire cached entries in one hour
				if(SystemClock.seconds() - v.get_timestamp() > 60 * 60) {
					if(mutex != null) {
						mutex.lock();
					}
					entries.set(hostname, null);
					if(mutex != null) {
						mutex.unlock();
					}
					v = null;
				}
			}
			if(v != null) {
				return(v.get_ip());
			}
			return(null);
		}

		public String resolve(String hostname) {
			var v = get_cached_entry(hostname);
			if(v != null) {
				Log.debug("DNSCache: `%s' -> `%s' (cached)".printf().add(hostname).add(v));
				return(v);
			}
			var dr = DNSResolver.create();
			if(dr == null) {
				return(null);
			}
			v = dr.get_ip_address(hostname);
			if(v != null) {
				Log.debug("DNSCache: `%s' -> `%s' (resolved)".printf().add(hostname).add(v));
				add(hostname, v);
			}
			return(v);
		}
	}

	private static DNSCacheImpl cc = null;

	public static String resolve(String hostname) {
		if(cc == null) {
			cc = new DNSCacheImpl();
		}
		return(cc.resolve(hostname));
	}
}

