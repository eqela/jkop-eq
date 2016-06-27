
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

IFNDEF("target_j2me") {
	class StringBufferImpl : Stringable, StringBuffer
	{
		embed "Java" {{{
			private StringBuilder builder = null;
		}}}

		public void allocate(int sz) {
			embed {{{
				builder.ensureCapacity(sz);
			}}}
		}

		public Buffer get_buffer() {
			ptr jptr = null;
			int len = 0;
			embed "Java" {{{
				try {
					jptr = builder.toString().getBytes("UTF-8");
				}
				catch(Exception e) {
					return(null);
				}
				len = jptr.length;
			}}}
			return(Buffer.for_pointer(Pointer.create(jptr), len));
		}

		public StringBufferImpl() {
			embed "Java" {{{
				builder = new StringBuilder();
			}}}
		}

		public StringBuffer dup() {
			var v = new StringBufferImpl();
			embed "Java" {{{
				v.builder.append(builder);
			}}}
			return(v);
		}

		public int count() {
			int v;
			embed "Java" {{{
				v = builder.length();
			}}}
			return(v);
		}

		public void clear() {
			embed "Java" {{{
				builder.setLength(0);
			}}}
		}

		public void append(String c) {
			if(c != null) {
				embed "Java" {{{
					builder.append(c.to_strptr());
				}}}
			}
		}

		public void append_c(int c) {
			embed "Java" {{{
				builder.append((char)c);
			}}}
		}

		public String dup_string() {
			var ds = dup() as Stringable;
			return(ds.to_string());
		}

		public String to_string() {
			String v;
			strptr vptr = null;
			embed "Java" {{{
				vptr = builder.toString();
			}}}
			v = String.for_strptr(vptr);
			embed "Java" {{{
				builder.setLength(0);
			}}}
			return(v);
		}
	}
}

