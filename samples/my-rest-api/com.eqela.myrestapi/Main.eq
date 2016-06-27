
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

public class Main : SympathyWebServerApplication
{
	class MyHTTPRequestHandler : HTTPRequestHandlerAdapter
	{
		property PersonDatabase person_db;
		
		public bool on_http_get(HTTPRequest req) {
			var p = req.pop_resource();
			if(p == null) {
				req.send_json_object(person_db.get_persons());
				return(true);
			}
			if(req.pop_resource() == null) {
				var person = person_db.get_person(p);
				if(person != null) {
					req.send_json_object(person);
					return(true);
				}
				req.send_json_object(JSONResponse.for_not_found());
				return(true);
			}
			req.send_json_object(JSONResponse.for_invalid_request());
			return(true);
		}
		
		public bool on_http_post(HTTPRequest req) {
			if(req.pop_resource() != null) {
				req.send_json_object(JSONResponse.for_invalid_request());
				return(true);
			}
			var data = req.get_body_json_hashtable();
			if(data == null) {
				req.send_json_object(JSONResponse.for_error("No data specified."));
				return(true);
			}
			var name = data.get_string("name");
			var age = data.get_int("age", -1);
			var gender = data.get_string("gender");
			if(String.is_empty(name) == true) {
				req.send_json_object(JSONResponse.for_error("No name specified."));
				return(true);
			}
			if(age < 0) {
				req.send_json_object(JSONResponse.for_error("Please specify a valid age."));
				return(true);
			}
			if("male".equals(gender) == false && "female".equals(gender) == false) {
				req.send_json_object(JSONResponse.for_error("No gender specified."));
				return(true);
			}
			if(person_db.get_person(name) != null) {
				req.send_json_object(JSONResponse.for_error("'%s' already exists.".printf()
					.add(name)
					.to_string()));
				return(true);
			}
			if(person_db.add_person(name, age, gender) == false) {
				req.send_json_object(JSONResponse.for_error("Internal error."));
				return(true);
			}
			req.send_json_object(JSONResponse.for_ok());
			return(true);
		}
		
		public bool on_http_put(HTTPRequest req) {
			var p = req.pop_resource();
			if(p == null) {
				req.send_json_object(JSONResponse.for_invalid_request());
				return(true);
			}
			if(req.pop_resource() == null) {
				var person = person_db.get_person(p);
				if(person == null) {
					req.send_json_object(JSONResponse.for_not_found());
					return(true);
				}
				var data = req.get_body_json_hashtable();
				if(data == null) {
					req.send_json_object(JSONResponse.for_error("No data specified."));
					return(true);
				}
				var name = data.get_string("name");
				var age = data.get_int("age", -1);
				var gender = data.get_string("gender");
				if(String.is_empty(name) == true) {
					req.send_json_object(JSONResponse.for_error("No name specified."));
					return(true);
				}
				if(age < 0) {
					req.send_json_object(JSONResponse.for_error("Please specify a valid age."));
					return(true);
				}
				if("male".equals(gender) == false && "female".equals(gender) == false) {
					req.send_json_object(JSONResponse.for_error("No gender specified."));
					return(true);
				}
				if(p.equals(name) == false) {
					person = person_db.get_person(name);
					if(person != null) {
						req.send_json_object(JSONResponse.for_error("'%s' already exists.".printf()
							.add(name)
							.to_string()));
						return(true);
					}
				}
				if(person_db.update_person(p, name, age, gender) == false) {
					req.send_json_object(JSONResponse.for_error("Internal error."));
					return(true);
				}
				req.send_json_object(JSONResponse.for_ok());
				return(true);
			}
			req.send_json_object(JSONResponse.for_invalid_request());
			return(true);
		}
		
		public bool on_http_delete(HTTPRequest req) {
			var p = req.pop_resource();
			if(p == null) {
				if(person_db.delete_persons() == false) {
					req.send_json_object(JSONResponse.for_error("Internal error."));
					return(true);
				}
				req.send_json_object(JSONResponse.for_ok());
				return(true);
			}
			if(req.pop_resource() == null) {
				var person = person_db.get_person(p);
				if(person == null) {
					req.send_json_object(JSONResponse.for_not_found());
					return(true);
				}
				if(person_db.delete_person(p) == false) {
					req.send_json_object(JSONResponse.for_error("Internal error."));
					return(true);
				}
				req.send_json_object(JSONResponse.for_ok());
				return(true);
			}
			req.send_json_object(JSONResponse.for_invalid_request());
			return(true);
		}
	}
	
	public Main() {
		set_require_datadir(true);
	}
	
	PersonDatabase person_db;
	
	public bool initialize() {
		if(base.initialize() == false) {
			return(false);
		}
		person_db = PersonDatabase.for_datadir(get_datadir());
		if(person_db == null) {
			return(false);
		}
		set_request_handler(new HTTPRequestHandlerContainer()
			.set_request_handler("persons", new MyHTTPRequestHandler()
			.set_person_db(person_db)));
		return(true);
	}
}
