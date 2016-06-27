
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

public class CameraIOS
{
	embed {{{
		#import <UIKit/UIKit.h>

		@interface CameraController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
		@property void* myself;
		@end

		@implementation CameraController
		- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
			UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
			eq_gui_camera_CameraIOS_camera_event_delegate(self.myself, (__bridge void*)image);
			[picker dismissViewControllerAnimated:YES completion:NULL];
			unref_eq_api_Object(self.myself);
		}

		- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
			[picker dismissViewControllerAnimated:YES completion:NULL];
		}
		@end
	}}}

	property EventReceiver listener;

	public void camera_event_delegate(ptr img) {
		var r = new CameraResult();
		if(img == null) {
			return;
		}
		int iw, ih;
		embed {{{
			UIImage* uiimage = (__bridge UIImage*)img;
			if(uiimage != nil) {
				iw = uiimage.size.width;
				ih = uiimage.size.height;
			}
		}}}
		var bm = QuartzBitmapImage.create(iw, ih, false);
		if(bm == null) {
			return;
		}
		var qctx = bm.get_context();
		if(qctx == null) {
			return;
		}
		embed "objc" {{{
			UIGraphicsPushContext((CGContextRef)qctx);
			[uiimage drawInRect:CGRectMake(0,0,iw,ih)];
			UIGraphicsPopContext();
		}}}
		r.set_image(bm);
		EventReceiver.event(listener, r);
	}

	public bool execute(Frame frame) {
		var frm = frame;
		if(frm == null) {
			return(false);
		}
		ptr vc;
		if(frm is UIKitFrame) {
			vc = ((UIKitFrame)frm).get_view_controller();
		}
		if(vc == null) {
			Log.error("Unable to get UIViewController");
			return(false);
		}
		embed {{{
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
				ref_eq_api_Object(self);
				CameraController* cc = [[CameraController alloc] init];
				cc.myself = self;
				UIViewController* vv = (__bridge UIViewController*)vc;
				[vv addChildViewController:cc];
				UIImagePickerController *picker = [[UIImagePickerController alloc] init];
				picker.delegate = cc;
				picker.allowsEditing = NO;
				picker.sourceType = UIImagePickerControllerSourceTypeCamera;
				picker.modalPresentationStyle = UIModalPresentationFullScreen;
				[cc presentViewController:picker animated:YES completion:NULL];
				return(true);
			}
		}}}
		return(false);
	}
}
