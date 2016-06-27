
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
		set_log_level(3);
	}

	public void log(String prefix, String amsg, String ident) {
		var msg = amsg;
		if(msg == null) {
			msg = "";
		}
		var msgp = msg.to_strptr();
		if(prefix == null) {
			if(ident != null) {
				var identp = ident.to_strptr();
				embed "cs" {{{
					System.Console.WriteLine("[" + identp + "] " + msgp);
				}}}
			}
			else {
				embed "cs" {{{
					System.Console.WriteLine(msgp);
				}}}
			}
		}
		else {
			var prefixp = prefix.to_strptr();
			if(ident != null) {
				var _identp = ident.to_strptr();
				embed "cs" {{{
					System.Console.WriteLine("[" + _identp + ":" + prefixp + "] " + msgp);
				}}}
			}
			else {
				embed "cs" {{{
					System.Console.WriteLine("[" + prefixp + "] " + msgp);
				}}}
			}
		}
	}
}
