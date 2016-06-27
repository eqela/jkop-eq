
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
	embed "objc" {{{
		#import <AppKit/NSImage.h>
		#import <AppKit/NSGraphicsContext.h>
		#import <AppKit/NSWorkspace.h>
	}}}

	public bool is_image_file(File file) {
		if(file == null) {
			return(false);
		}
		return(file.has_extension("png") || file.has_extension("jpg") || file.has_extension("jpeg"));
	}

	public RenderableImage create_renderable_image(int w, int h) {
		return(QuartzBitmapImage.create(w,h,false));
	}

	public Image create_image_for_buffer(ImageBuffer buffer) {
		if(buffer == null) {
			return(null);
		}
		if("image/x-rgba".equals(buffer.get_type())) {
			var buf = buffer.get_buffer();
			if(buf == null) {
				return(null);
			}
			var ptrdata = buf.get_pointer();
			if(ptrdata == null) {
				return(null);
			}
			var np = ptrdata.get_native_pointer();
			if(np == null) {
				return(null);
			}
			int w = buffer.get_width();
			int h = buffer.get_height();
			ptr img = null;
			embed "objc" {{{
				unsigned char *planes[1];
				planes[0] = (unsigned char *)np;
				NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc]
					initWithBitmapDataPlanes:planes 
					pixelsWide:w
					pixelsHigh:h 
					bitsPerSample:8 
					samplesPerPixel:4 
					hasAlpha:YES
					isPlanar:NO 
					colorSpaceName:NSDeviceRGBColorSpace
					bytesPerRow:w*4
					bitsPerPixel:32];
				NSImage* image = [[NSImage alloc] initWithSize:[bitmap size]];
				[image addRepresentation:bitmap];
				img = (__bridge void *)image;
			}}}
			return(create_image_for_nsimage(img, w, h));
		}
		return(ImageBufferHelper.buffer_to_image(buffer.get_buffer(), buffer.get_type()));
	}

	public Image create_image_for_nsimage(ptr nsimage, int w, int h) {
		if(nsimage == null) {
			return(null);
		}
		int pw = 0, ph = 0;
		embed "objc" {{{
			NSImage* img = (__bridge NSImage*)nsimage;
			if(img == nil) {
				return(NULL);
			}
			for(NSImageRep* rep in [img representations]) {
				int rw = [rep pixelsWide];
				int rh = [rep pixelsHigh];
				if(rw > pw) {
					pw = rw;
				}
				if(rh > ph) {
					ph = rh;
				}
			}
		}}}
		var bm = QuartzBitmapImage.create(pw, ph, false);
		if(bm == null) {
			return(null);
		}
		var qctx = bm.get_context();
		if(qctx == null) {
			return(null);
		}
		embed "objc" {{{
			NSGraphicsContext* gc = [NSGraphicsContext currentContext];
			NSGraphicsContext* mygc = [NSGraphicsContext graphicsContextWithGraphicsPort:(void*)qctx flipped:YES];
			[NSGraphicsContext setCurrentContext:mygc];
			[img drawInRect:CGRectMake(0,0,pw,ph) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0 respectFlipped:YES hints:nil];
			[NSGraphicsContext setCurrentContext:gc];
		}}}
		if(w > 0 || h > 0) {
			return(bm.resize(w, h));
		}
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
		ptr nsimage;
		embed "objc" {{{
			NSImage* img = [[NSImage alloc] initWithContentsOfFile:[[NSString alloc] initWithUTF8String:ps]];
			nsimage = (__bridge void*)img;
		}}}
		return(create_image_for_nsimage(nsimage, w, h));
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
		return(new OSXClipboard());
	}

	public TextLayout layout_text(TextProperties props, Frame frame, int dpi) {
		return(OSXTextLayout.create(props, frame, dpi));
	}

	public bool open_url(String url) {
		if(url == null) {
			return(false);
		}
		var sp = url.to_strptr();
		if(sp == null) {
			return(false);
		}
		embed "objc" {{{
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[NSString alloc] initWithUTF8String:sp]]];
		}}}
		return(true);
	}

	public bool open_file(File file) {
		if(file == null) {
			return(false);
		}
		var fn = file.get_native_path();
		if(fn == null) {
			return(false);
		}
		var sp = fn.to_strptr();
		if(sp == null) {
			return(false);
		}
		bool v = false;
		embed "objc" {{{
			if([[NSWorkspace sharedWorkspace] openFile:[[NSString alloc] initWithUTF8String:sp]] == YES) {
				v = 1;
			}
		}}}
		return(v);
	}

	BackgroundTaskManager btm;

	public BackgroundTaskManager get_background_task_manager() {
		if(btm == null) {
			btm = new EventLoopCocoa();
		}
		return(btm);
	}

	embed "objc" {{{
		#import <Cocoa/Cocoa.h>
		#import "MyApplicationDelegate.h"
	}}}

	public bool execute(FrameController main, String argv0, Collection args) {
		int r = 0;
		var appname = Application.get_display_name();
		if(appname == null) {
			appname = "Application";
		}
		var appnames = appname.to_strptr();
		embed "c" {{{
			[NSApplication sharedApplication];
			{
				NSString* appns = [[NSString alloc] initWithUTF8String:appnames];
				[NSApp setMainMenu:[[NSMenu alloc] initWithTitle:@""]];
				NSMenu* menubar = [NSApp mainMenu];
				NSMenu* appmenu = [[NSMenu alloc] initWithTitle:@""];
				NSMenuItem* appmenuitem = [[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""];
				[appmenu addItemWithTitle:[@"Quit " stringByAppendingString:appns] action:@selector(terminate:) keyEquivalent:@"q"];
				[menubar addItem:appmenuitem];
				[menubar setSubmenu:appmenu forItem:appmenuitem];
			}
			MyApplicationDelegate* ad = [[MyApplicationDelegate alloc] init];
			ad.controller = (void*)ref_eq_api_Object(main);
			[NSApp setDelegate:ad];
			[NSApp run];
		}}}
		return(r);
	}

	public WindowManager get_window_manager() {
		return(new OSXWindowManager());
	}
}
