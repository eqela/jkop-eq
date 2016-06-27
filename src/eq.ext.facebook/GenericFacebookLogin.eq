
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

public class GenericFacebookLogin : LayerWidget, WebWidgetListener
{
	public static GenericFacebookLogin instance (String application_id, String callback_url, FacebookLoginListener listener, Collection permissions, bool is_rerequest = false) {
		var login = new GenericFacebookLogin();
		var sb = StringBuffer.create("https://www.facebook.com/dialog/oauth?");
		sb.append("client_id=");
		sb.append(application_id);
		sb.append("&redirect_uri=");
		sb.append(callback_url);
		if(is_rerequest) {
			sb.append("&auth_type=rerequest");
		}
		sb.append("&response_type=token");
		if(permissions != null && permissions.count() > 0) {
			sb.append("&scope=");
			int x = 1;
			foreach(String p in permissions) {
				sb.append(p);
				if(permissions.count() - x > 0) {
					sb.append(",");
				}
				x++;
			}
		}
		login.link = sb.to_string();
		login.callback_url = callback_url;
		login.listener = listener;
		return(login);
	}

	FacebookLoginListener listener;
	WebWidget webwidget;
	String link;
	String callback_url;

	public void initialize() {
		base.initialize();
		set_draw_color(Color.instance("black"));
		add(CanvasWidget.for_color(Color.instance("white")));
		var align_w = AlignWidget.instance();
		add(align_w);
		webwidget = WebWidget.instance();
		if(webwidget != null) {
			webwidget.set_listener(this);
			align_w.set_margin(px("4mm"));
			align_w.add_align(0, 0, webwidget);
			webwidget.show_url(link);
		}
	}

	public void on_load_started(String url) {
		set_alpha(0.0);
	}

	public void on_load_finished(String url) {
		if(url.contains(callback_url)) {
			var ht = QueryString.parse(url);
			var access_token = "";
			foreach (String key in ht.iterate_keys()) {
				if(key.contains("access_token")) {
					access_token = ht.get(key) as String;
					break;
				}
			}
			if(String.is_empty(access_token) == false) {
				if(listener != null) {
					//FIX ME! Should include granted permissions
					listener.on_facebook_login_completed(access_token, null);
				}
				Popup.close(this);
			}
		}
		set_alpha(1.0);
	}

	public void on_error_received(String url, String description) {
	}
}
