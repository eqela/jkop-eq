
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

IFDEF("target_wp8cs")
{
	class WebWidgetImpl : WPNativeWidget, WebWidget
	{
		WebWidgetListener listener;
		String url;

		public static WebWidget create() {
			return(new WebWidgetImpl());
		}

		public WebWidget show_url(String url) {
			format_url(url);
			return(this);
		}

		public WebWidget show_file(File file) {
			if(file == null) {
				return(null);
			}
			var sf = "file://".append(file.get_native_path());
			if(sf.has_suffix(".html") == false) {
				return(null);
			}
			embed "cs" {{{
				var webview = wpcontrol as Microsoft.Phone.Controls.WebBrowser;
				System.Uri myuri = new System.Uri(sf.to_strptr());
				webview.Navigate(myuri);
				webview.LoadCompleted += new System.Windows.Navigation.LoadCompletedEventHandler(LoadHandler);
			}}}
			return(this);
		}

		public WebWidget show_html_string(String html) {
			if(String.is_empty(html)) {
				return(null);
			}
			embed "cs" {{{
				var webview = wpcontrol as Microsoft.Phone.Controls.WebBrowser;
				webview.NavigateToString(html.to_strptr());
			}}}
			return(this);
		}

		void format_url(String aurl) {
			if(aurl == null) {
				return;
			}
			String url = aurl;
			if(url.has_prefix("https://")) {
				url = url.replace_string("http://", "https://");
			}
			else if(!url.has_prefix("http://")) {
				url = "http://".append(url);
			}
			embed "cs" {{{
				var webview = wpcontrol as Microsoft.Phone.Controls.WebBrowser;
				if(webview != null) {
					System.Uri myuri = new System.Uri(url.to_strptr());
					webview.Navigate(myuri);
				}
			}}}
		}

		public WebWidget set_listener(WebWidgetListener listener) {
			this.listener = listener;
			return(this);
		}

		public void on_load_finished() {
			if(listener != null) {
				listener.on_load_finished(this.url);
			}
		}

		public void on_load_started() {
			if(listener != null) {
				listener.on_load_started(this.url);
			}
		}

		public void on_error() {
			if(listener != null) {
				listener.on_error_received(this.url, "WebWidget: Error Encountered");
			}
		}

		public override bool on_key_press(KeyEvent e) {
			if("back".equals(e.get_name())) {
				embed "cs" {{{
					var webview = wpcontrol as Microsoft.Phone.Controls.WebBrowser;
					if(webview != null && webview.CanGoBack) {
						webview.GoBack();
						return(true);
					}
				}}}
			}
			return(base.on_key_press(e));
		}

		embed "cs" {{{
			protected override System.Windows.Controls.Control create_wp_control() {
				Microsoft.Phone.Controls.WebBrowser webview = new Microsoft.Phone.Controls.WebBrowser();
				webview.LoadCompleted += new System.Windows.Navigation.LoadCompletedEventHandler(LoadHandler);
				webview.Navigating += new System.EventHandler<Microsoft.Phone.Controls.NavigatingEventArgs>(NavigatingHandler);
				webview.NavigationFailed += new System.Windows.Navigation.NavigationFailedEventHandler(NavigationFailedHandler);
				return(webview);
			}

			private void LoadHandler(System.Object sender, System.Windows.Navigation.NavigationEventArgs e) {
				on_load_finished();
			}

			private void NavigatingHandler(System.Object sender, System.EventArgs e) {
				on_load_started();
			}
		
			private void NavigationFailedHandler(System.Object sender, System.Windows.Navigation.NavigationFailedEventArgs e) {
				e.Handled = true;
				on_error();
			}
		}}}
	}
}

ELSE
{
	class WebWidgetImpl
	{
		public static WebWidget create() {
			return(null);
		}
	}
}