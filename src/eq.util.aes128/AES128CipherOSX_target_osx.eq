
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

public class AES128CipherOSX : BlockCipher
{
	embed {{{
		#include <CoreFoundation/CoreFoundation.h>
		#include <Security/Security.h>
	}}}

	ptr cryptkey;

	public static AES128CipherOSX for_key(Object key) {
		var v = new AES128CipherOSX();
		if(v.initialize(key)) {
			return(v);
		}
		return(null);
	}

	~AES128CipherOSX() {
		var key = cryptkey;
		embed {{{
			if(key) {
				CFRelease(key);
			}
		}}}
	}

	public bool initialize(Object o) {
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
		if(key == null) {
			return(false);
		}
		var pointer = key.get_pointer();
		if(pointer == null) {
			return(false);
		}
		bool v = true;
		int ks = key.get_size();
		var cptr = pointer.get_native_pointer();
		ptr cryptkey = null, cryptkeydata = null, params = null;
		embed {{{
			CFErrorRef error = NULL;
			params = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, 0, 0);
			int32_t bsz = 128;
			CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bsz);
			CFDictionarySetValue((CFMutableDictionaryRef)params, kSecAttrKeySizeInBits, num);
			CFDictionarySetValue((CFMutableDictionaryRef)params, kSecAttrKeyType, kSecAttrKeyTypeAES);
			cryptkeydata = CFDataCreate(kCFAllocatorDefault, (UInt8*)cptr, ks);
			cryptkey = SecKeyCreateFromData((CFMutableDictionaryRef)params, cryptkeydata, &error);
			if(error) {
				CFShow(error);
				CFRelease(error);
				v = FALSE;
			}
			CFRelease(num);
			CFRelease(params);
		}}}
		this.cryptkey = cryptkey;
		return(v);
	}

	public int get_block_size() {
		return(16);
	}

	public void do_transform(ptr transref, Buffer src, Buffer dest) {
		var spointer = src.get_pointer(), dpointer = dest.get_pointer();
		if(spointer == null || dpointer == null) {
			return;
		}
		int sz = src.get_size();
		ptr sptr = spointer.get_native_pointer(), dsptr = null;
		ptr encdata = null, srcdata = null;
		embed {{{
			CFErrorRef error = NULL;
			srcdata = CFDataCreate(kCFAllocatorDefault, (UInt8*)sptr, sz);
			SecTransformSetAttribute((SecTransformRef)transref, kSecEncryptionMode, kSecModeECBKey, &error);
			SecTransformSetAttribute((SecTransformRef)transref, kSecPaddingKey, kSecPaddingNoneKey, &error);
			SecTransformSetAttribute((SecTransformRef)transref, kSecTransformInputAttributeName, (CFDataRef)srcdata, &error);
			if(error != NULL) {
				CFShow(error);
			}
			else {
				encdata = SecTransformExecute((SecTransformRef)transref, &error);
				if(error != NULL) {
					CFShow(error);
				}
			}
			if(encdata) {
				dsptr = CFDataGetBytePtr((CFDataRef)encdata);
			}
		}}}
		if(dsptr != null) {
			dpointer.cpyfrom(Pointer.create(dsptr), 0, 0, dest.get_size());
		}
		embed {{{
			if(encdata) {
				CFRelease((CFDataRef)encdata);
				CFRelease((CFDataRef)srcdata);
			}
		}}}
	}

	public void encrypt_block(Buffer src, Buffer dest) {
		if(src == null || src.get_size() != 16 || dest == null || dest.get_size() != 16) {
			return;
		}
		ptr key = cryptkey;
		ptr encrypt = null;
		embed {{{
			CFErrorRef error = NULL;
			encrypt = SecEncryptTransformCreate(key, &error);
			if(error != NULL) {
				CFShow(error);
			}
		}}}
		if(encrypt != null) {
			do_transform(encrypt, src, dest);
			embed {{{
				CFRelease((SecTransformRef)encrypt);
			}}}
		}
	}

	public void decrypt_block(Buffer src, Buffer dest) {
		if(src == null || src.get_size() != 16 || dest == null || dest.get_size() != 16) {
			return;
		}
		ptr key = cryptkey;
		ptr decrypt = null;
		embed {{{
			CFErrorRef error = NULL;
			decrypt = SecDecryptTransformCreate(key, &error);
			if(error != NULL) {
				CFShow(error);
			}
		}}}
		if(decrypt != null) {
			do_transform(decrypt, src, dest);
			embed {{{
				CFRelease((SecTransformRef)decrypt);
			}}}
		}
	}
}
