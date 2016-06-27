
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

public class CaldavAPIHTTPClient
{
	public static CaldavAPIHTTPClient instance(BackgroundTaskManager btm, String host) {
		var caldavclient = new CaldavAPIHTTPClient();
		caldavclient.host = host;
		caldavclient.btm = btm;
		return(caldavclient);
	}

	BackgroundTaskManager btm;
	String host;

	public BackgroundTask get(String url, String authorization_code, String data, String depth, EventReceiver listener) {
		String new_url = host;
		if(url != null) {
			new_url = host.append(url);
		}
		HTTPClientRequest req;
		req = new HTTPClientRequest();
		req.set_method("PROPFIND");
		req.set_url(URL.for_string(new_url));
		req.set_header("Authorization", "Basic ".append(authorization_code));
		req.set_header("Depth", depth);
		req.set_header("Prefer", "return-minimal");
		req.set_header("Content-Type", "application/xml; charset=UTF-8");
		req.set_body(StringReader.create(data));
		return(HTTPClientOperation.start(btm, req, new HTTPClientStringReceiver().set_listener(listener)));
	}

	public BackgroundTask query(String url, String authorization_code, String data, EventReceiver listener) {
		var new_url = host.append(url);
		HTTPClientRequest req;
		req = new HTTPClientRequest();
		req.set_method("REPORT");
		req.set_url(URL.for_string(new_url));
		req.set_header("Authorization", "Basic ".append(authorization_code));
		req.set_header("Depth", "1");
		req.set_header("Prefer", "return-minimal");
		req.set_header("Content-Type", "application/xml; charset=UTF-8");
		req.set_header("Content-Length", String.as_string(data.get_length()));
		req.set_body(StringReader.create(data));
		return(HTTPClientOperation.start(btm, req, new HTTPClientStringReceiver().set_listener(listener)));
	}
}
