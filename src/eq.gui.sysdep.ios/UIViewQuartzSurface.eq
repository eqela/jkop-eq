
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

public class UIViewQuartzSurface : UIViewSurface, Renderable
{
	Collection ops;

	embed "objc" {{{
		#import <UIKit/UIKit.h>
		@interface UIViewSurfaceView : UIView
		@property void* uiViewSurface;
		@end
		@interface UIViewQuartzSurfaceView : UIViewSurfaceView
		@end
		@implementation UIViewQuartzSurfaceView
		- (void) drawRect:(CGRect)dirtyRect
		{
			CGContextRef ctx = UIGraphicsGetCurrentContext();
			eq_gui_sysdep_ios_UIViewQuartzSurface_on_draw_rect([self uiViewSurface], ctx);
		}
		@end
	}}}

	public bool initialize(Frame frame) {
		if(base.initialize(frame) == false) {
			return(false);
		}
		ptr v;
		embed {{{
			UIViewQuartzSurfaceView* view = [[UIViewQuartzSurfaceView alloc] init];
			view.uiViewSurface = self;
			v = (__bridge_retained void*)view;
		}}}
		set_uiview(v);
		return(true);
	}

	public void on_draw_rect(ptr ctx) {
		var vg = QuartzVgContext.for_context(ctx, get_scale_factor());
		vg.clear(0, 0, VgPathRectangle.create(0, 0, get_width(), get_height()), null);
		VgRenderer.render_to_vg_context(ops, vg);
	}

	public void render(Collection ops) {
		this.ops = ops;
		var uiview = get_uiview();
		if(uiview != null) {
			var uiw = uiview;
			embed {{{
				[(__bridge UIView*)uiw setNeedsDisplay];
			}}}
		}
	}
}
