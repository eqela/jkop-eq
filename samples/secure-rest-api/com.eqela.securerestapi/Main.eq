
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
		property PersonDatabase persondb;

		public override bool on_authenticated_get(HTTPRequest req, Object session) {
			var p = req.pop_resource();
			if(p == null) {
				req.send_json_object(persondb.get_persons());
				return(true);
			}
			if(req.pop_resource() == null) {
				var person = persondb.get_person(p);
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

		public override bool on_authenticated_post(HTTPRequest req, Object session) {
			if(req.pop_resource() != null) {
				req.send_json_object(JSONResponse.for_invalid_request());
				return(true);
			}
			var data = req.get_body_json_hashtable();
			if(data == null) {
				req.send_json_object(JSONResponse.for_error_message("No data specified."));
				return(true);
			}
			var name = data.get_string("name");
			var age = data.get_int("age", -1);
			var gender = data.get_string("gender");
			if(String.is_empty(name) == true) {
				req.send_json_object(JSONResponse.for_error_message("No name specified."));
				return(true);
			}
			if(age < 0) {
				req.send_json_object(JSONResponse.for_error_message("Please specify a valid age."));
				return(true);
			}
			if("male".equals(gender) == false && "female".equals(gender) == false) {
				req.send_json_object(JSONResponse.for_error_message("No gender specified."));
				return(true);
			}
			if(persondb.get_person(name) != null) {
				req.send_json_object(JSONResponse.for_error_message("'%s' already exists.".printf()
					.add(name)
					.to_string()));
				return(true);
			}
			if(persondb.add_person(name, age, gender) == false) {
				req.send_json_object(JSONResponse.for_internal_error());
				return(true);
			}
			req.send_json_object(JSONResponse.for_ok());
			return(true);
		}

		public override bool on_authenticated_put(HTTPRequest req, Object session) {
			var p = req.pop_resource();
			if(p == null) {
				req.send_json_object(JSONResponse.for_invalid_request());
				return(true);
			}
			if(req.pop_resource() == null) {
				var person = persondb.get_person(p);
				if(person == null) {
					req.send_json_object(JSONResponse.for_not_found());
					return(true);
				}
				var data = req.get_body_json_hashtable();
				if(data == null) {
					req.send_json_object(JSONResponse.for_error_message("No data specified."));
					return(true);
				}
				var name = data.get_string("name");
				var age = data.get_int("age", -1);
				var gender = data.get_string("gender");
				if(String.is_empty(name) == true) {
					req.send_json_object(JSONResponse.for_error_message("No name specified."));
					return(true);
				}
				if(age < 0) {
					req.send_json_object(JSONResponse.for_error_message("Please specify a valid age."));
					return(true);
				}
				if("male".equals(gender) == false && "female".equals(gender) == false) {
					req.send_json_object(JSONResponse.for_error_message("No gender specified."));
					return(true);
				}
				if(p.equals(name) == false) {
					person = persondb.get_person(name);
					if(person != null) {
						req.send_json_object(JSONResponse.for_error_message("'%s' already exists.".printf()
							.add(name)
							.to_string()));
						return(true);
					}
				}
				if(persondb.update_person(p, name, age, gender) == false) {
					req.send_json_object(JSONResponse.for_internal_error());
					return(true);
				}
				req.send_json_object(JSONResponse.for_ok());
				return(true);
			}
			req.send_json_object(JSONResponse.for_invalid_request());
			return(true);
		}

		public override bool on_authenticated_delete(HTTPRequest req, Object session) {
			var p = req.pop_resource();
			if(p == null) {
				if(persondb.delete_persons() == false) {
					req.send_json_object(JSONResponse.for_internal_error());
					return(true);
				}
				req.send_json_object(JSONResponse.for_ok());
				return(true);
			}
			if(req.pop_resource() == null) {
				var person = persondb.get_person(p);
				if(person == null) {
					req.send_json_object(JSONResponse.for_not_found());
					return(true);
				}
				if(persondb.delete_person(p) == false) {
					req.send_json_object(JSONResponse.for_internal_error());
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

	public bool initialize() {
		if(base.initialize() == false) {
			return(false);
		}
		var datadir = get_datadir();
		if(datadir == null) {
			return(false);
		}
		if(datadir.exists() == false) {
			if(datadir.mkdir_recursive() == false) {
				return(false);
			}
		}
		var db = SQLiteDatabase.for_file(datadir.entry("mydb.sqlite"));
		if(db == null) {
			return(false);
		}
		var persondb = PersonDatabase.for_sqldatabase(db);
		if(persondb == null) {
			return(false);
		}
		var userdb = UserDatabase.for_sqldatabase(db);
		if(userdb == null) {
			return(false);
		}
		var sessiondb = SessionDatabase.for_sqldatabase(db);
		if(sessiondb == null) {
			return(false);
		}
		sessiondb.set_userdb(userdb);
		set_request_handler(new HTTPRequestHandlerContainer()
			.set_session_handler(sessiondb)
			.set_request_handler("register", new UserRegistrationHandler()
				.set_userdb(userdb))
			.set_request_handler("auth", new AuthenticationHandler()
				.set_userdb(userdb)
				.set_sessiondb(sessiondb))
			.set_request_handler("persons", new MyHTTPRequestHandler()
				.set_persondb(persondb)));
		return(true);
	}
}
