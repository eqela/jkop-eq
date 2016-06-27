
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

public class URLEncoder
{
	public static String encode(String str, bool percent_only = false, bool encode_unreserved_chars = true) {
		if(str == null) {
			return(null);
		}
		var sb = StringBuffer.create();
		var it = str.iterate();
		while(it != null) {
			var c = it.next_char();
			if(c < 1) {
				break;
			}
			if((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')) {
				sb.append_c(c);
			}
			else if((c == '-' || c == '.' || c == '_' || c == '~') && encode_unreserved_chars == false){
				sb.append_c(c);
			}
			else if(c == ' ' && percent_only == false) {
				sb.append_c((int)'+');
			}
			else {
				sb.append("%%%02x".printf().add(Primitive.for_integer(c)).to_string());
			}
		}
		return(sb.to_string());
	}
}

