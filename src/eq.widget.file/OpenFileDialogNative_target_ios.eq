
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

class OpenFileDialogNative
{
	static OpenFileDialogListener listener;

	embed {{{
		#import <UIKit/UIKit.h>
		#import <MediaPlayer/MediaPlayer.h>
		#import <MobileCoreServices/MobileCoreServices.h>
		#import <AVFoundation/AVFoundation.h>	
		
		@interface VideoPickerController : UIViewController <UIImagePickerControllerDelegate>
		@property void* myself;
		@property id<UIImagePickerControllerDelegate> delegate;
		@end

		@implementation VideoPickerController
		- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
			NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
			if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
				NSURL *videoUrl = (NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
				NSString *moviePath = [videoUrl path];
				eq_widget_file_OpenFileDialogNative_on_file_selected(self.myself, [moviePath UTF8String]);
			}
			[self dismissViewControllerAnimated:YES completion:nil];
		}
		@end
	}}}

	public void on_file_selected(ptr url) {
		if(listener != null) {
			listener.on_open_file_dialog_ok(File.for_native_path(String.for_strptr(url)));
		}
	}

	public static bool execute(Frame frame, File directory, String filter, bool choose_directories, OpenFileDialogListener listen) {
		listener = listen;
		ptr vc;
		if(frame is UIKitFrame) {
			vc = ((UIKitFrame)frame).get_view_controller();
		}
		if(vc == null) {
			Log.error("Unable to get UIViewController");
			return(false);
		}
		embed {{{
			UIViewController* vv = (__bridge UIViewController*)vc;
			VideoPickerController* vpc = [[VideoPickerController alloc] init];
			[vv addChildViewController:vpc];
			UIImagePickerController *picker = [[UIImagePickerController alloc] init];
			picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
			picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			picker.delegate = vpc;
			[vpc presentViewController:picker animated:YES completion:nil];
		}}}
		return(true);
	}
}
