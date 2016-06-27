
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

public class NSFrame : NSFrameType, Frame, TitledFrame, ClosableFrame, CursorFrame, Size, SurfaceContainer
{
	embed "objc" {{{
		#import <Cocoa/Cocoa.h>
	}}}

	embed "objc" {{{
		@interface MyNSView : NSView
		@property void* myframe;
		- (void)layout;
		@end
		@implementation MyNSView
		- (BOOL)acceptsFirstResponder
		{
			return(YES);
		}
		- (BOOL) isFlipped
		{
			return(YES);
		}
		- (BOOL)isOpaque
		{
			return(NO);
		}
		- (void) resetCursorRects
		{
			eq_gui_sysdep_osx_NSFrame_on_reset_cursor_rects(_myframe);
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
			if(_myframe != nil) {
				if(eq_gui_sysdep_osx_NSFrame_on_key_down(_myframe, [event keyCode], (char*)[str UTF8String], flag)) {
					return;
				}
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
			if(_myframe != nil) {
				if(eq_gui_sysdep_osx_NSFrame_on_key_up(_myframe, [event keyCode], (char*)[str UTF8String], flag)) {
					return;
				}
			}
			[super keyUp:event];
		}
		- (void) mouseDown:(NSEvent*)event
		{
			NSPoint cp = [event locationInWindow];
			if(_myframe != nil) {
				if(eq_gui_sysdep_osx_NSFrame_on_mouse_down(_myframe, cp.x, cp.y, 0)) {
					return;
				}
			}
			[super mouseDown:event];
		}
		- (void) mouseUp:(NSEvent*)event
		{
			NSPoint cp = [event locationInWindow];
			if(_myframe != nil) {
				if(eq_gui_sysdep_osx_NSFrame_on_mouse_up(_myframe, cp.x, cp.y, 0)) {
					return;
				}
			}
			[super mouseUp:event];
		}
		- (void) mouseMoved:(NSEvent*)event
		{
			[super mouseMoved:event];
			NSPoint cp = [event locationInWindow];
			if(_myframe != nil) {
				if(eq_gui_sysdep_osx_NSFrame_on_mouse_moved(_myframe, cp.x, cp.y)) {
					return;
				}
			}
		}
		- (void) mouseDragged:(NSEvent*)event
		{
			NSPoint cp = [event locationInWindow];
			if(_myframe != nil) {
				if(eq_gui_sysdep_osx_NSFrame_on_mouse_moved(_myframe, cp.x, cp.y)) {
					return;
				}
			}
			[super mouseDragged:event];
		}
		- (void) rightMouseDown:(NSEvent*)event
		{
			NSPoint cp = [event locationInWindow];
			if(_myframe != nil) {
				if(eq_gui_sysdep_osx_NSFrame_on_mouse_down(_myframe, cp.x, cp.y, 2)) {
					return;
				}
			}
			[super rightMouseDown:event];
		}
		- (void) rightMouseUp:(NSEvent*)event
		{
			NSPoint cp = [event locationInWindow];
			if(_myframe != nil) {
				if(eq_gui_sysdep_osx_NSFrame_on_mouse_up(_myframe, cp.x, cp.y, 2)) {
					return;
				}
			}
			[super rightMouseUp:event];
		}
		- (void) rightMouseDragged:(NSEvent*)event
		{
			NSPoint cp = [event locationInWindow];
			if(_myframe != nil) {
				if(eq_gui_sysdep_osx_NSFrame_on_mouse_moved(_myframe, cp.x, cp.y)) {
					return;
				}
			}
			[super rightMouseDragged:event];
		}
		- (void)scrollWheel:(NSEvent *)event
		{
			NSPoint cp = [event locationInWindow];
			if(_myframe != nil) {
				if(eq_gui_sysdep_osx_NSFrame_on_mouse_wheel(_myframe, cp.x, cp.y, [event deltaX], [event deltaY])) {
					return;
				}
			}
			[super scrollWheel:event];
		}
		- (void)viewDidMoveToWindow
		{
			if(_myframe != nil) {
				eq_gui_sysdep_osx_NSFrame_on_view_window_changed(_myframe);
			}
		}
		- (void)viewWillStartLiveResize
		{
			// FIXME: Optimize resizing
		}
		- (void)viewDidEndLiveResize
		{
			// FIXME: Optimize resizing
		}
		- (void)layout
		{
			[super layout];
			if(_myframe != nil) {
				eq_gui_sysdep_osx_NSFrame_on_resize(_myframe);
			}
		}
		@end
	}}}

	property double width = 0;
	property double height = 0;
	property double scale_factor = 0.0;
	property ptr observer1;
	property ptr observer2;
	property FrameController controller;
	property int dpi = -1;
	property Cursor cursor;
	property ptr nsview;

	public NSFrame() {
		observer1 = null;
		observer2 = null;
		nsview = null;
	}

	public ptr get_nswindow() {
		var nsview = get_nsview();
		if(nsview == null) {
			return(null);
		}
		ptr v;
		embed {{{
			NSWindow* window = [(__bridge NSView*)nsview window];
			v = (__bridge void*)window;
		}}}
		return(v);
	}

	public int get_frame_type() {
		return(Frame.TYPE_DESKTOP);
	}

	public bool has_keyboard() {
		return(true);
	}

	public void on_view_window_changed() {
		if(get_nswindow() == null) {
			on_view_removed_from_window();
		}
		else {
			on_view_added_to_window();
		}
	}

	public virtual ptr create_nsview() {
		ptr vv;
		embed {{{
			MyNSView* mcv = [[MyNSView alloc] init];
			mcv.myframe = ref_eq_api_Object((void*)self);
			[mcv setWantsLayer:YES];
			vv = (__bridge_retained void*)mcv;
		}}}
		return(vv);
	}

	public virtual void on_view_added_to_window() {
		update_window_properties();
		ptr o1p, o2p;
		var myself = this;
		embed {{{
			id o1 = [[[NSWorkspace sharedWorkspace] notificationCenter] addObserverForName:NSWorkspaceWillSleepNotification object:nil queue:nil usingBlock:^(NSNotification* note) {
				eq_gui_sysdep_osx_NSFrame_on_sleep(myself);
			}];
			id o2 = [[[NSWorkspace sharedWorkspace] notificationCenter] addObserverForName:NSWorkspaceDidWakeNotification object:nil queue:nil usingBlock:^(NSNotification* note) {
				eq_gui_sysdep_osx_NSFrame_on_wakeup(myself);
			}];
			o1p = (__bridge_retained void*)o1;
			o2p = (__bridge_retained void*)o2;
		}}}
		observer1 = o1p;
		observer2 = o2p;
		if(controller != null) {
			controller.initialize_frame(this);
			controller.start();
		}
	}

	property bool destroy_when_removed = true;

	public virtual void on_view_removed_from_window() {
		if(controller != null) {
			var cc = controller;
			controller = null;
			cc.stop();
		}
		if(observer1 != null) {
			var o = observer1;
			embed {{{
				id oo = (__bridge_transfer id)o;
				[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:oo];	
			}}}
			observer1 = null;
		}
		if(observer2 != null) {
			var o = observer2;
			embed {{{
				id oo = (__bridge_transfer id)o;
				[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:oo];	
			}}}
			observer2 = null;
		}
		if(destroy_when_removed) {
			destroy();
		}
	}

	public void destroy() {
		if(controller != null) {
			controller.stop();
			controller.destroy();
			controller = null;
		}
		var nsview = get_nsview();
		if(nsview != null) {
			embed {{{
				MyNSView* mcv = (__bridge_transfer MyNSView*)nsview;
				mcv.myframe = unref_eq_api_Object((void*)self);
			}}}
			nsview = null;
		}
	}

	bool _ishidden = false;

	public void on_reset_cursor_rects() {
		int cid = Cursor.STOCK_DEFAULT;
		if(cursor != null) {
			cid = cursor.get_stock_cursor_id();
		}
		var nsv = nsview;;
		var ish = _ishidden;
		embed {{{
			NSView* cv = (__bridge NSWindow*)nsv;
			NSCursor* cc = nil;
			if(cid == eq_gui_Cursor_STOCK_DEFAULT) {
				cc = [NSCursor arrowCursor];
			}
			else if(cid == eq_gui_Cursor_STOCK_NONE) {
				cc = nil;
			}
			else if(cid == eq_gui_Cursor_STOCK_EDITTEXT) {
				cc = [NSCursor IBeamCursor];
			}
			else if(cid == eq_gui_Cursor_STOCK_POINT) {
				cc = [NSCursor pointingHandCursor];
			}
			else if(cid == eq_gui_Cursor_STOCK_RESIZE_HORIZONTAL) {
				cc = [NSCursor resizeLeftRightCursor];
			}
			else if(cid == eq_gui_Cursor_STOCK_RESIZE_VERTICAL) {
				cc = [NSCursor resizeUpDownCursor];
			}
			else {
				cc = [NSCursor arrowCursor];
			}
			if(cc == nil) {
				if(ish == false) {
					[NSCursor hide];
					ish = YES;
				}
			}
			else {
				if(ish == true) {
					[NSCursor unhide];
					ish = NO;
				}
				[cv addCursorRect:[cv visibleRect] cursor:cc];
			}
		}}}
		_ishidden = ish;
	}

	public Cursor get_current_cursor() {
		return(cursor);
	}

	public void set_current_cursor(Cursor cursor) {
		if(this.cursor == cursor) {
			return;
		}
		var nsv = get_nsview();
		var nsw = get_nswindow();
		if(nsv == null || nsw == null) {
			return;
		}
		this.cursor = cursor;
		embed {{{
			NSWindow* win = (__bridge NSWindow*)nsw;
			[win invalidateCursorRectsForView:(__bridge NSView*)nsv];
		}}}
	}

	public void update_window_properties() {
		update_dpi();
		update_scale_factor();
	}

	public virtual void update_size() {
		var nsv = get_nsview();
		if(nsv == null) {
			width = 0;
			height = 0;
		}
		else {
			double w, h;
			var sf = scale_factor;
			embed {{{
				NSView* view = (__bridge NSView*)nsv;
				w = view.bounds.size.width * sf;
				h = view.bounds.size.height * sf;
			}}}
			width = w;
			height = h;
		}
	}

	public virtual void update_dpi() {
		var eqdpi = SystemEnvironment.get_env_var("EQ_DPI");
		if(String.is_empty(eqdpi) == false) {
			dpi = eqdpi.to_integer();
			Log.debug("DPI forced to %d via environment variable EQ_DPI".printf().add(Primitive.for_integer(dpi)));
			return;
		}
		int v = -1;
		var ww = get_nswindow();
		if(ww == null) {
			dpi = 96;
		}
		else {
			embed {{{
				NSWindow* win = (__bridge NSWindow*)ww;
				NSScreen* screen = [win screen];
				NSDictionary* description = [screen deviceDescription];
				NSSize szpx = [[description objectForKey:NSDeviceSize] sizeValue];
				CGSize szph = CGDisplayScreenSize([[description objectForKey:@"NSScreenNumber"] unsignedIntValue]);
				v = (int)([win backingScaleFactor] * 25.4f * (double)szpx.width / (double)szph.width);
			}}}
			if(v < 0) {
				dpi = 96;
			}
			else {
				dpi = v;
			}
		}
		Log.debug("NSFrame DPI detected as %d".printf().add(dpi));
	}

	public virtual void update_scale_factor() {
		var nswindow = get_nswindow();
		if(nswindow == null) {
			scale_factor = 1.0;
		}
		else {
			double v = 1.0;
			var nsw = nswindow;
			embed {{{
				v = [(__bridge NSWindow*)nsw backingScaleFactor];
			}}}
			scale_factor = v;
		}
		Log.debug("NSFrame scale factor now %d".printf().add(dpi));
	}

	Position translate_xy(int x, int y) {
		int rx, ry;
		var view = get_nsview();
		embed {{{
			NSPoint cp = NSMakePoint(x, y);
			cp = [(__bridge NSView*)view convertPoint:cp fromView:nil];
			rx = cp.x;
			ry = cp.y - 1;
		}}}
		var sf = get_scale_factor();
		rx = rx * sf;
		ry = ry * sf;
		return(Position.instance(rx, ry));
	}

	bool is_on_screen(int x, int y) {
		if(x < 0 || y < 0 || x >= get_width() || y >= get_height()) {
			return(false);
		}
		return(true);
	}

	public bool on_mouse_down(int x, int y, int button) {
		var pp = translate_xy(x,y);
		if(is_on_screen(pp.get_x(), pp.get_y()) == false) {
			return(false);
		}
		return(event(new PointerPressEvent().set_button(button+1).set_x(pp.get_x())
			.set_y(pp.get_y()).set_pointer_type(PointerEvent.MOUSE).set_id(0)));
	}

	public bool on_mouse_up(int x, int y, int button) {
		var pp = translate_xy(x,y);
		if(is_on_screen(pp.get_x(), pp.get_y()) == false) {
			return(false);
		}
		return(event(new PointerReleaseEvent().set_button(button+1).set_x(pp.get_x())
			.set_y(pp.get_y()).set_pointer_type(PointerEvent.MOUSE).set_id(0)));
	}

	public bool on_mouse_moved(int x, int y) {
		var pp = translate_xy(x,y);
		if(is_on_screen(pp.get_x(), pp.get_y()) == false) {
			return(false);
		}
		return(event(new PointerMoveEvent().set_x(pp.get_x()).set_y(pp.get_y())
			.set_pointer_type(PointerEvent.MOUSE).set_id(0)));
	}

	public bool on_mouse_wheel(int x, int y, double deltax, double deltay) {
		var pp = translate_xy(x,y);
		if(is_on_screen(pp.get_x(), pp.get_y()) == false) {
			return(false);
		}
		var sf = get_scale_factor();
		return(event(new ScrollEvent().set_x(pp.get_x()).set_y(pp.get_y())
			.set_dx(deltax*sf).set_dy(deltay*sf)));
	}

	String key_name_for_keycode(int keycode) {
		if(keycode == 123) {
			return("left");
		}
		if(keycode == 124) {
			return("right");
		}
		if(keycode == 125) {
			return("down");
		}
		if(keycode == 126) {
			return("up");
		}
		if(keycode == 116) {
			return("pageup");
		}
		if(keycode == 121) {
			return("pagedown");
		}
		if(keycode == 51) {
			return("backspace");
		}
		if(keycode == 53) {
			return("escape");
		}
		if(keycode == 36) {
			return("enter");
		}
		if(keycode == 48) {
			return("tab");
		}
		if(keycode == 49) {
			return("space");
		}
		return(null);
	}

	void fill_key_event(KeyEvent e, int keycode, String str, int modifiers) {
		var name = key_name_for_keycode(keycode);
		if(String.is_empty(name)) {
			name = str;
		}
		e.set_name(name);
		e.set_str(str);
		e.set_keycode(keycode);
		embed "c" {{{
			if(modifiers & NSShiftKeyMask) {
				unref_eq_api_Object(eq_gui_KeyEvent_set_shift(e, 1));
			}
			if(modifiers & NSControlKeyMask) {
				unref_eq_api_Object(eq_gui_KeyEvent_set_ctrl(e, 1));
			}
			if(modifiers & NSAlternateKeyMask) {
				unref_eq_api_Object(eq_gui_KeyEvent_set_alt(e, 1));
			}
			if(modifiers & NSCommandKeyMask) {
				unref_eq_api_Object(eq_gui_KeyEvent_set_command(e, 1));
			}
		}}}
	}

	public bool on_key_down(int keycode, strptr str, int mods) {
		var e = new KeyPressEvent();
		fill_key_event(e, keycode, String.for_strptr(str).dup(), mods);
		return(event(e));
	}

	public bool on_key_up(int keycode, strptr str, int mods) {
		var e = new KeyReleaseEvent();
		fill_key_event(e, keycode, String.for_strptr(str).dup(), mods);
		return(event(e));
	}

	bool event(Object o) {
		if(controller != null) {
			var cc = controller;
			return(cc.on_event(o));
		}
		return(false);
	}

	public void set_icon(Image icon) {
		// it doesn't work this way on OS X
	}

	public void set_title(String title) {
		var nswindow = get_nswindow();
		if(nswindow == null) {
			return;
		}
		var tt = title;
		if(tt == null) {
			tt = "";
		}
		var sp = tt.to_strptr();
		embed {{{
			[(__bridge NSWindow*)nswindow setTitle:[[NSString alloc] initWithUTF8String:sp]];
		}}}
	}

	public Surface add_surface(SurfaceOptions opts) {
		if(opts == null) {
			return(null);
		}
		// NOTE: In this case, NSViewSurface can be either renderable or container
		var ss = NSViewSurface.create(this);
		if(ss == null) {
			return(null);
		}
		var nsview = ss.get_nsview();
		var nsv = get_nsview();
		embed {{{
			NSView* vv = (__bridge NSView*)nsv;
		}}}
		if(opts.get_placement() == SurfaceOptions.TOP) {
			embed {{{
				[vv addSubview:(__bridge NSView*)nsview];
			}}}
		}
		else if(opts.get_placement() == SurfaceOptions.BOTTOM) {
			embed {{{
				NSArray* subviews = [vv subviews];
				if([subviews count] < 1) {
					[vv addSubview:(__bridge NSView*)nsview];
				}
				else {
					NSView* bottom = (NSView*)subviews[0];
					if(bottom == nil) {
						[vv addSubview:(__bridge NSView*)nsview];
					}
					else {
						[vv addSubview:(__bridge NSView*)nsview positioned:NSWindowBelow relativeTo:bottom];
					}
				}
			}}}
		}
		else if(opts.get_placement() == SurfaceOptions.ABOVE) {
			var os = opts.get_relative();
			if(os as NSViewSurface == null) {
				return(add_surface(SurfaceOptions.top()));
			}
			var osview = ((NSViewSurface)os).get_nsview();
			if(osview == null) {
				return(add_surface(SurfaceOptions.top()));
			}
			embed {{{
				NSView* sv = [(__bridge NSView*)osview superview];
				[sv addSubview:(__bridge NSView*)nsview positioned:NSWindowAbove relativeTo:(__bridge NSView*)osview];
			}}}
		}
		else if(opts.get_placement() == SurfaceOptions.BELOW) {
			var os = opts.get_relative();
			if(os as NSViewSurface == null) {
				return(add_surface(SurfaceOptions.bottom()));
			}
			var osview = ((NSViewSurface)os).get_nsview();
			if(osview == null) {
				return(add_surface(SurfaceOptions.bottom()));
			}
			embed {{{
				NSView* sv = [(__bridge NSView*)osview superview];
				[sv addSubview:(__bridge NSView*)nsview positioned:NSWindowBelow relativeTo:(__bridge NSView*)osview];
			}}}
		}
		else if(opts.get_placement() == SurfaceOptions.INSIDE) {
			var os = opts.get_relative();
			if(os as NSViewSurface == null) {
				return(add_surface(SurfaceOptions.top()));
			}
			var osview = ((NSViewSurface)os).get_nsview();
			if(osview == null) {
				return(add_surface(SurfaceOptions.top()));
			}
			embed {{{
				NSView* pv = (__bridge NSView*)osview;
				[pv setWantsLayer:YES];
				pv.layer.masksToBounds = YES;
				NSArray* subviews = [pv subviews];
				if([subviews count] > 0) {
					NSView* bottom = (NSView*)subviews[0];
					[pv addSubview:(__bridge NSView*)nsview positioned:NSWindowBelow relativeTo:bottom];
				}
				else {
					[pv addSubview:(__bridge NSView*)nsview];
				}
			}}}
		}
		return(ss);
	}

	public void remove_surface(Surface ss) {
		if(ss as NSViewSurface != null) {
			((NSViewSurface)ss).destroy();
		}
	}

	public void on_backing_properties_changed() {
		update_window_properties();
	}

	public void on_sleep() {
		if(controller != null) {
			controller.stop();
		}
	}

	public void on_wakeup() {
		if(controller != null && get_nswindow() != null) {
			controller.start();
		}
	}

	public bool on_resize() {
		update_size();
		return(event(new FrameResizeEvent().set_width(get_width()).set_height(get_height())));
	}

	public void close() {
	}
}
