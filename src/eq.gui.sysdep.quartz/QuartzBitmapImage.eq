
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

public class QuartzBitmapImage : Size, Image, Renderable, RenderableImage, VgRenderable, VgRenderableImage
{
	embed "c" {{{
		#include <CoreGraphics/CGContext.h>
		#include <CoreGraphics/CGBitmapContext.h>
	}}}

	IFDEF("target_osx") {
		embed {{{
			#import <Cocoa/Cocoa.h>
		}}}
	}

	IFDEF("target_ios") {
		embed {{{
			#import <UIKit/UIKit.h>
		}}}
	}

	public static QuartzBitmapImage create(int w, int h, bool flip = true) {
		var v = new QuartzBitmapImage();
		if(v.initialize(w, h, flip) == false) {
			v = null;
		}
		return(v);
	}

	property ptr context;
	ptr imageref;

	public ~QuartzBitmapImage() {
		release();
	}

	public ptr get_imageref() {
		if(imageref == null) {
			update_imageref();
		}
		return(imageref);
	}

	public bool initialize(int w, int h, bool flip) {
		release();
		ptr c;
		embed "c" {{{
			CGColorSpaceRef colorspace;
		}}}
		IFDEF("target_osx") {
			embed "c" {{{
				colorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
			}}}
		}
		ELSE IFDEF("target_ios") {
			embed "c" {{{
				colorspace = CGColorSpaceCreateDeviceRGB();
			}}}
		}
		embed "c" {{{
			CGContextRef ctx = CGBitmapContextCreate(NULL, (size_t)w, (size_t)h, (size_t)8, (size_t)0, colorspace, kCGImageAlphaPremultipliedLast);
			c = (void*)ctx;
			if(flip && ctx != nil) {
				CGContextTranslateCTM(ctx, 0.0f, h);
				CGContextScaleCTM(ctx, 1.0f, -1.0f);
			}
			CGColorSpaceRelease(colorspace);
		}}}
		this.context = c;
		return(c != null);
	}

	public double get_width() {
		if(context == null) {
			return(0);
		}
		double v;
		var c = context;
		embed "c" {{{
			v = (double)CGBitmapContextGetWidth((CGContextRef)c);
		}}}
		return(v);
	}

	public double get_height() {
		if(context == null) {
			return(0);
		}
		double v;
		var c = context;
		embed "c" {{{
			v = (double)CGBitmapContextGetHeight((CGContextRef)c);
		}}}
		return(v);
	}

	public void release() {
		if(imageref != null) {
			var imageref = this.imageref;
			embed {{{
				CGImageRelease((CGImageRef)imageref);
			}}}
			this.imageref = null;
		}
		if(context == null) {
			return;
		}
		var c = context;
		embed "c" {{{
			CGContextRelease((CGContextRef)c);
		}}}
		context = null;
	}

	public Image resize(int w, int h) {
		if(w == get_width() && h == get_height()) {
			return(this);
		}
		if(w < 0 && h < 0) {
			return(this);
		}
		int tw = w, th = h;
		if(tw < 0 && th >= 0) {
			tw = (int)((double)get_width() / ((double)get_height() / (double)th));
		}
		if(th < 0 && tw >= 0) {
			th = (int)((double)get_height() / ((double)get_width() / (double)tw));
		}
		var bm = QuartzBitmapImage.create(tw, th, false);
		if(bm == null) {
			return(this);
		}
		var qctx = bm.get_context();
		if(qctx == null) {
			return(null);
		}
		var myimgref = get_imageref();
		embed "c" {{{
			CGContextDrawImage((CGContextRef)qctx, CGRectMake(0,0,tw,th), (CGImageRef)myimgref);
		}}}
		bm.update_imageref();
		return(bm);
	}

	public Image crop(int x, int y, int w, int h) {
		var bm = QuartzBitmapImage.create(w, h, false);
		if(bm == null) {
			return(null);
		}
		var vg = bm.get_vg_context();
		if(vg == null) {
			return(null);
		}
		vg.draw_graphic(-x, -y, null, this);
		bm.update_imageref();
		return(bm);
	}

	public Image flipme() {
		var tw = get_width(), th = get_height();
		var bm = QuartzBitmapImage.create(tw, th, true);
		if(bm == null) {
			return(this);
		}
		var qctx = bm.get_context();
		if(qctx == null) {
			return(null);
		}
		var myimgref = get_imageref();
		embed "c" {{{
			CGContextDrawImage((CGContextRef)qctx, CGRectMake(0,0,tw,th), (CGImageRef)myimgref);
		}}}
		bm.update_imageref();
		return(bm);
	}

	public ptr as_nsimage() {
		ptr v;
		IFDEF("target_osx") {
			var flipped = flipme() as QuartzBitmapImage;
			if(flipped == null) {
				return(null);
			}
			var ir = flipped.get_imageref();
			if(ir == null) {
				return(null);
			}
			ptr buf;
			int buflen;
			int width = (int)get_width();
			int height = (int)get_height();
			embed {{{
				NSImage* nsimg = [[NSImage alloc] initWithCGImage:(CGImageRef)ir size:CGSizeMake(width, height)];
				v = (__bridge_retained void*)nsimg;
			}}}
		}
		return(v);
	}

	public ptr as_uiimage() {
		ptr v;
		IFDEF("target_ios") {
			var flipped = flipme() as QuartzBitmapImage;
			if(flipped == null) {
				return(null);
			}
			var ir = flipped.get_imageref();
			if(ir == null) {
				return(null);
			}
			ptr buf;
			int buflen;
			int width = (int)get_width();
			int height = (int)get_height();
			embed {{{
				UIImage *img = [[UIImage alloc] initWithCGImage:(CGImageRef)ir];
				v = (__bridge_retained void*)img;
			}}}
		}
		return(v);
	}

	public Buffer encode(String type) {
		if("image/jpeg".equals(type)) {
			return(encode_jpeg());
		}
		if("image/png".equals(type)) {
			return(encode_png());
		}
		if("image/x-rgba32".equals(type)) {
			return(encode_rgba32());
		}
		return(null);
	}

	Buffer encode_rgba32() {
		var flipped = flipme() as QuartzBitmapImage;
		if(flipped == null) {
			return(null);
		}
		var ctx = flipped.get_context();
		if(ctx == null) {
			return(null);
		}
		ptr data;
		embed {{{
			data = CGBitmapContextGetData((CGContextRef)ctx);
		}}}
		if(data == null) {
			return(null);
		}
		var datalen = flipped.get_width() * flipped.get_height() * 4;
		var bb = Buffer.for_pointer(Pointer.create(data), datalen);
		if(bb == null) {
			return(null);
		}
		return(Buffer.dup(bb));
	}

	Buffer encode_jpeg() {
		var flipped = flipme() as QuartzBitmapImage;
		if(flipped == null) {
			return(null);
		}
		var ir = flipped.get_imageref();
		if(ir == null) {
			return(null);
		}
		ptr buf;
		int buflen;
		IFDEF("target_osx") {
			embed {{{
				NSBitmapImageRep* bmr = [[NSBitmapImageRep alloc] initWithCGImage:(CGImageRef)ir];
				NSData* data = [bmr representationUsingType:NSJPEGFileType properties:nil];
				if(data != nil) {
					buf = [data bytes];
					buflen = (int)[data length];
				}
			}}}
		}
		IFDEF("target_ios") {
			embed {{{
				UIImage *img = [[UIImage alloc] initWithCGImage:(CGImageRef)ir];				
				NSData *data = UIImageJPEGRepresentation(img, 1);
				if(data != nil) {
					buf = [data bytes];
					buflen = (int)[data length];
				}
			}}}
		}
		if(buf == null || buflen < 1) {
			return(null);
		}
		var bb = Buffer.for_pointer(Pointer.create(buf), buflen);
		if(bb == null) {
			return(null);
		}
		return(Buffer.dup(bb));
	}

	Buffer encode_png() {
		var flipped = flipme() as QuartzBitmapImage;
		if(flipped == null) {
			return(null);
		}
		var ir = flipped.get_imageref();
		if(ir == null) {
			return(null);
		}
		ptr buf;
		int buflen;
		IFDEF("target_osx") {
			embed {{{
				NSBitmapImageRep* bmr = [[NSBitmapImageRep alloc] initWithCGImage:(CGImageRef)ir];
				NSData* data = [bmr representationUsingType:NSPNGFileType properties:nil];
				if(data != nil) {
					buf = [data bytes];
					buflen = (int)[data length];
				}
			}}}
		}
		IFDEF("target_ios") {
			embed {{{
				UIImage *img = [[UIImage alloc] initWithCGImage:(CGImageRef)ir];				
				NSData *data = UIImagePNGRepresentation(img);
				if(data != nil) {
					buf = [data bytes];
					buflen = (int)[data length];
				}
			}}}
		}
		if(buf == null || buflen < 1) {
			return(null);
		}
		var bb = Buffer.for_pointer(Pointer.create(buf), buflen);
		if(bb == null) {
			return(null);
		}
		return(Buffer.dup(bb));
	}

	public void update_imageref() {
		var thisctx = context;
		ptr imageref = this.imageref;
		embed {{{
			if(imageref != NULL) {
				CGImageRelease((CGImageRef)imageref);
			}
			CGImageRef imgref = CGBitmapContextCreateImage((CGContextRef)thisctx);
			imageref = (void*)imgref;
		}}}
		this.imageref = imageref;
	}

	public void render(Collection ops) {
		var ctx = get_vg_context();
		VgRenderer.render_to_vg_context(ops, ctx);
		update_imageref();
	}

	public VgContext get_vg_context() {
		return(QuartzVgContext.for_context(context, 1.0));
	}
}
