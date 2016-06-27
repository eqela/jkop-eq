
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

class IOSWindowManager : WindowManager
{
	embed {{{
		#import <UIKit/UIKIt.h>
		#import "EqelaViewController.h"
	}}}

	public WindowManagerScreen get_default_screen() {
		return(null);
	}

	public Collection get_screens() {
		// FIXME: This can still be done. Handle external screens.
		return(null);
	}

	public Frame create_frame(FrameController fc, CreateFrameOptions opts) {
		if(fc == null) {
			return(null);
		}
		ptr pvc = null;
		if(opts != null) {
			var parent = opts.get_parent() as UIKitFrame;
			if(parent != null) {
				pvc = parent.get_view_controller();
				if(pvc != null) {
					embed {{{
						UIViewController *tvc = (__bridge UIViewController*)pvc;
						while (tvc.presentedViewController != nil) {
							tvc = tvc.presentedViewController;
						}
						pvc = (__bridge void*)tvc;
					}}}
				}
			}
		}
		Frame frame;
		bool fs = false;
		if(opts != null) {
			if(opts.get_type() == CreateFrameOptions.TYPE_FULLSCREEN) {
				fs = true;
			}
		}
		ptr popvc;
		embed {{{
			EqelaViewController* evc = [[EqelaViewController alloc] initWithController:fc isPopup:1 isPopupFullScreen:fs];
			popvc = (__bridge void*)evc;
			frame = ref_eq_gui_Frame(evc.frame);
		}}}
		IOSPopupSynchronizer.push_view_controller(pvc, popvc);
		return(frame);
	}
}
