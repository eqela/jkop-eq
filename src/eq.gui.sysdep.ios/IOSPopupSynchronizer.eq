
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

public class IOSPopupSynchronizer
{
	embed {{{
		#import <UIKit/UIKIt.h>
		#import <eq.gui.sysdep.ios/EqelaViewController.h>
	}}}

	static int in_progress = 0;
	static Queue queue;

	class PushItem
	{
		public ptr pvc;
		public ptr controller;
	}

	class PopItem
	{
		public ptr vc;
	}

	public static void push_view_controller(ptr apvc, ptr controller) {
		if(controller == null) {
			return;
		}
		var pvc = apvc;
		if(in_progress > 0) {
			if(queue == null) {
				queue = Queue.create();
			}
			var qi = new PushItem();
			embed {{{
				UIViewController *_controller = (__bridge UIViewController*)controller;
				(__bridge_retained void*)_controller;
				if(pvc != nil) {
					UIViewController *_pvc = (__bridge UIViewController*)pvc;
					(__bridge_retained void*)_pvc;
				}
			}}}
			qi.pvc = pvc;
			qi.controller = controller;
			queue.push(qi);
			return;
		}
		if(pvc == null) {
			embed {{{
				UIWindow *window = [UIApplication sharedApplication].keyWindow;
				UIViewController *rootViewController = window.rootViewController;
				while (rootViewController.presentedViewController) {
					rootViewController = rootViewController.presentedViewController;
				}
				pvc = (__bridge void*)rootViewController;
			}}}
		}
		embed {{{
			UIViewController* evc = (__bridge UIViewController*)controller;
			UIViewController* pvcc = (__bridge UIViewController*)pvc;
			[pvcc presentViewController:evc animated:YES completion:^{
				eq_gui_sysdep_ios_IOSPopupSynchronizer_on_animation_ended();
			}];
			if([pvcc presentedViewController] == evc) {
				}}}
				on_animation_started();
				embed {{{
			}
			else {
				}}}
				Log.error("FAILED to present the view controller.");
				embed {{{
			}
		}}}
	}

	public static void pop_view_controller(ptr vc) {
		if(vc == null) {
			return;
		}
		if(in_progress > 0) {
			if(queue == null) {
				queue = Queue.create();
			}
			var qi = new PopItem();
			embed {{{
				UIViewController *_vc = (__bridge UIViewController*)vc;
				(__bridge_retained void*)_vc;
			}}}
			qi.vc = vc;
			queue.push(qi);
			return;
		}
		embed {{{
			UIViewController* uivc = (__bridge UIViewController*)vc;
			// Check if this view controller (the one to be dismissed) has children.
			// If it has children, then dismissViewControllerAnimated will behave differently:
			// It will not dismiss the view controller itself but its children, but leaves this
			// view controller in place. (NOTE: This is as of iOS 8. May change as Apple may choose
			// to change it)
			if([uivc presentedViewController] != nil) {
				// For EqelaViewController, just mark it as automatically closing
				// whenever the stack reaches it again.
				if([uivc isKindOfClass:[EqelaViewController class]]) {
					EqelaViewController* evc = (EqelaViewController*)uivc;
					evc.closeOnAppear = YES;
				}
				// For non-EqelaViewController, we just don't know of any way to close it without
				// closing all of its children. So we leave it be.
				else {
					}}}
					Log.warning("Trying to dismiss view controller 0x%x that has a child but is not EqelaViewController. Ignoring it."
						.printf().add((int)vc));
					embed {{{
				}
				dispatch_after(0, dispatch_get_main_queue(), ^{
					eq_gui_sysdep_ios_IOSPopupSynchronizer_try_process_queue();
				});
			}
			else if([uivc presentingViewController] == nil) {
				}}}
				Log.warning("Trying to dismiss view controller 0x%x that has not been presented.".printf().add((int)vc));
				embed {{{
			}
			else {
				}}}
				on_animation_started();
				embed {{{
				[uivc dismissViewControllerAnimated:YES completion:^{
					eq_gui_sysdep_ios_IOSPopupSynchronizer_on_animation_ended();
				}];
			}
		}}}
	}

	public static void on_animation_started() {
		in_progress++;
	}

	public static void on_animation_ended() {
		in_progress --;
		embed {{{
			dispatch_after(0, dispatch_get_main_queue(), ^{
				eq_gui_sysdep_ios_IOSPopupSynchronizer_try_process_queue();
			});
		}}}
	}

	public static void try_process_queue() {
		if(in_progress < 1 && queue != null && queue.count() > 0) {
			var qi = queue.pop();
			if(qi == null) {
			}
			else if(qi is PushItem) {
				var pvc = ((PushItem)qi).pvc;
				var controller = ((PushItem)qi).controller;
				push_view_controller(pvc, controller);
				embed {{{
					if(pvc != nil) {
						(__bridge_transfer UIViewController*)pvc;
					}
					(__bridge_transfer UIViewController*)controller;
				}}}
			}
			else if(qi is PopItem) {
				var vc = ((PopItem)qi).vc;
				pop_view_controller(vc);
				embed {{{
					(__bridge_transfer UIViewController*)vc;
				}}}
			}
		}
	}
}
