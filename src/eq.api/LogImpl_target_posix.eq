
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

IFNDEF("target_ios") {

class LogImpl : Logger
{
	embed "c" {{{
		#include <stdio.h>
		#include <stdlib.h>
	}}}

	bool use_color = true;

	public LogImpl() {
		int loglevel = 3;
		strptr ep;
		embed "c" {{{
			ep = getenv("EQ_DEBUG");
		}}}
		if(ep != null) {
			var vv = String.for_strptr(ep);
			if("yes".equals(vv) || "true".equals(vv)) {
				loglevel = 4;
			}
		}
		embed "c" {{{
			ep = getenv("EQ_LOGLEVEL");
		}}}
		if(ep != null) {
			loglevel = String.for_strptr(ep).to_integer();
		}
		set_log_level(loglevel);
	}

	public void log(String prefix, String msg, String ident) {
		bool has_color = false;
		strptr sprefix = null;
		strptr smsg;
		strptr sident = null;
		if(prefix != null) {
			sprefix = prefix.to_strptr();
		}
		if(msg != null) {
			smsg = msg.to_strptr();
		}
		if(ident != null) {
			sident = ident.to_strptr();
		}
		if(use_color) {
			if(string_error.equals(prefix)) {
				embed "c" {{{
					printf("%c[91m", 0x1b);
				}}}
				has_color = true;
			}
			else if(string_warning.equals(prefix)) {
				embed "c" {{{
					printf("%c[95m", 0x1b);
				}}}
				has_color = true;
			}
			else if(string_debug.equals(prefix)) {
				embed "c" {{{
					printf("%c[96m", 0x1b);
				}}}
				has_color = true;
			}
		}
		embed "c" {{{
			if(sprefix == NULL) {
				if(sident != NULL) {
					printf("[%s] %s", sident, smsg);
				}
				else {
					printf("%s", smsg);
				}
			}
			else {
				if(sident != NULL) {
					printf("[%s:%s] %s", sident, sprefix, smsg);
				}
				else {
					printf("[%s] %s", sprefix, smsg);
				}
			}
		}}}
		if(has_color) {
			embed "c" {{{
				printf("%c[39m", 0x1b);
			}}}
		}
		embed "c" {{{
			printf("\n");
		}}}
	}
}

}
