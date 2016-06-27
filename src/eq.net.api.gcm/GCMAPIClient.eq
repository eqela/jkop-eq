
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

public class GCMAPIClient
{
	class GCMRequestListener : EventReceiver
	{
		property GCMAPIListener listener;
		public void on_event(Object o) {
			if(listener != null) {
				if(o is HTTPClientStringResponse) {
					listener.on_response(((HTTPClientStringResponse)o).get_data());
					return;
				}
				listener.on_response(o);
			}
		}
	}

	public static GCMAPIClient for_api_key(String apikey, BackgroundTaskManager btm) {
		return(new GCMAPIClient().set_api_key(apikey).set_background_task_manager(btm));
	}

	property String api_key = null;
	property String address = "https://android.googleapis.com/gcm/send";
	property BackgroundTaskManager background_task_manager = null;
	String authorization = null;

	String create_authorization() {
		if(String.is_empty(authorization)) {
			if(String.is_empty(api_key)) {
				return(null);
			}
			authorization = "key=%s".printf().add(api_key).to_string();
		}
		return(authorization);
	}

	HashTable create_data(String title, String message, Collection reg_ids) {
		if(String.is_empty(title) || String.is_empty(message) || reg_ids == null || reg_ids.count() < 1) {
			return(null);
		}
		var body = HashTable.create();
		var data = HashTable.create();
		data.set("title", title);
		data.set("message", message);
		body.set("data", data);
		body.set("registration_ids", reg_ids);
		return(body);
	}

	public void send_request(String title, String message, Collection reg_ids, GCMAPIListener listener) {
		if(String.is_empty(address)) {
			if(listener != null) {
				listener.on_response(null);
			}
			return;
		}
		var auth = create_authorization();
		if(String.is_empty(auth)) {
			if(listener != null) {
				listener.on_response(null);
			}
			return;
		}
		var data = create_data(title, message, reg_ids);
		if(data == null) {
			if(listener != null) {
				listener.on_response(null);
			}
			return;
		}
		HTTPClientRequest.post_with_data(URL.for_string(address),
			"application/json",
			StringReader.for_string(JSONEncoder.encode(data))
		)
		.set_header("Authorization", auth)
		.start_get_string(background_task_manager, new GCMRequestListener().set_listener(listener));
	}
}

