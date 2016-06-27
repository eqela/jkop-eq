
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

public class CustomPadget : Padget
{
	public static CustomPadget for_html(String html) {
		return(new CustomPadget().set_html_content_text(html));
	}

	property String html_header_text;
	property String html_body_text;
	property String html_page_header_text;
	property String html_before_content_text;
	property String html_content_text;
	property String html_after_content_text;
	property String html_page_footer_text;
	property String css_text;
	property String javascript_text;

	public void execute(HTTPRequest req, HashTable data) {
	}

	public void get_html_header(StringBuffer sb) {
		if(html_header_text != null) {
			sb.append(html_header_text);
		}
	}

	public void get_html_body(StringBuffer sb) {
		if(html_body_text != null) {
			sb.append(html_body_text);
		}
	}

	public void get_html_page_header(StringBuffer sb) {
		if(html_page_header_text != null) {
			sb.append(html_page_header_text);
		}
	}

	public void get_html_before_content(StringBuffer sb) {
		if(html_before_content_text != null) {
			sb.append(html_before_content_text);
		}
	}

	public void get_html_content(StringBuffer sb) {
		if(html_content_text != null) {
			sb.append(html_content_text);
		}
	}

	public void get_html_after_content(StringBuffer sb) {
		if(html_after_content_text != null) {
			sb.append(html_after_content_text);
		}
	}

	public void get_html_page_footer(StringBuffer sb) {
		if(html_page_footer_text != null) {
			sb.append(html_page_footer_text);
		}
	}

	public void get_css(StringBuffer sb) {
		if(css_text != null) {
			sb.append(css_text);
		}
	}

	public void get_javascript(StringBuffer sb) {
		if(javascript_text != null) {
			sb.append(javascript_text);
		}
	}
}
