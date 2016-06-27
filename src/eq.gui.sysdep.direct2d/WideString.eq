
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

class WideString
{
	public static WideString for_string(String s) {
		return(new WideString().initialize(s));
	}

	property ptr buffer;

	~WideString() {
		var b = this.buffer;
		embed "c" {{{
			if(b != NULL) {
				free(b);
			}
		}}}
	}

	WideString initialize(String s) {
		if(s == null) {
			return(null);
		}
		var str = s.to_strptr();
		if(str == null) {
			return(null);
		}
		var ll = s.get_length();
		ptr b;
		embed "c" {{{
			b = (char*)malloc(ll*2+2);
			mbstowcs((wchar_t*)b, str, ll); //*2+2);
			((char*)b)[ll*2] = 0;
			((char*)b)[ll*2+1] = 0;
		}}}
		this.buffer = b;
		return(this);
	}
}
