
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

class HMACSHA1Impl : HMACSHA1
{
	public static HMACSHA1 create() {
		return(new HMACSHA1Impl());
	}

	embed "c++" {{{
		#include "windows.h"
		#include <wincrypt.h>
	}}}

	Buffer dohmac(String base_string, String signing_key) {
		var str = base_string.to_strptr();
		var password = signing_key.to_strptr();
		String result;
		bool err = false;
		var v = DynamicBuffer.create(20);
		if(v == null) {
			Log.error("Failed to allocate memory for HMAC");
			return(null);
		}
		ptr pbHash = v.get_pointer().get_native_pointer();
		embed "c++" {{{
			HCRYPTPROV hProv = NULL;
			HCRYPTHASH hHash = NULL;
			HCRYPTKEY hKey = NULL;
			HCRYPTHASH hHmacHash = NULL;
			DWORD dwDataLen = 0;
			HMAC_INFO HmacInfo;
			ZeroMemory(&HmacInfo, sizeof(HmacInfo));
			HmacInfo.HashAlgid = CALG_SHA1;
			dwDataLen = 20;
			ZeroMemory(pbHash, sizeof(dwDataLen));
			struct {
				BLOBHEADER header;
				DWORD len;
				BYTE key[1024];
			}key_blob;
			key_blob.header.bType = PLAINTEXTKEYBLOB;
			key_blob.header.bVersion = CUR_BLOB_VERSION;
			key_blob.header.reserved = 0;
			key_blob.header.aiKeyAlg = CALG_RC2;
			key_blob.len = strlen(password);
			memcpy(&key_blob.key, password, strlen(password));
			DWORD kbSize = sizeof(key_blob);
			if(!CryptAcquireContext(&hProv, NULL, MS_ENHANCED_PROV, PROV_RSA_FULL,CRYPT_VERIFYCONTEXT | CRYPT_NEWKEYSET)) {
				eq_util_hmacsha1_HMACSHA1Impl_logger("ERROR ON CryptAcquireContext");
				goto Exit;
			}
			if(!CryptImportKey(hProv, (BYTE*)&key_blob, kbSize, 0, CRYPT_IPSEC_HMAC_KEY, &hKey)) {
				err = true;
				eq_util_hmacsha1_HMACSHA1Impl_logger("ERROR ON CryptImportKey");
				goto Exit;
			}
			if(!CryptCreateHash(hProv, CALG_HMAC, hKey, 0, &hHmacHash)) {
				err = true;
				eq_util_hmacsha1_HMACSHA1Impl_logger("ERROR ON CryptCreateHash");
				goto Exit;
			}
			if(!CryptSetHashParam(hHmacHash, HP_HMAC_INFO, (BYTE*)&HmacInfo, 0)) {
				err = true;
				eq_util_hmacsha1_HMACSHA1Impl_logger("ERROR ON CryptSetHashParam");
				goto Exit;
			}
			if(!CryptHashData(hHmacHash, (BYTE*)str, strlen(str), 0)){
				err = true;
				eq_util_hmacsha1_HMACSHA1Impl_logger("ERROR ON CryptHashData");
				goto Exit;
			}
			if(!CryptGetHashParam(hHmacHash, HP_HASHVAL, pbHash, &dwDataLen, 0)) {
				err = true;
				eq_util_hmacsha1_HMACSHA1Impl_logger("ERROR ON CryptGetHashParam");
				goto Exit;
			}
			Exit:
				if(hHmacHash)
					CryptDestroyHash(hHmacHash);
				if(hKey)
					CryptDestroyKey(hKey);
				if(hHash)
					CryptDestroyHash(hHash);
				if(hProv)
					CryptReleaseContext(hProv, 0);
		}}}
		if(err) {
			return(null);
		}
		return(v);
	}

	static void logger(strptr s) {
		Log.message(String.for_strptr(s));
	}

	public Buffer encrypt(String base_string, String signing_key) {
		if(signing_key == null || base_string == null) {
				return(null);
		}
		var hash_hmac = dohmac(base_string, signing_key);
		return(hash_hmac);
	}
}

