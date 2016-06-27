
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

public class IOSFont
{
	embed "objc" {{{
		#import <UIKit/UIKit.h>
	}}}

	public static IOSFont for_font(Font font, int dpi) {
		return(new IOSFont().initialize(font, dpi));
	}

	ptr uifont;

	public ~IOSFont() {
		if(uifont != null) {
			var fptr = uifont;
			uifont = null;
			embed "objc" {{{
				UIFont* uf = (__bridge_transfer UIFont*)fptr;
			}}}
		}
	}

	public ptr get_uifont() {
		return(uifont);
	}

	String translate_font_name(String afontname) {
		var fontname = afontname;
		if(fontname != null && (fontname.has_suffix(".ttf") || fontname.has_suffix(".otf"))) {
			fontname = fontname.substring(0, fontname.get_length()-4).replace_char('_', ' ');
		}
		if(String.is_empty(fontname)) {
			return("Arial");
		}
		if("sans".equals_ignore_case(fontname)) {
			return("Arial");
		}
		else if("serif".equals_ignore_case(fontname)) {
			return("Times-Roman");
		}
		else if("monospace".equals_ignore_case(fontname)) {
			return("Courier");
		}
		return(fontname);
	}

	public IOSFont initialize(Font font, int dpi) {
		String fontname;
		int fontsize;
		bool is_italic = false;
		bool is_bold = false;
		if(font != null) {
			fontname = translate_font_name(font.get_name());
			fontsize = Length.to_pixels(font.get_size(), dpi);
			is_italic = font.is_italic();
			is_bold = font.is_bold();
		}
		if(fontname == null) {
			fontname = "Arial";
		}
		if(fontsize < 1) {
			fontsize = 12;
		}
		var fontnameptr = fontname.to_strptr();
		ptr fptr = null;
		bool check = false;
		embed {{{
			NSString* fname = [[NSString alloc] initWithUTF8String:fontnameptr];
			if(is_italic == true) {
				CGAffineTransform matrix = CGAffineTransformMake(1.0, 0.0, 0.3f, 1.0, 0.0, 0.0);
				UIFontDescriptor* fd = [UIFontDescriptor fontDescriptorWithName:fname matrix:matrix];
				UIFont* uifontitalic = [UIFont fontWithDescriptor:fd size:fontsize];
				fptr = (__bridge_retained void*)uifontitalic;
			}
			else if(is_bold == true) {
				UIFontDescriptor *fdecs = [UIFontDescriptor fontDescriptorWithFontAttributes: @{
					@"NSFontFamilyAttribute" : fname,
					@"NSFontFaceAttribute" : @"Bold"
				}];
				UIFont* uifontbold = [UIFont fontWithDescriptor:fdecs size:fontsize];
				fptr = (__bridge_retained void*)uifontbold;
			}
			else {
				UIFont* uifont = [UIFont fontWithName:fname size:fontsize];
				fptr = (__bridge_retained void*)uifont;
			}
		}}}
		if(fptr == null) {
			Log.error("Font named `%s' was not found. Falling back to `Arial'.".printf().add(fontname));
			embed "objc" {{{
				UIFont* dfont = [UIFont fontWithName:@"Arial" size:fontsize];
				fptr = (__bridge_retained void*)dfont;
			}}}
		}
		if(fptr == null) {
			return(null);
		}
		this.uifont = fptr;
		return(this);
	}
}
