
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

public class IOSOrientationHelper
{
	embed {{{
		#import <UIKit/UIKit.h>
		#import <Foundation/Foundation.h>
		#import <eq.gui.sysdep.ios/MyApplicationDelegate.h>
	}}}

	public static void lock_and_set_to_portrait() {
		lock_to_portrait();
		set_to_portrait();
	}

	public static void lock_and_set_to_portrait_upside_down() {
		lock_to_portrait_upside_down();
		set_to_portrait_upside_down();
	}

	public static void lock_and_set_to_landscape_right() {
		lock_to_landscape_right();
		set_to_landscape_right();
	}

	public static void lock_and_set_to_landscape_left() {
		lock_to_landscape_left();
		set_to_landscape_left();
	}

	public static void lock_to_portrait() {
		embed {{{
			MyApplicationDelegate *appDelegate = (MyApplicationDelegate *)[[UIApplication sharedApplication] delegate];
			appDelegate.isLandscapeRight = NO;
			appDelegate.isLandscapeLeft = NO;
			appDelegate.isPortrait = YES;
			appDelegate.isPortraitUpsideDown = NO;
		}}}
	}

	public static void lock_to_portrait_upside_down() {
		embed {{{
			MyApplicationDelegate *appDelegate = (MyApplicationDelegate *)[[UIApplication sharedApplication] delegate];
			appDelegate.isLandscapeRight = NO;
			appDelegate.isLandscapeLeft = NO;
			appDelegate.isPortrait = NO;
			appDelegate.isPortraitUpsideDown = YES;
		}}}
	}

	public static void lock_to_landscape() {
		embed {{{
			MyApplicationDelegate *appDelegate = (MyApplicationDelegate *)[[UIApplication sharedApplication] delegate];
			appDelegate.isLandscapeRight = YES;
			appDelegate.isLandscapeLeft = YES;
			appDelegate.isPortrait = NO;
			appDelegate.isPortraitUpsideDown = NO;
		}}}
	}

	public static void lock_to_landscape_right() {
		embed {{{
			MyApplicationDelegate *appDelegate = (MyApplicationDelegate *)[[UIApplication sharedApplication] delegate];
			appDelegate.isLandscapeRight = YES;
			appDelegate.isLandscapeLeft = NO;
			appDelegate.isPortrait = NO;
			appDelegate.isPortraitUpsideDown = NO;
		}}}
	}

	public static void lock_to_landscape_left() {
		embed {{{
			MyApplicationDelegate *appDelegate = (MyApplicationDelegate *)[[UIApplication sharedApplication] delegate];
			appDelegate.isLandscapeRight = NO;
			appDelegate.isLandscapeLeft = YES;
			appDelegate.isPortrait = NO;
			appDelegate.isPortraitUpsideDown = NO;
		}}}
	}

	public static void set_to_portrait() {
		embed {{{
			NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
			[[UIDevice currentDevice] setValue:value forKey:@"orientation"];
		}}}
	}

	public static void set_to_landscape_right() {
		embed {{{
			NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
			[[UIDevice currentDevice] setValue:value forKey:@"orientation"];
		}}}
	}

	public static void set_to_landscape_left() {
		embed {{{
			NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
			[[UIDevice currentDevice] setValue:value forKey:@"orientation"];
		}}}
	}

	public static void set_to_portrait_upside_down() {
		embed {{{
			NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortraitUpsideDown];
			[[UIDevice currentDevice] setValue:value forKey:@"orientation"];
		}}}
	}

	public static void allow_all_orientations() {
		embed {{{
			MyApplicationDelegate *appDelegate = (MyApplicationDelegate *)[[UIApplication sharedApplication] delegate];
			appDelegate.isLandscapeRight = YES;
			appDelegate.isLandscapeLeft = YES;
			appDelegate.isPortrait = YES;
			appDelegate.isPortraitUpsideDown = YES;
		}}}
	}

	public static void allow_portrait(bool is_portrait) {
		embed {{{
			MyApplicationDelegate *appDelegate = (MyApplicationDelegate *)[[UIApplication sharedApplication] delegate];
			appDelegate.isPortrait = is_portrait;
		}}}
	}

	public static void allow_landscape(bool is_landscape) {
		embed {{{
			MyApplicationDelegate *appDelegate = (MyApplicationDelegate *)[[UIApplication sharedApplication] delegate];
			appDelegate.isLandscapeRight = is_landscape;
			appDelegate.isLandscapeLeft = is_landscape;
		}}}
	}

	public static void allow_landscape_right(bool is_landscape_right) {
		embed {{{
			MyApplicationDelegate *appDelegate = (MyApplicationDelegate *)[[UIApplication sharedApplication] delegate];
			appDelegate.isLandscapeRight = is_landscape_right;
		}}}
	}

	public static void allow_landscape_left(bool is_landscape_left) {
		embed {{{
			MyApplicationDelegate *appDelegate = (MyApplicationDelegate *)[[UIApplication sharedApplication] delegate];
			appDelegate.isLandscapeLeft = is_landscape_left;
		}}}
	}

	public static void allow_potrait_upside_down(bool is_upside_down) {
		embed {{{
			MyApplicationDelegate *appDelegate = (MyApplicationDelegate *)[[UIApplication sharedApplication] delegate];
			appDelegate.isPortraitUpsideDown = is_upside_down;
		}}}
	}
}