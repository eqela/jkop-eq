
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

class WebWidgetImpl : Widget, WebWidget
{
	embed "objc" {{{
		#import <UIKit/UIKit.h>
		@interface MyWebViewController : UIViewController<UIWebViewDelegate>
		@property void* myself;
		@property id<UIWebViewDelegate> delegate;
		@end
		
		@implementation MyWebViewController
		- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
		{
			NSString *currentURL = request.URL.absoluteString;
			eq_widget_web_WebWidgetImpl_on_started(self.myself, [currentURL UTF8String]);
			return YES;
		}
		
		- (void)webViewDidStartLoad:(UIWebView *)webView
		{
		}

		-(void)webViewDidFinishLoad:(UIWebView *)webView
		{
			NSString *currentURL = webView.request.URL.absoluteString;
			eq_widget_web_WebWidgetImpl_on_finished(self.myself, [currentURL UTF8String]);
		}

		- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
		{
			NSString *currentURL = webView.request.URL.absoluteString;
			NSString* error_msg = [[NSString alloc] initWithString:[error description]];
			eq_widget_web_WebWidgetImpl_on_error(self.myself, [currentURL UTF8String], [error_msg UTF8String]);
		}
		@end
	}}}

	public static WebWidget create() {
		return(new WebWidgetImpl());
	}

	public override bool get_always_has_surface() {
		return(true);
	}

	WebWidgetListener listener;
	String url;
	File file;
	String html;
	ptr webview;

	public void on_finished(ptr url) {
		if(listener != null) {
			listener.on_load_finished(String.for_strptr(url));
		}
	}

	public void on_error(ptr url, ptr error) {
		if(listener != null) {
			listener.on_error_received(String.for_strptr(url), String.for_strptr(error));
		}
	}

	public void on_started(ptr url) {
		if(listener != null) {
			listener.on_load_started(String.for_strptr(url));
		}
	}

	public WebWidget show_url(String url) {
		this.url = url;
		this.file = null;
		this.html = null;
		update_webview_content();
		return(this);
	}

	public WebWidget show_file(File file) {
		this.url = null;
		this.file = file;
		this.html = null;
		update_webview_content();
		return(this);
	}

	public WebWidget show_html_string(String html) {
		this.url = null;
		this.file = null;
		this.html = html;
		update_webview_content();
		return(this);
	}

	public WebWidget set_listener(WebWidgetListener listener) {
		this.listener = listener;
		return(this);
	}

	void delete_webview() {
		if(webview != null) {
			var p = webview;
			embed {{{
				UIWebView* wv = (__bridge_transfer UIWebView*)p;
				[wv removeFromSuperview];
			}}}
			webview = null;
		}
	}

	public void cleanup() {
		base.cleanup();
		delete_webview();
	}

	public void on_surface_created(Surface surface) {
		base.on_surface_created(surface);
		var ss = surface as UIViewSurface;
		if(ss == null) {
			Log.error("IOS Web Widget: Created surface is not a UIView surface!");
			return;
		}
		var pview = ss.get_uiview();
		if(pview == null) {
			Log.error("IOS Web Widget: Parent surface does not have a view");
			return;
		}
		ptr web_view;
		embed {{{
			MyWebViewController* myvv = [[MyWebViewController alloc] init];
			myvv.myself = self;
			UIWebView* mywebview = [[UIWebView alloc] initWithFrame:[(__bridge UIView*)pview bounds]];
			mywebview.scalesPageToFit = YES;
			mywebview.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
			myvv.delegate = myvv;
			mywebview.delegate = myvv;
			UIView* uipview = (__bridge UIView*)pview;
			[uipview addSubview:mywebview];
			web_view = (__bridge_retained void*)mywebview;
		}}}
		webview = web_view;
		update_webview_content();
	}

	void update_webview_content() {
		if(webview == null) {
			return;
		}
		var p = webview;
		if(String.is_empty(url) == false) {
			var up = url.to_strptr();
			embed {{{
				[(__bridge UIWebView*)p loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:up]]]];
			}}}
		}
		else if(String.is_empty(html) == false) {
			var hp = html.to_strptr();
			embed {{{
				[(__bridge UIWebView*)p loadHTMLString:[NSString stringWithUTF8String:hp] baseURL:[NSURL URLWithString:@"file://"]];
			}}}
		}
		else if(file != null) {
			var ff = file.get_native_path();
			ff = "file://".append(file.get_native_path());
			var ffp = ff.to_strptr();
			embed {{{
				[(__bridge UIWebView*)p loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:ffp]]]];
			}}}
		}
	}
}
