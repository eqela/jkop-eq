
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

public class NSViewFrame : NSFrame, ResizableFrame
{
	public static NSViewFrame create(FrameController fc, Frame parent) {
		var v = new NSViewFrame();
		v.set_parent_frame(parent);
		if(v.initialize(fc) == false) {
			v = null;
		}
		return(v);
	}

	embed "objc" {{{
		#import <Cocoa/Cocoa.h>
	}}}

	property Frame parent_frame;

	public bool initialize(FrameController fc) {
		Log.debug("NSViewFrame initialize");
		if(fc == null) {
			return(false);
		}
		set_controller(fc);
		set_nsview(create_nsview());
		update_window_properties();
		return(true);
	}

	public void close() {
		base.close();
		var nsview = get_nsview();
		if(nsview != null) {
			Log.debug("NSViewFrame close");
			embed {{{
				[(__bridge NSView*)nsview removeFromSuperview];
			}}}
		}
	}

	public void on_view_added_to_window() {
		Log.debug("NSViewFrame added to window");
		base.on_view_added_to_window();
	}

	public void on_view_removed_from_window() {
		Log.debug("NSViewFrame removed from window");
		base.on_view_removed_from_window();
	}

	public void resize(int w, int h) {
		var nsv = get_nsview();
		if(nsv == null) {
			return;
		}
		var sf = get_scale_factor();
		embed {{{
			NSView* view = (__bridge NSView*)nsv;
			[view setFrameSize:CGSizeMake(w / sf, h / sf)];
		}}}
	}
}
