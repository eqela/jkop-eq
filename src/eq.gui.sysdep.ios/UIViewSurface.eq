
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

public class UIViewSurface : Surface, Size, Position
{
	embed "objc" {{{
		#import <UIKit/UIKit.h>
		@interface UIViewSurfaceView : UIView
		- (id)init;
		@property void* uiViewSurface;
		@end
		@implementation UIViewSurfaceView
		- (id) init
		{
			self = [super init];
			if(self) {
				self.userInteractionEnabled = YES;
				self.clearsContextBeforeDrawing = NO;
				self.opaque = NO;
				// self.clipsToBounds = YES;
				self.autoresizesSubviews = YES;
			}
			return(self);
		}
		- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
			void* suf = ref_eq_api_Object(self.uiViewSurface);
			void* frame = eq_gui_sysdep_ios_UIViewSurface_get_frame(_uiViewSurface);
			for(UITouch* touch in touches) {
				CGPoint tapPoint = [touch locationInView:(__bridge UIView*)eq_gui_sysdep_ios_UIKitFrame_get_myview(frame)];
				eq_gui_sysdep_ios_UIViewSurface_on_touch_start(self.uiViewSurface, (int)touch, tapPoint.x, tapPoint.y);
			}
			unref_eq_api_Object(frame);
			unref_eq_api_Object(suf);
		}
		- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
			void* suf = ref_eq_api_Object(self.uiViewSurface);
			void* frame = eq_gui_sysdep_ios_UIViewSurface_get_frame(_uiViewSurface);
			for(UITouch* touch in touches) {
				CGPoint tapPoint = [touch locationInView:(__bridge UIView*)eq_gui_sysdep_ios_UIKitFrame_get_myview(frame)];
				eq_gui_sysdep_ios_UIViewSurface_on_touch_move(self.uiViewSurface, (int)touch, tapPoint.x, tapPoint.y);
			}
			unref_eq_api_Object(frame);
			unref_eq_api_Object(suf);
		}
		- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
			void* suf = ref_eq_api_Object(self.uiViewSurface);
			void* frame = eq_gui_sysdep_ios_UIViewSurface_get_frame(_uiViewSurface);
			for(UITouch* touch in touches) {
				CGPoint tapPoint = [touch locationInView:(__bridge UIView*)eq_gui_sysdep_ios_UIKitFrame_get_myview(frame)];
				eq_gui_sysdep_ios_UIViewSurface_on_touch_end(self.uiViewSurface, (int)touch, tapPoint.x, tapPoint.y);
			}
			unref_eq_api_Object(frame);
			unref_eq_api_Object(suf);
		}
		- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
			void* suf = ref_eq_api_Object(self.uiViewSurface);
			void* frame = eq_gui_sysdep_ios_UIViewSurface_get_frame(_uiViewSurface);
			for(UITouch* touch in touches) {
				CGPoint tapPoint = [touch locationInView:(__bridge UIView*)eq_gui_sysdep_ios_UIKitFrame_get_myview(frame)];
				eq_gui_sysdep_ios_UIViewSurface_on_touch_end(self.uiViewSurface, (int)touch, tapPoint.x, tapPoint.y);
			}
			unref_eq_api_Object(frame);
			unref_eq_api_Object(suf);
		}
		@end
	}}}

	property ptr uiview;
	UIKitFrame frame;
	property double scale_factor;
	double x;
	double y;
	double w;
	double h;
	double _rotat = 0.0;
	double _alpha = 1.0;
	double _scale_x = 1.0;
	double _scale_y = 1.0;

	public UIViewSurface() {
		double v = 1.0;
		embed "objc" {{{
			v = (double)[[UIScreen mainScreen] scale];
		}}}
		this.scale_factor = v;
	}

	public ~UIViewSurface() {
		destroy();
	}

	public UIKitFrame get_frame() {
		return(frame);
	}

	public virtual bool initialize(Frame frame) {
		this.frame = frame as UIKitFrame;
		if(this.frame == null) {
			return(false);
		}
		return(true);
	}

	public void on_touch_start(int id, int x, int y) {
		frame.event(new PointerMoveEvent().set_x(x*scale_factor)
			.set_y(y*scale_factor).set_pointer_type(PointerEvent.TOUCH).set_id(id));
		frame.event(new PointerPressEvent().set_button(1).set_x(x*scale_factor)
			.set_y(y*scale_factor).set_pointer_type(PointerEvent.TOUCH).set_id(id));
	}

	public void on_touch_move(int id, int x, int y) {
		frame.event(new PointerMoveEvent().set_x(x*scale_factor)
			.set_y(y*scale_factor).set_pointer_type(PointerEvent.TOUCH).set_id(id));
	}

	public void on_touch_end(int id, int x, int y) {
		frame.event(new PointerReleaseEvent().set_button(1).set_x(x*scale_factor)
			.set_y(y*scale_factor).set_pointer_type(PointerEvent.TOUCH).set_id(id));
		if(frame != null) {
			frame.event(new PointerLeaveEvent().set_x(x*scale_factor)
				.set_y(y*scale_factor).set_pointer_type(PointerEvent.TOUCH).set_id(id));
		}
	}

	public void destroy() {
		if(uiview != null) {
			var uiv = uiview;
			embed {{{
				UIView* mv = (__bridge_transfer UIView*)uiv;
				[mv removeFromSuperview];
			}}}
			uiview = null;
		}
		this.frame = null;
	}

	public double get_x() {
		return(x);
	}

	public double get_y() {
		return(y);
	}

	public double get_width() {
		return(w);
	}

	public double get_height() {
		return(h);
	}

	public void move(double x, double y) {
		if(uiview == null) {
			return;
		}
		var uiw = uiview;
		var sf = this.scale_factor;
		embed {{{
			UIView* uvv = (__bridge UIView*)uiw;
			CGAffineTransform tt = uvv.transform;
			uvv.transform = CGAffineTransformIdentity;
			uvv.center = CGPointMake(x/sf + uvv.bounds.size.width / 2, y/sf + uvv.bounds.size.height / 2);
			uvv.transform = tt;
		}}}
		this.x = x;
		this.y = y;
	}

	public void resize(double w, double h) {
		if(uiview == null) {
			return;
		}
		var uiw = uiview;
		var sf = this.scale_factor;
		embed {{{
			UIView* uvv = (__bridge UIView*)uiw;
			CGAffineTransform tt = uvv.transform;
			uvv.transform = CGAffineTransformIdentity;
			uvv.frame = CGRectMake(uvv.frame.origin.x, uvv.frame.origin.y, w/sf, h/sf);
			uvv.transform = tt;
		}}}
		this.w = w;
		this.h = h;
	}

	public void move_resize(double x, double y, double w, double h) {
		if(uiview == null) {
			return;
		}
		var uiw = uiview;
		var sf = this.scale_factor;
		embed {{{
			UIView* uvv = (__bridge UIView*)uiw;
			CGAffineTransform tt = uvv.transform;
			uvv.transform = CGAffineTransformIdentity;
			[uvv setFrame:CGRectMake(x/sf, y/sf, w/sf, h/sf)];
			uvv.transform = tt;
		}}}
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}

	public void set_scale(double sx, double sy) {
		// FIXME
		_scale_x = sx;
		_scale_y = sy;
	}

	public void set_alpha(double f) {
		if(uiview == null) {
			return;
		}
		var uiw = uiview;
		embed {{{
			[(__bridge UIView*)uiw setAlpha:(CGFloat)f];
		}}}
		_alpha = f;
	}

	public void set_rotation_angle(double a) {
		if(uiview == null || a == 0.0) {
			return;
		}
		var uiw = uiview;
		embed {{{
			CGAffineTransform tt = CGAffineTransformMakeRotation(a);
			[(__bridge UIView*)uiw setTransform:tt];
		}}}
		_rotat = a;
	}

	public double get_scale_x() {
		return(_scale_x);
	}

	public double get_scale_y() {
		return(_scale_y);
	}

	public double get_alpha() {
		return(_alpha);
	}

	public double get_rotation_angle() {
		return(_rotat);
	}
}
