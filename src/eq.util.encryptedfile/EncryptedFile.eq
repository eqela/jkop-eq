
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

public class EncryptedFile : FileExtender
{
	property BlockCipher cipher;

	public static EncryptedFile for_file(File f) {
		if(f == null) {
			return(null);
		}
		var v = new EncryptedFile();
		v.set_file(f);
		return(v);
	}

	public override SizedReader read() {
		var v = base.read();
		if(cipher != null) {
			v = BlockCipherReader.create(v, cipher);
		}
		return(v);
	}

	public override Writer write() {
		var v = base.write();
		if(cipher != null) {
			v = BlockCipherWriter.create(v, cipher);
		}
		return(v);
	}

	public override Writer append() {
		var v = base.append();
		if(cipher != null) {
			v = BlockCipherWriter.create(v, cipher);
		}
		return(v);
	}

	public Buffer get_contents_buffer() {
		var ins = InputStream.create(read());
		if(ins == null) {
			return(null);
		}
		return(ins.read_all_buffer());
	}

	public String get_contents_string() {
		var ins = InputStream.create(read());
		if(ins == null) {
			return(null);
		}
		return(ins.read_all_string());
	}

	public bool set_contents_buffer(Buffer buf) {
		var os = OutputStream.create(write());
		if(os == null) {
			return(false);
		}
		return(os.write_buffer(buf));
	}

	public bool set_contents_string(String str) {
		var os = OutputStream.create(write());
		if(os == null) {
			return(false);
		}
		return(os.write_string(str));
	}

	class LineReaderIterator : Iterator
	{
		property InputStream inputstream;
		public Object next() {
			if(inputstream == null) {
				return(null);
			}
			var r = inputstream.readline();
			if(r == null) {
				inputstream = null;
			}
			return(r);
		}
	}

	public Iterator lines() {
		var ins = InputStream.create(read());
		if(ins == null) {
			return(null);
		}
		return(new LineReaderIterator().set_inputstream(ins));
	}
}
