
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

class ArrayImpl : ArrayBase
{
	embed "c" {{{
		#include <stdlib.h>
		#include <string.h>
	}}}

	private ptr data = null;
	private int allocated = 0;
	private int items = 0;

	public ArrayImpl() {
	}

	~ArrayImpl() {
		clear();
	}

	public void clear() {
		var data = this.data;
		if(data != null) {
			int n;
			for(n=0; n<items; n++) {
				embed "c" {{{
					void* p = ((void**)data)[n];
					if(p != NULL) {
						unref_eq_api_Object(p);
					}
				}}}
			}
			embed "c" {{{
				free((void*)data);
			}}}
			this.data = null;
			allocated = 0;
			items = 0;
		}
	}

	private void do_allocate(int size) {
		var data = this.data;
		int original = allocated;
		embed "c" {{{
			data = realloc(data, size * sizeof(void*));
			if(data!=(void*)0 && size > original) {
				memset((void*)(data+original*sizeof(void*)), 0, (size-original) * sizeof(void*));
			}
		}}}
		this.data = data;
		if(data != null) {
			allocated = size;
		}
	}

	private void grow() {
		do_allocate(allocated + 4096);
	}

	public bool allocate(int size) {
		if(size > allocated) {
			do_allocate(size);
		}
		if(allocated >= size) {
			items = size;
			return(true);
		}
		return(false);
	}

	public int count() {
		return(items);
	}

	public Object get_index(int n) {
		Object v = null;
		if(n>=0 && n<items) {
			var data = this.data;
			embed "c" {{{
				v = ref_eq_api_Object(((void**)data)[n]);
			}}}
		}
		return(v);
	}

	public bool set_index(int n, Object o) {
		bool v = false;
		if(n>=0 && n<items) {
			var data = this.data;
			embed "c" {{{
				if(((void**)data)[n] != ((void*)0)) {
					unref_eq_api_Object(((void**)data)[n]);
				}
				((void**)data)[n] = ref_eq_api_Object(o);
			}}}
			v = true;
		}
		return(v);
	}

	public Collection add(Object o) {
		if(items >= allocated) {
			grow();
		}
		if(items < allocated) {
			var data = this.data;
			var its = items;
			embed "c" {{{
				((void**)data)[its] = ref_eq_api_Object(o);
			}}}
			items++;
		}
		return(this);
	}

	public Collection insert(Object o, int i) {
		if (i >= 0 && i <= count()) {
			if(items >= allocated) {
				grow();
			}
			var data = this.data;
			int n;
			for(n=items-1; n>=i; n--) {
				embed "c" {{{
					((void**)data)[n+1] = ((void**)data)[n];
				}}}
			}
			embed "c" {{{
				((void**)data)[i] = ref_eq_api_Object(o);
			}}}
			items++;
		}
		return(this);
	}

	public bool remove(Object o) {
		bool v = false;
		var data = this.data;
		int n=0;
		for(n=0 ;data!=null && n<items; n++) {
			embed "c" {{{
				if(((void**)data)[n] == o) {
					break;
				}
			}}}
		}
		if(n >= 0 && n < items && data != null) {
			remove_index(n);
			/*
			var its = items;
			embed "c" {{{
				unref_eq_api_Object(((void**)data)[n]);
				for(i=n; i<its-1; i++) {
					((void**)data)[i] = ((void**)data)[i+1];
				}
				((void**)data)[its-1] = (void*)0;
			}}}
			items--;
			*/
			v = true;
		}
		return(v);
	}

	public void remove_index(int n) {
		var data = this.data;
		if(n < 0 || n >= items || data == null) {
			return;
		}
		int i;
		var its = items;
		embed "c" {{{
			unref_eq_api_Object(((void**)data)[n]);
			for(i=n; i<its-1; i++) {
				((void**)data)[i] = ((void**)data)[i+1];
			}
			((void**)data)[its-1] = (void*)0;
		}}}
		items--;
	}

	public void remove_range(int first, int last) {
		var data = this.data;
		if(last < first || last < 0 || first >= items || data == null) {
			return;
		}
		int f = first, l = last, x;
		if(f < 0) {
			f = 0;
		}
		if(l >= items) {
			l = items-1;
		}
		var its = items;
		embed "c" {{{
			for(x=f; x<=l; x++) {
				unref_eq_api_Object(((void**)data)[x]);
			}
			x = l + 1;
			int d = f;
			while(x < its) {
				((void**)data)[d] = ((void**)data)[x];
				x ++;
				d ++;
			}
			((void**)data)[d] = (void*)0;
		}}}
		items -= (l - f + 1);
	}
}

