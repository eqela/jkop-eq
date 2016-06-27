
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

public class DummyCipher : BlockCipher
{
	public static DummyCipher instance() {
		return(new DummyCipher());
	}

	public int get_block_size() {
		return(32);
	}

	public void encrypt_block(Buffer src, Buffer dst) {
		if(src == null || dst == null) {
			return;
		}
		var srcptr = src.get_pointer();
		var dstptr = dst.get_pointer();
		if(srcptr == null || dstptr == null) {
			return;
		}
		int n;
		for(n=0 ;n<32; n++) {
			int x = srcptr.get_byte(n);
			x += 10;
			if(x > 255) {
				x -= 255;
			}
			dstptr.set_byte(n, x);
		}
	}

	public void decrypt_block(Buffer src, Buffer dst) {
		if(src == null || dst == null) {
			return;
		}
		var srcptr = src.get_pointer();
		var dstptr = dst.get_pointer();
		if(srcptr == null || dstptr == null) {
			return;
		}
		int n;
		for(n=0 ;n<32; n++) {
			int x = srcptr.get_byte(n);
			x -= 10;
			if(x < 0) {
				x += 255;
			}
			dstptr.set_byte(n, x);
		}
	}
}

