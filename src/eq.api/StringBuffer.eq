
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

public interface StringBuffer : Stringable
{
	public static StringBuffer create(String initial = null) {
		var v = new StringBufferImpl();
		if(initial != null) {
			v.append(initial);
		}
		return(v);
	}

	public static StringBuffer for_string(String initial) {
		var v = new StringBufferImpl();
		if(initial != null) {
			v.append(initial);
		}
		return(v);
	}

	public static StringBuffer for_initial_size(int szbytes) {
		var v = new StringBufferImpl();
		IFDEF("target_c") {
			v.grow(szbytes);
		}
		IFDEF("target_java") {
			IFNDEF("target_j2me") {
				v.allocate(szbytes);
			}
		}
		return(v);
	}

	public void append(String c);
	public void append_c(int c);
	public StringBuffer dup();
	public String dup_string();
	public Buffer get_buffer();
	public void clear();
	public int count();
}
