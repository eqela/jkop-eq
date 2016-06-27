
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

class AES128CipherUWPCS : BlockCipher
{
	Buffer key;
	embed {{{
		Windows.Security.Cryptography.Core.CryptographicKey cryptkey;
	}}}

	public static AES128CipherUWPCS create(Object k) {
		var v = new AES128CipherUWPCS().set_key(k);
		return(v);
	}

	AES128CipherUWPCS set_key(Object akey) {
		if(akey == null) {
			key = null;
		}
		else if(akey is String) {
			var md5 = MD5Encoder.instance();
			if(md5 != null) {
				var keyhash = md5.hash(akey);
				key = Buffer.for_hex_string(keyhash);
			}
		}
		else if(akey is Buffer) {
			key = akey as Buffer;
		}
		if(key != null) {
			var pointer = key.get_pointer();
			ptr ptr = null;
			if(pointer != null) {
				ptr = pointer.get_native_pointer();
			}
			embed {{{
				var aes = Windows.Security.Cryptography.Core.SymmetricKeyAlgorithmProvider.OpenAlgorithm(
					Windows.Security.Cryptography.Core.SymmetricAlgorithmNames.AesEcb
				);
				var buffer = System.Runtime.InteropServices.WindowsRuntime.WindowsRuntimeBufferExtensions.AsBuffer(ptr);
				if(buffer != null) {
					cryptkey = aes.CreateSymmetricKey(buffer);
				}
			}}}
		}
		return(this);
	}

	public int get_block_size() {
		return(16);
	}

	public void do_cipher(Buffer src, Buffer dest, bool encrypt) {
		if(src == null || dest == null || src.get_size() != 16 || dest.get_size() != 16) {
			return;
		}
		var spointer = src.get_pointer();
		var dpointer = dest.get_pointer();
		if(spointer == null || dpointer == null) {
			return;
		}
		int sz = src.get_size(), sidx = spointer.get_current_index();
		ptr sptr = spointer.get_native_pointer();
		ptr obytes = null;
		embed {{{
			var ib = System.Runtime.InteropServices.WindowsRuntime.WindowsRuntimeBufferExtensions.AsBuffer(sptr, sidx, sz);
			if(encrypt) {
				ib = Windows.Security.Cryptography.Core.CryptographicEngine.Encrypt(cryptkey, ib, null);
			}
			else {
				ib = Windows.Security.Cryptography.Core.CryptographicEngine.Decrypt(cryptkey, ib, null);
			}
			obytes = System.Runtime.InteropServices.WindowsRuntime.WindowsRuntimeBufferExtensions.ToArray(ib);
		}}}
		dpointer.cpyfrom(Pointer.create(obytes), 0, 0, 16);
	}

	public void encrypt_block(Buffer src, Buffer dest) {
		do_cipher(src, dest, true);
	}

	public void decrypt_block(Buffer src, Buffer dest) {
		do_cipher(src, dest, false);
	}
}
