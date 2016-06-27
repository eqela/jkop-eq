
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

public class NSWindowFrame : Frame, TitledFrame, ResizableFrame, HidableFrame, ClosableFrame,
	CursorFrame, DesktopWindowFrame, Size, SurfaceContainer, FocusAwareFrame, SizeConstrainedFrame,
	NSFrameType
{
	public static NSWindowFrame create(FrameController fc, CreateFrameOptions opts = null) {
		var v = new NSWindowFrame();
		if(v.initialize(fc, opts) == false) {
			v = null;
		}
		return(v);
	}

	embed "objc" {{{
		#import <Cocoa/Cocoa.h>
		#import "MyWindowDelegate.h"
	}}}

	double width = 0;
	double height = 0;
	double scale_factor = 0.0;
	ptr observer1;
	ptr observer2;
	property FrameController controller;
	property ptr nswindow;
	property ptr delegate;
	property ptr parentnswindow;
	property Frame parentframe;
	int dpi = -1;
	Cursor cursor;
	Collection menus;
	EventReceiver menulistener;
	ptr menubar_handler = null;
	static ptr windowsmenu = null;
	static int windowsmenu_entries = 0;

	public NSWindowFrame() {
		observer1 = null;
		observer2 = null;
		ptr mbh;
		embed {{{
			MyMenuBarActionHandler* mah = [[MyMenuBarActionHandler alloc] init];
			mah->frame = self;
			mbh = (__bridge_retained void*)mah;
		}}}
		menubar_handler = mbh;
	}

	public ~NSWindowFrame() {
		var mbh = menubar_handler;
		if(mbh != null) {
			embed {{{
				(__bridge_transfer MyMenuBarActionHandler*)mbh;
			}}}
			menubar_handler = null;
		}
		close();
		if(delegate != null) {
			var del = delegate;
			delegate = null;
			embed {{{
				MyWindowDelegate* dd = (__bridge_transfer MyWindowDelegate*)del;
				dd = nil;
			}}}
		}
		dpi = -1;
	}

	public void set_menus(Collection menus, EventReceiver evr) {
		this.menus = menus;
		this.menulistener = evr;
		update_menubar();
	}

	public void on_window_became_key() {
		update_menubar();
	}

	public void on_window_resign_key() {
	}

	public void on_menubar_action(ActionItem ai) {
		if(ai != null) {
			if(ai.execute()) {
				return;
			}
			if(menulistener != null) {
				var ee = ai.get_event();
				if(ee != null) {
					menulistener.on_event(ee);
				}
			}
		}
	}

	embed {{{
		@interface MyMenuBarActionHandler : NSObject
		{
			@public void* frame;
		}
		@end
		@implementation MyMenuBarActionHandler
		- (void) on_action:(NSMenuItem*)item
		{
			if(frame != nil) {
				eq_gui_sysdep_osx_NSWindowFrame_on_menubar_action(frame, (void*)[item tag]);
			}
		}
		@end
	}}}

	void update_menubar() {
		var nsw = nswindow;
		if(nsw == null) {
			return;
		}
		embed {{{
			if([(__bridge NSWindow*)nsw isKeyWindow] == NO) {
				return;
			}
		}}}
		var appname = Application.get_display_name();
		if(appname == null) {
			appname = "Application";
		}
		var appnames = appname.to_strptr();
		var mah = menubar_handler;
		embed {{{
			NSMenu* menubar = [NSApp mainMenu];
			[NSApp setHelpMenu:nil];
			[menubar removeAllItems];
			NSString* appns = [[NSString alloc] initWithUTF8String:appnames];
			NSMenu* appmenu = [[NSMenu alloc] initWithTitle:@""];
			NSMenuItem* appmenuitem = [[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""];
		}}}
		Iterator mit;
		bool f = false;
		if(menus != null) {
			mit = menus.iterate();
			var nmenu = mit.next() as Menu;
			if(nmenu != null) {
				foreach(Object o in nmenu.get_items()) {
					if(o is ActionItem) {
						var ai = (ActionItem)o;
						var tt = ai.get_text();
						var ss = ai.get_shortcut();
						if(String.is_empty(tt) == false) {
							if(ss == null) {
								ss = "";
							}
							var ttp = tt.to_strptr();
							var ssp = ss.to_strptr();
							embed {{{
								NSMenuItem* nmi = [appmenu addItemWithTitle:[[NSString alloc] initWithUTF8String:ttp] action:@selector(on_action:) keyEquivalent:[[NSString alloc] initWithUTF8String:ssp]];
								[nmi setTarget:(__bridge MyMenuBarActionHandler*)mah];
								[nmi setTag:(NSInteger)o];
							}}}
							f = true;
						}
					}
					else if(o is SeparatorItem) {
						embed {{{
							[appmenu addItem:[NSMenuItem separatorItem]];
						}}}
					}
				}
			}
		}
		if(f == false) {
			embed {{{
				[appmenu addItemWithTitle:[@"Quit " stringByAppendingString:appns] action:@selector(terminate:) keyEquivalent:@"q"];
			}}}
		}
		embed {{{
			[menubar addItem:appmenuitem];
			[menubar setSubmenu:appmenu forItem:appmenuitem];
		}}}
		foreach(Menu menu in mit) {
			var tit = menu.get_title();
			if(String.is_empty(tit)) {
				continue;
			}
			var titp = tit.to_strptr();
			if(titp == null) {
				continue;
			}
			embed {{{
				NSString* mt = [[NSString alloc] initWithUTF8String:titp];
				NSMenu* mm;
			}}}
			bool is_window_menu = false;
			if("Window".equals(tit)) {
				var wmm = windowsmenu;
				int ee = windowsmenu_entries;
				embed {{{
					mm = (__bridge NSMenu*)wmm;
					while(ee > 0) {
						[mm removeItemAtIndex:0];
						ee--;
					}
				}}}
				windowsmenu_entries = 0;
				is_window_menu = true;
			}
			else {
				embed {{{
					mm = [[NSMenu alloc] initWithTitle:mt];
				}}}
			}
			embed {{{
				NSMenuItem* mi = [[NSMenuItem alloc] initWithTitle:mt action:NULL keyEquivalent:@""];
				[mi setSubmenu:mm];
				[menubar addItem:mi];
			}}}
			int idx = 0;
			foreach(Object o in menu.get_items()) {
				if(o is ActionItem) {
					var ai = (ActionItem)o;
					var tt = ai.get_text();
					var ss = ai.get_shortcut();
					if(String.is_empty(tt) == false) {
						if(ss == null) {
							ss = "";
						}
						var ttp = tt.to_strptr();
						var ssp = ss.to_strptr();
						embed {{{
							NSMenuItem* nmi = [mm insertItemWithTitle:[[NSString alloc] initWithUTF8String:ttp] action:@selector(on_action:) keyEquivalent:[[NSString alloc] initWithUTF8String:ssp] atIndex:idx];
							[nmi setTarget:(__bridge MyMenuBarActionHandler*)mah];
							[nmi setTag:(NSInteger)o];
						}}}
						idx ++;
					}
				}
				else if(o is SeparatorItem) {
					embed {{{
						[mm insertItem:[NSMenuItem separatorItem] atIndex:idx];
					}}}
					idx ++;
				}
				else {
					continue;
				}
				if(is_window_menu) {
					windowsmenu_entries ++;
				}
			}
			if("Help".equals(tit)) {
				embed {{{
					[NSApp setHelpMenu:mm];
				}}}
			}
		}
	}

	public int get_frame_type() {
		return(Frame.TYPE_DESKTOP);
	}

	public bool has_keyboard() {
		return(true);
	}

	public double get_scale_factor() {
		return(scale_factor);
	}

	public double do_get_scale_factor() {
		if(nswindow == null) {
			return(1.0);
		}
		double v = 1.0;
		var nsw = nswindow;
		embed {{{
			v = [(__bridge NSWindow*)nsw backingScaleFactor];
		}}}
		return(v);
	}

	public bool on_mouse_down(int x, int y, int button) {
		var sf = get_scale_factor();
		var yy = get_height()-y*sf;
		if(yy < 0) {
			return(false);
		}
		return(event(new PointerPressEvent().set_button(button+1).set_x(x*sf)
			.set_y(yy).set_pointer_type(PointerEvent.MOUSE).set_id(0)));
	}

	public bool on_mouse_up(int x, int y, int button) {
		var sf = get_scale_factor();
		return(event(new PointerReleaseEvent().set_button(button+1).set_x(x*sf)
			.set_y(get_height()-y*sf).set_pointer_type(PointerEvent.MOUSE).set_id(0)));
	}

	public bool on_mouse_moved(int x, int y) {
		var sf = get_scale_factor();
		return(event(new PointerMoveEvent().set_x(x*sf).set_y(get_height()-y*sf)
			.set_pointer_type(PointerEvent.MOUSE).set_id(0)));
	}

	public bool on_mouse_wheel(int x, int y, double deltax, double deltay) {
		var sf = get_scale_factor();
		return(event(new ScrollEvent().set_x(x*sf).set_y(get_height()-y*sf)
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

	embed "objc" {{{
		@interface MyWindow : NSWindow
		@property void* myframe;
		@end
		@implementation MyWindow
		- (BOOL) canBecomeKeyWindow
		{
			return YES;
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
				if(eq_gui_sysdep_osx_NSWindowFrame_on_key_down(_myframe, [event keyCode], (char*)[str UTF8String], flag)) {
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
				if(eq_gui_sysdep_osx_NSWindowFrame_on_key_up(_myframe, [event keyCode], (char*)[str UTF8String], flag)) {
					return;
				}
			}
			[super keyUp:event];
		}
		- (void) mouseDown:(NSEvent*)event
		{
			NSPoint cp = [event locationInWindow];
			if(_myframe != nil) {
				if(eq_gui_sysdep_osx_NSWindowFrame_on_mouse_down(_myframe, cp.x, cp.y, 0)) {
					return;
				}
			}
			[super mouseDown:event];
		}
		- (void) mouseUp:(NSEvent*)event
		{
			NSPoint cp = [event locationInWindow];
			if(_myframe != nil) {
				if(eq_gui_sysdep_osx_NSWindowFrame_on_mouse_up(_myframe, cp.x, cp.y, 0)) {
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
				eq_gui_sysdep_osx_NSWindowFrame_on_mouse_moved(_myframe, cp.x, cp.y);
			}
		}
		- (void) mouseDragged:(NSEvent*)event
		{
			NSPoint cp = [event locationInWindow];
			if(_myframe != nil) {
				if(eq_gui_sysdep_osx_NSWindowFrame_on_mouse_moved(_myframe, cp.x, cp.y)) {
					return;
				}
			}
			[super mouseDragged:event];
		}
		- (void) rightMouseDown:(NSEvent*)event
		{
			NSPoint cp = [event locationInWindow];
			if(_myframe != nil) {
				if(eq_gui_sysdep_osx_NSWindowFrame_on_mouse_down(_myframe, cp.x, cp.y, 2)) {
					return;
				}
			}
			[super rightMouseDown:event];
		}
		- (void) rightMouseUp:(NSEvent*)event
		{
			NSPoint cp = [event locationInWindow];
			if(_myframe != nil) {
				if(eq_gui_sysdep_osx_NSWindowFrame_on_mouse_up(_myframe, cp.x, cp.y, 2)) {
					return;
				}
			}
			[super rightMouseUp:event];
		}
		- (void) rightMouseDragged:(NSEvent*)event
		{
			NSPoint cp = [event locationInWindow];
			if(_myframe != nil) {
				if(eq_gui_sysdep_osx_NSWindowFrame_on_mouse_moved(_myframe, cp.x, cp.y)) {
					return;
				}
			}
			[super rightMouseDragged:event];
		}
		- (void)scrollWheel:(NSEvent *)event
		{
			NSPoint cp = [event locationInWindow];
			if(_myframe != nil) {
				if(eq_gui_sysdep_osx_NSWindowFrame_on_mouse_wheel(_myframe, cp.x, cp.y, [event deltaX], [event deltaY])) {
					return;
				}
			}
			[super scrollWheel:event];
		}
		@end
	}}}

	embed "objc" {{{
		@interface MyContentView : NSView
		@property void* myframe;
		@end
		@implementation MyContentView
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
			eq_gui_sysdep_osx_NSWindowFrame_on_reset_cursor_rects(_myframe);
		}
		@end
	}}}

	public void on_focus_reset() {
		if(nswindow != null) {
			var w = nswindow;
			embed {{{
				[(__bridge NSWindow*)w makeFirstResponder:nil];
			}}}
		}
	}

	int compute_dpi() {
		if(nswindow == null) {
			return(-1);
		}
		int v = -1;
		var ww = nswindow;
		embed {{{
			NSWindow* win = (__bridge NSWindow*)ww;
			NSScreen* screen = [win screen];
			NSDictionary* description = [screen deviceDescription];
			NSSize szpx = [[description objectForKey:NSDeviceSize] sizeValue];
			CGSize szph = CGDisplayScreenSize([[description objectForKey:@"NSScreenNumber"] unsignedIntValue]);
			v = (int)([win backingScaleFactor] * 25.4f * (double)szpx.width / (double)szph.width);
		}}}
		return(v);
	}

	public bool initialize(FrameController fc, CreateFrameOptions aopts) {
		if(controller != null || fc == null) {
			return(false);
		}
		var opts = aopts;
		if(opts == null && fc != null) {
			opts = fc.get_frame_options();
		}
		if(opts == null) {
			opts = new CreateFrameOptions();
		}
		ptr nsw;
		ptr del;
		controller = fc;
		int screenindex = -1;
		if(opts != null) {
			var s = opts.get_screen() as OSXWindowManagerScreen;
			if(s != null) {
				screenindex = s.get_index();
			}
		}
		embed {{{
			NSWindow* w;
			NSRect scrr;
		}}}
		int screenwidth, screenheight;
		if(screenindex < 0) {
			embed {{{
				scrr = [[NSScreen mainScreen] frame];
			}}}
		}
		else {
			embed {{{
				NSArray* screens = [NSScreen screens];
				if(screenindex >= [screens count]) {
					scrr = [[NSScreen mainScreen] frame];
				}
				else {
					scrr = [(NSScreen*)screens[screenindex] frame];
				}
			}}}
		}
		embed {{{
			screenwidth = scrr.size.width;
			screenheight = scrr.size.height;
		}}}
		String screeninfo;
		if(screenindex < 0) {
			screeninfo = "default display";
		}
		else if(screenindex == 0) {
			screeninfo = "main display";
		}
		else {
			screeninfo = "on external display %d".printf().add(screenindex).to_string();
		}
		bool sheet = false;
		if(opts.get_type() == CreateFrameOptions.TYPE_FULLSCREEN) {
			Log.debug("Creating a full screen window on ".append(screeninfo));
			embed {{{
				w = [[MyWindow alloc] initWithContentRect:scrr
					styleMask:NSBorderlessWindowMask
					backing:NSBackingStoreBuffered defer:YES];
				[w setPreferredBackingLocation:NSWindowBackingLocationVideoMemory];
				[w setLevel:NSMainMenuWindowLevel+1];
				if(screenindex < 1) {
					[w setHidesOnDeactivate:YES];
				}
			}}}
		}
		else if(opts.get_type() == CreateFrameOptions.TYPE_SPLASH) {
			Log.debug("Creating a splash window on ".append(screeninfo));
			embed {{{
				w = [[MyWindow alloc] initWithContentRect:CGRectMake(0,0,1,1)
					styleMask:0
					backing:NSBackingStoreBuffered defer:YES];
				[w setPreferredBackingLocation:NSWindowBackingLocationVideoMemory];
				[w setLevel:NSMainMenuWindowLevel+1];
			}}}
		}
		else if(opts != null && opts.get_parent() != null) {
			Log.debug("Creating a child window on ".append(screeninfo));
			embed {{{
				w = [[MyWindow alloc] initWithContentRect:CGRectMake(0,0,1,1)
					styleMask:0
					backing:NSBackingStoreBuffered defer:YES];
				[w setPreferredBackingLocation:NSWindowBackingLocationVideoMemory];
			}}}
			sheet = true;
		}
		else {
			Log.debug("Creating a normal window on ".append(screeninfo));
			int mask;
			if(opts.get_resizable()) {
				embed {{{
					mask = NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask;
				}}}
			}
			else {
				embed {{{
					mask = NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask;
				}}}
			}
			embed {{{
				w = [[MyWindow alloc] initWithContentRect:CGRectMake(0,0,1,1)
					styleMask:mask
					backing:NSBackingStoreBuffered defer:YES];
				[w setPreferredBackingLocation:NSWindowBackingLocationVideoMemory];
			}}}
		}
		embed {{{
			[w setAutorecalculatesKeyViewLoop:YES];
		}}}
		var minsz = opts.get_minimum_size();
		if(minsz != null) {
			set_minimum_size(minsz.get_width(), minsz.get_height());
		}
		var maxsz = opts.get_maximum_size();
		if(maxsz != null) {
			set_maximum_size(maxsz.get_width(), maxsz.get_height());
		}
		embed {{{
			[w setReleasedWhenClosed: NO];
			((MyWindow*)w).myframe = (void*)self;
			MyWindowDelegate* dd = [[MyWindowDelegate alloc] init];
			dd.windowframe = (void*)self;
			w.delegate = dd;
			MyContentView* mcv = [[MyContentView alloc] init];
			mcv.myframe = (void*)self;
			[mcv setWantsLayer:YES];
			[w setContentView:mcv];
		}}}
		if(sheet == false) {
			embed {{{
				[w setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
			}}}
		}
		embed {{{
			[w setTitle:@"Eqela Window"];
			nsw = (__bridge_retained void*)w;
			del = (__bridge_retained void*)dd;
		}}}
		if(windowsmenu == null) {
			ptr wmm;
			embed {{{
				NSMenu* windowmenu = [[NSMenu alloc] initWithTitle:@"Window"];
				[NSApp setWindowsMenu:windowmenu];
				wmm = (__bridge_retained void*)windowmenu;
			}}}
			windowsmenu = wmm;
		}
		nswindow = nsw;
		delegate = del;
		scale_factor = do_get_scale_factor();
		screenwidth = scale_factor * screenwidth;
		screenheight = scale_factor * screenheight;
		Log.debug("OSX Window Frame initializing: DPI=%d, scale factor=%f".printf().add(get_dpi()).add(get_scale_factor()));
		Log.debug("Screen height detected as %dx%d".printf().add(screenwidth).add(screenheight));
		var eqdpi = SystemEnvironment.get_env_var("EQ_DPI");
		if(String.is_empty(eqdpi) == false) {
			this.dpi = eqdpi.to_integer();
			Log.debug("DPI forced to %d via environment variable EQ_DPI".printf().add(Primitive.for_integer(dpi)));
		}
		controller.initialize_frame(this);
		if(opts.get_type() == CreateFrameOptions.TYPE_FULLSCREEN) {
			width = do_get_width();
			height = do_get_height();
			event(new FrameResizeEvent().set_width(get_width()).set_height(get_height()));
		}
		else {
			int rw = 640, rh = 480;
			var psz = opts.get_default_size();
			if(psz == null) {
				psz = fc.get_preferred_size();
			}
			if(psz != null) {
				rw = psz.get_width();
				rh = psz.get_height();
			}
			if(rw < 64 * scale_factor) {
				rw = 640 * scale_factor;
			}
			if(rh < 64 * scale_factor) {
				rh = 480 * scale_factor;
			}
			if(rw > screenwidth) {
				rw = screenwidth;
			}
			if(rh > screenheight) {
				rh = screenheight;
			}
			Log.debug("Configuring normal main window as %dx%d".printf().add(rw).add(rh));
			embed {{{
				CGFloat ss = [w backingScaleFactor];
				CGFloat xw = rw / ss, xh = rh / ss;
				NSScreen* myscreen = [w screen];
				[w setContentSize:CGSizeMake(xw, xh)];
				// center on screen
				[w setFrameOrigin:CGPointMake(myscreen.frame.size.width/2 - xw/2, myscreen.frame.size.height/2 - xh/2)];
			}}}
		}
		bool opened = false;
		if(opts != null && opts.get_parent() != null) {
			NSWindowFrame parent;
			var ppx = opts.get_parent();
			while(ppx != null && parent == null) {
				if(ppx is NSWindowFrame) {
					parent = (NSWindowFrame)ppx;
					continue;
				}
				if(ppx is NSViewFrame) {
					ppx = ((NSViewFrame)ppx).get_parent_frame();
					continue;
				}
				break;
			}
			if(parent != null) {
				var pp = parent;
				while(pp != null) {
					var px = pp.get_parentframe() as NSWindowFrame;
					if(px != null) {
						pp = px;
						continue;
					}
					break;
				}
				var pnsw = pp.get_nswindow();
				if(pnsw != null) {
					embed {{{
						NSWindow* www = (__bridge NSWindow*)pnsw;
						if([www respondsToSelector:@selector(beginCriticalSheet: completionHandler:)]) {
							[www beginCriticalSheet:w completionHandler:^(NSModalResponse resp) {
								[www makeKeyAndOrderFront:nil];
								[www becomeFirstResponder];
							}];
							[w setAcceptsMouseMovedEvents:YES];
						}
						else {
							[NSApp beginSheet:w modalForWindow:www modalDelegate:nil didEndSelector:nil contextInfo:nil];
							[www makeKeyAndOrderFront:nil];
							[www becomeFirstResponder];
						}
					}}}
					set_parentnswindow(pnsw);
					set_parentframe(pp);
					opened = true;
				}
			}
		}
		if(opened == false) {
			embed {{{
				// this displays the window
				[w makeKeyAndOrderFront:nil];
				[w setAcceptsMouseMovedEvents:YES];
			}}}
		}
		ptr o1p, o2p;
		var myself = this;
		embed {{{
			id o1 = [[[NSWorkspace sharedWorkspace] notificationCenter] addObserverForName:NSWorkspaceWillSleepNotification object:nil queue:nil usingBlock:^(NSNotification* note) {
				eq_gui_sysdep_osx_NSWindowFrame_on_sleep(myself);
			}];
			id o2 = [[[NSWorkspace sharedWorkspace] notificationCenter] addObserverForName:NSWorkspaceDidWakeNotification object:nil queue:nil usingBlock:^(NSNotification* note) {
				eq_gui_sysdep_osx_NSWindowFrame_on_wakeup(myself);
			}];
			o1p = (__bridge_retained void*)o1;
			o2p = (__bridge_retained void*)o2;
		}}}
		observer1 = o1p;
		observer2 = o2p;
		controller.start();
		Log.debug("OSX Window Frame successfully created.");
		return(nswindow != null);
	}

	public int get_dpi() {
		if(dpi < 0) {
			dpi = compute_dpi();
		}
		return(dpi);
	}

	public double get_width() {
		return(width);
	}

	public void set_minimum_size(int w, int h) {
		var nsw = nswindow;
		embed {{{
			NSWindow* win = (__bridge NSWindow*)nsw;
			CGFloat ss = [win backingScaleFactor];
			[win setMinSize:NSMakeSize(w / ss, h / ss)];
		}}}
	}

	public void set_maximum_size(int w, int h) {
		var nsw = nswindow;
		embed {{{
			NSWindow* win = (__bridge NSWindow*)nsw;
			CGFloat ss = [win backingScaleFactor];
			[win setMaxSize:NSMakeSize(w / ss, h / ss)];
		}}}
	}

	public double do_get_width() {
		double v;
		var nsw = nswindow;
		embed {{{
			NSWindow* win = (__bridge NSWindow*)nsw;
			NSSize wsz = [[win contentView] frame].size;
			v = wsz.width * [win backingScaleFactor];
		}}}
		return(v);
	}

	public double get_height() {
		return(height);
	}

	public double do_get_height() {
		double v;
		var nsw = nswindow;
		embed {{{
			NSWindow* win = (__bridge NSWindow*)nsw;
			NSSize wsz = [[win contentView] frame].size;
			v = wsz.height * [win backingScaleFactor];
		}}}
		return(v);
	}

	bool _ishidden = false;

	public void on_reset_cursor_rects() {
		int cid = Cursor.STOCK_DEFAULT;
		if(cursor != null) {
			cid = cursor.get_stock_cursor_id();
		}
		var nsw = nswindow;
		var ish = _ishidden;
		embed {{{
			NSView* cv = [(__bridge NSWindow*)nsw contentView];
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
		this.cursor = cursor;
		var nsw = nswindow;
		embed {{{
			NSWindow* win = (__bridge NSWindow*)nsw;
			[win invalidateCursorRectsForView:win.contentView];
		}}}
	}

	public void set_icon(Image icon) {
		// it doesn't work this way on OS X
	}

	public void set_title(String title) {
		if(nswindow == null) {
			return;
		}
		var tt = title;
		if(tt == null) {
			tt = "";
		}
		var sp = tt.to_strptr();
		var nsw = nswindow;
		embed {{{
			[(__bridge NSWindow*)nsw setTitle:[[NSString alloc] initWithUTF8String:sp]];
		}}}
	}

	bool event(Object o) {
		if(controller != null) {
			var cc = controller;
			return(cc.on_event(o));
		}
		return(false);
	}

	public bool on_close_request() {
		var ce = new FrameCloseRequestEvent();
		event(ce);
		return(ce.get_accepted());
	}

	public void on_window_will_close() {
		if(controller != null) {
			var cc = controller;
			controller = null;
			cc.stop();
			cc.destroy();
		}
	}

	public bool on_resize() {
		width = do_get_width();
		height = do_get_height();
		return(event(new FrameResizeEvent().set_width(get_width()).set_height(get_height())));
	}

	public void on_backing_properties_changed() {
		scale_factor = do_get_scale_factor();
		dpi = compute_dpi();
		Log.debug("Screen backing properties changed: DPI=%d, scale factor=%f".printf().add(dpi).add(scale_factor));
	}

	public void resize(int w, int h) {
		var nsw = nswindow;
		embed {{{
			NSWindow* win = (__bridge NSWindow*)nsw;
			CGFloat ss = [win backingScaleFactor];
			[win setContentSize:CGSizeMake(w / ss, h / ss)];
		}}}
	}

	public void on_sleep() {
		if(controller != null) {
			controller.stop();
		}
	}

	public void on_wakeup() {
		if(controller != null) {
			controller.start();
		}
	}

	public void hide() {
		var nsw = nswindow;
		embed {{{
			[(__bridge NSWindow*)nsw orderOut:nil];
		}}}
	}

	public void show() {
		var nsw = nswindow;
		embed {{{
			[(__bridge NSWindow*)nsw makeKeyAndOrderFront:nil];
		}}}
	}

	public void close() {
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
		if(nswindow != null) {
			var nsw = nswindow;
			nswindow = null;
			var pnsw = parentnswindow;
			if(pnsw != null) {
				on_window_will_close();
				embed {{{
					if([(__bridge NSWindow*)pnsw respondsToSelector:@selector(endSheet:)]) {
						NSWindow* kw = [[NSApplication sharedApplication] keyWindow];
						NSWindow* uw = (__bridge_transfer NSWindow*)nsw;
						[(__bridge NSWindow*)pnsw endSheet:uw];
						// HACK: endSheet has a nasty side effect of bringing the window hosting the sheet
						// to the front. In those cases, we restore the previously fronted window right back:
						if(kw != nil && kw != [[NSApplication sharedApplication] keyWindow] && kw != uw) {
							[kw makeKeyAndOrderFront:nil];
						}
						uw = nil;
					}
					else {
						NSWindow* uw = (__bridge_transfer NSWindow*)nsw;
						[NSApp endSheet: uw];
						[uw orderOut:nil];
						uw = nil;
					}
				}}}
				parentnswindow = null;
			}
			else {
				embed {{{
					NSWindow* uw = (__bridge_transfer NSWindow*)nsw;
					[((MyWindow*)uw) setMyframe:nil];
					[uw close];
					uw = nil;
				}}}
			}
		}
		if(parentframe != null) {
			parentframe = null;
		}
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
		var nsw = nswindow;
		embed {{{
			NSWindow* uw = (__bridge NSWindow*)nsw;
			NSView* vv = [uw contentView];
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
}
