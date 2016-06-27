
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

public class OSXSolidColorControl : OSXNativeWidget, SolidColorControl
{
	embed {{{
		#import <Cocoa/Cocoa.h>
	}}}

	embed {{{
		@interface MySolidView : NSView
		{
			NSColor* color;
		}
		@end
		@implementation MySolidView
		- (void) setColor:(NSColor*)newColor
		{
			self->color = newColor;
			[self setNeedsDisplay:YES];
		}
		- (void) drawRect:(NSRect)dirtyRect
		{
			if(self->color != nil) {
				[self->color set];
				NSRectFill(dirtyRect);
			}
		}
		@end
	}}}

	Color color;

	public void initialize_nsview() {
		base.initialize_nsview();
		update_my_view();
	}

	public ptr create_nsview() {
		ptr v = null;
		embed {{{
			MySolidView* view = [[MySolidView alloc] init];
			v = (__bridge_retained void*)view;
		}}}
		return(v);
	}

	void update_my_view() {
		var view = get_nsview();
		if(view == null) {
			return;
		}
		double r = 0.0, g = 0.0, b = 0.0, a = 0.0;
		if(color != null) {
			r = color.get_r();
			g = color.get_g();
			b = color.get_b();
			a = color.get_a();
		}
		embed {{{
			NSColor* cc = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:a];
			MySolidView* sv = (__bridge MySolidView*)view;
			[sv setColor:cc];
		}}}
	}

	public SolidColorControl set_color(Color color) {
		this.color = color;
		update_my_view();
		return(this);
	}
}
