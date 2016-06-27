
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

public class UserDatabaseCookieSessionManager : HTTPRequestHandlerWrapper
{
	public static UserDatabaseCookieSessionManager for_handler(HTTPRequestHandler handler) {
		var v = new UserDatabaseCookieSessionManager();
		v.set_handler(handler);
		return(v);
	}

	property int session_cookie_ttl;
	property String session_cookie_path;
	property String session_cookie_domain;
	property String session_cookie_name;
	property String login_url_path;
	property String logout_url_path;
	property String login_redirect_url;
	property String logout_redirect_url;
	property UserDatabase userdb;
	property bool require_authentication = false;

	public UserDatabaseCookieSessionManager() {
		session_cookie_ttl = 60 * 60 * 24 * 365;
		session_cookie_path = "/";
		session_cookie_domain = null;
		session_cookie_name = "session";
		login_url_path = "/login";
		logout_url_path = "/logout";
		login_redirect_url = "/";
		logout_redirect_url = "/";
	}

	void send_error_response(HTTPRequest req, String error) {
		req.send_response(HTTPResponse.for_error(Error.for_message(error)));
	}

	void on_login_request(HTTPRequest req) {
		if(userdb == null) {
			send_error_response(req, "No user database");
			return;
		}
		var username = req.get_post_parameter("username"),
			password = req.get_post_parameter("password");
		if(String.is_empty(username) || password == null) {
			send_error_response(req, "Invalid input parameters.");
			return;
		}
		var v = userdb.check_credentials(username, password);
		if(v == null) {
			send_error_response(req, "Invalid username and/or password.");
			return;
		}
		var session = userdb.create_session(username);
		if(session == null) {
			send_error_response(req, "Failed to create a new session.");
			return;
		}
		req.add_response_cookie(HTTPCookie.instance(session_cookie_name, session.get_id())
			.set_path(session_cookie_path).set_domain(session_cookie_domain)
			.set_max_age(session_cookie_ttl));
		req.send_response(HTTPResponse.for_redirect(login_redirect_url));
	}

	void on_logout_request(HTTPRequest req) {
		if(userdb == null) {
			send_error_response(req, "No user database");
			return;
		}
		var sessionid = req.get_cookie_value(session_cookie_name);
		if(String.is_empty(sessionid) == false) {
			userdb.remove_session(sessionid);
			req.add_response_cookie(HTTPCookie.instance(session_cookie_name, "")
				.set_path(session_cookie_path).set_domain(session_cookie_domain)
				.set_max_age(0));
		}
		req.send_response(HTTPResponse.for_redirect(logout_redirect_url));
	}

	UserDatabaseSession update_session_for_request(HTTPRequest req) {
		var v = req.get_session() as UserDatabaseSession;
		if(v != null) {
			return(v);
		}
		var sessionid = req.get_cookie_value(session_cookie_name);
		if(String.is_empty(sessionid) != false) {
			v = userdb.get_update_session(sessionid);
		}
		req.set_session(v);
		return(v);
	}

	public bool on_http_request(HTTPRequest req) {
		if(req.is_for_resource(login_url_path)) {
			on_login_request(req);
			return(true);
		}
		if(req.is_for_resource(logout_url_path)) {
			on_logout_request(req);
			return(true);
		}
		var session = update_session_for_request(req);
		if(session == null && require_authentication) {
			req.send_response(HTTPResponse.for_http_not_allowed());
			return(true);
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
