
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

class IOSAdMobView
{
	embed {{{
		#import <Foundation/Foundation.h>
		#import <UIKit/UIKit.h>
		#import "GoogleMobileAds/GADBannerView.h"
	}}}
	
	public static bool apply_to_frame(Frame aframe, String id, Collection test_devices) {
		var frame = aframe as UIKitFrame;
		if(frame == null || String.is_empty(id)) {
			return(false);
		}
		var rvc = frame.get_view_controller();
		var idc = id.to_strptr();
		ptr bb;
		embed {{{
			GADBannerView* banner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape]; // FIXME: ORIENTATION
			banner.adUnitID = [[NSString alloc] initWithUTF8String:idc];
			banner.rootViewController = (__bridge UIViewController*)rvc;
			bb = (__bridge_retained void*)banner;
		}}}
		frame.set_bottom_element(bb);
		embed {{{
			GADRequest* req = [GADRequest request];
			NSMutableArray* aa = [[NSMutableArray alloc] init];
		}}}
		foreach(String device in test_devices) {
			var dc = device.to_strptr();
			embed {{{
				[aa addObject:[[NSString alloc] initWithUTF8String:dc]];
			}}}
		}
		embed {{{
			req.testDevices = aa;
			[banner loadRequest:req];
		}}}
		return(true);
	}

	public static void remove_from_frame(Frame frame) {
	}
}
