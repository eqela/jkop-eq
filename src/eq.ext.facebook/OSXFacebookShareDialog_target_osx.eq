
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

public class OSXFacebookShareDialog : FacebookShareDialog
{
	embed "objc" {{{
		#import <Social/Social.h>
		#import <Appkit/NSSharingService.h>
		#import <Foundation/Foundation.h>

		@interface NSSharingServiceForFacebookDelegate : NSObject
		@property void* myself;
		@end

		@implementation NSSharingServiceForFacebookDelegate
		- (void)sharingService:(NSSharingService *)sharingService willShareItems:(NSArray *)items
		{
			eq_ext_facebook_OSXFacebookShareDialog_will_share_items(self.myself);
		}

		- (void)sharingService:(NSSharingService *)sharingService didShareItems:(NSArray *)items
		{
			eq_ext_facebook_OSXFacebookShareDialog_did_share_items(self.myself);
			unref_eq_api_Object(self.myself);
		}

		- (void)sharingService:(NSSharingService *)sharingService didFailToShareItems:(NSArray *)items error:(NSError *)error
		{
			eq_ext_facebook_OSXFacebookShareDialog_did_fail_to_share_items(self.myself);
			unref_eq_api_Object(self.myself);
		}
		@end
	}}}

	SocialShareDialogListener listener;

	public void will_share_items() {
	}

	public void did_share_items() {
		listener.on_social_share_complete(true);
	}

	public void did_fail_to_share_items() {
		listener.on_social_share_complete(false);
	}

	public void execute(Frame frame, SocialShareDialogListener listener) {
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
			NSArray *items = @[[[NSString alloc] initWithUTF8String:p], baseURL];
			NSSharingService *service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnFacebook];
			NSSharingServiceForFacebookDelegate* nssd = [[NSSharingServiceForFacebookDelegate alloc] init];
			nssd.myself = self;
			service.delegate = nssd;
			[service performWithItems:items];
			ref_eq_api_Object(self);
		}}}
		this.listener = listener;
	}
}
