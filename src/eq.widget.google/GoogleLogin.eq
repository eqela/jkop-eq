
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

public class GoogleLogin : EventReceiver, GoogleCalendarAPIListener
{
	public static GoogleLogin instance(BackgroundTaskManager btm, String ckey, String scope) {
		var gcl = new GoogleLogin();
		gcl.google_api = GoogleCalendarAPI.instance(btm, ckey, scope);
		return(gcl);
	}

	property Frame frame;
	property GoogleCalendarAPI google_api;
	property Image close_icon;
	GoogleLoginListener listener;

	public bool execute(Frame fr, GoogleLoginListener l) {
		if(WebWidget.instance() == null) {
			return(false);
		}
		if(fr == null) {
			return(false);
		}
		frame = fr;
		listener = l;
		show_login_dialog();
		return(true);
	}

	private void show_login_dialog() {
		var client = google_api.get_client();
		var login_widget = GoogleLoginWidget.create(client.get_scope(), client.get_client_id(), this);
		int w = frame.get_width();
		int h = frame.get_height();
		var gcc = new GoogleCustomLogin();
		gcc.set_close_icon(close_icon);
		gcc.set_size_request_override(w, h);
		gcc.set_login_widget(login_widget);
		gcc.set_listener(listener);
		var engine = frame.get_controller() as WidgetEngine;
		if(engine == null) {
			if(listener != null) {
				listener.on_google_login_status(null);
			}
			return;
		}
		bool show_login = Popup.execute_in_widget_engine(engine, PopupSettings.for_widget(gcc).set_x(0).set_y(0));
		if(show_login == false) {
			if(listener != null) {
				listener.on_google_login_status(null);
			}
		}
	}

	public virtual void on_request_token_completed() {
	}

	public void on_google_api_request_completed(GoogleCalendarAPIResponse resp, Error err) {
		if(resp != null) {
			if(resp is GoogleCalendarAPIAccessTokenResponse) {
				var o = (GoogleCalendarAPIAccessTokenResponse)resp;
				on_request_token_completed();
				listener.on_google_login_status(o);
				return;
			}
		}
		listener.on_google_login_status(null);
	}

	public void on_event(Object o) {
		if(o is GoogleCalendarAPIAccessTokenResponse) {
			var token = (GoogleCalendarAPIAccessTokenResponse)o;
			google_api.exchange_token(token.get_authorization_code(), this);
		}
	}
}
