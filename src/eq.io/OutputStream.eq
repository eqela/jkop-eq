
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

public class OutputStream : Writer
{
	public static OutputStream for_writer(Writer w) {
		if(w == null) {
			return(null);
		}
		return(new OutputStream().set_writer(w));
	}

	// deprecated
	public static OutputStream create(Writer w) {
		if(w == null) {
			return(null);
		}
		return(new OutputStream().set_writer(w));
	}

	property Writer writer = null;
	property bool insert_carriage_return = false;

	public void close() {
		var cw = writer as ClosableWriter;
		if(cw != null) {
			cw.close();
		}
		writer = null;
	}

	public int write(Buffer b, int asz = -1) {
		var sz = asz;
		if(sz < 0 && b != null) {
			sz = b.get_size();
		}
		return(writer.write(b, sz));
	}

	public bool write_buffer(Buffer b) {
		if(b == null) {
			return(true);
		}
		if(write(b) == b.get_size()) {
			return(true);
		}
		return(false);
	}

	private void appendbyte(DynamicBuffer buffer, uint8 byte) {
		int pos = buffer.get_size();
		if(buffer.append(1)) {
			var ptr = buffer.get_pointer();
			if(ptr != null) {
				ptr.set_byte(pos, byte);
			}
		}
	}

	public bool write_byte(uint8 byte) {
		bool v = false;
		var buf = DynamicBuffer.create(0);
		if(buf != null) {
			appendbyte(buf, byte);
			if(write(buf, -1) > 0) {
				v = true;
			}
		}
		return(v);
	}

	public bool write_int(int n) {
		var bb = Integer.int_to_buffer(n);
		if(bb == null) {
			return(false);
		}
		return(write(bb) == bb.get_size());
	}

	public bool write_long(long n) {
		var bb = Integer.long_to_buffer(n);
		if(bb == null) {
			return(false);
		}
		return(write(bb) == bb.get_size());
	}

	public bool write_int8(int byte) {
		return(write(Integer.to_buffer8(byte)) == 1);
	}

	public bool write_int16(int word) {
		return(write(Integer.to_buffer16(word)) == 2);
	}

	public bool write_int32(int lword) {
		return(write(Integer.to_buffer32(lword)) == 4);
	}

	public bool write_string(String d) {
		if(d == null) {
			return(false);
		}
		var b = d.to_utf8_buffer();
		if(b != null && b.get_size() > 0) {
			return(write(b, b.get_size() - 1) >= 0);
		}
		return(false);
	}

	public bool print(String d) {
		return(write_string(d));
	}

	public bool println(String ln) {
		if(insert_carriage_return) {
			return(write_string(ln.append("\r\n")));
		}
		return(write_string(ln.append("\n")));
	}

	public int write_from_reader(Reader reader) {
		if(reader == null) {
			return(0);
		}
		int v = 0;
		var buf = DynamicBuffer.create(4096 * 4);
		if(buf != null) {
			int n = 0, r;
			while((n = reader.read(buf)) > 0) {
				r = write(buf, n);
				if(r > 0) {
					v += r;
				}
				if(r != n) {
					break;
				}
			}
		}
		return(v);
	}
}

