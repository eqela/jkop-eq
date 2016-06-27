
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

class IOSAdMobInterstitialAdView
{
	embed {{{
		#import <Foundation/Foundation.h>
		#import <UIKit/UIKit.h>
		#import "GoogleMobileAds/GADInterstitial.h"
		#import "GoogleMobileAds/GADInterstitialDelegate.h"

		static GADInterstitial* interstitial;

		@interface IOSAdMobInterstitialDelegate : NSObject <GADInterstitialDelegate>
		@property UIViewController* ad_placeholder;
		@end

		@implementation IOSAdMobInterstitialDelegate
		-(void)interstitialDidDismissScreen:(GADInterstitial*) interstitial {
			[_ad_placeholder willMoveToParentViewController:nil];
			[_ad_placeholder dismissViewControllerAnimated:YES completion:nil];
			[_ad_placeholder.view removeFromSuperview];
			[_ad_placeholder removeFromParentViewController];
		}
		@end
	}}}

	public static bool initialize_interstitial(String id, Collection test_devs) {
		if(String.is_empty(id)) {
			return(false);
		}
		var idptr = id.to_strptr();
		embed {{{
			interstitial = [[GADInterstitial alloc] init];
			interstitial.adUnitID = [[NSString alloc] initWithUTF8String:idptr];
			GADRequest* request = [[GADRequest alloc] init];
			NSMutableArray* dev_list = [[NSMutableArray alloc] init];
		}}}
		foreach(String dev in test_devs) {
			var devptr = dev.to_strptr();
			embed {{{
				[dev_list addObject:[[NSString alloc] initWithUTF8String:devptr]];
			}}}
		}
		embed {{{
			request.testDevices = dev_list;
			[interstitial loadRequest:request];
		}}}
		return(true);
	}

	public static void show_interstitial(Frame frame = null) {
		var f = frame as UIKitFrame;
		if(f == null) {
			return;
		}
		var uv = ((UIKitFrame)f).get_view_controller();
		embed {{{
			if(interstitial != nil) {
				if([interstitial isReady]) {
					IOSAdMobInterstitialDelegate* del = [[IOSAdMobInterstitialDelegate alloc] init];
					UIViewController* view_controller = (__bridge UIViewController*)uv;
					UIViewController* placeholder = [[UIViewController alloc] init];
					[view_controller addChildViewController:placeholder];
					del.ad_placeholder = placeholder;
					interstitial.delegate = del;
					[interstitial presentFromRootViewController:view_controller];
					interstitial = nil;
				}
			}
		}}}
	}
}
