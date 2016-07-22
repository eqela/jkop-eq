
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

public class UserRegistrationHandler : HTTPRequestHandlerAdapter
{
	property UserDatabase userdb;

	public override bool on_http_post(HTTPRequest req) {
		var data = req.get_body_json_hashtable();
		if(data == null) {
			req.send_json_object(JSONResponse.for_invalid_request());
			return(true);
		}
		var username = data.get_string("username");
		if(String.is_empty(username)) {
			req.send_json_object(JSONResponse.for_missing_data("username"));
			return(true);
		}
		if(userdb.is_username_valid(username) == false) {
			req.send_json_object(JSONResponse.for_invalid_data("username"));
			return(true);
		}
		var password = data.get_string("password");
		if(String.is_empty(password)) {
			req.send_json_object(JSONResponse.for_missing_data("password"));
			return(true);
		}
		if(userdb.is_password_valid(password) == false) {
			req.send_json_object(JSONResponse.for_invalid_data("password"));
			return(true);
		}
		if(userdb.get_user_for_username(username) != null) {
			req.send_json_object(JSONResponse.for_error_message("This username has already been used."));
			return(true);
		}
		if(userdb.add_user(username, password) == false) {
			req.send_json_object(JSONResponse.for_internal_error("An error occured. Please try again."));
			return(true);
		}
		req.send_json_object(JSONResponse.for_ok());
		return(true);
	}
}
