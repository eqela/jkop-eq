
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

#import "EqelaViewController.h"
#import "UIKitFrame.h"
#import "UIKitFramePopup.h"
#import "MyApplicationDelegate.h"
#import <eq.gui/FrameController.h>
#import <eq.gui/Frame.h>

@implementation EqelaViewController

{
	int isPopup;
	int isPopupFullScreen;
	int initialized;
}

- (id)initWithController:(void*)controller isPopup:(int)popup isPopupFullScreen:(int)popupfs
{
	self = [super init];
	if(self) {
		self->_closeOnAppear = NO;
		self->_frameController = ref_eq_api_Object(controller);
		self->_frame = nil;
		self->isPopup = popup;
		self->isPopupFullScreen = popupfs;
		if(isPopup == 1 && popupfs == 0) {
			[self setModalPresentationStyle:UIModalPresentationFormSheet];
		}
		self->initialized = 0;
		if(self->isPopup) {
			self->_frame = eq_gui_sysdep_ios_UIKitFramePopup_create(self->_frameController);
		}
		else {
			self->_frame = eq_gui_sysdep_ios_UIKitFrame_create(self->_frameController);
		}
		eq_gui_sysdep_ios_UIKitFrame_set_eqela_view_controller(self->_frame, (__bridge void*)self);
		unref_eq_gui_Frame(eq_gui_sysdep_ios_UIKitFrame_set_is_popup_fullscreen(self->_frame, self->isPopupFullScreen));
	}
	return(self);
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	if(self->_frameController != nil) {
		eq_gui_FrameController_destroy(self->_frameController);
		self->_frameController = unref_eq_api_Object(self->_frameController);
	}
	if(self->_frame != nil) {
		eq_gui_sysdep_ios_UIKitFrame_destroy(self->_frame);
		unref_eq_api_Object(self->_frame);
		self->_frame = NULL;
	}
}

- (void)loadView
{
	UIView* mvw = (__bridge UIView*)eq_gui_sysdep_ios_UIKitFrame_get_myview(self->_frame);
	self.view = mvw;
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];   
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];   
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	if(isPopup) {
		eq_gui_sysdep_ios_UIKitFrame_start(self->_frame);
	}
}

- (void)onDidBecomeActive:(NSNotification*)notification
{
	eq_gui_sysdep_ios_UIKitFrame_start(self->_frame);
}

- (void)onWillResignActive:(NSNotification*)notification
{
	eq_gui_sysdep_ios_UIKitFrame_stop(self->_frame);
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if(self->_closeOnAppear) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewDidLayoutSubviews
{
	if(initialized == 0) {
		initialized = 1;
		eq_gui_sysdep_ios_UIKitFrame_initialize(self->_frame);
		[self handleRotation];
	}
	else {
		eq_gui_sysdep_ios_UIKitFrame_update_frame_size(self->_frame);
	}
}

- (BOOL)disablesAutomaticKeyboardDismissal {
	return NO;

}
- (BOOL)prefersStatusBarHidden {
	return YES;
}

#define DegreesToRadians(degrees) (degrees * M_PI / 180)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

- (NSUInteger)supportedInterfaceOrientations
{
	return(UIInterfaceOrientationMaskAll);
}
- (void)didRotate:(NSNotification *)notification {
	[self handleRotation];
}

- (void)handleRotation
{
	MyApplicationDelegate *appDelegate = (MyApplicationDelegate *)[[UIApplication sharedApplication] delegate];
	UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
	switch (deviceOrientation) {
		case UIDeviceOrientationLandscapeLeft:
			if(appDelegate.isLandscapeLeft) {
				if(SYSTEM_VERSION_LESS_THAN(@"6.0")) {
					[self.view setTransform:CGAffineTransformMakeRotation(-DegreesToRadians(90))];
					[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
				}
				eq_gui_sysdep_ios_UIKitFrame_on_orientation_change(self->_frame, true);
			}
			break;
		case UIDeviceOrientationLandscapeRight:
			if(appDelegate.isLandscapeRight) {
				if(SYSTEM_VERSION_LESS_THAN(@"6.0")) {
					[self.view setTransform:CGAffineTransformMakeRotation(DegreesToRadians(90))];
					[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
				}
				eq_gui_sysdep_ios_UIKitFrame_on_orientation_change(self->_frame, true);
			}
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			if(appDelegate.isPortraitUpsideDown) {
				if(SYSTEM_VERSION_LESS_THAN(@"6.0")) {
					[self.view setTransform:CGAffineTransformMakeRotation(DegreesToRadians(180))];
					[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortraitUpsideDown]; 
				}
				eq_gui_sysdep_ios_UIKitFrame_on_orientation_change(self->_frame, false);
			}
			break;
		case UIDeviceOrientationFaceUp:
		case UIDeviceOrientationFaceDown:
		case UIDeviceOrientationUnknown:
			break;
		case UIInterfaceOrientationPortrait:
			if(appDelegate.isPortrait) {
				if(SYSTEM_VERSION_LESS_THAN(@"6.0")) {
					[self.view setTransform:CGAffineTransformMakeRotation(DegreesToRadians(0))];
					[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
				}
				eq_gui_sysdep_ios_UIKitFrame_on_orientation_change(self->_frame, false);
			}
			break;
	}
}

- (void)keyboardWillShow:(NSNotification *)notification {
	CGSize kbSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	eq_gui_sysdep_ios_UIKitFrame_on_keyboard_shown(self->_frame, kbSize.width, kbSize.height);
}

- (void)keyboardDidShow:(NSNotification *)notification {
}

- (void)keyboardWillHide:(NSNotification *)notification {
	eq_gui_sysdep_ios_UIKitFrame_on_keyboard_hidden(self->_frame);
}

@end
