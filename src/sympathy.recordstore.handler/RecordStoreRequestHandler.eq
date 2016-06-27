
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

public class RecordStoreRequestHandler : HTTPRequestHandlerAdapter
{
	public static RecordStoreRequestHandler for_record_store(RecordStore store) {
		return(new RecordStoreRequestHandler().set_store(store));
	}

	property RecordStore store;
	property Collection list_fields;

	public bool on_http_request(HTTPRequest req) {
		if(store == null) {
			req.send_json_object(JSONResponse.for_internal_error("No record store for RecordStoreRequestHandler"));
			return(true);
		}
		var err = new Error();
		var r1 = req.pop_resource();
		if(String.is_empty(r1)) {
			if(req.is_get_request()) {
				RecordFilter filter;
				var search = req.get_query_parameter("search");
				if(search != null) {
					var it = search.split((int)':', 2);
					if(it != null) {
						var key = String.as_string(it.next());
						var val = String.as_string(it.next());
						if(String.is_empty(key) == false && val != null) {
							filter = FilterEquals.values(key, val);
						}
					}
				}
				int offset = 0, limit = 0;
				var p_offset = req.get_query_parameter("offset");
				if(p_offset != null) {
					offset = p_offset.to_integer();
				}
				var p_limit = req.get_query_parameter("limit");
				if(p_limit != null) {
					limit = p_limit.to_integer();
				}
				// FIXME: Sorting
				var v = store.get_records(filter, offset, limit, null, list_fields, err);
				if(v == null) {
					req.send_json_object(JSONResponse.for_error(err));
					return(true);
				}
				req.send_json_object(JSONResponse.for_ok(v));
				return(true);
			}
			if(req.is_post_request()) {
				var data = JSONParser.parse_string(req.get_body_string()) as HashTable;
				if(data == null) {
					req.send_json_object(JSONResponse.for_error_message("Invalid POST data"));
					return(true);
				}
				if(store.append(data, err) == false) {
					req.send_json_object(JSONResponse.for_error(err));
					return(true);
				}
				req.send_json_object(JSONResponse.for_ok());
				return(true);
			}
			return(false);
		}
		var r2 = req.pop_resource();
		if(String.is_empty(r2) == false) {
			req.send_json_object(JSONResponse.for_error_message("Invalid request (1)"));
			return(true);
		}
		var it = r1.split((int)':', 2);
		var key = String.as_string(it.next());
		var val = String.as_string(it.next());
		if(String.is_empty(key) || val == null) {
			req.send_json_object(JSONResponse.for_error_message("Invalid request (2)"));
			return(true);
		}
		var filter = FilterEquals.values(key, val);
		if(req.is_delete_request()) {
			var error = new Error();
			if(store.delete(filter, error) == false) {
				req.send_json_object(JSONResponse.for_error(error));
				return(true);
			}
			req.send_json_object(JSONResponse.for_ok());
			return(true);
		}
		if(req.is_get_request()) {
			var record = store.get_one_matching(filter, null, null);
			if(record == null) {
				req.send_json_object(JSONResponse.for_error_message("Record not found"));
				return(true);
			}
			req.send_json_object(JSONResponse.for_ok(record));
			return(true);
		}
		if(req.is_put_request()) {
			var data = JSONParser.parse_string(req.get_body_string()) as HashTable;
			if(data == null) {
				req.send_json_object(JSONResponse.for_error_message("Invalid PUT data"));
				return(true);
			}
			var error = new Error();
			if(store.update(data, filter, error) == false) {
				req.send_json_object(JSONResponse.for_error(error));
				return(true);
			}
			req.send_json_object(JSONResponse.for_ok());
			return(true);
		}
		return(false);
	}
}
