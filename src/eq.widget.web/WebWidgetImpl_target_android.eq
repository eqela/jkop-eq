
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

class WebWidgetImpl : AndroidNativeWidget, WebWidget
{
	String url;
	String html;
	File file;

	public static WebWidget create() {
		return(new WebWidgetImpl());
	}

	public WebWidget show_url(String url) {
		this.url = url;
		update_webview_content();
		return(this);
	}

	public WebWidget show_file(File file) {
		this.file = file;
		update_webview_content();
		return(this);
	}

	public WebWidget show_html_string(String html) {
		this.html = html;
		update_webview_content();
		return(this);
	}

	public void update_webview_content() {
		embed "java" {{{
			if(webview == null) {
				return;
			}
		}}}
		if(!String.is_empty(url)) {
			load_url();
			url = null;
		}
		else if(file != null) {
			var sf = "file://".append(file.get_native_path());
			if(sf.has_suffix(".html")) {
				embed "java" {{{
					webview.loadUrl(sf.to_strptr());
				}}}
			}
			file = null;
		}
		else if(!String.is_empty(html)) {
			embed "java" {{{
				webview.loadData(html.to_strptr(), "text/html", null);
			}}}
			html = null;
		}
	}

	void load_url() {
		String url = this.url;
		if(url.has_prefix("https://")) {
			url = url.replace_string("http://", "https://");
		}
		else if(!url.has_prefix("http://")) {
			url = "http://".append(url);
		}
		embed "java" {{{
			if(webview != null) {
				webview.loadUrl(url.to_strptr());
			}
		}}}
	}

	public WebWidget set_listener(WebWidgetListener listener) {
		embed "java" {{{
			if(webclient != null) {
				webclient.set_listener(listener);
			}
		}}}
		return(this);
	}

	public override bool on_key_press(KeyEvent e) {
		if("back".equals(e.get_name())) {
			embed "java" {{{
				if(webview != null && webview.canGoBack()) {
					webview.goBack();
					return(true);
				}
			}}}
		}
		return(base.on_key_press(e));
	}

	embed "java" {{{
		private class WebClient extends android.webkit.WebViewClient
		{
			eq.widget.web.WebWidgetListener listener = null;
			public void set_listener(eq.widget.web.WebWidgetListener listener) {
				this.listener = listener;
			}

			@Override
			public boolean shouldOverrideUrlLoading(android.webkit.WebView webview, java.lang.String url) {
				return(false);
			}

			@Override
			public void onPageStarted(android.webkit.WebView webview, java.lang.String url, android.graphics.Bitmap favicon) {
				if(listener != null) {
					listener.on_load_started(eq.api.String.Static.for_strptr(url));
				}
			}

			@Override
			public void onPageFinished(android.webkit.WebView webview, java.lang.String url) {
				if(listener != null) {
					listener.on_load_finished(eq.api.String.Static.for_strptr(url));
				}
			}

			@Override
			public void onReceivedError(android.webkit.WebView webview, int errCode, java.lang.String desc, java.lang.String url) {
				if(listener != null) {
					listener.on_error_received(eq.api.String.Static.for_strptr(url), eq.api.String.Static.for_strptr(desc));
				}
			}
		}

		private class KeyHandler implements android.view.View.OnKeyListener
		{
			eq.widget.WidgetEngine engine = null;
			public KeyHandler(eq.widget.WidgetEngine engine) {
				this.engine = engine;
			}

			@Override
			public boolean onKey(android.view.View view, int keyCode, android.view.KeyEvent event) {
				if(engine == null) {
					return(false);
				}
				java.lang.String keyName = null;
				eq.api.String keyStr = eqstr(java.lang.Character.toString((char)event.getUnicodeChar()));
				if(keyCode == event.KEYCODE_BACK) {
					keyName = "back";
				}
				return(engine.on_event(new eq.gui.KeyEvent()
					.set_name((eq.api.String)eqstr(keyName))
					.set_str((eq.api.String)keyStr)));
			}

			private eq.api.String eqstr(java.lang.String s) {
				return((eq.api.String)eq.api.String.Static.for_strptr(s));
			}
		}

		WebClient webclient = new WebClient();
		android.webkit.WebView webview = null;
		android.webkit.WebSettings websettings = null;

		@Override protected android.view.View create_android_view(android.content.Context context) {
			webview = new android.webkit.WebView(context);
			webview.setWebViewClient(webclient);
			webview.setOnKeyListener(new KeyHandler(((eq.widget.Widget)this).get_engine()));
			websettings = webview.getSettings();
			websettings.setJavaScriptEnabled(true);
			update_webview_content();
			return((android.view.View)webview);
		}
	}}}
}
