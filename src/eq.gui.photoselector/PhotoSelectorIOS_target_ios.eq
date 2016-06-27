
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

public class PhotoSelectorIOS
{
	embed {{{
		#import <UIKit/UIKit.h>
		#import <AssetsLibrary/AssetsLibrary.h>

		@interface ImagePickerController : UIViewController <UIImagePickerControllerDelegate>
		@property void* selector;
		@end

		@implementation ImagePickerController

		- (void) imagePickerController : (UIImagePickerController*) picker didFinishPickingMediaWithInfo : (NSDictionary*) info
		{
			NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
			ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
			{
				ALAssetRepresentation *representation = [myasset defaultRepresentation];
				NSString *filename = [representation filename];
				UIImage* image = [info valueForKey:UIImagePickerControllerOriginalImage];
				eq_gui_photoselector_PhotoSelectorIOS_image_picker_event_delegate(self.selector, (__bridge void*)image, (__bridge void*)picker, [filename UTF8String]);
				[self dismissViewControllerAnimated:YES completion:nil];
				unref_eq_api_Object(self.selector);
			};
			ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
			[assetslibrary assetForURL:imageURL 
				resultBlock:resultblock
				failureBlock:nil];
		}
		@end
	}}}

	property EventReceiver listener;

	public void image_picker_event_delegate(ptr img, ptr picker, ptr filename) {
		var r = new PhotoSelectorResult();
		int iw, ih;
		embed {{{
			UIImage* uiimage = (__bridge UIImage*)img;
			if(uiimage != nil) {
				iw = uiimage.size.width;
				ih = uiimage.size.height;
			}
		}}}
		var bm = QuartzBitmapImage.create(iw, ih, false);
		if(bm != null) {
			var qctx = bm.get_context();
			if(qctx != null) {
				embed "objc" {{{
					UIGraphicsPushContext((CGContextRef)qctx);
					[uiimage drawInRect:CGRectMake(0,0,iw,ih)];
					UIGraphicsPopContext();
				}}}
				r.set_image(bm);
			}
		}
		r.set_filename(String.for_strptr(filename).dup());
		EventReceiver.event(listener, r);
	}

	public bool execute(Frame frm) {
		ptr vc = null;
		if(frm != null && frm is UIKitFrame) {
			vc = ((UIKitFrame)frm).get_view_controller();
		}
		if(vc == null) {
			embed {{{
				UIWindow *window = [UIApplication sharedApplication].keyWindow;
				UIViewController *rootViewController = window.rootViewController;
				vc = (__bridge void*)rootViewController;
			}}}
		}
		embed {{{
			ref_eq_api_Object(self);
			UIViewController* vv = (__bridge UIViewController*)vc;
			ImagePickerController* ipc = [[ImagePickerController alloc] init];
			[vv addChildViewController:ipc];
			ipc.selector = self;
			UIImagePickerController *picker = [[UIImagePickerController alloc] init];
			picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			picker.delegate = ipc;
			[ipc presentViewController:picker animated:YES completion:nil];
		}}}
		return(true);
	}
}

