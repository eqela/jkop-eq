
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

public class SocialWebSessionBackend : WebSessionBackend, WebSessionBackendWithLogin
{
	public static SocialWebSessionBackend instance(BackgroundTaskManager btm) {
		return(new SocialWebSessionBackend().set_btm(btm));
	}

	property BackgroundTaskManager btm;
	property SocialWebSessionBackendListener listener;
	HashTable sessions;

	FacebookAPI get_facebook_api_for_token(String token) {
		return(FacebookAPI.instance(btm, token));
	}

	WebSessionWithFacebookUser create_session_for_facebook_user(FacebookAPIUserProfile user, String token) {
		if(user == null) {
			return(null);
		}
		if(sessions == null) {
			sessions = HashTable.create();
		}
		int n;
		for(n=0; n<100000; n++) {
			var id = MD5Encoder.encode("%d%d".printf().add(SystemClock.seconds()).add(Math.random(0,1000000)).to_string());
			if(sessions.get_string(id) == null) {
				var v = WebSessionWithFacebookUser.instance(user);
				v.set_facebook_token(token);
				v.set_sessionid(id);
				sessions.set(id, v);
				return(v);
			}
		}
		return(null);
	}

	class MyFacebookProfileListener : FacebookAPIListener
	{
		property String token;
		property HTTPRequest req;
		property WebSessionLoginListener listener;
		property SocialWebSessionBackend backend;
		public void on_facebook_api_request_completed(FacebookAPIResponse resp, Error error) {
			var up = resp as FacebookAPIUserProfileResponse;
			if(up == null || error != null) {
				var ee = error;
				if(ee == null) {
					ee = Error.for_message("Unknown Facebook API error");
				}
				listener.on_web_session_login_result(req, null, ee);
				return;
			}
			var prof = up.get_user_profile();
			if(prof == null) {
				listener.on_web_session_login_result(req, null, Error.for_message("No Facebook user profile found"));
				return;
			}
			backend.on_facebook_login(req, listener, prof, token);
		}
	}

	public virtual void on_facebook_login(HTTPRequest req, WebSessionLoginListener listener, FacebookAPIUserProfile user, String token) {
		if(listener == null) {
			return;
		}
		var ss = create_session_for_facebook_user(user, token);
		if(ss == null) {
			listener.on_web_session_login_result(req, null, Error.for_message("Unable to create a new (Facebook user) session"));
			return;
		}
		add_response_cookie(req, ss);
		listener.on_web_session_login_result(req, ss, null);
		if(this.listener != null) {
			this.listener.on_facebook_login(ss);
		}
		return;
	}

	public void login(HTTPRequest req, WebSessionLoginListener listener) {
		if(listener == null) {
			return;
		}
		var fbtoken = req.get_query_parameter("facebook_token");
		if(fbtoken != null) {
			var fbapi = get_facebook_api_for_token(fbtoken);
			if(fbapi == null) {
				listener.on_web_session_login_result(req, null, Error.for_message("No Facebook API available."));
				return;
			}
			fbapi.query_current_user_profile(new MyFacebookProfileListener()
				.set_token(fbtoken).set_req(req).set_listener(listener).set_backend(this));
			return;
		}
		listener.on_web_session_login_result(req, null, Error.for_message("Invalid credentials"));
	}

	public void get_session(HTTPRequest req, WebSessionGetListener listener) {
		if(listener == null) {
			return;
		}
		var sessionid = req.get_cookie_value("session");
		if(String.is_empty(sessionid)) {
			listener.on_web_session_get_result(req, null, null);
			return;
		}
		if(sessions != null) {
			var ss = sessions.get(sessionid) as WebSession;
			if(ss != null) {
				listener.on_web_session_get_result(req, ss, null);
				return;
			}
		}
		listener.on_web_session_get_result(req, null, null);
	}

	public void logout(HTTPRequest req, WebSessionLogoutListener listener) {
		if(listener == null) {
			return;
		}
		var sessionid = req.get_cookie_value("session");
		if(String.is_empty(sessionid) == false) {
			if(sessions != null) {
				sessions.remove(sessionid);
				remove_response_cookie(req);
			}
		}
		listener.on_web_session_logout_result(req, null);
	}
}
