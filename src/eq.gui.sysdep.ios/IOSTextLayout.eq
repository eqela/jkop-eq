
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

public class IOSTextLayout : TextLayout, Size, ImageTextLayout, QuartzContextTextLayout
{
	embed "objc" {{{
		#import <UIKit/UIKit.h>
		#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
	}}}

	TextProperties props;
	double width;
	double height;
	ptr attrstr;
	Image image;
	Frame frame;
	int dpi;

	public static IOSTextLayout create(TextProperties props, Frame frame, int dpi) {
		var v = new IOSTextLayout();
		v.props = props;
		v.frame = frame;
		v.dpi = dpi;
		if(v.init_layout() == false) {
			return(null);
		}
		return(v);
	}

	~IOSTextLayout() {
		if(attrstr != null) {
			var ast = attrstr;
			attrstr = null;
			embed "objc" {{{
				NSAttributedString* aa = (__bridge_transfer NSAttributedString*)ast;
			}}}
		}
	}

	IOSFont get_ios_font() {
		if(props == null) {
			return(null);
		}
		var f = props.get_font();
		if(f == null) {
			return(null);
		}
		var v = f.get_backend_data() as IOSFont;
		if(v != null) {
			return(v);
		}
		int dpi = 96;
		if(frame != null) {
			dpi = frame.get_dpi();
		}
		if(this.dpi > 0) {
			dpi = this.dpi;
		}
		v = IOSFont.for_font(f, dpi);
		if(v == null) {
			return(v);
		}
		f.set_backend_data(v);
		return(v);
	}

	ptr get_uifont() {
		var iosf = get_ios_font();
		if(iosf == null) {
			return(null);
		}
		return(iosf.get_uifont());
	}

	public double get_scale_factor() {
		double v = 1.0;
		embed {{{
			v = (double)[[UIScreen mainScreen] scale];
		}}}
		return(v);
	}

	bool init_layout() {
		if(props == null) {
			return(false);
		}
		var proptext = props.get_text();
		if(proptext == null) {
			return(false);
		}
		var is_empty = false;
		if(String.is_empty(proptext)) {
			// The OS X API (and supposedly I guess iOS API also) computes the size of an
			// empty string wrong (it's about half of the height of what it should be)
			is_empty = true;
			proptext = "XgjyPl";
		}
		var textptr = proptext.to_strptr();
		var wrapwidth = props.get_wrap_width();
		var alignment = props.get_alignment();
		var textcolor = props.get_color();
		var outlinecolor = props.get_outline_color();
		var outlinewidth = 3;
		double fcr, fcg, fcb, fca;
		double ocr, ocg, ocb, oca;
		if(textcolor != null) {
			fcr = textcolor.get_r();
			fcg = textcolor.get_g();
			fcb = textcolor.get_b();
			fca = textcolor.get_a();
		}
		if(outlinecolor != null) {
			ocr = outlinecolor.get_r();
			ocg = outlinecolor.get_g();
			ocb = outlinecolor.get_b();
			oca = outlinecolor.get_a();
		}
		var uifont = get_uifont();
		embed "objc" {{{
			NSString* str = [[NSString alloc] initWithUTF8String:textptr];
			UITextAlignment ali = NSTextAlignmentLeft;
			if(alignment == 1) {
				ali = NSTextAlignmentCenter;
			}
			if(alignment == 2) {
				ali = NSTextAlignmentRight;
			}
			NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
			textStyle.lineBreakMode = NSLineBreakByWordWrapping;
			textStyle.alignment = ali;
			UIColor *textColor = [UIColor colorWithRed:fcr green:fcg blue:fcb alpha:fca];
    			UIColor *strokeColor = [UIColor colorWithRed:ocr green:ocg blue:ocb alpha:oca];
    			NSDictionary *attrs = @{
				NSFontAttributeName:(__bridge UIFont*)uifont,
				NSParagraphStyleAttributeName:textStyle,
				NSForegroundColorAttributeName:textColor,
				NSStrokeColorAttributeName:strokeColor,
				NSStrokeWidthAttributeName:[NSNumber numberWithFloat:-2.0]
			};
			NSAttributedString* attrstr = [[NSAttributedString alloc] initWithString:str attributes:attrs];
		}}}
		double width, height;
		if(wrapwidth > 0) {
			embed "objc" {{{
				CGRect rect = [attrstr boundingRectWithSize:CGSizeMake(wrapwidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
				width = rect.size.width;
				height = rect.size.height;
			}}}
			if(width < wrapwidth) {
				width = wrapwidth;
			}
		}
		else {
			embed "objc" {{{
				CGSize sz = [attrstr size];
				width = sz.width;
				height = sz.height;
			}}}
		}
		if(is_empty) {
			width = 0;
		}
		this.width = width;
		this.height = height;
		ptr ast = null;
		embed "objc" {{{
			ast = (__bridge_retained void*)attrstr;
		}}}
		this.attrstr = ast;
		return(true);
	}

	public double get_width() {
		return(width);
	}

	public double get_height() {
		return(height);
	}

	public void draw_in_context(ptr contextp, int x, int y) {
		var ww = get_width(), hh = get_height();
		var aa = attrstr;
		var wrapwidth = props.get_wrap_width();
		embed "objc" {{{
			NSAttributedString* attrstr = (__bridge NSAttributedString*)aa;
			UIGraphicsPushContext((CGContextRef)contextp);
			if(wrapwidth > 0) {
				[attrstr drawInRect:CGRectMake(x, y, ww, hh)];
			}
			else {
				[attrstr drawAtPoint:CGPointMake(x, y)];
			}
			UIGraphicsPopContext();
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
			var image = QuartzBitmapImage.create(w, h, false) as VgRenderableImage;
			if(image != null) {
				var vc = image.get_vg_context();
				if(vc != null && vc is QuartzVgContext) {
					draw_in_context(((QuartzVgContext)vc).get_context(), 0, 0);
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
		if(tptr == null || tptr.equals("")) {
			return(Rectangle.instance(0, 0, 2, 12));
		}
		var ttptr = tptr.to_strptr();
		int ww = props.get_wrap_width();
		int xcoord = 0;
		var uifont = get_uifont();
		int h;
		embed "objc" {{{
			NSString * astr = [[NSString alloc] initWithUTF8String:ttptr];
			NSString * cstr = [astr substringToIndex:index];
			xcoord = [cstr sizeWithFont:(__bridge UIFont*)uifont].width;
			h = [(__bridge UIFont*)uifont lineHeight];
		}}}
		return(Rectangle.instance(xcoord, 0, 1, h));
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
		var uifont = get_uifont();
		int tw = 0;
		for(counter = 0; counter < s.get_length(); counter++) {
			var ss = s.substring(counter, 1);
			var sptr = ss.to_strptr();
			embed "objc" {{{
				w = [[[NSString alloc] initWithUTF8String:sptr] sizeWithFont:(__bridge UIFont*)uifont].width;
				tw += w;
			}}}
			index++;
			if(tw > x) {
				break;
			}
		}
		return(index);
	}
}
