
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

public class UserDatabaseHeaderSessionManager : HTTPRequestHandlerWrapper
{
	public static UserDatabaseHeaderSessionManager for_handler(HTTPRequestHandler handler) {
		var v = new UserDatabaseHeaderSessionManager();
		v.set_handler(handler);
		return(v);
	}

	property UserDatabase userdb;
	property bool require_authentication = false;
	property String header_name;
	property Collection allowed_users;

	public UserDatabaseHeaderSessionManager() {
		header_name = "session";
	}

	void send_error_response(HTTPRequest req, String error) {
		req.send_response(HTTPResponse.for_error(Error.for_message(error)));
	}

	UserDatabaseSession update_session_for_request(HTTPRequest req) {
		var v = req.get_session() as UserDatabaseSession;
		if(v != null) {
			return(v);
		}
		var sessionid = req.get_header(header_name);
		if(String.is_empty(sessionid) == false) {
			v = userdb.get_update_session(sessionid);
		}
		req.set_session(v);
		return(v);
	}

	public bool on_http_request(HTTPRequest req) {
		var session = update_session_for_request(req);
		if(session == null && require_authentication) {
			req.send_response(HTTPResponse.for_http_not_allowed());
			return(true);
		}
		if(allowed_users != null) {
			if(String.is_in_collection(session.get_username(), allowed_users) == false) {
				req.send_response(HTTPResponse.for_http_not_allowed());
				return(true);
			}
		}
		var handler = get_handler();
		if(handler != null) {
			return(handler.on_http_request(req));
		}
		return(false);
	}

	public HTTPRequestBodyHandler get_request_body_handler(HTTPRequest req) {
		var handler = get_handler();
		if(handler == null) {
			return(null);
		}
		var session = update_session_for_request(req);
		if(session == null && require_authentication) {
			return(null);
		}
		return(handler.get_request_body_handler(req));
	}
}
