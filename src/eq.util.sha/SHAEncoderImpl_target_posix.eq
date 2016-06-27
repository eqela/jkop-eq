
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

IFDEF("target_osx") {
}
ELSE IFDEF("target_ios") {
}
ELSE {
class SHAEncoderImpl : SHAEncoder
{
	public static SHAEncoder create() {
		return(new SHAEncoderImpl());
	}

	embed "c" {{{
		#include <stdio.h>
		#include <string.h>
		#include <openssl/sha.h>
	}}}

	IFDEF("target_win32") {
		embed "c" {{{
			#define snprintf _snprintf
		}}}
	}

	public String hash(Object o, int version) {
		var ins = o as String;
		if(ins == null) {
			return(null);
		}
		strptr basestring = ins.to_strptr();
		if(basestring == null) {
			return(null);
		}
		ptr vp = null;
		embed "c" {{{
			char* p;
			unsigned char* cSHA;
			int digest_length, output_length, n;
		}}}
		if(SHAEncoder.SHA1 == version) {
			embed "c" {{{
				digest_length = SHA_DIGEST_LENGTH;
				cSHA = malloc(digest_length * sizeof(char));
				SHA1((unsigned char*)basestring, strlen(basestring), cSHA);
			}}}
		}
		else if(SHAEncoder.SHA224 == version) {
			embed "c" {{{
				digest_length = SHA224_DIGEST_LENGTH;
				cSHA = malloc(digest_length * sizeof(char));
				SHA224((unsigned char*)basestring, strlen(basestring), cSHA);
			}}}
		}
		else if(SHAEncoder.SHA256 == version) {
			embed "c" {{{
				digest_length = SHA256_DIGEST_LENGTH;
				cSHA = malloc(digest_length * sizeof(char));
				SHA256((unsigned char*)basestring, strlen(basestring), cSHA);
			}}}
		}
		else if(SHAEncoder.SHA384 == version) {
			embed "c" {{{
				digest_length = SHA384_DIGEST_LENGTH;
				cSHA = malloc(digest_length * sizeof(char));
				SHA384((unsigned char*)basestring, strlen(basestring), cSHA);
			}}}
		}
		else if(SHAEncoder.SHA512 == version) {
			embed "c" {{{
				digest_length = SHA512_DIGEST_LENGTH;
				cSHA = malloc(digest_length * sizeof(char));
				SHA512((unsigned char*)basestring, strlen(basestring), cSHA);
			}}}
		}
		int ol;
		embed "c" {{{
			output_length = digest_length * 2 + 1;
			ol = output_length;
			char str[output_length];
			p = str;
			for(n=0; n<digest_length; n++) {
				snprintf(p, 3, "%02x", *(cSHA + n));
				p += 2;
			}
			vp = str;
			free(cSHA);
		}}}
		return(String.for_utf8_buffer(Buffer.for_pointer(Pointer.create(vp), ol)).dup());
	}
}
}
