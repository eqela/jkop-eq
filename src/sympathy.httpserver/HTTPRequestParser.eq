
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

public class HTTPRequestParser
{
	String method;
	String uri;
	String version;
	String key;
	HashTable headers;
	bool headers_done;
	HTTPRequestBodyHandler body;
	bool body_done;
	StringBuffer hdr;
	int content_length;
	bool body_is_chunked = false;
	int data_counter;
	HTTPRequest hdr_req;

	public void reset() {
		method = null;
		uri = null;
		version = null;
		key = null;
		headers = null;
		headers_done = false;
		body = null;
		body_done = false;
		hdr = null;
		content_length = 0;
		body_is_chunked = false;
		data_counter = 0;
		hdr_req = null;
	}

	public virtual HTTPRequestBodyHandler get_request_body_handler(HTTPRequest req) {
		return(null);
	}

	public virtual void on_request(HTTPRequest req) {
	}

	public virtual void on_request_error(HTTPRequest req, HTTPResponse resp) {
	}

	void on_headers_done() {
		if(method == null || uri == null) {
			on_request_error(hdr_req, HTTPResponse.for_http_invalid_request());
			reset();
			return;
		}
		hdr_req = HTTPRequest.for_details(method, uri, version, headers);
		if("POST".equals(method) || "PUT".equals(method) || "PATCH".equals(method)) {
			HTTPResponse error;
			body = get_request_body_handler(hdr_req);
			if(body != null) {
				var ll = content_length;
				if(body_is_chunked) {
					ll = -1;
				}
				if(body.on_body_start(ll) == false) {
					error = get_body_error(body);
					body = null;
				}
			}
			if(error != null) {
				on_request_error(hdr_req, error);
				reset();
			}
		}
		else {
			on_request(hdr_req);
			reset();
		}
	}

	void on_body_done() {
		if(body != null) {
			if(body.on_body_end() == false) {
				on_request_error(hdr_req, get_body_error(body));
				reset();
				body = null;
				return;
			}
		}
		var req = hdr_req;
		if(req == null) {
			req = HTTPRequest.for_details(method, uri, version, headers);
		}
		req.set_body(body);
		on_request(req);
		reset();
	}

	public void on_data(Buffer buffer, int offset = 0, int asz = -1) {
		if(buffer == null) {
			return;
		}
		var sz = asz;
		if(sz < 0) {
			sz = buffer.get_size();
		}
		if(headers_done && body_done) {
			// should not happen, but we'll consider it a sanity check
			Log.debug("Headers done and body bone when receiving data. This should not happen.");
			reset();
		}
		if(headers_done == false) {
			on_header_data(buffer, offset, sz);
		}
		else if(body_done == false) {
			on_body_data(buffer, offset, sz);
		}
	}

	HTTPResponse get_body_error(HTTPRequestBodyHandler handler) {
		if(handler == null) {
			return(HTTPResponse.for_http_not_allowed());
		}
		HTTPResponse resp;
		if(handler is HTTPRequestBodyHandlerWithError) {
			resp = ((HTTPRequestBodyHandlerWithError)handler).get_error_response();
		}
		if(resp == null) {
			resp = HTTPResponse.for_http_not_allowed();
		}
		return(resp);
	}

	void on_body_data(Buffer input_buffer, int offset, int sz) {
		if(input_buffer == null) {
			return;
		}
		if(body == null) {
			on_request_error(hdr_req, HTTPResponse.for_http_not_allowed());
			reset();
			return;
		}
		if(content_length > 0) {
			int p = 0;
			if(data_counter + sz <= content_length) {
				p = sz;
			}
			else {
				p = content_length - data_counter;
			}
			if(body.on_body_data(SubBuffer.create(input_buffer, offset, p)) == false) {
				on_request_error(hdr_req, get_body_error(body));
				reset();
				return;
			}
			data_counter += p;
			if(data_counter >= content_length) {
				body_done = true;
				on_body_done();
				if(p < sz) {
					on_data(input_buffer, offset + p, sz-p);
				}
			}
			return;
		}
		else if(body_is_chunked) {
			// FIXME
		}
		else {
			on_request_error(hdr_req, HTTPResponse.for_http_invalid_request());
			reset();
		}
	}

	void on_header_data(Buffer input_buffer, int offset, int sz) {
		if(input_buffer == null) {
			return;
		}
		var bptr = input_buffer.get_pointer();
		if(bptr == null) {
			return;
		}
		int p = 0;
		while(p < sz) {
			var c = bptr.get_byte(p + offset);
			p ++;
			if(c == '\r') {
				continue;
			}
			if(method == null) {
				if(c == '\n') {
					// ignore empty lines and other garbage in the beginning
					continue;
				}
				if(c == ' ') {
					if(hdr != null) {
						method = hdr.to_string();
						hdr = null;
					}
					continue;
				}
			}
			else if(uri == null) {
				if(c == ' ') {
					if(hdr != null) {
						uri = hdr.to_string();
						hdr = null;
					}
					continue;
				}
				else if(c == '\n') {
					if(hdr != null) {
						uri = hdr.to_string();
						hdr = null;
					}
					version = "HTTP/0.9";
					headers_done = true;
					on_headers_done();
					if(p < sz) {
						on_data(input_buffer, offset + p, sz-p);
					}
					return;
				}
			}
			else if(version == null) {
				if(c == '\n') {
					if(hdr != null) {
						version = hdr.to_string();
						hdr = null;
					}
					continue;
				}
			}
			else if(key == null) {
				if(c == ':') {
					if(hdr != null) {
						key = hdr.to_string();
						hdr = null;
					}
					continue;
				}
				else if(c == '\n') {
					if(hdr != null) {
						on_request_error(hdr_req, HTTPResponse.for_http_invalid_request());
						reset();
						return;
					}
					headers_done = true;
					on_headers_done();
					if(p < sz) {
						on_data(input_buffer, offset + p, sz-p);
					}
					return;
				}
				if(c >= 'A' && c <= 'Z') {
					c = (int)'a' + c - (int)'A';
				}
			}
			else if(c == ' ' && hdr == null) {
				continue;
			}
			else if(c == '\n') {
				String value;
				if(hdr != null) {
					value = hdr.to_string();
					hdr = null;
				}
				if(headers == null) {
					headers = HashTable.create();
				}
				var oo = headers.get_string(key);
				if(oo == null) {
					headers.set(key, value);
				}
				else {
					headers.set(key, "%s, %s".printf().add(oo).add(value).to_string());
				}
				if("content-length".equals(key) && value != null) {
					content_length = value.to_integer();
				}
				else if("transfer-encoding".equals(key) && value != null && value.contains("chunked")) {
					body_is_chunked = true;
				}
				key = null;
				continue;
			}
			if(hdr == null) {
				int bsz;
				if(method == null) {
					bsz = 8;
				}
				else if(uri == null) {
					bsz = 1024;
				}
				else if(version == null) {
					bsz = 9;
				}
				else if(key == null) {
					bsz = 64;
				}
				else {
					bsz = 1024;
				}
				hdr = StringBuffer.for_initial_size(bsz);
			}
			hdr.append_c(c);
			if(hdr.count() > 32 * 1024) {
				on_request_error(hdr_req, HTTPResponse.for_http_invalid_request());
				reset();
				return;
			}
		}
	}
}
