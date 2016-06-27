
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

public class StringReader : Reader, Stringable, SizedReader
{
	public static StringReader for_string(String str) {
		return(new StringReader().set_string(str));
	}

	// deprecated
	public static StringReader create(String str) {
		return(new StringReader().set_string(str));
	}

	String str;
	Buffer buffer;
	BufferReader rd;

	public StringReader set_string(String str) {
		this.str = str;
		this.buffer = null;
		this.rd = null;
		if(str != null) {
			this.buffer = str.to_utf8_buffer(false);
			this.rd = BufferReader.for_buffer(this.buffer);
		}
		return(this);
	}

	public Buffer get_buffer() {
		return(buffer);
	}

	public BufferReader get_buffer_reader() {
		return(rd);
	}

	public String get_string() {
		return(str);
	}

	public int read(Buffer buf) {
		if(rd == null) {
			return(0);
		}
		return(rd.read(buf));
	}

	public int get_size() {
		if(buffer != null) {
			return(buffer.get_size());
		}
		return(0);
	}

	public String to_string() {
		return(str);
	}
}
