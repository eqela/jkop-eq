
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

public class NSViewSurface : Surface, Size, Position, Renderable, FocusableSurface
{
	property ptr nsview;
	double x;
	double y;
	double w;
	double h;
	FocusableSurfaceListener focus_listener;

	embed "objc" {{{
		#import <Cocoa/Cocoa.h>
		#import <QuartzCore/QuartzCore.h>
		@interface MyView : NSView
		@property void* myframe;
		@property void* vs;
		@property NSEvent* leftPressed;
		@property NSEvent* rightPressed;
		@property BOOL focusable;
		@end
		@implementation MyView
		- (void) drawRect:(NSRect)dirtyRect
		{
			NSGraphicsContext* ctx = [NSGraphicsContext currentContext];
			eq_gui_sysdep_osx_NSViewSurface_on_draw_rect(self.vs, [ctx graphicsPort]);
		}
		- (void) layout
		{
		}
		- (BOOL)acceptsFirstResponder
		{
			return(_focusable);
		}
		- (BOOL) isFlipped
		{
			return(YES);
		}
		- (void) keyDown:(NSEvent*)event
		{
			NSString* str = [event characters];
			NSString* strw = [event charactersIgnoringModifiers];
			if([str length] == 1) {
				unichar cc = [str characterAtIndex:0];
				if(cc >= 0xF700 && cc <= 0xF8FF) {
					str = nil;
				}
			}
			int flag = [event modifierFlags];
			if(flag & NSControlKeyMask) {
				str = strw;
			}
			if(flag & NSAlternateKeyMask && str != nil) {
				flag = 0;
			}
			if(eq_gui_sysdep_osx_NSFrameType_on_key_down(_myframe, [event keyCode], (char*)[str UTF8String], flag)) {
				return;
			}
			[super keyDown:event];
		}
		- (void) keyUp:(NSEvent*)event
		{
			NSString* str = [event characters];
			NSString* strw = [event charactersIgnoringModifiers];
			if([str length] == 1) {
				unichar cc = [str characterAtIndex:0];
				if(cc >= 0xF700 && cc <= 0xF8FF) {
					str = nil;
				}
			}
			int flag = [event modifierFlags];
			if(flag & NSControlKeyMask) {
				str = strw;
			}
			if(flag & NSAlternateKeyMask && str != nil) {
				flag = 0;
			}
			if(eq_gui_sysdep_osx_NSFrameType_on_key_up(_myframe, [event keyCode], (char*)[str UTF8String], flag)) {
				return;
			}
			[super keyUp:event];
		}
		- (void) mouseDown:(NSEvent*)event
		{
			_leftPressed = event;
			NSPoint cp = [event locationInWindow];
			if(eq_gui_sysdep_osx_NSFrameType_on_mouse_down(_myframe, cp.x, cp.y, 0)) {
				return;
			}
			[super mouseDown:event];
		}
		- (void) mouseUp:(NSEvent*)event
		{
			_leftPressed = nil;
			NSPoint cp = [event locationInWindow];
			if(eq_gui_sysdep_osx_NSFrameType_on_mouse_up(_myframe, cp.x, cp.y, 0)) {
				return;
			}
			[super mouseUp:event];
		}
		- (void) mouseMoved:(NSEvent*)event
		{
			[super mouseMoved:event];
			NSPoint cp = [event locationInWindow];
			if(eq_gui_sysdep_osx_NSFrameType_on_mouse_moved(_myframe, cp.x, cp.y)) {
				return;
			}
		}
		- (void) mouseDragged:(NSEvent*)event
		{
			NSPoint cp = [event locationInWindow];
			if(eq_gui_sysdep_osx_NSFrameType_on_mouse_moved(_myframe, cp.x, cp.y)) {
				return;
			}
			[super mouseDragged:event];
		}
		- (void) rightMouseDown:(NSEvent*)event
		{
			_rightPressed = event;
			NSPoint cp = [event locationInWindow];
			if(eq_gui_sysdep_osx_NSFrameType_on_mouse_down(_myframe, cp.x, cp.y, 2)) {
				return;
			}
			[super rightMouseDown:event];
		}
		- (void) rightMouseUp:(NSEvent*)event
		{
			_rightPressed = nil;
			NSPoint cp = [event locationInWindow];
			if(eq_gui_sysdep_osx_NSFrameType_on_mouse_up(_myframe, cp.x, cp.y, 2)) {
				return;
			}
			[super rightMouseUp:event];
		}
		- (void) rightMouseDragged:(NSEvent*)event
		{
			NSPoint cp = [event locationInWindow];
			if(eq_gui_sysdep_osx_NSFrameType_on_mouse_moved(_myframe, cp.x, cp.y)) {
				return;
			}
			[super rightMouseDragged:event];
		}
		- (void)scrollWheel:(NSEvent *)event
		{
			NSPoint cp = [event locationInWindow];
			if(eq_gui_sysdep_osx_NSFrameType_on_mouse_wheel(_myframe, cp.x, cp.y, [event deltaX], [event deltaY])) {
				return;
			}
			[super scrollWheel:event];
		}
		- (void)mouseEntered:(NSEvent *)theEvent
		{
			_leftPressed = nil;
			_rightPressed = nil;
		}
		- (void)mouseExited:(NSEvent *)theEvent
		{
			_leftPressed = nil;
			_rightPressed = nil;
		}
		- (BOOL)becomeFirstResponder
		{
			BOOL v = [super becomeFirstResponder];
			eq_gui_sysdep_osx_NSViewSurface_on_surface_gain_focus(_vs);
			return(v);
		}
		- (BOOL)resignFirstResponder
		{
			BOOL v = [super resignFirstResponder];
			eq_gui_sysdep_osx_NSViewSurface_on_surface_lose_focus(_vs);
			return(v);
		}
		@end
	}}}

	public static NSViewSurface create(NSFrameType frame) {
		var v = new NSViewSurface();
		if(v.initialize(frame) == false) {
			v = null;
		}
		return(v);
	}

	public ~NSViewSurface() {
		destroy();
	}

	public void on_surface_gain_focus() {
		if(focus_listener != null) {
			focus_listener.on_surface_gain_focus();
		}
	}

	public void on_surface_lose_focus() {
		if(focus_listener != null) {
			focus_listener.on_surface_lose_focus();
		}
	}

	public void set_focusable_surface_listener(FocusableSurfaceListener listener) {
		focus_listener = listener;
	}

	bool _is_focusable = false;

	public void set_focusable(bool v) {
		var view = nsview;
		if(view == null) {
			return;
		}
		_is_focusable = true;
		embed {{{
			MyView* vv = (__bridge MyView*)view;
			if(v) {
				[vv setFocusable:YES];
			}
			else {
				[vv setFocusable:NO];
			}
		}}}
	}

	public void grab_focus() {
		var view = nsview;
		if(view == null || _is_focusable == false) {
			return;
		}
		embed {{{
			NSView* vv = (__bridge NSView*)view;
			[[vv window] makeFirstResponder:vv];
		}}}
	}

	public void release_focus() {
		var view = nsview;
		if(view == null || _is_focusable == false) {
			return;
		}
		embed {{{
			NSView* vv = (__bridge NSView*)view;
			[[vv window] makeFirstResponder:nil];
		}}}
	}

	public double get_scale_factor() {
		double v = 1.0;
		var nsw = nsview;
		embed "objc" {{{
			NSView* vv = (__bridge NSView*)nsw;
			v = [vv.window backingScaleFactor];
		}}}
		return(v);
	}

	public bool initialize(NSFrameType frame) {
		destroy();
		if(frame == null) {
			return(false);
		}
		ptr v;
		embed {{{
			MyView* view =[[MyView alloc] initWithFrame:CGRectMake(0,0,20,20)];
			[view setFocusable:NO];
			[view setAutoresizesSubviews:YES];
			[view setWantsLayer:YES];
			[(MyView*)view setMyframe:frame];
			[(MyView*)view setVs:self];
			[(MyView*)view setLeftPressed:nil];
			[(MyView*)view setRightPressed:nil];
		}}}
		embed {{{
			v = (__bridge_retained void*)view;
		}}}
		this.nsview = v;
		return(this.nsview != null);
	}

	public void destroy() {
		if(nsview == null) {
			return;
		}
		var nsv = nsview;
		embed {{{
			MyView* mv = (__bridge_transfer MyView*)nsv;
			NSEvent* le = [mv leftPressed];
			if(le != nil) {
				[mv mouseUp:le];
			}
			NSEvent* re = [mv rightPressed];
			if(re != nil) {
				[mv rightMouseUp:re];
			}
			[mv removeFromSuperview];
		}}}
		nsview = null;
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
		if(nsview == null || (this.x == x && this.y == y)) {
			return;
		}
		var sf = get_scale_factor();
		if(sf == 0) {
			return;
		}
		var nsw = nsview;
		var rotate = _rot;
		embed {{{
			if(rotate != 0) { [(__bridge NSView*)nsw setFrameCenterRotation:0]; }
			[(__bridge NSView*)nsw setFrameOrigin:CGPointMake(x/sf, y/sf)];
			if(rotate != 0) { [(__bridge NSView*)nsw setFrameCenterRotation:rotate]; }
		}}}
		this.x = x;
		this.y = y;
		update_transform();
	}

	public void resize(double w, double h) {
		if(nsview == null || (this.w == w && this.h == h)) {
			return;
		}
		var sf = get_scale_factor();
		if(sf == 0) {
			return;
		}
		var nsw = nsview;
		var rotate = _rot;
		embed {{{
			if(rotate != 0) { [(__bridge NSView*)nsw setFrameCenterRotation:0]; }
			[(__bridge NSView*)nsw setFrameSize:CGSizeMake(w/sf, h/sf)];
			if(rotate != 0) { [(__bridge NSView*)nsw setFrameCenterRotation:rotate]; }
		}}}
		this.w = w;
		this.h = h;
		update_transform();
	}

	public void move_resize(double x, double y, double w, double h) {
		if(nsview == null || (this.x == x && this.y == y && this.w == w && this.h == h)) {
			return;
		}
		var sf = get_scale_factor();
		if(sf == 0) {
			return;
		}
		var nsw = nsview;
		var rotate = _rot;
		embed {{{
			if(rotate != 0) { [(__bridge NSView*)nsw setFrameCenterRotation:0]; }
			[(__bridge NSView*)nsw setFrame:CGRectMake(x/sf, y/sf, w/sf, h/sf)];
			if(rotate != 0) { [(__bridge NSView*)nsw setFrameCenterRotation:rotate]; }
		}}}
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		update_transform();
	}

	double _scale_x = 1.0;
	double _scale_y = 1.0;

	public void set_scale(double sx, double sy) {
		_scale_x = sx;
		_scale_y = sy;
		update_transform();
	}

	void update_transform() {
		if(nsview == null || (_scale_x == 1.0 && _scale_y == 1.0)) {
			return;
		}
		var sx = _scale_x;
		var sy = _scale_y;
		var nsw = nsview;
		var w = get_width(), h = get_height();
		embed {{{
			NSView* view = (__bridge NSView*)nsw;
			CATransform3D transform = CATransform3DIdentity;
			transform = CATransform3DScale(transform, sx, sy, 1);
			view.layer.transform = transform;
		}}}
	}

	public void set_alpha(double f) {
		if(nsview == null) {
			return;
		}
		var nsw = nsview;
		embed {{{
			[(__bridge NSView*)nsw setAlphaValue:(CGFloat)f];
		}}}
	}

	double _rot = 0.0;
	double _rota = 0.0;

	public void set_rotation_angle(double a) {
		if(nsview == null || a == 0.0) {
			return;
		}
		var nsw = nsview;
		var deg = a * 180.0 / MathConstant.M_PI;
		embed {{{
			[(__bridge NSView*)nsw setFrameCenterRotation:(CGFloat)deg];
		}}}
		_rot = deg;
		_rota = a;
		update_transform();
	}

	public double get_scale_x() {
		return(_scale_x);
	}

	public double get_scale_y() {
		return(_scale_y);
	}

	public double get_alpha() {
		if(nsview == null) {
			return(0.0);
		}
		double v;
		var nsw = nsview;
		embed {{{
			v = (double)[(__bridge NSView*)nsw alphaValue];
		}}}
		return(v);
	}

	public double get_rotation_angle() {
		return(_rota);
	}

	Collection ops;

	public void on_draw_rect(ptr ctx) {
		var sf = get_scale_factor();
		if(sf == 0) {
			return;
		}
		var vg = QuartzVgContext.for_context(ctx, sf);
		VgRenderer.render_to_vg_context(ops, vg);
	}

	public void render(Collection ops) {
		this.ops = ops;
		if(nsview != null) {
			var nsw = nsview;
			if(ops != null) {
				var rr = ops.get(0) as ClipOperation;
				if(rr != null) {
					var sf = get_scale_factor();
					var ss = rr.get_shape() as RectangleShape;
					if(sf != 0 && ss != null) {
						var x = ss.get_x() / sf, y = ss.get_y() / sf, w = ss.get_width() / sf, h = ss.get_height() / sf;
						embed {{{
							[(__bridge NSView*)nsw setNeedsDisplayInRect:CGRectMake(x,y,w,h)];
						}}}
						return;
					}
				}
			}
			embed {{{
				[(__bridge NSView*)nsw setNeedsDisplay:YES];
			}}}
		}
	}
}
