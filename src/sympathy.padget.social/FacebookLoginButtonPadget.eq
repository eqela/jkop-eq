
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

public class FacebookLoginButtonPadget : Padget
{
	property int max_rows = 1;
	property String size;
	property bool show_faces = false;
	property bool show_logout = false;
	property String scope;
	property String button_text;
	property String redirect_url;

	public FacebookLoginButtonPadget() {
		size = "medium";
		scope = "public_profile,email";
		set_button_text("Log in with Facebook");
		set_redirect_url("/session_login");
	}

	public void execute(HTTPRequest req, WebSession session, HashTable data) {
		data.set("FacebookLoginButtonPadget", HashTable.create()
			.set("max_rows", max_rows)
			.set("size", size)
			.set("show_faces", show_faces)
			.set("show_logout", show_logout)
			.set("scope", scope)
			.set("button_text", button_text)
			.set("redirect_url", redirect_url)
		);
	}

	public void get_html_content(StringBuffer sb) {
		sb.append(TEXTFILE("FacebookLoginButtonPadget.html"));
	}
}
