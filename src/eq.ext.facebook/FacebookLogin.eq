
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

public class FacebookLogin
{
	class LoginDialog : DialogWidget
	{
		property Widget login_widget;

		public void initialize() {
			base.initialize();
			set_main_widget(login_widget);
		}
	}

	property String callback_url;
	property String application_id;
	property Frame frame;

	public bool execute_with_read_permissions(FacebookLoginListener listener, Collection permissions = null) {
		IFDEF("target_android") {
			return(AndroidFacebookLogin.instance().execute(application_id, listener, permissions));
		}
		ELSE IFDEF("target_ios") {
			return(IOSFacebookLogin.instance().execute(application_id, listener, permissions));
		}
		ELSE {
			var login_widget = GenericFacebookLogin.instance(application_id, callback_url, listener, permissions);
			return(execute_generic_facebook_login(login_widget));
		}
	}

	public bool request_new_read_permissions(Collection permissions, FacebookLoginListener listener) {
		IFDEF("target_android") {
			return(AndroidFacebookLogin.instance().request_new_read_permissions(permissions, listener));
		}
		ELSE IFDEF("target_ios") {
			return(IOSFacebookLogin.instance().request_new_read_permissions(permissions, listener));
		}
		ELSE {
			var login_widget = GenericFacebookLogin.instance(application_id, callback_url, listener, permissions, true);
			return(execute_generic_facebook_login(login_widget));
		}
	}

	public bool request_new_publish_permissions(Collection permissions, FacebookLoginListener listener) {
		IFDEF("target_android") {
			return(AndroidFacebookLogin.instance().request_new_publish_permissions(permissions, listener));
		}
		ELSE IFDEF("target_ios") {
			return(IOSFacebookLogin.instance().request_new_publish_permissions(permissions, listener));
		}
		ELSE {
			var login_widget = GenericFacebookLogin.instance(application_id, callback_url, listener, permissions, true);
			return(execute_generic_facebook_login(login_widget));
		}
	}

	private bool execute_generic_facebook_login(GenericFacebookLogin login_widget)
	{
		if(frame == null || WebWidget.instance() == null) {
			return(false);
		}
		var ld = new LoginDialog();
		ld.set_login_widget(login_widget);
		int w = frame.get_width();
		int h = frame.get_height();
		ld.set_size_request_override(w, (int)h * 0.8);
		return(Popup.execute_in_frame(frame, PopupSettings.for_widget(ld)));
	}
}
