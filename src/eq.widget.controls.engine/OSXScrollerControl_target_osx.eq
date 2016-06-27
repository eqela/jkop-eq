
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

public class OSXScrollerControl : OSXNativeWidget, ScrollerControl
{
	class MyWidgetEngine : WidgetEngine
	{
		property bool maximize_horizontal = false;
		property bool maximize_vertical = false;
		int mywr = -1;
		int myhr = -1;

		void update_size() {
			var frame = get_frame() as NSViewFrame;
			if(frame == null) {
				return;
			}
			var nw = mywr;
			var nh = myhr;
			if(nw < 0 || maximize_horizontal) {
				nw = get_width();
			}
			if(nh < 0 || maximize_vertical) {
				nh = get_height();
			}
			frame.resize(nw, nh);
		}

		public void on_resize(int w, int h) {
			base.on_resize(w,h);
			update_size();
		}

		public void on_new_size_request(int wr, int hr) {
			base.on_new_size_request(wr, hr);
			mywr = wr;
			myhr = hr;
			update_size();
		}
	}

	embed {{{
		#import <Cocoa/Cocoa.h>
	}}}

	property bool vertical = true;
	property bool horizontal = true;
	property Widget widget;
	NSViewFrame ff;

	public void on_resize() {
		base.on_resize();
		if(ff != null) {
			var nw = ff.get_width(), nh = ff.get_height();
			if(horizontal == false) {
				nw = get_width();
			}
			if(vertical == false) {
				nh = get_height();
			}
			ff.resize(nw, nh);
		}
	}

	public void cleanup_nsview() {
		base.cleanup_nsview();
		if(ff != null) {
			ff.destroy();
			ff = null;
		}
	}

	public ptr create_nsview() {
		ptr v = null;
		embed {{{
			BOOL scroll_vertical = YES;
			BOOL scroll_horizontal = YES;
		}}}
		if(vertical == false) {
			embed {{{
				scroll_vertical = NO;
			}}}
		}
		if(horizontal == false) {
			embed {{{
				scroll_horizontal = NO;
			}}}
		}
		var we = new MyWidgetEngine();
		if(vertical == false) {
			we.set_maximize_vertical(true);
		}
		if(horizontal == false) {
			we.set_maximize_horizontal(true);
		}
		we.set_main_widget(widget);
		ff = NSViewFrame.create(we, get_frame());
		if(ff == null) {
			return(null);
		}
		ff.set_destroy_when_removed(false);
		var nsv = ff.get_nsview();
		if(nsv == null) {
			ff.destroy();
			ff = null;
			return(null);
		}
		embed {{{
			NSScrollView* sv = [[NSScrollView alloc] init];
			[sv setDrawsBackground:NO];
			[sv setBorderType:NSNoBorder];
			[sv setHasVerticalScroller:scroll_vertical];
			[sv setHasHorizontalScroller:scroll_horizontal];
			[sv setDocumentView:(__bridge NSView*)nsv];
			v = (__bridge_retained void*)sv;
		}}}
		return(v);
	}
}
