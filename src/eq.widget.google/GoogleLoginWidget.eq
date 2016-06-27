
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

public class GoogleLoginWidget : LayerWidget, WebWidgetListener
{
	public static GoogleLoginWidget create(String scope, String ckey, EventReceiver listener) {
		var login = new GoogleLoginWidget();
		var url = "https://accounts.google.com/o/oauth2/auth";
		login.request_url = url.append("?scope=")
			.append(scope)
			.append("&redirect_uri=http://localhost")
			.append("&response_type=code")
			.append("&client_id=")
			.append(ckey);
		login.listener = listener;
		return(login);
	}

	String request_url;
	EventReceiver listener;

	public void initialize() {
		base.initialize();
		var align_w = AlignWidget.instance();
		add(align_w);
		var webwidget = WebWidget.instance();
		webwidget.set_listener(this);
		align_w.add_align(0, 0, webwidget);
		webwidget.show_url(URL.for_string(request_url).to_string());
	}

	public void on_load_started(String url) {
		if(url.contains("code")) {
			var ht = QueryString.parse(url);
			var authorization_code = "";
			foreach(String key in ht.iterate_keys()) {
				if(key.contains("code")) {
					authorization_code = ht.get(key) as String;
					break;
				}
			}
			if(String.is_empty(authorization_code) == false) {
				if(listener != null) {
					listener.on_event(new GoogleCalendarAPIAccessTokenResponse().set_authorization_code(authorization_code));
				}
				Popup.close(this);
			}
		}
	}

	public void on_load_finished(String url) {
	}

	public void on_error_received(String url, String description) {
	}
}
