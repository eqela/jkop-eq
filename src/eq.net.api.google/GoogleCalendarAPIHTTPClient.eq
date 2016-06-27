
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

public class GoogleCalendarAPIHTTPClient
{
	public static GoogleCalendarAPIHTTPClient instance(BackgroundTaskManager btm, String host = null, String cid = null, String scope = null) {
		var gc = new GoogleCalendarAPIHTTPClient();
		gc.host = host;
		if(gc.host == null) {
			gc.host = "https://www.googleapis.com";
		}
		gc.btm = btm;
		gc.scope = scope;
		gc.client_id = cid;
		return(gc);
	}

	BackgroundTaskManager btm;
	String host;
	property String scope;
	property String client_id;

	private String append_host_and_access_token(String url, String access_token) {
		var sb = StringBuffer.create(host);
		sb.append(url);
		if(String.is_empty(access_token) == false) {
			if(url.contains("?")) {
				var len = url.get_length();
				if(url.get_char(len - 1) != 63) {
					sb.append("&");
				}
			}
			else {
				sb.append("?");
			}
			sb.append("key=");
			sb.append(access_token);
		}
		return(sb.to_string());
	}

	public BackgroundTask query_access_token(String url, String code, EventReceiver listener) {
		var sb = StringBuffer.create(host);
		sb.append(url);
		sb.append("?grant_type=authorization_code");
		sb.append("&redirect_uri=http://localhost");
		sb.append("&client_id=");
		sb.append(client_id);
		sb.append("&code=");
		sb.append(code);
		var new_url = sb.to_string();
		HTTPClientRequest req;
		req = new HTTPClientRequest();
		req.set_method("POST");
		req.set_url(URL.for_string(new_url));
		req.set_header("Content-Type", "application/x-www-form-urlencoded");
		return(req.start_get_string(btm, listener));
	}

	public BackgroundTask query_refresh_token(String url, String code, EventReceiver listener) {
		var sb = StringBuffer.create(host);
		sb.append(url);
		sb.append("?client_id=");
		sb.append(client_id);
		sb.append("&refresh_token=");
		sb.append(code);
		sb.append("&grant_type=refresh_token");
		var new_url = sb.to_string();
		HTTPClientRequest req;
		req = new HTTPClientRequest();
		req.set_method("POST");
		req.set_url(URL.for_string(new_url));
		req.set_header("Content-Type", "application/x-www-form-urlencoded");
		return(req.start_get_string(btm, listener));
	}

	public BackgroundTask query(String url, String token, EventReceiver listener) {
		HTTPClientRequest req;
		var new_url = new URL();
		new_url.set_encode_unreserved_chars(false);
		var splitted_str = host.split((int)':');
		var scheme = splitted_str.next() as String;
		var h = splitted_str.next() as String;
		new_url.set_scheme(scheme);
		new_url.set_host(h.substring(2));
		new_url.set_path("%s?key=".printf().add(url).add(token).to_string());
		req = HTTPClientRequest.get(new_url);
		req.set_header("Authorization", "Bearer ".append(token));
		return(req.start_get_string(btm, listener));
	}
}
