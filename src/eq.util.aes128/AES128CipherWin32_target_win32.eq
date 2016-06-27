
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

public class AES128CipherWin32 : BlockCipher
{
	embed {{{
		#include <string.h>
		#include <wincrypt.h>

		#include <stdio.h>
	}}}
	ptr cryptkey;
	ptr cryptprov;

	~AES128CipherWin32() {
		var ck = cryptkey;
		if(ck != null) {
			embed {{{
				CryptDestroyKey((HCRYPTKEY)ck);
			}}}
		}
		var cp = cryptprov;
		if(cp != null) {
			embed {{{
				CryptReleaseContext((HCRYPTPROV)cp, 0);
			}}}
		}
	}

	public void set_key(Object k) {
		Buffer key = null;
		if(k is Buffer) {
			key = (Buffer)k;
		}
		else if(k is String) {
			var md5 = MD5Encoder.instance();
			if(md5 != null) {
				var keyhash = md5.hash(k);
				key = Buffer.for_hex_string(keyhash);
			}
		}
		if(key != null) {
			ptr hkey = null, cp = null;
			var keypointer = key.get_pointer();
			int sz = key.get_size();
			ptr kp = null;
			if(keypointer != null) {
				kp = keypointer.get_native_pointer();
			}
			bool success = false;
			if(kp != null) {
				embed {{{
					struct AES128
					{
						BLOBHEADER hdr;
						DWORD ksz;
						BYTE data[16];
					} aesblob;
					aesblob.hdr.bType = PLAINTEXTKEYBLOB;
					aesblob.hdr.bVersion = CUR_BLOB_VERSION;
					aesblob.hdr.reserved = 0;
					aesblob.hdr.aiKeyAlg = CALG_AES_128;
					aesblob.ksz = sz;
					memcpy(aesblob.data, kp, sz);
					HCRYPTPROV cp = 0;
					success = CryptAcquireContext((HCRYPTPROV*)&cp, 0, MS_ENH_RSA_AES_PROV, PROV_RSA_AES, CRYPT_NEWKEYSET | CRYPT_VERIFYCONTEXT);
					if(success) {
						success = CryptImportKey(cp, (BYTE*)&aesblob, sizeof(struct AES128), 0, 0, (HCRYPTKEY*)&hkey);
					}
					if(success) {
						DWORD mode= CRYPT_MODE_ECB;
						success = CryptSetKeyParam((HCRYPTKEY)hkey, KP_MODE, (const BYTE*)&mode, 0);
					}
				}}}
			}
			if(success) {
				cryptprov = cp;
				cryptkey = hkey;
			}
		}
	}

	public int get_block_size() {
		return(16);
	}

	public void encrypt_block(Buffer src, Buffer dest) {
		var ck = cryptkey;
		if(ck == null || src == null || dest == null || src.get_size() != 16 || src.get_size() != 16) {
			return;
		}
		var iodata = DynamicBuffer.create(src.get_size() * 2);
		if(iodata == null) {
			return;
		}
		var ioptr = iodata.get_pointer();
		var sptr = src.get_pointer();
		if(ioptr == null || sptr == null) {
			return;
		}
		int ssz = src.get_size();
		ioptr.set_range(0, iodata.get_size());
		int iosz = iodata.get_size();
		ioptr.cpyfrom(sptr, 0, 0, src.get_size());
		var iop = ioptr.get_native_pointer();
		bool success = false;
		embed {{{
			success = CryptEncrypt((HCRYPTKEY)ck, NULL, TRUE, 0, (BYTE*)iop, (DWORD*)&ssz, iosz);
		}}}
		if(success) {
			var dptr = dest.get_pointer();
			dptr.cpyfrom(ioptr, 0, 0, dest.get_size());
		}
		iodata.free();
		iodata = null;
	}

	public void decrypt_block(Buffer src, Buffer dest) {
		var ck = cryptkey;
		if(ck == null || src == null || dest == null || src.get_size() != 16 || src.get_size() != 16) {
			return;
		}
		var iodata = DynamicBuffer.create(src.get_size());
		if(iodata == null) {
			return;
		}
		var ioptr = iodata.get_pointer();
		var sptr = src.get_pointer();
		if(ioptr == null || sptr == null) {
			return;
		}
		int iosz = iodata.get_size();
		ioptr.set_range(0, iosz);
		ioptr.cpyfrom(sptr, 0, 0, iosz);
		var iop = ioptr.get_native_pointer();
		bool success = false;
		embed {{{
			success = CryptDecrypt((HCRYPTKEY)ck, NULL, FALSE, 0, (BYTE*)iop, (DWORD*)&iosz);
		}}}
		if(success) {
			var dptr = dest.get_pointer();
			dptr.cpyfrom(ioptr, 0, 0, iosz);
		}
		iodata.free();
		iodata = null;
	}

}
