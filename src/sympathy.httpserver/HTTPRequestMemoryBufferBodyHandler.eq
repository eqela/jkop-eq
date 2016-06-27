
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

public class HTTPRequestMemoryBufferBodyHandler : HTTPRequestBodyHandler, Reader
{
	public static HTTPRequestMemoryBufferBodyHandler for_maximum_size(int sz) {
		return(new HTTPRequestMemoryBufferBodyHandler().set_maximum_size(sz));
	}

	property int maximum_size;
	BufferWriter writer;
	Buffer buffer;
	Reader reader;

	public Buffer get_buffer() {
		return(buffer);
	}

	public bool on_body_start(int length) {
		if(maximum_size >= 0 && length > maximum_size) {
			return(false);
		}
		Buffer buffer;
		if(length > 0) {
			buffer = DynamicBuffer.create(length);
		}
		writer = BufferWriter.for_buffer(buffer);
		return(true);
	}

	public bool on_body_data(Buffer data) {
		if(writer != null && data != null) {
			if(writer.get_buffer_pos() + data.get_size() > maximum_size) {
				return(false);
			}
			writer.write(data, -1);
		}
		return(true);
	}

	public bool on_body_end() {
		buffer = writer.get_buffer();
		writer = null;
		reader = BufferReader.for_buffer(buffer);
		return(true);
	}

	public int read(Buffer buf) {
		if(reader != null) {
			return(reader.read(buf));
		}
		return(0);
	}
}
