
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

public class FacebookShareDialog : SocialShareDialog
{
	public static FacebookShareDialog create() {
		IFDEF("target_ios") {
			return(new IOSFacebookShareDialog());
		}
		ELSE IFDEF("target_osx") {
			return(new OSXFacebookShareDialog());
		}
		ELSE IFDEF("target_android") {
			return(new AndroidFacebookShareDialog());
		}
		ELSE IFDEF("target_wp8cs") {
			return(new WPCSFacebookShareDialog());
		}
		ELSE {
			return(new GenericFacebookShareDialog());
		}
	}

	public static FacebookShareDialog for_text(String text) {
		var v = FacebookShareDialog.create();
		if(v != null) {
			v.set_initial_text(text);
		}
		return(v);
	}

	property String application_id;
	property String link_title;
	property String link_subtitle;
	property String link_description;
	property String link_picture;
}
