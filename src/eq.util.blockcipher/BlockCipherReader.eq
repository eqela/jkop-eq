
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

public class BlockCipherReader : Reader, SizedReader, Seekable
{
	public static SizedReader create(SizedReader reader, BlockCipher cipher) {
		if(reader == null) {
			return(null);
		}
		if(cipher == null) {
			return(reader);
		}
		var v = new BlockCipherReader();
		v.reader = reader;
		v.cipher = cipher;
		v.bcurrent = DynamicBuffer.create(cipher.get_block_size());
		v.bnext = DynamicBuffer.create(cipher.get_block_size());
		v.ddata = DynamicBuffer.create(cipher.get_block_size());
		v.csize = 0;
		v.cindex = 0;
		v.nsize = 0;
		return(v);
	}

	BlockCipher cipher;
	SizedReader reader;
	Buffer bcurrent;
	int csize;
	int cindex;
	Buffer bnext;
	int nsize;
	Buffer ddata;

	public int get_size() {
		if(reader != null) {
			return(reader.get_size());
		}
		return(0);
	}

	public bool seek_set(int n) {
		int rem = n % cipher.get_block_size();
		int ss = n - rem;
		csize = 0;
		cindex = 0;
		nsize = 0;
		bool v = false;
		if(reader != null && reader is Seekable) {
			v = ((Seekable)reader).seek_set(ss);
		}
		if(v && rem > 0) {
			var bb = DynamicBuffer.create(rem);
			if(read(bb) != rem) {
				v = false;
			}
		}
		return(v);
	}

	public int seek_current() {
		if(reader != null && reader is Seekable) {
			return(((Seekable)reader).seek_current());
		}
		return(-1);
	}

	public int read(Buffer buf) {
		if(buf == null || buf.get_size() < 1) {
			return(0);
		}
		var ptr = buf.get_pointer();
		if(ptr == null) {
			return(0);
		}
		int v = 0;
		int bs = cipher.get_block_size();
		while(v<buf.get_size()) {
			int x = bs;
			if(v + x > buf.get_size()) {
				x = buf.get_size() - v;
			}
			int r = read_block(ptr, v, x);
			if(r < 1) {
				break;
			}
			v += r;
		}
		return(v);
	}

	int read_and_decrypt(Buffer buf) {
		int v = reader.read(ddata);
		if(v == cipher.get_block_size()) {
			cipher.decrypt_block(ddata, buf);
		}
		else {
			buf.get_pointer().cpyfrom(ddata.get_pointer(), 0, 0, v);
		}
		return(v);
	}

	int read_block(Pointer ptr, int offset, int size) {
		if(cindex >= csize) {
			csize = 0;
		}
		if(nsize < 1) {
			nsize = read_and_decrypt(bnext);
		}
		if(csize < 1) {
			if(nsize < cipher.get_block_size()) {
				// end of data
				return(0);
			}
			var nn = bcurrent;
			bcurrent = bnext;
			csize = nsize;
			cindex = 0;
			bnext = nn;
			nsize = read_and_decrypt(bnext);
		}
		int data = cipher.get_block_size();
		if(nsize < cipher.get_block_size()) {
			var ptr2 = bnext.get_pointer();
			if(ptr2 != null ) {
				data -= ptr2.get_byte(0);
			}
		}
		data -= cindex;
		if(data < 1) {
			csize = 0;
			return(read_block(ptr, offset, size));
		}
		if(data < size) {
			ptr.cpyfrom(bcurrent.get_pointer(), cindex, offset, data);
			cindex += data;
			return(data);
		}
		ptr.cpyfrom(bcurrent.get_pointer(), cindex, offset, size);
		cindex += size;
		return(size);
	}
}

