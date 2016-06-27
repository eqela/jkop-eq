
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

#import "MyApplicationDelegate.h"
#import "EqelaViewController.h"

void* my_application_delegate_frame_controller;

@implementation MyApplicationDelegate
{
	NSMutableArray *_ui_application_delegates;
	NSMutableArray *_addable_ui_application_delegates;
	NSMutableArray *_removable_ui_application_delegates;
}

- (id)init 
{
	self = [super init];
	if(self)
	{
		self->_isPortrait = NO;
		self->_isLandscapeRight = NO;
		self->_isLandscapeLeft = NO;
		self->_isPortraitUpsideDown = NO;
		_ui_application_delegates = [[NSMutableArray alloc]init];
		NSArray *_supportedOrientations = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedInterfaceOrientations"];
		for(NSString* o in _supportedOrientations) {
			if([o isEqualToString:@"UIInterfaceOrientationLandscapeRight"]) {
				self->_isLandscapeRight = YES;
			}
			if([o isEqualToString:@"UIInterfaceOrientationLandscapeLeft"]) {
				self->_isLandscapeLeft = YES;
			}
			if([o isEqualToString:@"UIInterfaceOrientationPortrait"]) {
				self->_isPortrait = YES;
			}
			if([o isEqualToString:@"UIInterfaceOrientationPortraitUpsideDown"]) {
				self->_isPortraitUpsideDown = YES; 
			}
		}
	}
	return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = [[EqelaViewController alloc] initWithController:my_application_delegate_frame_controller isPopup:0 isPopupFullScreen:0];
	[self.window makeKeyAndVisible];
	[self prepare_queue_delegates];
	for (NSObject<UIApplicationDelegate> *delegate in _ui_application_delegates) {
		if ([delegate respondsToSelector:@selector(application:didFinishLaunchingWithOptions:)]) {
			[delegate application:application didFinishLaunchingWithOptions:launchOptions];
		}
	}
	[self perform_and_cleanup_queue_delegates];
	return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	[self prepare_queue_delegates];
	for (NSObject<UIApplicationDelegate> *delegate in _ui_application_delegates) {
		if ([delegate respondsToSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)]) {
			[delegate application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
		}
	}
	[self perform_and_cleanup_queue_delegates];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	[self prepare_queue_delegates];
	for (NSObject<UIApplicationDelegate> *delegate in _ui_application_delegates) {
		if ([delegate respondsToSelector:@selector(application:didFailToRegisterForRemoteNotificationsWithError:)]) {
			[delegate application:application didFailToRegisterForRemoteNotificationsWithError:error];
		}
	}
	[self perform_and_cleanup_queue_delegates];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[self prepare_queue_delegates];
	for (NSObject<UIApplicationDelegate> *delegate in _ui_application_delegates) {
		if ([delegate respondsToSelector:@selector(applicationWillResignActive:)]) {
			[delegate applicationWillResignActive:application];
		}
	}
	[self perform_and_cleanup_queue_delegates];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[self prepare_queue_delegates];
	for (NSObject<UIApplicationDelegate> *delegate in _ui_application_delegates) {
		if ([delegate respondsToSelector:@selector(applicationDidEnterBackground:)]) {
			[delegate applicationDidEnterBackground:application];
		}
	}
	[self perform_and_cleanup_queue_delegates];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	[self prepare_queue_delegates];
	for (NSObject<UIApplicationDelegate> *delegate in _ui_application_delegates) {
		if ([delegate respondsToSelector:@selector(applicationWillEnterForeground:)]) {
			[delegate applicationWillEnterForeground:application];
		}
	}
	[self perform_and_cleanup_queue_delegates];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[self prepare_queue_delegates];
	for (NSObject<UIApplicationDelegate> *delegate in _ui_application_delegates) {
		if ([delegate respondsToSelector:@selector(applicationDidBecomeActive:)]) {
			[delegate applicationDidBecomeActive:application];
		}
	}
	[self perform_and_cleanup_queue_delegates];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[self prepare_queue_delegates];
	for (NSObject<UIApplicationDelegate> *delegate in _ui_application_delegates) {
		if ([delegate respondsToSelector:@selector(applicationWillTerminate:)]) {
			[delegate applicationWillTerminate:application];
		}
	}
	[self perform_and_cleanup_queue_delegates];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	[self prepare_queue_delegates];
	for (NSObject<UIApplicationDelegate> *delegate in _ui_application_delegates) {
		if ([delegate respondsToSelector:@selector(application:openURL:sourceApplication:annotation:)]) {
			[delegate application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
		}
	}
	[self perform_and_cleanup_queue_delegates];
	return(YES);
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
	if(self->_isLandscapeRight && self->_isLandscapeLeft && self->_isPortrait && self->_isPortraitUpsideDown) {
		return(UIInterfaceOrientationMaskAll); 
	}
	else if(self->_isLandscapeRight && self->_isLandscapeLeft && self->_isPortrait) {
		return(UIInterfaceOrientationMaskAllButUpsideDown); 
	}
	else if(self->_isPortrait) {
		return(UIInterfaceOrientationMaskPortrait);
	}
	else if(self->_isLandscapeRight && self->_isLandscapeLeft) {
		return(UIInterfaceOrientationMaskLandscape);
	}
	else if(self->_isLandscapeRight) {
		return(UIInterfaceOrientationMaskLandscapeRight);
	}
	else if(self->_isLandscapeLeft) {
		return(UIInterfaceOrientationMaskLandscapeLeft);
	}
	else if(self->_isPortraitUpsideDown) {
		return(UIInterfaceOrientationMaskPortraitUpsideDown);
	}
	return(UIInterfaceOrientationMaskAllButUpsideDown);
}

-(void)prepare_queue_delegates
{
	_addable_ui_application_delegates = [[NSMutableArray alloc]init];
	_removable_ui_application_delegates = [[NSMutableArray alloc]init];
}

-(void)perform_and_cleanup_queue_delegates
{
	for (NSObject<UIApplicationDelegate> *delegate in _addable_ui_application_delegates) {
		[_ui_application_delegates addObject:delegate];
	}
	for (NSObject<UIApplicationDelegate> *delegate in _removable_ui_application_delegates) {
		[_ui_application_delegates removeObject:delegate];
	}
	_addable_ui_application_delegates = nil;
	_removable_ui_application_delegates = nil;
}

- (void)add_ui_application_delegate:(NSObject<UIApplicationDelegate> *)delegate
{
	if(_addable_ui_application_delegates != nil) {
		[_addable_ui_application_delegates addObject:delegate];
	}
	else {
		[_ui_application_delegates addObject:delegate];
	}
}

- (void)remove_ui_application_delegate:(NSObject<UIApplicationDelegate> *)delegate
{
	if(_removable_ui_application_delegates != nil) {
		[_removable_ui_application_delegates addObject:delegate];
	}
	else {
		[_ui_application_delegates removeObject:delegate];
	}
}

@end
