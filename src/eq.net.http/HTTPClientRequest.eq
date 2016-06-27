
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

public class HTTPClientRequest
{
	public static HTTPClientRequest get(URL url) {
		return(new HTTPClientRequest().set_method("GET").set_url(url));
	}

	public static HTTPClientRequest get_with_params(URL url, HashTable params) {
		if(params != null && url != null) {
			var qp = url.get_query_parameters();
			if(qp == null) {
				url.set_query_parameters(params);
			}
			else {
				foreach(String key in params) {
					qp.set(key, params.get(key));
				}
			}
		}
		return(new HTTPClientRequest().set_method("GET").set_url(url));
	}

	public static HTTPClientRequest post_with_params(URL url, HashTable params) {
		var sb = StringBuffer.create();
		if(params != null) {
			foreach(String key in params) {
				if(sb.count() > 0) {
					sb.append_c((int)'&');
				}
				sb.append(key);
				sb.append_c((int)'=');
				sb.append(URLEncoder.encode(params.get_string(key)));
			}
		}
		return(new HTTPClientRequest().set_method("POST").set_url(url)
			.set_header("Content-Type", "application/x-www-form-urlencoded")
			.set_body(StringReader.create(sb.to_string())));
	}

	public static HTTPClientRequest post_with_data(URL url, String mimetype, SizedReader data) {
		return(new HTTPClientRequest()
			.set_method("POST")
			.set_url(url)
			.set_header("Content-Type", mimetype)
			.set_body(data));
	}

	property String method;
	property URL url;
	property SizedReader body;
	property HashTable headers;

	public HTTPClientRequest set_header(String k, String v) {
		if(headers == null) {
			headers = HashTable.create();
		}
		headers.set(k, v);
		return(this);
	}

	public BackgroundTask start(BackgroundTaskManager el, EventReceiver listener) {
		return(HTTPClientOperation.start(el, this, listener));
	}

	public BackgroundTask start_get_string(BackgroundTaskManager el, EventReceiver listener) {
		return(start(el, new HTTPClientStringReceiver().set_listener(listener)));
	}

	public BackgroundTask start_get_buffer(BackgroundTaskManager el, EventReceiver listener) {
		return(start(el, new HTTPClientBufferReceiver().set_listener(listener)));
	}

	public bool execute(EventReceiver listener) {
		var v = HTTPClientOperation.execute(this, listener);
		if(v == false) {
			Log.warning("HTTPClientRequest: This platform does not support synchronous HTTP requests");
		}
		return(v);
	}

	public String execute_to_string() {
		var listener = new HTTPClientStringReceiver();
		if(execute(listener) == false) {
			return(null);
		}
		return(listener.to_string());
	}

	public Buffer execute_to_buffer() {
		var listener = new HTTPClientBufferReceiver();
		if(execute(listener) == false) {
			return(null);
		}
		return(listener.get_data());
	}

	public File execute_to_file(File destfile) {
		if(destfile == null) {
			return(null);
		}
		var listener = new HTTPClientFileWriter().set_destfile(destfile);
		if(execute(listener) == false) {
			return(null);
		}
		if(destfile.is_file() == false) {
			return(null);
		}
		return(destfile);
	}
}
