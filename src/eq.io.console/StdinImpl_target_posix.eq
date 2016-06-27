
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

public class StdinImpl : PropertyObject, Reader, FileDescriptor, ByteReader
{
	public static Reader create() {
		return(new StdinImpl());
	}

	embed "c" {{{
		#include <termios.h>
		#include <unistd.h>
		#include <sys/ioctl.h>
		#ifndef TCGETS
		# ifdef TIOCGETA
		#  define TCGETS TIOCGETA
		# endif
		#endif
		#ifndef TCSETS
		# ifdef TIOCSETA
		#  define TCSETS TIOCSETA
		# endif
		#endif
	}}}

	public StdinImpl() {
	}

	public void on_property_changed(String key, Object val) {
		if("raw-input".equals(key)) {
			if(get_bool("raw-input", false) == true) {
				embed "c" {{{
					struct termios termios;
					#ifdef TCGETS
					ioctl(0, TCGETS, &termios);
					#endif
					termios.c_lflag &= ~ECHO;
					termios.c_lflag &= ~ICANON;
					#ifdef TCSETS
					ioctl(0, TCSETS, &termios);
					#endif
				}}}
			}
			else {
				embed "c" {{{
					struct termios termios;
					#ifdef TCGETS
					ioctl(0, TCGETS, &termios);
					#endif
					termios.c_lflag |= ECHO;
					termios.c_lflag |= ICANON;
					#ifdef TCSETS
					ioctl(0, TCSETS, &termios);
					#endif
				}}}
			}
		}
	}

	public int get_fd() {
		return(0);
	}

	public int read(eq.api.Buffer buf) {
		int v = 0;
		if(buf != null) {
			var ptr = buf.get_pointer();
			if(ptr != null) {
				var np = ptr.get_native_pointer();
				var sz = buf.get_size();
				embed "c" {{{
					v = read(0, np, sz);
				}}}
			}
		}
		return(v);
	}

	public int readByte() {
		int v = 0;
		embed "c" {{{
			int8_t buf[1];
			read(0, buf, 1);
			v = buf[0];
		}}}
		return(v);
	}
}
