
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

public class HTTPResponse
{
	// Standard / fundamental type responses

	public static HTTPResponse for_file(File f, int max_cached_size = -1) {
		if(f == null) {
			return(HTTPResponse.for_http_internal_error());
		}
		if(f.is_file() == false) {
			return(HTTPResponse.for_http_not_found());
		}
		var bodyset = false;
		var resp = new HTTPResponse();
		resp.set_status("200");
		resp.add_header("Content-Type", MimeTypeRegistry.type_for_file(f));
		var st = f.stat();
		if(st != null) {
			int lm = st.get_modify_time();
			if(lm > 0) {
				var dts = VerboseDateTimeString.for_datetime(DateTime.for_time(lm));
				resp.add_header("Last-Modified", dts);
				var md5 = MD5Encoder.instance();
				if(md5 != null) {
					resp.set_etag(md5.hash(dts));
				}
			}
			var mcs = max_cached_size;
			if(mcs < 0) {
				mcs = 32 * 1024;
			}
			if(st.get_size() < mcs) {
				resp.set_body_buffer(f.get_contents_buffer());
				bodyset = true;
			}
		}
		if(bodyset == false) {
			resp.set_body_file(f);
		}
		return(resp);
	}

	public static HTTPResponse for_buffer(Buffer data, String mimetype = null) {
		var mt = mimetype;
		if(String.is_empty(mt)) {
			mt = "application/binary";
		}
		var resp = new HTTPResponse();
		resp.set_status("200");
		resp.add_header("Content-Type", mt);
		resp.set_body_buffer(data);
		return(resp);
	}

	public static HTTPResponse for_string(String text, String mimetype) {
		var resp = new HTTPResponse();
		resp.set_status("200");
		if(String.is_empty(mimetype) == false) {
			resp.add_header("Content-Type", mimetype);
		}
		resp.set_body_string(text);
		return(resp);
	}

	public static HTTPResponse for_text_string(String text) {
		var resp = new HTTPResponse();
		resp.set_status("200");
		resp.add_header("Content-Type", "text/plain; charset=\"UTF-8\"");
		resp.set_body_string(text);
		return(resp);
	}

	public static HTTPResponse for_html_string(String html) {
		var resp = new HTTPResponse();
		resp.set_status("200");
		resp.add_header("Content-Type", "text/html; charset=\"UTF-8\"");
		resp.set_body_string(html);
		return(resp);
	}

	public static HTTPResponse for_xml_string(String xml) {
		var resp = new HTTPResponse();
		resp.set_status("200");
		resp.add_header("Content-Type", "text/xml; charset=\"UTF-8\"");
		resp.set_body_string(xml);
		return(resp);
	}

	public static HTTPResponse for_json_object(Object o) {
		return(HTTPResponse.for_json_string(JSONEncoder.encode(o)));
	}

	public static HTTPResponse for_json_string(String json) {
		var resp = new HTTPResponse();
		resp.set_status("200");
		resp.add_header("Content-Type", "application/json; charset=\"UTF-8\"");
		resp.set_body_string(json);
		return(resp);
	}

	public static HTTPResponse for_error(Error error) {
		var err = error;
		if(err == null) {
			err = Error.for_message("Unknown error");
		}
		return(HTTPResponse.for_http_internal_error(String.as_string(err)));
	}

	// Standard HTTP status codes

	static String string_with_message(String str, String message) {
		if(String.is_empty(message)) {
			return(str);
		}
		return("%s: %s".printf().add(str).add(message).to_string());
	}

	public static HTTPResponse for_http_invalid_request(String message = null) {
		var resp = HTTPResponse.for_text_string(string_with_message("Invalid request", message));
		resp.set_status("400");
		resp.add_header("Connection", "close");
		resp.set_message(message);
		return(resp);
	}

	public static HTTPResponse for_http_internal_error(String message = null) {
		var resp = HTTPResponse.for_text_string(string_with_message("Internal server error", message));
		resp.set_status("500");
		resp.add_header("Connection", "close");
		resp.set_message(message);
		return(resp);
	}

	public static HTTPResponse for_http_not_implemented(String message = null) {
		var resp = HTTPResponse.for_text_string(string_with_message("Not implemented", message));
		resp.set_status("501");
		resp.add_header("Connection", "close");
		resp.set_message(message);
		return(resp);
	}

	public static HTTPResponse for_http_not_allowed(String message = null) {
		var resp = HTTPResponse.for_text_string(string_with_message("Not allowed", message));
		resp.set_status("405");
		resp.set_message(message);
		return(resp);
	}

	public static HTTPResponse for_http_not_found(String message = null) {
		var resp = HTTPResponse.for_text_string(string_with_message("Not found", message));
		resp.set_status("404");
		resp.set_message(message);
		return(resp);
	}

	public static HTTPResponse for_http_forbidden(String message = null) {
		var resp = HTTPResponse.for_text_string(string_with_message("Forbidden", message));
		resp.set_status("403");
		resp.set_message(message);
		return(resp);
	}

	public static HTTPResponse for_redirect(String url) {
		return(for_http_moved_temporarily(url));
	}

	public static HTTPResponse for_http_moved_permanently(String url) {
		var resp = new HTTPResponse();
		resp.set_status("301");
		resp.add_header("Location", url);
		resp.set_body_string(url);
		return(resp);
	}

	public static HTTPResponse for_http_moved_temporarily(String url) {
		var resp = new HTTPResponse();
		resp.set_status("303");
		resp.add_header("Location", url);
		resp.set_body_string(url);
		return(resp);
	}

	int cache_ttl = 0;
	String status;
	bool status_is_ok = false;
	property KeyValueList headers;
	property String message;
	Object body;
	String etag;

	public void set_etag(String etag) {
		this.etag = etag;
		add_header("ETag", etag);
	}

	public String get_etag() {
		return(etag);
	}

	public HTTPResponse set_status(String status) {
		this.status = status;
		if("200".equals(status)) {
			status_is_ok = true;
		}
		return(this);
	}

	public String get_status() {
		return(status);
	}

	public int get_cache_ttl() {
		if(status_is_ok) {
			return(cache_ttl);
		}
		return(0);
	}

	public HTTPResponse enable_caching(int ttl = 3600) {
		cache_ttl = ttl;
		return(this);
	}

	public HTTPResponse disable_caching() {
		cache_ttl = 0;
		return(this);
	}

	public HTTPResponse enable_cors(HTTPRequest req = null) {
		add_header("Access-Control-Allow-Origin", "*");
		if(req != null) {
			add_header("Access-Control-Allow-Methods", req.get_header("access-control-request-method"));
			add_header("Access-Control-Allow-Headers", req.get_header("access-control-request-headers"));
		}
		add_header("Access-Control-Max-Age", "1728000");
		return(this);
	}

	public HTTPResponse add_header(String key, String value) {
		if(headers == null) {
			headers = new KeyValueList();
		}
		headers.append(key, value);
		return(this);
	}

	public void add_cookie(HTTPCookie cookie) {
		if(cookie == null) {
			return;
		}
		add_header("Set-Cookie", cookie.to_string());
	}

	public HTTPResponse set_body_buffer(Buffer buf) {
		if(buf == null) {
			body = null;
			add_header("Content-Length", "0");
		}
		else {
			body = buf;
			add_header("Content-Length", String.for_integer(buf.get_size()));
		}
		return(this);
	}

	public HTTPResponse set_body_string(String str) {
		if(str == null) {
			body = null;
			add_header("Content-Length", "0");
		}
		else {
			var buf = str.to_utf8_buffer(false);
			body = buf;
			add_header("Content-Length", String.for_integer(buf.get_size()));
		}
		return(this);
	}

	public HTTPResponse set_body_file(File file) {
		if(file == null || file.is_file() == false) {
			body = null;
			add_header("Content-Length", "0");
		}
		else {
			body = file;
			add_header("Content-Length", String.for_integer(file.get_size()));
		}
		return(this);
	}

	/* FIXME
	public HTTPResponse set_body_reader(Reader reader) {
		body_reader = reader;
		add_header("Transfer-Encoding", "chunked");
		log_warning("Chunked encoding not implemented");
		return(this);
	}
	*/

	public HTTPResponse set_body(Object bd) {
		body = bd;
		return(this);
	}

	public Object get_body() {
		return(body);
	}

	public Reader get_body_reader() {
		if(body == null) {
			return(null);
		}
		if(body is File) {
			return(((File)body).read());
		}
		if(body is String) {
			return(StringReader.for_string((String)body));
		}
		if(body is Buffer) {
			return(BufferReader.for_buffer((Buffer)body));
		}
		if(body is Reader) {
			return((Reader)body);
		}
		return(null);
	}
}
