
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
	int length;

	public StringBufferImpl() {
		embed "js" {{{
			this.strings = new Array("");
		}}}
		this.length = 0;
	}

	public Buffer get_buffer() {
		return(null); // FIXME
	}

	public StringBuffer dup() {
		var v = new StringBufferImpl();
		v.append(this.to_string());
		return(v);
	}

	public int count() {
		return(length);
	}

	public void clear() {
		embed "js" {{{
			this.strings = new Array("");
		}}}
		this.length = 0;
	}

	public void append(String c) {
		if(c != null) {
			embed "js" {{{
				this.strings.push(c.to_strptr());
			}}}
			length += c.get_length();
		}
	}

	public void append_c(int c) {
		embed "js" {{{
			this.strings.push(String.fromCharCode(c));
		}}}
		this.length ++;
	}

	public String dup_string() {
		var ds = dup() as Stringable;
		return(ds.to_string());
	}

	public String to_string() {
		String v;
		embed "js" {{{
			v = eq.api.StringStatic.for_strptr(this.strings.join(""));
		}}}
		return(v);
	}
}

