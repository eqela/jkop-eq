
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

public class FacebookAPIHTTPClient
{
	public static FacebookAPIHTTPClient instance(BackgroundTaskManager btm, String access_token = null, String host = null) {
		var fb = new FacebookAPIHTTPClient();
		fb.host = host;
		fb.access_token = access_token;
		if(fb.host == null) {
			fb.host = "https://graph.facebook.com/v2.2/";
		}
		fb.btm = btm;
		return(fb);
	}

	String host;
	BackgroundTaskManager btm;
	property String access_token;

	private String append_host_and_access_token(String url, String facebook_host = null) {
		StringBuffer sb;
		if(String.is_empty(facebook_host) == false) {
			sb = StringBuffer.create(facebook_host);
		}
		else {
			sb = StringBuffer.create(host);
		}
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
			sb.append("access_token=");
			sb.append(access_token);
		}
		return(sb.to_string());
	}

	public BackgroundTask query(String url, EventReceiver listener) {
		var new_url = append_host_and_access_token(url);
		HTTPClientRequest req;
		req = HTTPClientRequest.get(URL.for_string(new_url));
		req.set_header("Content-Type", "application/json");
		return(req.start_get_string(btm, listener));
	}

	public BackgroundTask publish(String url, EventReceiver listener) {
		var new_url = append_host_and_access_token(url);
		HTTPClientRequest req;
		req = new HTTPClientRequest();
		req.set_method("POST");
		req.set_url(URL.for_string(new_url));
		return(req.start_get_string(btm, listener));
	}

	public BackgroundTask publish_with_data(String url, String mimetype, SizedReader data, EventReceiver listener) {
		var new_url = append_host_and_access_token(url);
		HTTPClientRequest req;
		req = HTTPClientRequest.post_with_data(URL.for_string(new_url), mimetype, data);
		return(req.start_get_string(btm, listener));
	}

	public BackgroundTask publish_with_video(String url, String mimetype, SizedReader data, EventReceiver listener) {
		var new_url = append_host_and_access_token(url, "https://graph-video.facebook.com/");
		HTTPClientRequest req;
		req = HTTPClientRequest.post_with_data(URL.for_string(new_url), mimetype, data);
		return(req.start_get_string(btm, listener));
	}
}
