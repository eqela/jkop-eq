
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

public class HTTPCookie : Stringable
{
	public static HTTPCookie instance(String key, String value) {
		return(new HTTPCookie().set_key(key).set_value(value));
	}

	property String key;
	property String value;
	property int max_age = -1;
	property String path;
	property String domain;

	public String to_string() {
		var sb = StringBuffer.create();
		sb.append(key);
		sb.append_c((int)'=');
		sb.append(value);
		if(max_age >= 0) {
			sb.append("; Max-Age=");
			sb.append(String.for_integer(max_age));
		}
		if(String.is_empty(path) == false) {
			sb.append("; Path=");
			sb.append(path); // FIXME: Should we URL encode this?
		}
		if(String.is_empty(domain) == false) {
			sb.append("; Domain=");
			sb.append(domain);
		}
		return(sb.to_string());
	}
}
