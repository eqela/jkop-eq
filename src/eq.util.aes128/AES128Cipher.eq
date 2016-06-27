
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

public class AES128Cipher
{
	public static BlockCipher instance(Object key) {
		if(key == null) {
			return(null);
		}
		IFDEF("target_win32") {
			var v = new AES128CipherWin32();
			v.set_key(key);
			return(v);
		}
		ELSE IFDEF("target_osx") {
			var v = AES128CipherOSX.for_key(key);
			if(v != null) {
				return(v);
			}
		}
		ELSE IFDEF("target_c") {
			var v = new AES128CipherC();
			v.set_key(key);
			return(v);
		}
		IFDEF("target_uwpcs") {
			var v = AES128CipherUWPCS.create(key);
			if(v != null) {
				return(v);
			}
		}
		IFDEF("target_java") {
			var v = AES128CipherJava.create(key);
			if(v != null) {
				return(v);
			}
		}
		return(null);
	}
}
