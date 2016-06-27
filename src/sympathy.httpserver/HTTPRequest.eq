
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

public class HTTPRequest
{
	public static HTTPRequest for_details(String method, String uri, String version, HashTable headers) {
		var v = new HTTPRequest();
		v.method = method;
		v.uri_string = uri;
		v.version = version;
		v.headers = headers;
		return(v);
	}

	// Standard properties

	String method;
	String uri_string;
	String version;
	HashTable headers;
	Reader body_reader;

	// Links to other classes

	property HTTPServerConnection connection;
	property HTTPServer server;
	property Object data;
	property Object session;
	property HTTPResponse error_response;

	// Caching

	String cache_id;

	public String get_cache_id() {
		if(cache_id == null) {
			if("GET".equals(method)) {
				cache_id = "%s %s".printf().add(method).add(uri_string).to_string();
			}
		}
		return(cache_id);
	}

	// Header queries

	public String get_method() {
		return(method);
	}

	public String get_uri_string() {
		return(uri_string);
	}

	public String get_version() {
		return(version);
	}

	public HashTable get_headers() {
		return(headers);
	}

	public String get_header(String hdrname) {
		if(String.is_empty(hdrname)) {
			return(null);
		}
		if(headers == null) {
			return(null);
		}
		return(headers.get_string(hdrname));
	}

	URL url;

	public URL get_url() {
		if(url == null) {
			url = URL.for_string(uri_string);
		}
		return(url);
	}

	public HashTable get_query_parameters() {
		var url = get_url();
		if(url == null) {
			return(null);
		}
		return(url.get_query_parameters());
	}

	public Iterator iterate_query_parameters() {
		if(uri_string == null) {
			return(null);
		}
		var q = uri_string.chr((int)'?');
		if(q < 0) {
			return(null);
		}
		var ss = uri_string.substring(q+1);
		if(String.is_empty(ss)) {
			return(null);
		}
		var vs = ss.split((int)'&');
		if(vs == null) {
			return(null);
		}
		var v = Array.create();
		foreach(String qp in vs) {
			if(String.is_empty(qp)) {
				continue;
			}
			var kvp = new KeyValuePair();
			var e = qp.chr((int)'=');
			if(e < 0) {
				kvp.set_key(qp);
				kvp.set_value(null);
			}
			else {
				kvp.set_key(qp.substring(0, e));
				kvp.set_value(URLDecoder.decode(qp.substring(e+1)));
			}
			v.append(kvp);
		}
		return(v.iterate());
	}

	public String get_query_parameter(String key) {
		var url = get_url();
		if(url == null) {
			return(null);
		}
		return(url.get_query_parameter(key));
	}

	String url_path;

	String normalize_url(String url) {
		if(url == null) {
			return(null);
		}
		var p = Path.normalize_path(url);
		if(p == null) {
			return(null);
		}
		var slash = "/";
		if(slash.equals(p)) {
		}
		else if(url.has_suffix(slash)) {
			p = p.append(slash);
		}
		return(p);
	}

	public String get_url_path() {
		if(url_path == null) {
			if(uri_string != null) {
				var q = uri_string.chr((int)'?');
				if(q < 1) {
					url_path = normalize_url(uri_string);
				}
				else {
					url_path = normalize_url(uri_string.substring(0,q));
				}
			}
		}
		return(url_path);
	}

	public String get_remote_address() {
		if(connection == null) {
			return(null);
		}
		return(connection.get_remote_address());
	}

	// Header shortcuts

	public bool get_connection_close() {
		if(headers == null) {
			return(false);
		}
		return("close".equals(headers.get_string("connection")));
	}

	public String get_etag() {
		if(headers == null) {
			return(null);
		}
		return(headers.get_string("if-none-match"));
	}

	// Cookies

	HashTable cookies;

	public HashTable get_cookie_values() {
		if(cookies == null) {
			var v = HashTable.create();
			if(headers != null) {
				var cookies = headers.get_string("cookie");
				if(cookies != null) {
					var sp = cookies.split((int)';');
					String ck;
					while((ck = sp.next() as String) != null) {
						ck = ck.strip();
						if(ck == null) {
							continue;
						}
						var e = ck.chr((int)'=');
						if(e < 0) {
							v.set_bool(ck, true);
						}
						else {
							v.set(ck.substring(0,e), ck.substring(e+1));
						}
					}
				}
			}
			cookies = v;
		}
		return(cookies);
	}

	public String get_cookie_value(String name) {
		var c = get_cookie_values();
		if(c == null) {
			return(null);
		}
		return(c.get_string(name));
	}

	// Body shortcuts

	public void set_body(Reader body) {
		this.body_reader = body;
	}

	public Reader get_body_reader() {
		return(body_reader);
	}

	Buffer body_buffer_cached;

	public Buffer get_body_buffer() {
		if(body_buffer_cached == null && body_reader != null) {
			var ins = InputStream.create(body_reader);
			if(ins != null) {
				body_buffer_cached = ins.read_all_buffer();
			}
			body_reader = null;
		}
		return(body_buffer_cached);
	}

	String body_string_cached;

	public String get_body_string() {
		if(body_string_cached == null && body_reader != null) {
			var ins = InputStream.create(body_reader);
			if(ins != null) {
				body_string_cached = ins.read_all_string();
			}
			body_reader = null;
		}
		return(body_string_cached);
	}

	public HashTable get_body_json_hashtable() {
		return(JSONParser.parse_string(get_body_string()) as HashTable);
	}

	HashTable post_parameters;

	public HashTable get_post_parameters() {
		if(post_parameters != null) {
			return(post_parameters);
		}
		var bs = get_body_string();
		if(String.is_empty(bs)) {
			return(null);
		}
		post_parameters = QueryString.parse(bs);
		return(post_parameters);
	}

	public String get_post_parameter(String key) {
		var pps = get_post_parameters();
		if(pps == null) {
			return(null);
		}
		return(pps.get_string(key));
	}

	// Unknown

	LinkedList resources;
	LinkedListNode current_resource;

	public String get_relative_request_path(String relative_to) {
		var url = get_url();
		if(url != null) {
			var urls = url.get_path();
			if(urls != null) {
				var path = Path.normalize_path(urls);
				if(relative_to != null && path.has_prefix(relative_to)) {
					path = path.substring(relative_to.get_length());
				}
				if(String.is_empty(path)) {
					path = "/";
				}
				return(path);
			}
		}
		return(null);
	}

	void init_resources() {
		resources = LinkedList.create();
		var url = get_url();
		if(url != null) {
			var urls = url.get_path();
			if(urls != null) {
				var path = Path.normalize_path(urls);
				foreach(String cmp in path.split((int)'/')) {
					if(String.is_empty(cmp)) {
						continue;
					}
					resources.append(cmp);
				}
			}
		}
		current_resource = resources.get_first_node();
	}

	public bool has_more_resources() {
		if(resources == null) {
			init_resources();
		}
		if(current_resource == null) {
			return(false);
		}
		return(true);
	}

	public String pop_resource() {
		if(resources == null) {
			init_resources();
		}
		var v = get_resource();
		if(current_resource != null) {
			current_resource = current_resource.next;
			relative_resource_path = null;
		}
		return(v);
	}

	public String get_resource() {
		if(resources == null) {
			init_resources();
		}
		if(current_resource != null) {
			return(String.as_string(current_resource.get_node_value()));
		}
		return(null);
	}

	public Collection get_relative_resources() {
		if(resources == null) {
			init_resources();
		}
		var v = LinkedList.create();
		var cr = current_resource;
		while(cr != null) {
			var val = String.as_string(cr.get_node_value());
			if(String.is_empty(val) == false) {
				v.add(val);
			}
			cr = cr.next;
		}
		return(v);
	}

	String relative_resource_path;

	public String get_relative_resource_path() {
		if(relative_resource_path != null) {
			return(relative_resource_path);
		}
		if(resources == null) {
			init_resources();
		}
		var sb = StringBuffer.create();
		var cr = current_resource;
		while(cr != null) {
			var val = String.as_string(cr.get_node_value());
			if(String.is_empty(val) == false) {
				sb.append_c((int)'/');
				sb.append(val);
			}
			cr = cr.next;
		}
		if(sb.count() < 1) {
			sb.append_c((int)'/');
		}
		relative_resource_path = sb.to_string();
		return(relative_resource_path);
	}

	public bool is_for_resource(String res) {
		if(res == null) {
			return(false);
		}
		if(res.equals(get_relative_resource_path())) {
			return(true);
		}
		return(false);
	}

	public bool is_for_directory() {
		var url = get_url();
		if(url != null) {
			var urls = url.get_path();
			if(urls != null) {
				if(urls.has_suffix("/")) {
					return(true);
				}
			}
		}
		return(false);
	}

	public bool is_for_prefix(String res) {
		if(res == null) {
			return(false);
		}
		var rr = get_relative_resource_path();
		if(rr != null && rr.has_prefix(res)) {
			return(true);
		}
		return(false);
	}

	public void unpop_resource() {
		if(resources == null) {
			return;
		}
		if(current_resource == null) {
			current_resource = resources.get_last_node();
		}
		else if(current_resource.prev != null) {
			current_resource = current_resource.prev;
		}
		relative_resource_path = null;
	}

	public void reset_resources() {
		resources = null;
		current_resource = null;
		relative_resource_path = null;
	}

	public bool is_get_request() {
		return("GET".equals(method));
	}

	public bool is_post_request() {
		return("POST".equals(method));
	}

	public bool is_delete_request() {
		return("DELETE".equals(method));
	}

	public bool is_put_request() {
		return("PUT".equals(method));
	}

	public bool is_patch_request() {
		return("PATCH".equals(method));
	}

	// Sending of responses

	public void send_json_object(Object o) {
		send_json_string(JSONEncoder.encode(o));
	}

	public void send_json_string(String json) {
		send_response(HTTPResponse.for_json_string(json));
	}

	public void send_text_string(String text) {
		send_response(HTTPResponse.for_text_string(text));
	}

	public void send_html_string(String html) {
		send_response(HTTPResponse.for_html_string(html));
	}

	public void send_xml_string(String xml) {
		send_response(HTTPResponse.for_xml_string(xml));
	}

	public void send_file(File file) {
		send_response(HTTPResponse.for_file(file));
	}

	public void send_redirect(String url) {
		send_response(HTTPResponse.for_http_moved_temporarily(url));
	}

	public void send_redirect_as_directory() {
		String urls;
		var url = get_url();
		if(url != null) {
			urls = url.get_path();
		}
		if(urls == null) {
			urls = "";
		}
		send_redirect(urls.append("/"));
	}

	bool response_sent = false;
	Collection response_cookies;

	public bool is_response_sent() {
		return(response_sent);
	}

	public void add_response_cookie(HTTPCookie cookie) {
		if(cookie == null) {
			return;
		}
		if(response_cookies == null) {
			response_cookies = LinkedList.create();
		}
		response_cookies.append(cookie);
	}

	public void send_response(HTTPResponse resp) {
		if(response_sent) {
			return;
		}
		if(server != null) {
			foreach(HTTPCookie cookie in response_cookies) {
				resp.add_cookie(cookie);
			}
			response_cookies = null;
			server.send_response(connection, this, resp);
			response_sent = true;
		}
	}
}
