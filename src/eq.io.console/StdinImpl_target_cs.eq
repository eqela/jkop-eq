
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

IFDEF("target_uwp")
{
	class StdinImpl
	{
		public static Reader create() {
			return(null);
		}
	}
}

ELSE
{
	class StdinImpl : Reader, ByteReader
	{
		public static Reader create() {
			return(new StdinImpl());
		}

		embed {{{
			System.IO.Stream stream;
		}}}
		InputStream instream;

		public StdinImpl() {
			embed {{{
				stream = System.Console.OpenStandardInput();
			}}}
			instream = InputStream.for_reader(this);
		}

		public int read(Buffer buf) {
			if(buf == null) {
				return(0);
			}
			var p = buf.get_pointer();
			if(p == null) {
				return(0);
			}
			var np = p.get_native_pointer();
			if(np == null) {
				return(0);
			}
			int v;
			embed {{{
				v = stream.Read(np, 0, np.Length);
			}}}
			return(v);
		}

		public int readByte() {
			instream.nextbyte();
			return(instream.getbyte());
		}
	}
}
