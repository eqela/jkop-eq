
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

public class HTTPClientResponseHeader
{
	property String status;
	property HashTable headers;

	public HTTPClientResponseHeader copy_header_from(HTTPClientResponseHeader hdr) {
		if(hdr != null) {
			set_status(hdr.get_status());
			set_headers(hdr.get_headers());
		}
		else {
			status = null;
			headers = null;
		}
		return(this);
	}

	public bool is_ok() {
		if("200".equals(status)) {
			return(true);
		}
		return(false);
	}

	public String get_mime_type() {
		return(get_header("content-type"));
	}

	public String get_header(String hdr) {
		if(headers == null) {
			return(null);
		}
		return(headers.get_string(hdr));
	}
}
