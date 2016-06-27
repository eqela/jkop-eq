
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

public class TwitterAPIHTTPClient
{
	public static TwitterAPIHTTPClient instance(BackgroundTaskManager btm, String ckey, String csecret, String host = null) {
		var tt = new TwitterAPIHTTPClient();
		tt.host = host;
		if(tt.host == null) {
			tt.host = "https://api.twitter.com/";
		}
		tt.btm = btm;
		tt.ckey = ckey;
		tt.csecret = csecret;
		return(tt);
	}

	String host;
	BackgroundTaskManager btm;
	property String ckey;
	property String csecret;
	property String tkey;
	property String tsecret;

	public BackgroundTask get(String url, EventReceiver listener) {
		HTTPClientRequest req;
		req = HTTPClientRequest.get(URL.for_string(host.append("1.1/").append(url)));
		req.set_header("Content-Type", "application/json");
		TwitterSignature.sign_http_request(req, ckey, csecret, tkey, tsecret);
		return(req.start_get_string(btm, listener));
	}

	public BackgroundTask post(String url, EventReceiver listener) {
		HTTPClientRequest req;
		req = new HTTPClientRequest();
		req.set_method("POST");
		req.set_url(URL.for_string(host.append("1.1/").append(url)));
		req.set_header("Content-Type", "application/x-www-form-urlencoded");
		TwitterSignature.sign_http_request(req, ckey, csecret, tkey, tsecret);
		return(req.start_get_string(btm, listener));
	}

	public BackgroundTask post_for_login(String url, String oauth_callback, EventReceiver listener) {
		HTTPClientRequest req;
		req = new HTTPClientRequest();
		req.set_method("POST");
		req.set_url(URL.for_string(host.append(url)));
		TwitterLoginSignature.sign_http_request_for_login(req, oauth_callback, ckey, csecret);
		return(req.start_get_string(btm, listener));
	}

	public BackgroundTask post_with_data(String mimetype, SizedReader data, EventReceiver listener) {
		var url = "https://upload.twitter.com/1.1/media/upload.json";
		HTTPClientRequest req;
		req = HTTPClientRequest.post_with_data(URL.for_string(url), mimetype, data);
		TwitterSignature.sign_http_request(req, ckey, csecret, tkey, tsecret, false);
		return(req.start_get_string(btm, listener));
	}

	public BackgroundTask post_for_access_token(String url, TwitterAPIConvertableToken token, String ltsecret, EventReceiver listener) {
		HTTPClientRequest req;
		req = new HTTPClientRequest();
		req.set_method("POST");
		req.set_url(URL.for_string(host.append(url)));
		req.set_header("Content-Type", "application/x-www-form-urlencoded");
		var body_params = "oauth_verifier=".append(token.get_oauth_verifier());
		req.set_body(StringReader.create(body_params));
		TwitterSignature.sign_http_request(req, ckey, csecret, token.get_oauth_token(), ltsecret);
		return(req.start_get_string(btm, listener));
	}
}
