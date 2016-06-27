
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

class StringBufferImpl : Stringable, StringBuffer
{
	embed "Java" {{{
		private java.lang.StringBuffer buffer = null;
	}}}

	public Buffer get_buffer() {
		return(null); // FIXME
	}

	public StringBufferImpl() {
		embed "Java" {{{
			buffer = new java.lang.StringBuffer();
		}}}
	}

	public StringBuffer dup() {
		var v = new StringBufferImpl();
		embed "Java" {{{
			v.buffer.append(buffer);
		}}}
		return(v);
	}

	public int count() {
		int v;
		embed "Java" {{{
			v = buffer.length();
		}}}
		return(v);
	}

	public void clear() {
		embed "Java" {{{
			buffer = new java.lang.StringBuffer();	
		}}}
	}

	public void append(String c) {
		if(c != null) {
			embed "Java" {{{
				buffer.append(c.to_strptr());
			}}}
		}
	}

	public void append_c(int c) {
		embed "Java" {{{
			buffer.append((char)c);
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
			vptr = buffer.toString();
		}}}
		v = String.for_strptr(vptr);
		embed "Java" {{{
			buffer = new java.lang.StringBuffer();	
		}}}
		return(v);
	}
}

