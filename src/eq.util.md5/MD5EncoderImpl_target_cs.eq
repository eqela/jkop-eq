
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

IFDEF("target_uwpcs")
{
	public class MD5EncoderImpl : MD5Encoder
	{
		public static MD5Encoder create() {
			return(new MD5EncoderImpl());
		}
		public String hash(Object o) {
			embed {{{
				Windows.Storage.Streams.IBuffer buffer = null;
			}}}
			if(o is Buffer) {
				var pointer = ((Buffer)o).get_pointer();
				if(pointer != null) {
					var bytes = pointer.get_native_pointer();
					embed {{{
						buffer = System.Runtime.InteropServices.WindowsRuntime.WindowsRuntimeBufferExtensions.AsBuffer(bytes);
					}}}
				}
			}
			else if(o is String) {
				var str = ((String)o).to_strptr();
				embed {{{
					buffer = Windows.Security.Cryptography.CryptographicBuffer.ConvertStringToBinary(
						str,
						Windows.Security.Cryptography.BinaryStringEncoding.Utf8
					);
				}}}
			}
			strptr v = null;
			embed {{{
				if(buffer != null) {
					var algoprovider = Windows.Security.Cryptography.Core.HashAlgorithmProvider.OpenAlgorithm(
						Windows.Security.Cryptography.Core.HashAlgorithmNames.Md5
					);
					var hashed_buffer = algoprovider.HashData(buffer);
					if(hashed_buffer.Length != algoprovider.HashLength) {
						return(null);
					}
					v = Windows.Security.Cryptography.CryptographicBuffer.EncodeToHexString(hashed_buffer);
				}
				
			}}}
			if(v != null) {
				return(String.for_strptr(v));
		}
			return(null);
		}
	}
}

ELSE
{
	@class MD5EncoderImpl : MD5Encoder
	{
		#public #static MD5Encoder create() {
			return(new $this());
		}

		@lang "cs" {{{
			string calculateMD5Hash(string input) {
				var md5 = System.Security.Cryptography.MD5.Create();
				byte[] inputBytes = System.Text.Encoding.ASCII.GetBytes(input);
				byte[] hash = md5.ComputeHash(inputBytes);
				var sb = new System.Text.StringBuilder();
				for (int i = 0; i < hash.Length; i++) {
					sb.Append(hash[i].ToString("X2"));
				}
				return(sb.ToString());
			}
		}}}

		#public String hash(Object o) {
			$auto os = String.as_string(o);
			if(os == null) {
				return(null);
			}
			$auto sp = os.to_strptr();
			if(sp == null) {
				return(null);
			}
			$auto hs = @lang "cs" $string {{{ calculateMD5Hash(sp) }}};
			if(hs == null) {
				return(null);
			}
			return(String.for_strptr(hs));
		}
	}
}
