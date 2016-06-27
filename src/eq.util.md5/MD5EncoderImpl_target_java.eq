
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

IFNDEF("target_bbjava")
{
	private class MD5EncoderImpl : MD5Encoder
	{
		public static MD5Encoder create() {
			return(new MD5EncoderImpl());
		}

		public String hash(Object o) {
			var ins = o as String;
			if(ins == null) {
				Log.error("Java implementation of MD5 encoder can only handle strings.");
				return(null);
			}
			strptr r = null;
			var sp = ins.to_strptr();
			embed "java" {{{
				try {
					java.security.MessageDigest digest = java.security.MessageDigest.getInstance("MD5");	
					}}}
					IFDEF("target_j2me") {
						embed "java" {{{
							byte spptr[] = sp.getBytes();
							byte messageDigest[] = new byte[32];
							digest.update(spptr, 0, spptr.length);
							digest.digest(messageDigest, 0, messageDigest.length);
						}}}
					}
					ELSE {
						embed "java" {{{
							digest.update(sp.getBytes());
							byte messageDigest[] = digest.digest();
						}}}
					}
					embed "java" {{{
					java.lang.StringBuffer hexString = new java.lang.StringBuffer();
					for(int i=0; i<messageDigest.length; i++) {
						java.lang.String ii = java.lang.Integer.toHexString(0xFF & messageDigest[i]);
						if(ii.length() < 2) {
							hexString.append("0");
						}
						hexString.append(ii);
					}
					r = hexString.toString();
				}
				catch(Exception e) {
					e.printStackTrace();
				}
			}}}
			if(r != null) {
				return(String.for_strptr(r));
			}
			return(null);
		}
	}
}

