
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

public class UserDatabaseSessionAPIHandler : HTTPRequestHandlerAdapter
{
	public static UserDatabaseSessionAPIHandler for_db(UserDatabase db) {
		return(new UserDatabaseSessionAPIHandler().set_db(db));
	}

	property UserDatabase db;

	public bool on_http_post(HTTPRequest req) {
		if(db == null) {
			req.send_json_object(JSONResponse.for_internal_error("No user session database set"));
			return(true);
		}
		var session = req.get_session();
		if(session != null) {
			req.send_json_object(JSONResponse.for_invalid_request("A session already exists."));
			return(true);
		}
		var data = req.get_body_json_hashtable();
		if(data == null) {
			req.send_json_object(JSONResponse.for_invalid_request());
			return(true);
		}
		var un = data.get_string("username");
		if(String.is_empty(un)) {
			req.send_json_object(JSONResponse.for_missing_data("username"));
			return(true);
		}
		var pw = data.get_string("password");
		if(pw == null) {
			req.send_json_object(JSONResponse.for_missing_data("password"));
			return(true);
		}
		if(db.check_credentials(un, pw) == null) {
			req.send_json_object(JSONResponse.for_incorrect_username_password());
			return(true);
		}
		var ss = db.create_session(un);
		if(ss == null) {
			req.send_json_object(JSONResponse.for_internal_error("Failed to create session"));
			return(true);
		}
		req.send_json_object(JSONResponse.for_ok(HashTable.create().set("session", ss.get_id())));
		return(true);
	}

	public bool on_http_delete(HTTPRequest req) {
		var userid = req.pop_resource();
		if(String.is_empty(userid)) {
			req.send_json_object(JSONResponse.for_missing_data("userid"));
			return(true);
		}
		var sessionid = req.pop_resource();
		if(String.is_empty(sessionid)) {
			req.send_json_object(JSONResponse.for_missing_data("sessionid"));
			return(true);
		}
		if(db == null) {
			req.send_json_object(JSONResponse.for_internal_error("No user session database set"));
			return(true);
		}
		var ss = db.get_session(sessionid);
		if(ss == null) {
			req.send_json_object(JSONResponse.for_internal_error("Invalid session (1)"));
			return(true);
		}
		if(userid.equals(ss.get_username()) == false) {
			req.send_json_object(JSONResponse.for_internal_error("Invalid session (2)"));
			return(true);
		}
		db.remove_session(sessionid);
		req.send_json_object(JSONResponse.for_ok());
		return(true);
	}
}
