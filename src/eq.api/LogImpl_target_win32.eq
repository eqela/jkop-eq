
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

class LogImpl : Logger
{
	embed "c" {{{
		#include <stdio.h>
		#include <stdlib.h>
		#include <string.h>
		#include <io.h>
		#include <windows.h>
	}}}

	String logfile = null;

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
		embed "c" {{{
			ep = getenv("EQ_LOGFILE");
		}}}
		if(ep != null) {
			logfile = String.for_strptr(ep).dup();
		}
		set_log_level(loglevel);
		if(loglevel >= 4) {
			embed "c" {{{
				HANDLE h = GetStdHandle(STD_OUTPUT_HANDLE);
				if(h == NULL || h == INVALID_HANDLE_VALUE) {
					AllocConsole();
					freopen("CONIN$", "r", stdin); 
					freopen("CONOUT$", "w", stdout); 
					freopen("CONOUT$", "w", stderr); 
				}
			}}}
		}
	}

	public void log(String prefix, String msg, String ident) {
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
		if(logfile != null) {
			var ff = logfile.to_strptr();
			embed "c" {{{
				FILE* fp = fopen(ff, "a");
				if(fp != NULL) {
					if(sprefix == NULL) {
						if(sident != NULL) {
							fprintf(fp, "[%s] %s\n", sident, smsg);
						}
						else {
							fprintf(fp, "%s\n", smsg);
						}
					}
					else {
						if(sident != NULL) {
							fprintf(fp, "[%s:%s] %s\n", sident, sprefix, smsg);
						}
						else {
							fprintf(fp, "[%s] %s\n", sprefix, smsg);
						}
					}
					fclose(fp);
				}
			}}}
		}
		embed "c" {{{
			if(sprefix == NULL) {
				if(sident != NULL) {
					printf("[%s] %s\n", sident, smsg);
				}
				else {
					printf("%s\n", smsg);
				}
			}
			else {
				if(sident != NULL) {
					printf("[%s:%s] %s\n", sident, sprefix, smsg);
				}
				else {
					printf("[%s] %s\n", sprefix, smsg);
				}
			}
			fflush(stdout);
		}}}
	}
}
