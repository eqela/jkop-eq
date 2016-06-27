
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

public class JSONRequestHandler : HTTPRequestHandlerAdapter
{
	public virtual Object on_json_get(HTTPRequest req) {
		return(null);
	}

	public virtual Object on_json_post_array(HTTPRequest req, Array data) {
		return(null);
	}

	public virtual Object on_json_post_hash_table(HTTPRequest req, HashTable data) {
		return(null);
	}

	public virtual Object on_json_post(HTTPRequest req, Object data) {
		if(data is Array) {
			return(on_json_post_array(req, (Array)data));
		}
		if(data is HashTable) {
			return(on_json_post_hash_table(req, (HashTable)data));
		}
		return(null);
	}

	public bool on_http_get(HTTPRequest req) {
		var r = on_json_get(req);
		if(r != null) {
			req.send_response(HTTPResponse.for_json_object(r));
			return(true);
		}
		return(base.on_http_get(req));
	}

	public bool on_http_post(HTTPRequest req) {
		var ct = req.get_header("content-type");
		if(ct == null) {
			return(false);
		}
		var sp = ct.split((int)';', 2);
		if(sp == null) {
			return(false);
		}
		var cts = String.as_string(sp.next());
		if("application/json".equals(cts) == false) {
			return(false);
		}
		var body = JSONParser.parse_string(req.get_body_string());
		if(body == null) {
			body = HashTable.create();
		}
		var r = on_json_post(req, body);
		if(r != null) {
			req.send_response(HTTPResponse.for_json_object(r));
			return(true);
		}
		return(base.on_http_post(req));
	}
}
