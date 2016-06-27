
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

public class GoogleCalendarAPIStringResponseReceiver : EventReceiver
{
	property GoogleCalendarAPIListener listener;

	public void on_event(Object o) {
		if(o is HTTPClientStringResponse) {
			var resp = ((HTTPClientStringResponse)o);
			var http_status = Integer.as_integer(resp.get_status());
			if(http_status >= 200 && http_status < 300) {
				on_string_response(resp.get_data(), resp);
			}
			else {
				Error err;
				if(String.is_empty(resp.get_status()) == false){
					err = Error.for_code("HTTP Status ".append(resp.get_status()));
				}
				if(err == null) {
					err = Error.for_message("Error occurred.");
				}
				on_http_request_failed(err);
			}
		}
	}

	public virtual void on_string_response(String data, HTTPClientStringResponse resp) {
	}

	public virtual void on_http_request_failed(Error error) {
		if(listener != null) {
			listener.on_google_api_request_completed(null, error);
		}
	}
}
