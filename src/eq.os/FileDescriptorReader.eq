
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

IFDEF("target_posix") {
	public class FileDescriptorReader : Reader
	{
		property int fd;
		public static Reader create(int fd) {
			return(new FileDescriptorReader().set_fd(fd));
		}
		embed {{{
			#include <stdio.h>
			#include <unistd.h>
		}}}
		public int read(Buffer buf) {
			int v = 0;
			if(buf != null) {
				var ptr = buf.get_pointer();
				if(ptr != null) {
					var np = ptr.get_native_pointer();
					var sz = buf.get_size();
					int fd = this.fd;
					embed "c" {{{
						v = read(fd, np, sz);
					}}}
				}
			}
			return(v);
		}
	}
}
ELSE {
	public class FileDescriptorReader {
		public static Reader create(int fd) {
			return(null);
		}
	}
}

