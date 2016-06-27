
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

public class APNsConfig
{
	IFDEF("target_ios") {
		embed "objc" {{{
			#import <eq.gui.sysdep.ios/MyApplicationDelegate.h>
			@interface MyPushNotificationConfigDelegate : NSObject <UIApplicationDelegate>
			@property void* myself;
			@end
			@implementation MyPushNotificationConfigDelegate
				- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
				{
					[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
				}
				- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
				{
					NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
					token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    				eq_gui_sysdep_apns_APNsConfig_on_device_token_received(self.myself, [token UTF8String]);
				}
				- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
				{
			    	NSLog(@"Failed to get device token, error: %@", error);
					// - FIXME
				}
				- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
				{
					[UIApplication sharedApplication].applicationIconBadgeNumber += [[[userInfo objectForKey:@"aps"] objectForKey: @"badgecount"] intValue];
				}
				- (void)applicationDidBecomeActive:(UIApplication *)application
				{
					[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
				}
			@end
		}}}

		private void on_device_token_received(ptr device_token) {
			if(receiver != null) {
				receiver.on_device_token_received(String.for_strptr(device_token));
			}
		}
	}

	public static APNsConfig for_receiver(APNsDeviceTokenReceiver receiver) {
		return(new APNsConfig().set_receiver(receiver));
	}

	property APNsDeviceTokenReceiver receiver;

	public void register_for_push_notification() {
		IFDEF("target_ios") {
			embed "objc" {{{
				MyPushNotificationConfigDelegate *mpncd = [[MyPushNotificationConfigDelegate alloc] init];
				mpncd.myself = self;
				MyApplicationDelegate *appdelegate = (MyApplicationDelegate *)[[UIApplication sharedApplication] delegate];
				[appdelegate add_ui_application_delegate:mpncd];
			}}}
		}
	}
}
