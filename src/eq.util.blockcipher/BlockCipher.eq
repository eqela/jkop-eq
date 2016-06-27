
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

public interface BlockCipher
{
	public static Buffer encrypt_string(String data, BlockCipher cipher) {
		if(data == null) {
			return(null);
		}
		return(BlockCipher.encrypt_buffer(data.to_utf8_buffer(false), cipher));
	}

	public static String decrypt_string(Buffer data, BlockCipher cipher) {
		var db = BlockCipher.decrypt_buffer(data, cipher);
		if(db == null) {
			return(null);
		}
		return(String.for_utf8_buffer(db, false));
	}

	public static Buffer encrypt_buffer(Buffer data, BlockCipher cipher) {
		if(cipher == null || data == null) {
			return(null);
		}
		var bw = BufferWriter.create();
		if(bw == null) {
			return(null);
		}
		var ww = BlockCipherWriter.create(bw, cipher);
		if(ww == null) {
			return(null);
		}
		int r = ww.write(data);
		ww.close();
		if(r < data.get_size()) {
			return(null);
		}
		return(bw.get_buffer());
	}

	public static Buffer decrypt_buffer(Buffer data, BlockCipher cipher) {
		if(cipher == null || data == null) {
			return(null);
		}
		var br = BufferReader.for_buffer(data);
		if(br == null) {
			return(null);
		}
		var rr = BlockCipherReader.create(br, cipher);
		if(rr == null) {
			return(null);
		}
		var db = DynamicBuffer.create(data.get_size());
		if(db == null) {
			return(null);
		}
		int ll = rr.read(db);
		if(ll < 0) {
			return(null);
		}
		if(ll < db.get_size()) {
			db.allocate(ll);
		}
		return(db);
	}

	public int get_block_size();
	public void encrypt_block(Buffer src, Buffer dest);
	public void decrypt_block(Buffer src, Buffer dest);
}

