
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
	public LogImpl() {
		int loglevel = 3;
		IFDEF("target_android") {
			loglevel = 4;
		}
		ELSE IFDEF("target_j2me") {
			loglevel = 4;
		}
		ELSE {
			strptr val = null;
			embed "Java" {{{
				val = java.lang.System.getenv("EQ_DEBUG");
			}}}
			var dbg = String.for_strptr(val);
			if("yes".equals(dbg) || "true".equals(dbg)) {
				loglevel = 4;
			}
		}
		set_log_level(loglevel);
	}

	public void log(String prefix, String msg, String ident) {
		if(msg == null) {
			return;
		}
		embed "java" {{{
			if(prefix == null) {
				if(ident == null) {
					System.out.println(msg.to_strptr());
				}
				else {
					System.out.println("[" + ident.to_strptr() + "] " + msg.to_strptr());
				}
			}
			else {
				if(ident == null) {
					System.out.println("[" + prefix.to_strptr() + "] " + msg.to_strptr());
				}
				else {
					System.out.println("[" + ident.to_strptr() + ":" + prefix.to_strptr() + "] " + msg.to_strptr());
				}
			}
		}}}
	}
}

