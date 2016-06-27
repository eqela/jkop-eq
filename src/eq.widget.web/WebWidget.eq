
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

public interface WebWidget : Widget
{
	public static WebWidget for_url(String url) {
		var ww = WebWidgetImpl.create();
		if(ww == null) {
			return(null);
		}
		return(ww.show_url(url));
	}

	public static WebWidget for_file(File file) {
		var ww = WebWidgetImpl.create();
		if(ww == null) {
			return(null);
		}
		return(ww.show_file(file));
	}

	public static WebWidget for_html_string(String str) {
		var ww = WebWidgetImpl.create();
		if(ww == null) {
			return(null);
		}
		return(ww.show_html_string(str));
	}

	public static WebWidget instance() {
		return(WebWidgetImpl.create());
	}

	public WebWidget show_url(String url);
	public WebWidget show_file(File file);
	public WebWidget show_html_string(String html);
	public WebWidget set_listener(WebWidgetListener listener);
}
