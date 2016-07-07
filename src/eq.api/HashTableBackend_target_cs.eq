
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

class HashTableBackend : HashTableBase
{
	embed "cs" {{{
		System.Collections.Generic.Dictionary<string, object> hashtable = null;
	}}}

	public HashTableBackend() {
		embed "cs" {{{
			hashtable = new System.Collections.Generic.Dictionary<string, object>();
		}}}
	}

	public override bool allocate(int size) {
		// not supported
		clear();
		return(true);
	}

	public override HashTable set(String k, Object v) {
		if(k == null) {
			return(null);
		}
		embed "cs" {{{
			if(hashtable != null) {
				hashtable[k.to_strptr()] = v as object;
			}
		}}}
		return(this);
	}

	public override Object get(String k) {
		if(k == null) {
			return(null);
		}
		embed "cs" {{{
			if(hashtable!=null && hashtable.ContainsKey(k.to_strptr())) {
				return(hashtable[k.to_strptr()] as eq.api.Object);
			}
		}}}
		return(null);
	}

	public override void clear() {
		embed "cs" {{{	
			if(hashtable!=null) {
				hashtable.Clear();
			}
		}}}
	}

	public override void remove(String k) {
		if(k == null) {
			return;
		}
		embed "cs" {{{
			if(hashtable!=null) {
				hashtable.Remove(k.to_strptr());
			}
		}}}
	}

	public override Iterator iterate_keys() {
		var keyarr = Array.create();
		if(keyarr == null) {
			return(null);
		}
		String str;
		strptr x;
		embed "cs" {{{
			if(hashtable == null) {
				return(null);
			}
			System.Collections.Generic.Dictionary<string, object>.KeyCollection keys = hashtable.Keys;
			foreach(string k in keys) {
				x = k;
				}}}
				str = String.for_strptr(x);
				embed "cs" {{{
				((eq.api.Collection)keyarr).add((eq.api.Object)str);
			}
		}}}
		return(keyarr.iterate());
	}

	public override Iterator iterate_values() {
		var valarr = Array.create();
		if(valarr == null) {
			return(null);
		}
		embed "cs" {{{
			if(hashtable == null) {
				return(null);
			}
			System.Collections.Generic.Dictionary<string, object>.ValueCollection values = hashtable.Values;
			foreach(eq.api.Object v in values) {
				((eq.api.Collection)valarr).add(v);
			}
		}}}
		return(valarr.iterate());
	}

	public override int count() {
		embed "cs" {{{
			if(hashtable!=null) {
				return(hashtable.Count);
			}
		}}}
		return(0);
	}
}

