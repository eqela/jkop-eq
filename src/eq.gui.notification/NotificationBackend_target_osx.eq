
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

class NotificationBackend
{
	static NotificationBackend _instance;

	public static NotificationBackend instance() {
		if(_instance == null) {
			_instance = new NotificationBackend();
		}
		return(_instance);
	}

	embed {{{
		#import <Foundation/Foundation.h>
		#import <Foundation/NSUserNotification.h>
		@interface MyDelegate : NSObject <NSUserNotificationCenterDelegate>
		@end
		@implementation MyDelegate
		- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
		{
		    return YES;
		}
		@end
	}}}

	ptr delegate = null;

	public NotificationBackend() {
		ptr dd;
		embed {{{
			MyDelegate* mdg = [[MyDelegate alloc] init];
			[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:mdg];
			dd = (__bridge_retained void*)mdg;
		}}}
		delegate = dd;
	}

	~NotificationBackend() {
		var dd = delegate;
		if(dd != null) {
			embed {{{
				(__bridge_transfer MyDelegate*)dd;
			}}}
			delegate = null;
		}
	}

	public bool show(Notification ni) {
		if(ni == null) {
			return(false);
		}
		var title = ni.get_title();
		var content = ni.get_content();
		if(String.is_empty(content)) {
			return(false);
		}
		if(String.is_empty(title)) {
			title = "Notification";
		}
		ptr n;
		var titlep = title.to_strptr();
		var contentp = content.to_strptr();
		embed "objc" {{{
			NSString *nsTitle = [NSString stringWithUTF8String:titlep];
			NSString *nsContent = [NSString stringWithUTF8String:contentp];
			NSUserNotification* notif = [[NSUserNotification alloc] init];
			notif.title = nsTitle;
			notif.informativeText = nsContent;
			notif.soundName = NSUserNotificationDefaultSoundName;
			[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notif];
		}}}
		return(true);
	}
}
