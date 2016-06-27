
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

public class StaticContentHandler : HTTPRequestHandler
{
	public static StaticContentHandler for_response(HTTPResponse resp) {
		return(new StaticContentHandler().set_response(resp));
	}

	property HTTPResponse response;

	public bool on_http_request(HTTPRequest req) {
		if(response == null) {
			return(false);
		}
		req.send_response(response);
		return(true);
	}

	public bool on_authenticated_request(HTTPRequest req, Object session) {
		if(response == null) {
			return(false);
		}
		req.send_response(response);
		return(true);
	}

	public bool on_unhandled_request(HTTPRequest req, HTTPRequestHandler handler = null) {
		return(false);
	}

	public HTTPRequestBodyHandler get_request_body_handler(HTTPRequest req) {
		return(null);
	}

	public HTTPRequestBodyHandler get_authenticated_request_body_handler(HTTPRequest req, Object session) {
		return(null);
	}
}
