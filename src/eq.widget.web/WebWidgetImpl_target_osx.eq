
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
	embed {{{
		#import <Foundation/NSURL.h>
		#import <Foundation/NSURLRequest.h>
		#import <WebKit/WebView.h>
		#import <WebKit/WebFrame.h>
	}}}

	embed {{{
		@interface WebFrameLoadDelegate : NSObject
		@property void* myself;
		@end

		@implementation WebFrameLoadDelegate
		- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame*)frame {
			if(frame == [sender mainFrame]) {
				NSString* url = [sender mainFrameURL];
				eq_widget_web_WebWidgetImpl_on_load_started(self.myself, [url UTF8String]);
			}
		}
		- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame*)frame {
			if(frame == [sender mainFrame]) {
				NSString* url = [sender mainFrameURL];
				eq_widget_web_WebWidgetImpl_on_load_finished(self.myself, [url UTF8String]);
			}
		}
		- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
			if(frame == [sender mainFrame]) {
				NSString* url = [sender mainFrameURL];
				NSString *error_msg = [[NSString alloc] initWithString:[error description]];
				eq_widget_web_WebWidgetImpl_on_error_received(self.myself, [url UTF8String], [error_msg UTF8String]);
			}
		}
		- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
			if(frame == [sender mainFrame]) {
				NSString* url = [sender mainFrameURL];
				NSString *error_msg = [[NSString alloc] initWithString:[error description]];
				eq_widget_web_WebWidgetImpl_on_error_received(self.myself, [url UTF8String], [error_msg UTF8String]);
			}
		}
		@end
	}}}

	public static WebWidget create() {
		return(new WebWidgetImpl());
	}

	WebWidgetListener listener;
	String url;
	File file;
	String html;
	ptr webview;
	ptr del;

	public void on_load_started(ptr u) {
		if(listener != null) {
			listener.on_load_started(String.for_strptr(u).dup());
		}
	}

	public void on_load_finished(ptr u) {
		if(listener != null) {
			listener.on_load_finished(String.for_strptr(u).dup());
		}
	}

	public void on_error_received(ptr u, ptr err) {
		if(listener != null) {
			listener.on_error_received(String.for_strptr(u).dup(), String.for_strptr(err).dup());
		}
	}

	public override bool get_always_has_surface() {
		return(true);
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
			var d = del;
			embed {{{
				WebView* wv = (__bridge_transfer WebView*)p;
				[wv close];
				[wv removeFromSuperview];
				WebFrameLoadDelegate* wwd = (__bridge_transfer WebFrameLoadDelegate*)d;
			}}}
			webview = null;
			del = null;
		}
	}

	public void cleanup() {
		base.cleanup();
		delete_webview();
	}

	public void on_surface_created(Surface surface) {
		base.on_surface_created(surface);
		delete_webview();
		var ss = surface as NSViewSurface;
		if(ss == null) {
			return;
		}
		var view = ss.get_nsview();
		ptr p;
		ptr d;
		embed {{{
			WebFrameLoadDelegate* wwd = [[WebFrameLoadDelegate alloc] init];
			wwd.myself = self;
			WebView* wv = [[WebView alloc] initWithFrame:[(__bridge NSView*)view bounds]];
			[wv setFrameLoadDelegate:wwd];
			[wv setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
			[(__bridge NSView*)view addSubview:wv];
			p = (__bridge_retained void*)wv;
			d = (__bridge_retained void*)wwd;
		}}}
		webview = p;
		del = d;
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
				[[(__bridge WebView*)p mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:up]]]];
			}}}
		}
		else if(String.is_empty(html) == false) {
			var hp = html.to_strptr();
			embed {{{
				[[(__bridge WebView*)p mainFrame] loadHTMLString:[NSString stringWithUTF8String:hp] baseURL:[NSURL URLWithString:@"file://"]];
			}}}
		}
		else if(file != null) {
			var ff = file.get_native_path();
			ff = "file://".append(file.get_native_path());
			var ffp = ff.to_strptr();
			embed {{{
				[[(__bridge WebView*)p mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:ffp]]]];
			}}}
		}
	}
}
