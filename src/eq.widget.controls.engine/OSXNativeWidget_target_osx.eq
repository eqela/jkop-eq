
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

public class OSXNativeWidget : Widget
{
	embed {{{
		#import <Cocoa/Cocoa.h>
	}}}

	property ptr nsview = null;

	public override bool get_always_has_surface() {
		return(true);
	}

	public void on_became_first_responder() {
		var we = get_engine();
		if(we != null) {
			we.set_focus_widget(this);
		}
	}

	public void configure_focusable_surface(FocusableSurface surface) {
	}

	public void on_gain_focus() {
		base.on_gain_focus();
		if(is_focusable()) {
			var view = get_nsview();
			if(view == null) {
				return;
			}
			embed {{{
				NSView* vv = (__bridge NSView*)view;
				NSWindow* window = [vv window];
				if([window firstResponder] != vv) {
					[window makeFirstResponder:vv];
				}
			}}}
		}
	}

	public void on_lose_focus() {
		base.on_lose_focus();
		if(is_focusable()) {
			var view = get_nsview();
			if(view == null) {
				return;
			}
			embed {{{
				NSView* vv = (__bridge NSView*)view;
				NSWindow* window = [vv window];
				if([window firstResponder] == vv) {
					[[vv window] makeFirstResponder:nil];
				}
			}}}
		}
	}

	public virtual void initialize_nsview() {
		update_size_request();
	}

	public virtual void update_size_request() {
		var nsview = get_nsview();
		int wr = -1, hr = -1;
		var sf = get_scale_factor();
		embed {{{
			NSView* vv = (__bridge NSView*)nsview;
			NSSize isz;
			isz = [vv fittingSize];
			wr = isz.width;
			hr = isz.height;
		}}}
		if(wr >= 0) {
			wr = wr * sf;
		}
		if(hr >= 0) {
			hr = hr * sf;
		}
		set_size_request(wr, hr);
	}

	public virtual void cleanup_nsview() {
		if(nsview == null) {
			return;
		}
		var p = nsview;
		embed {{{
			NSView* ov = (__bridge_transfer NSView*)p;
			[ov removeFromSuperview];
		}}}
		nsview = null;
	}

	public void on_resize() {
		base.on_resize();
		var nsw = get_nsview();
		if(nsw != null) {
			var sf = get_scale_factor();
			int w = get_width() / sf;
			int h = get_height() / sf;
			embed {{{
				NSView* vv = (__bridge NSView*)nsw;
				[vv setFrameSize:CGSizeMake(w,h)];
			}}}
		}
	}

	public virtual ptr create_nsview() {
		return(null);
	}

	public double get_scale_factor() {
		double v = 1.0;
		if(nsview != null) {
			var nsw = nsview;
			embed "objc" {{{
				NSView* vv = (__bridge NSView*)nsw;
				v = [vv.window backingScaleFactor];
			}}}
		}
		return(v);
	}

	public void cleanup() {
		base.cleanup();
		if(nsview != null) {
			cleanup_nsview();
		}
	}

	public void on_surface_created(Surface surface) {
		base.on_surface_created(surface);
		if(nsview != null) {
			cleanup_nsview();
		}
		var ss = surface as NSViewSurface;
		if(ss == null) {
			return;
		}
		var view = ss.get_nsview();
		if(view == null) {
			return;
		}
		var p = create_nsview();
		if(p == null) {
			return;
		}
		embed {{{
			NSView* vv = (__bridge NSView*)p;
			[vv setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable |NSViewMaxXMargin|NSViewMaxYMargin|NSViewMinXMargin|NSViewMinYMargin];
			[(__bridge NSView*)view addSubview:vv];
		}}}
		nsview = p;
		initialize_nsview();
	}
}
