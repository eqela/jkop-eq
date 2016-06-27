
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

public class TwitterLogin : EventReceiver, TwitterAPIListener
{
	class TwitterCustomLogin : LayerWidget, EventReceiver
	{
		class CloseButton : ClickWidget
		{
			property Image close_icon;

			public void initialize() {
				base.initialize();
				if(close_icon != null) {
					add(ImageWidget.for_image(close_icon).set_size_request_override(px("6mm"), px("6mm")));
				}
				else {
					add(ImageWidget.for_icon("close_window").set_size_request_override(px("6mm"), px("6mm")));
				}
				set_event("close_btn_clicked");
			}
		}

		property Widget login_widget;
		property TwitterLoginListener listener;
		property Image close_icon;

		public void initialize() {
			base.initialize();
			var bg = LayerWidget.instance().add(CanvasWidget.for_color(Color.instance("#50524f")));
			bg.set_alpha(0.9);
			add(bg);
			var layer = LayerWidget.instance();
			layer.set_margin(px("3mm"));
			layer.add(login_widget);
			add(layer);
			var align_btn = AlignWidget.instance();
			add(align_btn);
			align_btn.add_align(-1, -1, new CloseButton().set_close_icon(close_icon));
		}

		public void on_event(Object o) {
			if("close_btn_clicked".equals(o)) {
				Popup.close(this);
				if(listener != null) {
					listener.on_twitter_login_status(null);
				}
			}
		}
	}

	public static TwitterLogin instance(BackgroundTaskManager btm, String ckey, String csecret, String oauth_callback) {
		var tl = new TwitterLogin();
		tl.twitter_api = TwitterAPI.instance(btm, ckey, csecret);
		tl.oauth_callback = oauth_callback;
		return(tl);
	}

	public static TwitterLogin for_twitter_api(TwitterAPI tt, String oauth_callback) {
		var tl = new TwitterLogin();
		tl.twitter_api = tt;
		tl.oauth_callback = oauth_callback;
		return(tl);
	}

	property TwitterAPI twitter_api;
	property Frame frame;
	property String oauth_callback;
	property Image close_icon;
	TwitterLoginListener listener;
	TwitterAPIRequestTokenResponse token_request;
	WaitDialogWidget wdw;

	public bool execute(Frame f, TwitterLoginListener l) {
		if(WebWidget.instance() == null) {
			return(false);
		}
		if(f == null) {
			return(false);
		}
		frame = f;
		listener = l;
		twitter_api.request_oauth_token_for_login(oauth_callback, this);
		on_request_token_started();
		return(true);
	}

	public virtual void on_request_token_started() {
		wdw = new WaitDialogWidget();
		wdw.set_title("Communicating ..");
		wdw.set_text("Contacting Twitter ..");
		Frame.open_as_popup(WidgetEngine.for_widget(wdw), frame);
	}

	public virtual void on_request_token_completed() {
		if(wdw != null) {
			Frame.close(wdw.get_frame());
			wdw = null;
		}
	}

	public virtual void on_convert_token_started() {
		if(wdw == null) {
			wdw = new WaitDialogWidget();
			wdw.set_title("Communicating ..");
			wdw.set_text("Finalizing ..");
			Frame.open_as_popup(WidgetEngine.for_widget(wdw), frame);
		}
	}

	public virtual void on_convert_token_completed() {
		if(wdw != null) {
			Frame.close(wdw.get_frame());
			wdw = null;
		}
	}

	public virtual void on_twitter_api_request_failed() {
		if(wdw != null) {
			Frame.close(wdw.get_frame());
			wdw = null;
		}
	}

	private void show_login_dialog() {
		var login_widget = TwitterLoginWebWidget.create(token_request.get_oauth_token(), oauth_callback, this);
		int w = frame.get_width();
		int h = frame.get_height();
		var ld = new TwitterCustomLogin();
		ld.set_close_icon(close_icon);
		ld.set_size_request_override(w, h);
		ld.set_login_widget(login_widget);
		ld.set_listener(listener);
		var engine = frame.get_controller() as WidgetEngine;
		if(engine == null) {
			if(listener != null) {
				listener.on_twitter_login_status(null);
			}
			return;
		}
		bool is_showed = Popup.execute_in_widget_engine(engine, PopupSettings.for_widget(ld).set_x(0).set_y(0));
		if(is_showed == false) {
			if(listener != null) {
				listener.on_twitter_login_status(null);
			}
		}
	}

	public void on_twitter_api_request_completed(TwitterAPIResponse resp, Error error) {
		if(resp != null) {
			if(resp is TwitterAPIRequestTokenResponse) {
				on_request_token_completed();
				token_request = (TwitterAPIRequestTokenResponse)resp;
				if(token_request.get_oauth_callback_confirmed()) {
					show_login_dialog();
				}
				else {
					if(listener != null) {
						listener.on_twitter_login_status(null);
					}
				}
			}
			else if(resp is TwitterAPIAccessTokenResponse) {
				on_convert_token_completed();
				var tresp = (TwitterAPIAccessTokenResponse)resp;
				if(listener != null) {
					listener.on_twitter_login_status(tresp);
				}
			}
		}
		else {
			on_twitter_api_request_failed();
			if(listener != null) {
				listener.on_twitter_login_status(null);
			}
		}
	}

	public void on_event(Object o) {
		if(o is TwitterAPIConvertableToken) {
			var ctoken = (TwitterAPIConvertableToken)o;
			twitter_api.request_access_token(ctoken, token_request.get_oauth_token_secret(), this);
			on_convert_token_started();
		}
	}
}
