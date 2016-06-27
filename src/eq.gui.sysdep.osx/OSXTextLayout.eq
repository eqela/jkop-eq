
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

public class OSXTextLayout : TextLayout, Size, ImageTextLayout, QuartzContextTextLayout
{
	embed "objc" {{{
		#import <AppKit/NSFont.h>
		#import <AppKit/NSText.h>
		#import <AppKit/NSAttributedString.h>
		#import <AppKit/NSStringDrawing.h>
		#import <AppKit/NSTextAttachment.h>
		#import <AppKit/NSColor.h>
		#import <AppKit/NSGraphicsContext.h>
		#import <AppKit/NSWindow.h>
	}}}

	TextProperties props;
	String fontname;
	double width;
	double height;
	ptr fontptr;
	Image image;
	Frame frame;
	int dpi;

	public static OSXTextLayout create(TextProperties props, Frame frame, int dpi) {
		var v = new OSXTextLayout();
		v.props = props;
		v.frame = frame;
		v.dpi = dpi;
		if(v.init_layout() == false) {
			return(null);
		}
		return(v);
	}

	~OSXTextLayout() {
		if(fontptr != null) {
			var fptr = fontptr;
			fontptr = null;
			embed "objc" {{{
				NSFont* uf = (__bridge_transfer NSFont*)fptr;
			}}}
		}
	}

	public double get_scale_factor() {
		double multiplier = 1.0;
		if(frame is NSWindowFrame) {
			var nsw = ((NSWindowFrame)frame).get_nswindow();
			if(nsw != null) {
				embed "objc" {{{
					multiplier = (double)[(__bridge NSWindow*)nsw backingScaleFactor];
				}}}
			}
		}
		return(multiplier);
	}

	String translate_font_name(String afontname) {
		var fontname = afontname;
		if(fontname != null && (fontname.has_suffix(".ttf") || fontname.has_suffix(".otf"))) {
			fontname = fontname.substring(0, fontname.get_length()-4).replace_char('_', ' ');
		}
		if("sans".equals_ignore_case(fontname)) {
			return("Arial");
		}
		else if("serif".equals_ignore_case(fontname)) {
			return("Times-Roman");
		}
		else if("monospace".equals_ignore_case(fontname)) {
			return("Menlo");
		}
		return(fontname);
	}

	bool init_layout() {
		if(props == null) {
			return(false);
		}
		int dpi = 96;
		if(frame != null) {
			dpi = frame.get_dpi();
		}
		if(this.dpi > 0) {
			dpi = this.dpi;
		}
		var proptext = props.get_text();
		if(proptext == null) {
			return(false);
		}
		var is_empty = false;
		if(String.is_empty(proptext)) {
			// The OS X API computes the size of an empty string wrong (it's about half of the height of what it should be)
			is_empty = true;
			proptext = "XgjyPl";
		}
		fontname = "Arial";
		int fontsize = 12;
		bool font_bold = false;
		bool font_italic = false;
		var font = props.get_font();
		if(font != null) {
			fontname = translate_font_name(font.get_name());
			fontsize = Length.to_pixels(font.get_size(), dpi);
			font_bold = font.is_bold();
			font_italic = font.is_italic();
		}
		var sf = get_scale_factor();
		fontsize = fontsize; // * sf;
		var fontnameptr = fontname.to_strptr();
		var textptr = proptext.to_strptr();
		int wrapwidth = props.get_wrap_width();
		double width, height;
		ptr fptr = null;
		int traits = 0;
		if(font_bold) {
			embed "objc" {{{
				traits |= NSBoldFontMask;
			}}}
		}
		if(font_italic) {
			embed "objc" {{{
				traits |= NSItalicFontMask;
			}}}
		}
		int alignment = props.get_alignment();
		embed "objc" {{{
			NSString* fontnameoc = [[NSString alloc] initWithUTF8String:fontnameptr];
			if(fontnameoc == nil) {
				fontnameoc = @"Arial";
			}
			NSFontManager* fontmgr = [NSFontManager sharedFontManager];
			NSFont* fffont = [fontmgr fontWithFamily:fontnameoc traits:traits weight:0 size:fontsize];
			if(fffont == nil) {
				if([fontnameoc isEqualToString:@"Menlo"]) {
					fffont = [NSFont fontWithName:@"Monaco" size:fontsize];
				}
				if(fffont == nil) {
					fffont = [NSFont fontWithName:@"Arial" size:fontsize];
				}
			}
			NSString* str = [[NSString alloc] initWithUTF8String:textptr];
			if(str == nil) {
				str = @"XgjyPl";
				is_empty = 1;
			}
			NSMutableDictionary* attributes = [[NSMutableDictionary alloc] init];
			[attributes setObject:fffont forKey:NSFontAttributeName];
			[attributes setObject:[NSColor colorWithDeviceRed:(CGFloat)0.0 green:(CGFloat)0.0 blue:(CGFloat)0.0 alpha:(CGFloat)1.0] forKey:NSForegroundColorAttributeName];
			NSMutableParagraphStyle* ps = [[NSMutableParagraphStyle alloc] init];
			if(alignment == 1) {
				[ps setAlignment:NSCenterTextAlignment];
			}
			else if(alignment == 2) {
				[ps setAlignment:NSRightTextAlignment];
			}
			else {
				[ps setAlignment:NSNaturalTextAlignment];
			}
			[attributes setObject:ps forKey:NSParagraphStyleAttributeName];
			fptr = (__bridge_retained void*)fffont;
		}}}
		this.fontptr = fptr;
		if(wrapwidth > 0) {
			embed "objc" {{{
				NSSize sz;
				sz.width = wrapwidth;
				sz.height = 0;
				NSRect nsz = [[[NSAttributedString alloc] initWithString:str attributes:attributes] boundingRectWithSize:sz options:NSStringDrawingUsesLineFragmentOrigin];
				width = nsz.size.width + 4;
				height = nsz.size.height;
			}}}
		}
		else {
			embed "objc" {{{
				CGSize sz = [[[NSAttributedString alloc] initWithString:str attributes:attributes] size];
				width = sz.width + 4;
				height = sz.height;
			}}}
		}
		if(is_empty) {
			width = 0;
		}
		this.width = width;
		this.height = height;
		this.fontptr = fptr;
		return(true);
	}

	public double get_width() {
		return(width);
	}

	public double get_height() {
		return(height);
	}

	public void draw_in_context(ptr contextp, int drawx, int drawy) {
		do_draw_in_context(contextp, drawx, drawy, true);
	}

	void do_draw_in_context(ptr contextp, int drawx, int drawy, bool flip) {
		var props = get_text_properties();
		if(props == null) {
			return;
		}
		var proptext = props.get_text();
		if(proptext == null) {
			return;
		}
		var textcolor = props.get_color();
		var outlinecolor = props.get_outline_color();
		double fcr, fcg, fcb, fca;
		if(textcolor != null) {
			fcr = textcolor.get_r();
			fcg = textcolor.get_g();
			fcb = textcolor.get_b();
			fca = textcolor.get_a();
		}
		int alignment = props.get_alignment();
		var textptr = proptext.to_strptr();
		var fptr = fontptr;
		embed "objc" {{{
			NSFontManager* fontmgr = [NSFontManager sharedFontManager];
			NSFont* ofont = (__bridge NSFont*)fptr;
			NSFont* fffont = ofont;
		}}}
		int ww = get_width(), hh = get_height();
		embed "objc" {{{
			NSString* str = [[NSString alloc] initWithUTF8String:textptr];
			if(str == nil) {
				str = @"";
			}
			NSMutableDictionary* attributes = [[NSMutableDictionary alloc] init];
			[attributes setObject:fffont forKey:NSFontAttributeName];
			[attributes setObject:[NSColor colorWithDeviceRed:(CGFloat)fcr green:(CGFloat)fcg blue:(CGFloat)fcb alpha:(CGFloat)fca] forKey:NSForegroundColorAttributeName];
			NSMutableParagraphStyle* ps = [[NSMutableParagraphStyle alloc] init];
			if(alignment == 1) {
				[ps setAlignment:NSCenterTextAlignment];
			}
			else if(alignment == 2) {
				[ps setAlignment:NSRightTextAlignment];
			}
			else {
				[ps setAlignment:NSNaturalTextAlignment];
			}
			[attributes setObject:ps forKey:NSParagraphStyleAttributeName];
		}}}
		if(outlinecolor != null) {
			double ocr = outlinecolor.get_r(), ocg = outlinecolor.get_g(),
				ocb = outlinecolor.get_b(), oca = outlinecolor.get_a();
			embed "c" {{{
				[attributes setObject:[NSColor colorWithDeviceRed:(CGFloat)ocr green:(CGFloat)ocg blue:(CGFloat)ocb alpha:(CGFloat)oca] forKey:NSStrokeColorAttributeName];
				[attributes setObject:[NSNumber numberWithFloat:-3.0] forKey:NSStrokeWidthAttributeName];
			}}}
		}
		embed "objc" {{{
			NSAttributedString* as = [[NSAttributedString alloc] initWithString:str attributes:attributes];
			NSGraphicsContext* gc = [NSGraphicsContext currentContext];
			NSGraphicsContext* mygc = [NSGraphicsContext graphicsContextWithGraphicsPort:(void*)contextp flipped:flip ? YES : NO];
			[NSGraphicsContext setCurrentContext:mygc];
		}}}
		int wrapwidth = props.get_wrap_width();
		if(wrapwidth > 0) {
			embed "objc" {{{
				NSRect sz;
				sz.origin.x = drawx;
				sz.origin.y = drawy;
				sz.size.width = ww;
				sz.size.height = hh;
				[as drawInRect:sz];
			}}}
		}
		else {
			embed "objc" {{{
				NSPoint sz;
				sz.x = drawx;
				sz.y = drawy;
				[as drawAtPoint:sz];
			}}}
		}
		embed "objc" {{{
			[NSGraphicsContext setCurrentContext:gc];
		}}}
	}

	public bool is_image_prepared() {
		if(image != null) {
			return(true);
		}
		return(false);
	}

	public Image get_image() {
		if(image == null) {
			var w = width, h = height;
			var image = QuartzBitmapImage.create(w, h) as VgRenderableImage;
			if(image != null) {
				var vc = image.get_vg_context();
				if(vc != null && vc is QuartzVgContext) {
					do_draw_in_context(((QuartzVgContext)vc).get_context(), 0, 0, false);
				}
				this.image = image;
			}
		}
		return(image);
	}

	public TextProperties get_text_properties() {
		return(props);
	}

	public Rectangle get_cursor_position(int index) {
		if(props == null) {
			return(Rectangle.instance(0, 0, 2, 12));
		}
		var tptr = props.get_text();
		if(tptr == null ||tptr.equals("")) {
			return(Rectangle.instance(0, 0, 2, 12));
		}
		var ttptr = tptr.to_strptr();
		int ww = props.get_wrap_width();
		int xcoord = 0;
		var fptr = fontptr;
		embed "objc" {{{
			NSString * astr = [[NSString alloc] initWithUTF8String:ttptr];
			if(astr == nil) {
				astr = @"";
			}
			NSString * cstr = [astr substringToIndex:index];
			NSFont * fffont = (__bridge NSFont*)fptr;
			NSDictionary* attributes = @{ NSFontAttributeName : fffont };
			xcoord = [[[NSAttributedString alloc] initWithString:cstr attributes:attributes] size].width;
		}}}
		return(Rectangle.instance(xcoord, 0, 1, height));
	}

	public int xy_to_index(double x, double y) {
		if(props == null) {
			return(0);
		}
		var s = props.get_text();
		if(s == null) {
			return(0);
		}
		int index = 0;
		int w = 0, counter = 0;
		var fptr = fontptr;
		embed "objc" {{{
			NSFont * fffont = (__bridge NSFont*)fptr;
			NSDictionary* attributes = @{ NSFontAttributeName : fffont };
		}}}
		int tw = 0;
		for(counter = 0; counter < s.get_length(); counter++) {
			var ss = s.substring(0,counter);
			var sptr = ss.to_strptr();
			embed "objc" {{{
				NSString* nss = [[NSString alloc] initWithUTF8String:sptr];
				if(nss == nil) {
					nss = @"";
				}
				CGSize sz = [[[NSAttributedString alloc] initWithString:nss attributes:attributes] size];
				tw = sz.width + 4;
			}}}
			if(tw > x) {
				break;
			}
			index++;
		}
		return(index);
	}
}
