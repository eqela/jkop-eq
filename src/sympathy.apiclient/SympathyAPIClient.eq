
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

public class SympathyAPIClient
{
	public static SympathyAPIClient for_server(String server, BackgroundTaskManager mgr) {
		return(new SympathyAPIClient().set_server(server).set_manager(mgr));
	}

	property String server;
	property String username;
	property String session;
	property BackgroundTaskManager manager;

	public BackgroundTask get(String url, EventReceiver listener) {
		var urls = "%s%s".printf().add(server).add(url).to_string();
		var urlo = URL.for_string(urls);
		if(urlo == null) {
			EventReceiver.event(listener,
				SympathyAPICallResult.for_error_message("Invalid URL string: `%s'".printf().add(urls).to_string()));
			return(null);
		}
		if(String.is_empty(urlo.get_scheme())) {
			urlo.set_scheme("http");
		}
		Log.debug("Sympathy API call URL: GET `%s'".printf().add(urlo));
		var req = HTTPClientRequest.get(urlo);
		if(session != null) {
			req.set_header("Session", session);
		}
		return(req.start(manager, new SympathyAPICallResultReceiver().set_listener(listener)));
	}

	public BackgroundTask post(String url, Object data, EventReceiver listener) {
		var urls = "%s%s".printf().add(server).add(url).to_string();
		var urlo = URL.for_string(urls);
		if(urlo == null) {
			EventReceiver.event(listener,
				SympathyAPICallResult.for_error_message("Invalid URL string: `%s'".printf().add(urls).to_string()));
			return(null);
		}
		if(String.is_empty(urlo.get_scheme())) {
			urlo.set_scheme("http");
		}
		Log.debug("Sympathy API call URL: POST `%s'".printf().add(urlo));
		var req = HTTPClientRequest.post_with_data(urlo, "application/json", StringReader.for_string(JSONEncoder.encode(data)));
		if(session != null) {
			req.set_header("Session", session);
		}
		return(req.start(manager, new SympathyAPICallResultReceiver().set_listener(listener)));
	}

	public BackgroundTask put(String url, Object data, EventReceiver listener) {
		var urls = "%s%s".printf().add(server).add(url).to_string();
		var urlo = URL.for_string(urls);
		if(urlo == null) {
			EventReceiver.event(listener,
				SympathyAPICallResult.for_error_message("Invalid URL string: `%s'".printf().add(urls).to_string()));
			return(null);
		}
		if(String.is_empty(urlo.get_scheme())) {
			urlo.set_scheme("http");
		}
		Log.debug("Sympathy API call URL: PUT `%s'".printf().add(urlo));
		var req = new HTTPClientRequest();
		req.set_method("PUT");
		req.set_url(urlo);
		req.set_header("Content-Type", "application/json");
		req.set_body(StringReader.for_string(JSONEncoder.encode(data)));
		if(session != null) {
			req.set_header("Session", session);
		}
		return(req.start(manager, new SympathyAPICallResultReceiver().set_listener(listener)));
	}

	public BackgroundTask patch(String url, Object data, EventReceiver listener) {
		var urls = "%s%s".printf().add(server).add(url).to_string();
		var urlo = URL.for_string(urls);
		if(urlo == null) {
			EventReceiver.event(listener,
				SympathyAPICallResult.for_error_message("Invalid URL string: `%s'".printf().add(urls).to_string()));
			return(null);
		}
		if(String.is_empty(urlo.get_scheme())) {
			urlo.set_scheme("http");
		}
		Log.debug("Sympathy API call URL: PATCH `%s'".printf().add(urlo));
		var req = new HTTPClientRequest();
		req.set_method("PATCH");
		req.set_url(urlo);
		req.set_header("Content-Type", "application/json");
		req.set_body(StringReader.for_string(JSONEncoder.encode(data)));
		if(session != null) {
			req.set_header("Session", session);
		}
		return(req.start(manager, new SympathyAPICallResultReceiver().set_listener(listener)));
	}

	public BackgroundTask delete(String url, EventReceiver listener) {
		var urls = "%s%s".printf().add(server).add(url).to_string();
		var urlo = URL.for_string(urls);
		if(urlo == null) {
			EventReceiver.event(listener,
				SympathyAPICallResult.for_error_message("Invalid URL string: `%s'".printf().add(urls).to_string()));
			return(null);
		}
		if(String.is_empty(urlo.get_scheme())) {
			urlo.set_scheme("http");
		}
		Log.debug("Sympathy API call URL: DELETE `%s'".printf().add(urlo));
		var req = new HTTPClientRequest().set_method("DELETE").set_url(urlo);
		if(session != null) {
			req.set_header("Session", session);
		}
		return(req.start(manager, new SympathyAPICallResultReceiver().set_listener(listener)));
	}
}
