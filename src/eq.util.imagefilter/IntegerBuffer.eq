
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

class IntegerBuffer
{
	IFDEF("target_c") {
		embed "c" {{{
			#include <stdio.h>
		}}}
		ptr buffer;
	}
	ELSE IFDEF("target js") {
	}
	ELSE {
		embed {{{
			int[] buffer;
		}}}
	}

	~IntegerBuffer() {
		IFDEF("target_c") {
			var b = buffer;
			if(b != null) {
				embed "c" {{{
					free(b);
				}}}
			}
		}
	}

	public static IntegerBuffer create(int size) {
		var v = new IntegerBuffer();
		return(v.init(size));
	}

	IntegerBuffer init(int sz) {
		IFDEF("target_c") {
			ptr b;
			embed "c" {{{
				b = malloc(sz*sizeof(int));
				memset(b, 0, sizeof(int)*sz);
			}}}
			buffer = b;
		}
		ELSE IFDEF("target_js") {
		}
		ELSE {
			embed {{{
				buffer = new int[sz];
			}}}
		}
		return(this);
	}

	public int get_index(int i) {
		IFDEF("target_c") {
			var b = buffer;
			if(b != null) {
				embed {{{
					int* ib = (int*)b;
					return(ib[i]);
				}}}
			}
		}
		ELSE IFDEF("target_js") {
		}
		ELSE {
			embed {{{
				if(buffer != null) {
					return(buffer[i]);
				}
			}}}
		}
		return(0);
	}

	public void set_index(int i, int v) {
		IFDEF("target_c") {
			var b = buffer;
			if(b != null) {
				embed {{{
					int* ib = (int*)b;
					ib[i] = v;
				}}}
			}
		}
		ELSE IFDEF("target_js") {
		}
		ELSE {
			embed {{{
				if(buffer != null) {
					buffer[i] = v;
				}
			}}}
		}
	}
}