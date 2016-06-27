
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
	embed "cs" {{{
		private System.Text.StringBuilder builder = null;
	}}}

	public Buffer get_buffer() {
		Buffer buf = null;
		var v = dup() as StringBuffer;
		if (v!=null) {
			var s = v.to_string();
			buf = s.to_utf8_buffer(false);
		}
		return(buf);
	}

	public StringBufferImpl() {
		embed "cs" {{{
			builder = new System.Text.StringBuilder();
		}}}
	}

	public StringBuffer dup() {
		var v = new StringBufferImpl();
		strptr str = null;
		embed "cs" {{{
			str = builder.ToString();
		}}}
		v.append(String.for_strptr(str));
		return(v);
	}

	public int count() {
		int v;
		embed "cs" {{{
			v = builder.Length;
		}}}
		return(v);
	}

	public void clear() {
		embed "cs" {{{
			builder.Clear();
		}}}
	}

	public void append(String c) {
		if(c != null) {
			embed "cs" {{{
				builder.Append(c.to_strptr());
			}}}
		}
	}

	public void append_c(int c) {
		if(c < 1) {
			return;
		}
		embed "cs" {{{
			builder.Append((char)c);
		}}}
	}

	public String dup_string() {
		strptr vptr = null;
		embed "cs" {{{
			vptr = builder.ToString();
		}}}
		return(String.for_strptr(vptr));
	}

	public String to_string() {
		var v = dup_string();
		embed "cs" {{{
			builder.Clear();
		}}}
		return(v);
	}
}

