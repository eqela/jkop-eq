
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

public class IOSFacebookLogin
{

	embed "objc" {{{
		#import <FacebookSDK/FBSettings.h>
		#import <FacebookSDK/FBSession.h>
		#import <FacebookSDK/FBAppCall.h>
		#import <eq.gui.sysdep.ios/MyApplicationDelegate.h>
		@interface MyFacebookLoginDelegate : NSObject <UIApplicationDelegate>
		@end
		@implementation MyFacebookLoginDelegate
			- (void)applicationDidBecomeActive:(UIApplication *)application
			{
				[FBAppCall handleDidBecomeActive];
			}

			- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
			{
				return[FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
			}
		@end
	}}}

	static IOSFacebookLogin _instance;

	public static IOSFacebookLogin instance() {
		if(_instance == null) {
			_instance = new IOSFacebookLogin();
		}
		return(_instance);
	}

	public bool execute(String application_id, FacebookLoginListener listener, Collection permissions = null) {
		if(String.is_empty(application_id)) {
			return(false);
		}
		var appidp = application_id.to_strptr();
		embed "objc" {{{
			NSString *nsAppID = [NSString stringWithUTF8String:appidp];
			[FBSettings setDefaultAppID:nsAppID];
			FBSession *active_session = [FBSession activeSession];
			if(active_session!= nil && active_session.isOpen) {
				[active_session closeAndClearTokenInformation];
			}
			NSMutableArray *list = [[NSMutableArray alloc]init];
		}}}
		if(permissions != null) {
			foreach(String p in permissions) {
				var pp = p.to_strptr();
				embed "objc" {{{
					[list addObject:[NSString stringWithUTF8String:pp]];
				}}}
			} 
		}
		else {
			embed "objc" {{{
				[list addObject:@"public_profile"];
			}}}
		}
		embed "objc" {{{
			MyFacebookLoginDelegate *mdg = [[MyFacebookLoginDelegate alloc] init];
			MyApplicationDelegate *appDelegate = (MyApplicationDelegate *)[[UIApplication sharedApplication] delegate];
			[appDelegate add_ui_application_delegate:mdg];
			__block BOOL oneTimeRunFlag = NO;
			ref_eq_api_Object(listener);
			[FBSession openActiveSessionWithReadPermissions:list
				allowLoginUI:YES
				completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
					if(!oneTimeRunFlag) {
						oneTimeRunFlag = YES;
						if(session.isOpen) {
							eq_ext_facebook_IOSFacebookLogin_on_logged_in(self, (__bridge void*)session, listener);
						}
						else {
							eq_ext_facebook_IOSFacebookLogin_on_logged_out(self, listener);
						}
						MyApplicationDelegate *appDelegate = (MyApplicationDelegate *)[[UIApplication sharedApplication] delegate];
						[appDelegate remove_ui_application_delegate:mdg];
						unref_eq_api_Object(listener);
					}
				}
			];
		}}}
		return(true);
	}

	public bool request_new_read_permissions(Collection permissions, FacebookLoginListener listener) {
		return(request_new_permissions(permissions, listener, true));
	}

	public bool request_new_publish_permissions(Collection permissions, FacebookLoginListener listener) {
		return(request_new_permissions(permissions, listener, false));
	}

	private bool request_new_permissions(Collection permissions, FacebookLoginListener listener, bool is_read_permissions) {
		if(permissions == null || permissions.count() < 1) {
			return(false);
		}
		embed "objc" {{{
			NSMutableArray *list = [[NSMutableArray alloc]init];
		}}}
		foreach(String p in permissions) {
			var pp = p.to_strptr();
			embed "objc" {{{
				[list addObject:[NSString stringWithUTF8String:pp]];
			}}}
		}
		embed "objc" {{{
			if([FBSettings defaultAppID] == nil) {
				return(false);
			}
			FBSession *active_session = [FBSession activeSession];
			if(active_session != nil && active_session.isOpen) {
				MyFacebookLoginDelegate *mdg = [[MyFacebookLoginDelegate alloc] init];
				MyApplicationDelegate *appDelegate = (MyApplicationDelegate *)[[UIApplication sharedApplication] delegate];
				[appDelegate add_ui_application_delegate:mdg];
				ref_eq_api_Object(listener);
				if(is_read_permissions) {
					[active_session requestNewReadPermissions:list
						completionHandler:^(FBSession *session, NSError *error) {
							if(session.isOpen) {
								eq_ext_facebook_IOSFacebookLogin_on_logged_in(self, (__bridge void*)session, listener);
							}
							else {
								eq_ext_facebook_IOSFacebookLogin_on_logged_out(self, listener);
							}
							MyApplicationDelegate *appDelegate = (MyApplicationDelegate *)[[UIApplication sharedApplication] delegate];
							[appDelegate remove_ui_application_delegate:mdg];
							unref_eq_api_Object(listener);
						}
					];
				}
				else {
					[active_session requestNewPublishPermissions:list 
						defaultAudience:FBSessionDefaultAudienceFriends
						completionHandler:^(FBSession *session, NSError *error) {
							if(session.isOpen) {
								eq_ext_facebook_IOSFacebookLogin_on_logged_in(self, (__bridge void*)session, listener);
							}
							else {
								eq_ext_facebook_IOSFacebookLogin_on_logged_out(self, listener);
							}
							MyApplicationDelegate *appDelegate = (MyApplicationDelegate *)[[UIApplication sharedApplication] delegate];
							[appDelegate remove_ui_application_delegate:mdg];
							unref_eq_api_Object(listener);
						}
					];
				}
				return(true);
			}
		}}}
		return(false);
	}

	private void on_logged_in(ptr sessionp, FacebookLoginListener l) {
		strptr access_tokenp, key;
		var permission_collection = LinkedList.create();
		embed "objc" {{{
			FBSession *active_session = (__bridge FBSession*)sessionp;
			FBAccessTokenData *fb_data = [active_session accessTokenData];
			NSArray *permission = [active_session permissions];
			for(NSString *p in permission) {
				key = [p UTF8String];
				}}}
				permission_collection.add(String.for_strptr(key));
				embed "objc" {{{
			}
			access_tokenp = [[fb_data accessToken] UTF8String];
		}}}
		if(l != null) {
			l.on_facebook_login_completed(String.for_strptr(access_tokenp), permission_collection);
		}
	}

	private void on_logged_out(FacebookLoginListener l) {
		if(l != null) {
			l.on_facebook_login_completed(null, null);
		}
	}
}
