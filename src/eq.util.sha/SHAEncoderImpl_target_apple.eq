
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

class SHAEncoderImpl : SHAEncoder
{
	public static SHAEncoder create() {
		return(new SHAEncoderImpl());
	}

	embed "objc" {{{
		#include <string.h>
		#include <Foundation/Foundation.h>
		#include <CommonCrypto/CommonDigest.h>
	}}}

	public String hash(Object o, int version) {
		var ins = o as String;
		if(ins == null) {
			return(null);
		}
		strptr basestring = ins.to_strptr();
		if(basestring == null) {
			return(null);
		}
		strptr phash_string;
		embed "objc" {{{
			unsigned char* cSHA;
			int digest_length, output_length;
		}}}
		if(SHAEncoder.SHA1 == version) {
			embed "objc" {{{
				digest_length = CC_SHA1_DIGEST_LENGTH;
				cSHA = malloc(digest_length * sizeof(char));
				CC_SHA1(basestring, strlen(basestring), cSHA);
			}}}
		}
		else if(SHAEncoder.SHA224 == version) {
			embed "objc" {{{
				digest_length = CC_SHA224_DIGEST_LENGTH;
				cSHA = malloc(digest_length * sizeof(char));
				CC_SHA224(basestring, strlen(basestring), cSHA);
			}}}
		}
		else if(SHAEncoder.SHA256 == version) {
			embed "objc" {{{
				digest_length = CC_SHA256_DIGEST_LENGTH;
				cSHA = malloc(digest_length * sizeof(char));
				CC_SHA256(basestring, strlen(basestring), cSHA);
			}}}
		}
		else if(SHAEncoder.SHA384 == version) {
			embed "objc" {{{
				digest_length = CC_SHA384_DIGEST_LENGTH;
				cSHA = malloc(digest_length * sizeof(char));
				CC_SHA384(basestring, strlen(basestring), cSHA);
			}}}
		}
		else if(SHAEncoder.SHA512 == version) {
			embed "objc" {{{
				digest_length = CC_SHA512_DIGEST_LENGTH;
				cSHA = malloc(digest_length * sizeof(char));
				CC_SHA512(basestring, strlen(basestring), cSHA);
			}}}
		}
		embed "objc" {{{
			output_length = digest_length * 2 + 1;
			NSMutableString* hash = [NSMutableString stringWithCapacity:output_length];
			for(int i = 0; i < digest_length; i++) {
				[hash appendFormat:@"%02x", cSHA[i]];
			}
			free(cSHA);
			phash_string = [hash UTF8String];
		}}}
		if(phash_string == null) {
			return(null);
		}
		return(String.for_strptr(phash_string).dup());
	}
}
