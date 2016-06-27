
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

public class HTTPRequestHandlerWrapper : HTTPRequestHandler, HTTPRequestHandlerWithLifeCycle
{
	property HTTPRequestHandler handler;

	public void initialize() {
		var hl = handler as HTTPRequestHandlerWithLifeCycle;
		if(hl != null) {
			hl.initialize();
		}
	}

	public void on_maintenance() {
		var hl = handler as HTTPRequestHandlerWithLifeCycle;
		if(hl != null) {
			hl.on_maintenance();
		}
	}

	public void on_refresh() {
		var hl = handler as HTTPRequestHandlerWithLifeCycle;
		if(hl != null) {
			hl.on_refresh();
		}
	}

	public void cleanup() {
		var hl = handler as HTTPRequestHandlerWithLifeCycle;
		if(hl != null) {
			hl.cleanup();
		}
	}

	public bool on_http_request(HTTPRequest req) {
		if(handler != null) {
			return(handler.on_http_request(req));
		}
		return(false);
	}

	public bool on_authenticated_request(HTTPRequest req, Object session) {
		if(handler != null) {
			return(handler.on_authenticated_request(req, session));
		}
		return(false);
	}

	public HTTPRequestBodyHandler get_request_body_handler(HTTPRequest req) {
		if(handler != null) {
			return(handler.get_request_body_handler(req));
		}
		return(null);
	}

	public HTTPRequestBodyHandler get_authenticated_request_body_handler(HTTPRequest req, Object session) {
		if(handler != null) {
			return(handler.get_authenticated_request_body_handler(req, session));
		}
		return(null);
	}

	public virtual bool on_unhandled_request(HTTPRequest req, HTTPRequestHandler handler = null) {
		if(handler != null) {
			return(handler.on_unhandled_request(req, handler));
		}
		return(false);
	}
}
