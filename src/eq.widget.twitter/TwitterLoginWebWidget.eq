
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

public class TwitterLoginWebWidget : LayerWidget, WebWidgetListener
{
	public static TwitterLoginWebWidget create (String oauth_token, String oauth_callback, EventReceiver listener) {
		var login = new TwitterLoginWebWidget();
		var base_url ="https://api.twitter.com/oauth/authorize?oauth_token=";
		login.link = base_url.append(oauth_token);
		login.oauth_callback = oauth_callback;
		login.listener = listener;
		return(login);
	}

	public void initialize() {
		base.initialize();
		var align_w = AlignWidget.instance();
		add(align_w);
		var webwidget = WebWidget.instance();
		webwidget.set_listener(this);
		align_w.add_align(0, 0, webwidget);
		webwidget.show_url(link);
	}

	EventReceiver listener;
	String link;
	String oauth_callback;

	public void on_load_started(String url) {
		if(url.contains(oauth_callback)) {
			var ht = QueryString.parse(url);
			var oauth_token = "";
			var denied = "";
			foreach (String key in ht.iterate_keys()) {
				if(key.contains("oauth_token")) {
					oauth_token = ht.get(key) as String;
					break;
				}
				if(key.contains("denied")) {
					denied = ht.get(key) as String;
					break;
				}
			}
			var oauth_verifier = ht.get("oauth_verifier") as String;
			if(String.is_empty(oauth_token) == false && String.is_empty(oauth_verifier) == false ) {
				if(listener != null) {
					listener.on_event(new TwitterAPIConvertableToken()
						.set_oauth_token(oauth_token)
						.set_oauth_verifier(oauth_verifier));
				}
				Popup.close(this);
			}
			else if(String.is_empty(denied) == false) {
				if(listener != null) {
					listener.on_event(null);
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
