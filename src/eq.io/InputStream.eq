
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

public class InputStream : Reader
{
	public static InputStream for_reader(Reader reader, int buffersize = 1024) {
		if(reader == null) {
			return(null);
		}
		var v = new InputStream();
		v.reader = reader;
		v.buffer = DynamicBuffer.create(buffersize);
		if(v.buffer == null) {
			return(null);
		}
		v.bptr = v.buffer.get_pointer();
		return(v);
	}

	// deprecated
	public static InputStream create(Reader reader, int buffersize = 1024) {
		return(InputStream.for_reader(reader, buffersize));
	}

	Buffer buffer = null;
	int buffers = 0;
	int bufferp = 0;
	Reader reader = null;
	bool eof = false;
	uint8 current = 0;
	Pointer bptr;
	bool been_read = false;

	public void close() {
		if(reader != null) {
			if(reader is ClosableReader) {
				((ClosableReader)reader).close();
			}
			reader = null;
		}
	}

	public Reader get_reader() {
		return(reader);
	}

	public bool is_eof() {
		return(eof);
	}

	public Buffer read_all_buffer() {
		if(reader == null) {
			return(null);
		}
		if(been_read == false && reader is SizedReader) {
			var sz = ((SizedReader)reader).get_size();
			if(sz >= 0) {
				var rb = DynamicBuffer.create(sz);
				if(rb == null) {
					return(null);
				}
				var rc = reader.read(rb);
				if(rc < sz) {
					return(null);
				}
				return(rb);
			}
		}
		var r = DynamicBuffer.create(0);
		if(buffers - bufferp > 0) {
			if(r.append(buffers) == false) {
				return(null);
			}
			var dptr = r.get_pointer();
			if(dptr == null) {
				return(null);
			}
			if(dptr.cpyfrom(buffer.get_pointer(), bufferp, 0, buffers - bufferp) == false) {
				return(null);
			}
		}
		var tb = DynamicBuffer.create(4096);
		while(true) {
			var c = reader.read(tb);
			if(c < 1) {
				break;
			}
			if(DynamicBuffer.cat(r, tb, c) == false) {
				return(null);
			}
		}
		return(r);
	}

	public String read_all_string() {
		var bb = read_all_buffer();
		if(bb == null) {
			return(null);
		}
		return(String.for_utf8_buffer(bb, false));
	}

	public String readline() {
		DynamicBuffer v = null;
		int vsz = 0;
		int n = 0;
		while(!eof) {
			if(nextbyte() == false) {
				break;
			}
			var c = current;
			if(c == '\n') {
				if(v == null) {
					v = DynamicBuffer.create(0);
					vsz = v.get_size();
				}
				break;
			}
			if(c == '\r') {
				continue;
			}
			if(v == null) {
				v = DynamicBuffer.create(1024);
				vsz = v.get_size();
			}
			if(v != null) {
				if(n >= vsz) {
					v.allocate(vsz + 1024);
					vsz = v.get_size();
				}
				if(n < vsz) {
					var ptr = v.get_pointer();
					if(ptr != null) {
						ptr.set_byte(n, c);
						n++;
					}
				}
			}
		}
		if(v != null) {
			if(n >= vsz) {
				v.allocate(vsz + 1);
				vsz = v.get_size();
			}
			if(n < vsz) {
				var ptr = v.get_pointer();
				if(ptr != null) {
					ptr.set_byte(n++, 0);
				}
			}
			if(n != vsz) {
				v.allocate(n);
				vsz = v.get_size();
			}
		}
		if(v == null) {
			return(null);
		}
		return(String.for_utf8_buffer(v));
	}

	public bool nextbyte() {
		been_read = true;
		bool v = false;
		if(reader == null || eof) {
			eof = true;
			return(false);
		}
		if(buffers - bufferp == 0) {
			buffers = reader.read(buffer);
			if(buffers < 0) {
				buffers = 0;
			}
			bufferp = 0;
		}
		if(buffers - bufferp == 0) {
			eof = true;
		}
		else if(bufferp < buffers) {
			if(bptr != null) {
				current = bptr.get_byte(bufferp);
				bufferp ++;
				v = true;
			}
		}
		return(v);
	}

	public uint8 getbyte() {
		return(current);
	}

	public int read(Buffer buf) {
		if(buf == null || buf.get_size() < 1) {
			return(0);
		}
		int r = 0;
		var ptr = buf.get_pointer();
		while(r < buf.get_size() && nextbyte()) {
			ptr.set_byte(r, current);
			r++;
		}
		return(r);
	}

	public Integer read_int8() {
		if(nextbyte()) {
			return(Primitive.for_integer((int)current));
		}
		return(null);
	}

	public Integer read_int16() {
		var buf = DynamicBuffer.create(2);
		if(buf != null) {
			if(read(buf) == 2) {
				return(Primitive.for_integer(Integer.from_buffer16(buf)));
			}
		}
		return(null);
	}

	public Integer read_int32() {
		var buf = DynamicBuffer.create(4);
		if(buf != null) {
			if(read(buf) == 4) {
				return(Primitive.for_integer(Integer.from_buffer32(buf)));
			}
		}
		return(null);
	}

	public Buffer read_long_buffer() {
		var bb = Integer.long_to_buffer(0);
		if(bb == null) {
			return(null);
		}
		var len = bb.get_size();
		if(len < 1) {
			return(null);
		}
		var buf = DynamicBuffer.create(len);
		if(buf == null) {
			return(null);
		}
		if(read(buf) != len) {
			return(null);
		}
		return(buf);
	}

	public Buffer read_int_buffer() {
		var bb = Integer.int_to_buffer(0);
		if(bb == null) {
			return(null);
		}
		var len = bb.get_size();
		if(len < 1) {
			return(null);
		}
		var buf = DynamicBuffer.create(len);
		if(buf == null) {
			return(null);
		}
		if(read(buf) != len) {
			return(null);
		}
		return(buf);
	}
}

