
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

public class HTTPRequestHandlerAdapter : HTTPRequestHandler, LoggerObject
{
	property int maximum_request_body_size = 32 * 1024;

	public virtual bool on_http_get(HTTPRequest req) {
		return(false);
	}

	public virtual bool on_http_post(HTTPRequest req) {
		return(false);
	}

	public virtual bool on_http_put(HTTPRequest req) {
		return(false);
	}

	public virtual bool on_http_delete(HTTPRequest req) {
		return(false);
	}

	public virtual bool on_http_patch(HTTPRequest req) {
		return(false);
	}

	public bool on_http_request(HTTPRequest req) {
		if(req.is_get_request()) {
			return(on_http_get(req));
		}
		if(req.is_post_request()) {
			return(on_http_post(req));
		}
		if(req.is_put_request()) {
			return(on_http_put(req));
		}
		if(req.is_delete_request()) {
			return(on_http_delete(req));
		}
		if(req.is_patch_request()) {
			return(on_http_patch(req));
		}
		return(false);
	}

	public bool on_authenticated_request(HTTPRequest req, Object session) {
		if(req.is_get_request()) {
			return(on_authenticated_get(req, session));
		}
		if(req.is_post_request()) {
			return(on_authenticated_post(req, session));
		}
		if(req.is_put_request()) {
			return(on_authenticated_put(req, session));
		}
		if(req.is_delete_request()) {
			return(on_authenticated_delete(req, session));
		}
		if(req.is_patch_request()) {
			return(on_authenticated_patch(req, session));
		}
		return(false);
	}

	public virtual bool on_authenticated_get(HTTPRequest req, Object session) {
		return(false);
	}

	public virtual bool on_authenticated_post(HTTPRequest req, Object session) {
		return(false);
	}

	public virtual bool on_authenticated_put(HTTPRequest req, Object session) {
		return(false);
	}

	public virtual bool on_authenticated_delete(HTTPRequest req, Object session) {
		return(false);
	}

	public virtual bool on_authenticated_patch(HTTPRequest req, Object session) {
		return(false);
	}

	public HTTPRequestBodyHandler get_request_body_handler(HTTPRequest req) {
		return(HTTPRequestMemoryBufferBodyHandler.for_maximum_size(maximum_request_body_size));
	}

	public HTTPRequestBodyHandler get_authenticated_request_body_handler(HTTPRequest req, Object session) {
		return(HTTPRequestMemoryBufferBodyHandler.for_maximum_size(maximum_request_body_size));
	}

	public bool on_unhandled_request(HTTPRequest req, HTTPRequestHandler handler = null) {
		return(false);
	}
}
