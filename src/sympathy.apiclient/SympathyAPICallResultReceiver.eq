
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

public class SympathyAPICallResultReceiver : HTTPClientStringReceiver
{
	void error(Object error) {
		EventReceiver.event(get_listener(), SympathyAPICallResult.for_error_message(String.as_string(error)));
	}

	public void on_string_response(HTTPClientStringResponse resp) {
		var datastr = resp.get_data();
		if(datastr == null) {
			error("Failed to connect to the server");
			return;
		}
		Log.debug("Sympathy API call, received data: `%s'".printf().add(datastr));
		if(resp.is_ok() == false) {
			error("Server responded with error status %s".printf().add(resp.get_status()));
			return;
		}
		var json = JSONParser.parse_string(datastr) as HashTable;
		if(json == null) {
			error("Server did not respond with proper JSON data");
			return;
		}
		if("ok".equals(json.get_string("status")) == false) {
			var err = json.get_string("message");
			if(String.is_empty(err)) {
				err = json.get_string("code");
			}
			if(String.is_empty(err)) {
				err = "Unknown error";
			}
			error("Operation failed: ".append(err));
			return;
		}
		var data = json.get("data");
		if(data == null) {
			data = HashTable.create();
		}
		EventReceiver.event(get_listener(), new SympathyAPICallResult().set_data(data));
	}
}
