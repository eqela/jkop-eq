
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

public class GuiEngine : GUI
{
	public bool is_image_file(File file) {
		if(file == null) {
			return(false);
		}
		return(file.has_extension("png") || file.has_extension("jpg"));
	}

	public RenderableImage create_renderable_image(int w, int h) {
		return(QuartzBitmapImage.create(w,h,false));
	}

	public Image create_image_for_buffer(ImageBuffer ib) {
		if(ib == null) {
			return(null);
		}
		var buffer = ib.get_buffer();
		var type = ib.get_type();
		if(buffer == null) {
			return(null);
		}
		var ptr = buffer.get_pointer().get_native_pointer();
		int sz = buffer.get_size();
		int iw, ih;
		embed "objc" {{{
			NSData* data = [[NSData alloc] initWithBytes:ptr length:sz];
			UIImage* image = [[UIImage alloc] initWithData: data];
			if(image != nil) {
				iw = image.size.width;
				ih = image.size.height;
			}
			
		}}}
		var bm = QuartzBitmapImage.create(iw, ih, false);
		if(bm == null) {
			return(null);
		}
		var qctx = bm.get_context();
		if(qctx == null) {
			return(null);
		}
		embed "objc" {{{
			UIGraphicsPushContext((CGContextRef)qctx);
			[image drawInRect:CGRectMake(0, 0, iw, ih)];
			UIGraphicsPopContext();
		}}}
		return(bm);
	}

	public Image create_image_for_file(File file, int w, int h) {
		if(file == null) {
			return(null);
		}
		var pp = file.get_native_path();
		if(pp == null) {
			return(null);
		}
		var ps = pp.to_strptr();
		if(ps == null) {
			return(null);
		}
		int iw, ih;
		embed "objc" {{{
			NSString* str = [[NSString alloc] initWithUTF8String:ps];
			UIImage* img = [UIImage imageWithContentsOfFile:str];
			if(img != nil) {
				iw = img.size.width;
				ih = img.size.height;
			}
			else {
				return(NULL);
			}
		}}}
		var bm = QuartzBitmapImage.create(iw, ih, false);
		if(bm == null) {
			return(null);
		}
		var qctx = bm.get_context();
		if(qctx == null) {
			return(null);
		}
		embed "objc" {{{
			UIGraphicsPushContext((CGContextRef)qctx);
			[img drawInRect:CGRectMake(0,0,iw,ih)];
			UIGraphicsPopContext();
		}}}
		if(w > 0 || h > 0) {
			return(bm.resize(w, h));
		}
		return(bm);
	}

	File try_icon_path(String epath) {
		File pp;
		if((pp = File.for_eqela_path(epath.append(".png"))).is_file()) {
			return(pp);
		}
		if((pp = File.for_eqela_path(epath.append(".jpg"))).is_file()) {
			return(pp);
		}
		return(null);
	}

	public Image create_image_for_resource(String icon, int w, int h) {
		File f;
		if((f = try_icon_path("/app/".append(icon))) != null) {
			return(create_image_for_file(f, w, h));
		}
		if((f = try_icon_path("/native%s/../Resources/%s".printf()
			.add(File.for_eqela_path("/app").get_native_path())
			.add(icon).to_string())) != null) {
			return(create_image_for_file(f, w, h));
		}
		return(null);
	}

	public Clipboard get_default_clipboard() {
		Log.warning("get_default_clipboard: Not implemented for iOS");
		return(null); // FIXME
	}

	public TextLayout layout_text(TextProperties props, Frame frame, int dpi) {
		return(IOSTextLayout.create(props, frame, dpi));
	}

	embed "objc" {{{
		#import <UIKit/UIKit.h>
		#import <UIKit/UIApplication.h>
	}}}

	public bool open_url(String url) {
		if(url == null) {
			return(false);
		}
		var uptr = url.to_strptr();
		embed "objc" {{{
			NSString* str = [[NSString alloc] initWithUTF8String:uptr];
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
		}}}
		return(true);
	}

	public bool open_file(File file) {
		return(false); // FIXME
	}

	BackgroundTaskManager btm;

	public BackgroundTaskManager get_background_task_manager() {
		if(btm == null) {
			btm = new EventLoopCocoa();
		}
		return(btm);
	}

	embed {{{
		#import "MyApplicationDelegate.h"
		extern int _eq_argc;
		extern char** _eq_argv;
	}}}

	public bool execute(FrameController main, String argv0, Collection args) {
		int r = 0;
		embed "c" {{{
			@autoreleasepool {
				my_application_delegate_frame_controller = (void*)ref_eq_api_Object(main);
				return UIApplicationMain(_eq_argc, _eq_argv, nil, NSStringFromClass([MyApplicationDelegate class]));
			}
		}}}
		return(r);
	}

	public WindowManager get_window_manager() {
		return(new IOSWindowManager());
	}
}
