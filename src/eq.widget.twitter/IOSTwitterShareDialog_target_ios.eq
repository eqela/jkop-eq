
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

public class IOSTwitterShareDialog : TwitterShareDialog
{
	embed "objc" {{{
		#import <Social/Social.h>
	}}}

	public void execute(Frame frame, SocialShareDialogListener listener) {
		if(frame == null) {
			if(listener != null) {
				listener.on_social_share_complete(false);
			}
			return;
		}
		ptr vc;
		if(frame is UIKitFrame) {
			vc = ((UIKitFrame)frame).get_view_controller();
		}
		if(vc == null) {
			if(listener != null) {
				listener.on_social_share_complete(false);
			}
			return;
		}
		var text = get_initial_text();
		if(String.is_empty(text)) {
			 text = "";
		}
		var sb = StringBuffer.create(text);
		var h = get_hashtags();
		foreach(String s in h) {
			if(String.is_empty(s)) {
				continue;
			}
			sb.append(s);
		}
		var sbt = sb.to_string();
		var p = sbt.to_strptr();
		var link = get_initial_link();
		if(String.is_empty(link)) {
			link = "";
		}
		var l = link.to_strptr();
		embed "objc" {{{
			if(p == NULL) {
				p = "";
			}
			if(l == NULL) {
				l = "";
			}
			NSURL *baseURL = [NSURL URLWithString:[[NSString alloc] initWithUTF8String:l]];
			UIViewController* uivc = (__bridge UIViewController*)vc;
			SLComposeViewController* controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
			[controller setInitialText:[[NSString alloc] initWithUTF8String:p]];
			[controller addURL:baseURL];
			ref_eq_gui_social_SocialShareDialogListener(listener);
			controller.completionHandler = ^(SLComposeViewControllerResult result) {
				unref_eq_gui_social_SocialShareDialogListener(listener);
				if(result == SLComposeViewControllerResultDone) {
					}}}
					if(listener != null) {
						listener.on_social_share_complete(true);
					}
					embed "objc" {{{
				}
				else {
					}}}
					if(listener != null) {
						listener.on_social_share_complete(false);
					}
					embed "objc" {{{
				}
			};
			[uivc presentViewController:controller animated:YES completion:nil];
		}}}
	}
}
