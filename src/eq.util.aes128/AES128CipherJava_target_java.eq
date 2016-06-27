
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

public class AES128CipherJava : BlockCipher
{
	embed {{{
		java.security.Key key;
	}}}

	public static AES128CipherJava create(Object k) {
		var v = new AES128CipherJava();
		if(v.set_key(k)) {
			return(v);
		}
		return(null);
	}

	public bool set_key(Object o) {
		Buffer key = null;
		if(o == null) {
		}
		else if(o is Buffer) {
			key = (Buffer)o;
		}
		else if(o is String) {
			var md5 = MD5Encoder.instance();
			if(md5 != null) {
				var keyhash = md5.hash(o);
				key = Buffer.for_hex_string(keyhash);
			}
		}
		if(key != null) {
			var kptr = key.get_pointer();
			if(kptr != null) {
				var kp = kptr.get_native_pointer();
				embed {{{
					this.key = new javax.crypto.spec.SecretKeySpec(kp, 0, kp.length, "AES");
				}}}
			}
			return(true);
		}
		return(false);
	}

	public int get_block_size() {
		return(16);
	}

	public void do_cipher(Buffer src, Buffer dest, int mode) {
		if(src == null || dest == null  || src.get_size() != 16  || dest.get_size() != 16) {
			return;
		}
		embed {{{
			eq.api.Pointer sptr = src.get_pointer(), dptr = dest.get_pointer();
			if(sptr == null || dptr == null) {
				return;
			}
			byte[] sp = sptr.get_native_pointer();
			byte[] dp = dptr.get_native_pointer();
			try {
				javax.crypto.Cipher aes = javax.crypto.Cipher.getInstance("AES/ECB/NoPadding");
				aes.init(mode, key);
				aes.doFinal(sp, sptr.get_current_index(), src.get_size(), dp, 0);
			}
			catch(java.lang.Exception e) {
				e.printStackTrace();
			}
		}}}
	}

	public void encrypt_block(Buffer src, Buffer dest) {
		embed {{{
			do_cipher(src, dest, javax.crypto.Cipher.ENCRYPT_MODE);
		}}}
	}

	public void decrypt_block(Buffer src, Buffer dest) {
		embed {{{
			do_cipher(src, dest, javax.crypto.Cipher.DECRYPT_MODE);
		}}}
	}
}
