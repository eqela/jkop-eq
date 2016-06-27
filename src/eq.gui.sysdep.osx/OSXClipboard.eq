
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

class OSXClipboard : Clipboard
{
	embed {{{
		#import <Foundation/Foundation.h>
		#import <AppKit/NSPasteboard.h>
	}}}

	bool set_string_data(String str) {
		var s = str;
		if(s == null) {
			s = "";
		}
		var sp = s.to_strptr();
		int len = s.get_length();
		var v = false;
		embed "objc" {{{
			NSPasteboard* pb = [NSPasteboard generalPasteboard];
			if(pb != nil) {
				[pb clearContents];
				NSString* data = [NSString stringWithUTF8String: sp];
				[pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
				v = [pb setString:data forType:NSStringPboardType];
			}
		}}}
		return(v);
	}

	public bool set_data(ClipboardData data) {
		var dt = data;
		if(data == null) {
			dt = ClipboardData.for_string("");
		}
		if("text/plain".equals(dt.get_mimetype()) == false) {
			Log.error("OSXClipboard.set_data: Mime type `%s' is not supported".printf().add(dt.get_mimetype()));
			return(false);
		}
		return(set_string_data(dt.to_string()));
	}

	public bool set_data_provider(ClipboardDataProvider dp) {
		//FIXME
		return(false);
	}

	ImageBuffer get_image_data() {
		String type;
		ptr bytes = null;
		int length = 0;
		embed "objc" {{{
			NSPasteboard* pb = [NSPasteboard generalPasteboard];
			NSData* data = [pb dataForType:NSPasteboardTypePNG];
			if(data != nil) {
				bytes = [data bytes];
				length = [data length];
			}
		}}}
		if(bytes != null) {
			type = "image/png";
		}
		else {
			embed "objc" {{{
				NSData* data = [pb dataForType:NSPasteboardTypeTIFF];
				if(data != nil) {
					bytes = [data bytes];
					length = [data length];
				}
			}}}
			if(bytes != null) {
				type = "image/tiff";
			}
		}
		if(bytes != null) {
			var bf = Buffer.dup(Buffer.for_pointer(Pointer.create(bytes), length));
			return(new ImageBuffer().set_type(type).set_buffer(bf));
		}
		return(null);
	}

	String get_string_data() {
		strptr cstr;
		embed "objc" {{{
			NSPasteboard* pb = [NSPasteboard generalPasteboard];
			NSString* nsstr = [pb stringForType:NSPasteboardTypeString];
			cstr = (char*) [nsstr UTF8String];
		}}}
		if(cstr != null) {
			return(String.for_strptr(cstr).dup());
		}
		return(null);
	}

	public bool get_data(EventReceiver listener) {
		if(listener == null) {
			return(false);
		}
		var img = get_image_data();
		if(img != null) {
			listener.on_event(ClipboardData.for_buffer(img.get_buffer(), img.get_type()));
			return(true);
		}
		var str = get_string_data();
		if(str != null) {
			listener.on_event(ClipboardData.for_string(str));
			return(true);
		}
		listener.on_event(null);
		return(false);
	}
}
