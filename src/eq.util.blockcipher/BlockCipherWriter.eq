
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

public class BlockCipherWriter : Writer, Seekable
{
	public static BlockCipherWriter create(Writer writer, BlockCipher cipher) {
		if(writer == null || cipher == null) {
			return(null);
		}
		var v = new BlockCipherWriter();
		v.writer = writer;
		v.cipher = cipher;
		v.bsize = cipher.get_block_size();
		v.bcurr = 0;
		v.bdata = DynamicBuffer.create(cipher.get_block_size());
		v.outbuf = DynamicBuffer.create(cipher.get_block_size());
		return(v);
	}

	BlockCipher cipher;
	Writer writer;
	int bsize;
	int bcurr;
	Buffer bdata;
	Buffer outbuf;

	~BlockCipherWriter() {
		close();
	}

	public void close() {
		if(writer != null && bdata != null) {
			var bb = DynamicBuffer.create(1);
			var bbptr = bb.get_pointer();
			if(bcurr > 0) {
				var bdataptr = bdata.get_pointer();
				int n;
				for(n = bcurr; n<bsize; n++) {
					bdataptr.set_byte(n, 0);
				}
				write_complete_block(bdata);
				bbptr.set_byte(0, bsize - bcurr);
				writer.write(bb);
			}
			else {
				bbptr.set_byte(0, 0);
				writer.write(bb);
			}
		}
		writer = null;
		cipher = null;
		bdata = null;
	}

	public bool seek_set(int n) {
		// FIXME: Need to clear / reset the state (and read the current block to be a part of it)
		if(writer != null && writer is Seekable) {
			return(((Seekable)writer).seek_set(n));
		}
		return(false);
	}

	public int seek_current() {
		if(writer != null && writer is Seekable) {
			return(((Seekable)writer).seek_current());
		}
		return(-1);
	}

	bool write_complete_block(Buffer buf) {
		cipher.encrypt_block(buf, outbuf);
		if(writer.write(outbuf) == outbuf.get_size()) {
			return(true);
		}
		return(false);
	}

	int write_block(Buffer buf) {
		var size = buf.get_size();
		if(bcurr + size < bsize) {
			var bufptr = buf.get_pointer();
			bdata.get_pointer().cpyfrom(bufptr, 0, bcurr, size);
			bcurr += size;
			return(size);
		}
		if(bcurr > 0) {
			var bufptr = buf.get_pointer();
			int x = bsize - bcurr;
			bdata.get_pointer().cpyfrom(bufptr, 0, bcurr, x);
			if(write_complete_block(bdata) == false) {
				return(0);
			}
			bcurr = 0;
			if(x == size) {
				return(x);
			}
			return(x + write_block(SubBuffer.create(buf, x, size - x)));
		}
		if(write_complete_block(buf) == false) {
			return(0);
		}
		return(bsize);
	}

	public int write(Buffer buf, int asize = -1) {
		if(buf == null) {
			return(0);
		}
		var bufptr = buf.get_pointer();
		if(bufptr == null) {
			return(0);
		}
		var size = asize;
		if(size < 0) {
			size = buf.get_size();
		}
		if(size < 1) {
			return(0);
		}
		int v = 0;
		int n;
		for(n=0 ;n<size; n += bsize) {
			int x = bsize;
			if(n + x > size) {
				x = size - n;
			}
			v += write_block(SubBuffer.create(buf, n, x));
		}
		return(v);
	}
}

