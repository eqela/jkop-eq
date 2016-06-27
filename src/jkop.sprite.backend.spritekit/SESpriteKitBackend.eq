
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

public class SESpriteKitBackend : SEBackend
{
	public static SESpriteKitBackend instance(Frame fr, bool debug = false) {
		var v = new SESpriteKitBackend();
		if(debug) {
			v.set_debug(debug);
		}
		v.set_frame(fr);
		return(v.initialize());
	}

	IFDEF("target_osx") {
		embed {{{
			#include <Cocoa/Cocoa.h>
		}}}
	}

	IFDEF("target_ios") {
		embed {{{
			#include <UIKit/UIKit.h>
		}}}
	}

	property bool debug = false;

	public SESpriteKitBackend() {
		if("yes".equals(SystemEnvironment.get_env_var("EQ_SPRITEKIT_DEBUG"))) {
			debug = true;
		}
	}

	embed {{{
		#import <SpriteKit/SpriteKit.h>
		@interface MyScene : SKScene
		{
			@public void* ec;
			int first;
		}
		@end
		@implementation MyScene
		-(id)initWithSize:(CGSize)size {    
			if(self = [super initWithSize:size]) {
				self.backgroundColor = [SKColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
				self.scaleMode = SKSceneScaleModeAspectFill;
				self->first = 1;
			}
			return(self);
		}
		- (void)update:(NSTimeInterval)currentTime
		{
			if(first == 1) {
				first = 0;
				return;
			}
			jkop_sprite_backend_spritekit_SESpriteKitBackend_on_update(ec);
		}
		@end
	}}}

	IFDEF("target_osx") { embed {{{
		@interface MySKView : SKView
		@property void* myframe;
		@end
		@implementation MySKView
		- (BOOL) acceptsFirstResponder
		{
			return(NO);
		}
		- (void) keyDown:(NSEvent*)event
		{
			[[self nextResponder] keyDown:event];
		}
		- (void) keyUp:(NSEvent*)event
		{
			[[self nextResponder] keyUp:event];
		}
		- (void) mouseDown:(NSEvent*)event
		{
			[[self nextResponder] mouseDown:event];
		}
		- (void) mouseUp:(NSEvent*)event
		{
			[[self nextResponder] mouseUp:event];
		}
		- (void) mouseMoved:(NSEvent*)event
		{
			[[self nextResponder] mouseMoved:event];
		}
		- (void) mouseDragged:(NSEvent*)event
		{
			[[self nextResponder] mouseDragged:event];
		}
		- (void) rightMouseDown:(NSEvent*)event
		{
			[[self nextResponder] rightMouseDown:event];
		}
		- (void) rightMouseUp:(NSEvent*)event
		{
			[[self nextResponder] rightMouseUp:event];
		}
		- (void) rightMouseDragged:(NSEvent*)event
		{
			[[self nextResponder] rightMouseDragged:event];
		}
		- (void)scrollWheel:(NSEvent *)event
		{
			[[self nextResponder] scrollWheel:event];
		}
		- (void) resetCursorRects
		{
			eq_gui_sysdep_osx_NSWindowFrame_on_reset_cursor_rects(_myframe);
		}
		@end
	}}} }

	public void on_touch_begin(int id, int x, int y) {
		var sescene = get_sescene();
		if(sescene != null) {
			sescene.on_event(new PointerMoveEvent().set_id(id)
				.set_x(x).set_y(y).set_pointer_type(PointerEvent.TOUCH));
			sescene.on_event(new PointerPressEvent().set_button(1).set_id(id)
				.set_x(x).set_y(y).set_pointer_type(PointerEvent.TOUCH));
		}
	}

	public void on_touch_move(int id, int x, int y) {
		var sescene = get_sescene();
		if(sescene != null) {
			sescene.on_event(new PointerMoveEvent().set_id(id)
				.set_x(x).set_y(y).set_pointer_type(PointerEvent.TOUCH));
		}
	}

	public void on_touch_end(int id, int x, int y) {
		var sescene = get_sescene();
		if(sescene != null) {
			sescene.on_event(new PointerReleaseEvent().set_button(1).set_id(id)
				.set_x(x).set_y(y).set_pointer_type(PointerEvent.TOUCH));
			sescene.on_event(new PointerLeaveEvent().set_x(x)
				.set_y(y).set_pointer_type(PointerEvent.TOUCH).set_id(id));
		}
	}

	IFDEF("target_ios") { embed {{{
		@interface MySKView : SKView
		{
			@public void* backend;
			@public double scalefactor;
		}
		@end
		@implementation MySKView
		- (BOOL) acceptsFirstResponder
		{
			return(NO);
		}
		- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
			for(UITouch* touch in touches) {
				CGPoint tapPoint = [touch locationInView:self];
				jkop_sprite_backend_spritekit_SESpriteKitBackend_on_touch_begin(backend, (int)touch, scalefactor*tapPoint.x, scalefactor*tapPoint.y);
			}
		}
		- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
			for(UITouch* touch in touches) {
				CGPoint tapPoint = [touch locationInView:self];
				jkop_sprite_backend_spritekit_SESpriteKitBackend_on_touch_move(backend, (int)touch, scalefactor*tapPoint.x, scalefactor*tapPoint.y);
			}
		}
		- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
			for(UITouch* touch in touches) {
				CGPoint tapPoint = [touch locationInView:self];
				jkop_sprite_backend_spritekit_SESpriteKitBackend_on_touch_end(backend, (int)touch, scalefactor*tapPoint.x, scalefactor*tapPoint.y);
			}
		}
		- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
			for(UITouch* touch in touches) {
				CGPoint tapPoint = [touch locationInView:self];
				jkop_sprite_backend_spritekit_SESpriteKitBackend_on_touch_end(backend, (int)touch, scalefactor*tapPoint.x, scalefactor*tapPoint.y);
			}
		}
		@end
	}}} }

	ptr skview;
	ptr skscene;
	ptr contentview;
	bool started = false;

	public void on_update() {
		var se = get_sescene();
		if(se != null) {
			se.tick();
		}
	}

	public SEResourceCache create_resource_cache() {
		return(new SESpriteKitResourceCache());
	}

	IFDEF("target_osx") {
		public SESpriteKitBackend initialize() {
			var frame = this.get_frame() as NSWindowFrame;
			if(frame == null || frame.get_width() < 1 || frame.get_height() < 1) {
				Log.warning("SpriteKit backend: No frame");
				return(null);
			}
			update_resource_cache();
			var nsw = frame.get_nswindow();
			if(nsw == null) {
				Log.warning("SpriteKit backend: No NSWindow for frame");
				return(null);
			}
			var ww = frame.get_width();
			var hh = frame.get_height();
			ptr p, sp, cv;
			var myself = this;
			var dbg = this.debug;
			embed {{{
				MySKView* skview = [[MySKView alloc] initWithFrame:CGRectMake(0, 0, ww, hh)];
				skview.myframe = frame;
				if(dbg) {
					skview.showsFPS = YES;
					skview.showsNodeCount = YES;
				}
				MyScene* scene = [MyScene sceneWithSize:CGSizeMake(ww, hh)];
				if(scene == nil) {
					return(NULL);
				}
				scene->ec = myself;
				NSView* cvv = [(__bridge NSWindow*)nsw contentView];
				if(cvv != nil) {
					cv = (__bridge_retained void*)cvv;
				}
				[(__bridge NSWindow*)nsw setContentView:skview];
				p = (__bridge_retained void*)skview;
				sp = (__bridge_retained void*)scene;
				[skview presentScene:scene];
			}}}
			this.skview = p;
			this.skscene = sp;
			this.contentview = cv;
			this.started = true;
			Log.debug("Sprite Kit backend initialized.");
			return(this);
		}
	}

	IFDEF("target_ios") {
		ptr viewcontroller;
		public SESpriteKitBackend initialize() {
			embed {{{
				if(NSClassFromString(@"SKView") == nil) {
					return(nil);
				}
			}}}
			var frame = this.get_frame() as UIKitFrame;
			if(frame == null || frame.get_width() < 1 || frame.get_height() < 1) {
				Log.warning("SpriteKit backend: No frame");
				return(null);
			}
			update_resource_cache();
			var vc = frame.get_view_controller();
			if(vc == null) {
				Log.warning("SpriteKit backend: No view controller for frame");
				return(null);
			}
			var ww = frame.get_content_width();
			var hh = frame.get_content_height();
			ptr p, sp, cv;
			var myself = this;
			var dbg = this.debug;
			embed {{{
				double scale = (double)[[UIScreen mainScreen] scale];
				MySKView* skview = [[MySKView alloc] initWithFrame:CGRectMake(0, 0, ww/scale, hh/scale)];
				skview->backend = myself;
				skview->scalefactor = scale;
				skview.multipleTouchEnabled = YES;
				if(dbg) {
					skview.showsFPS = YES;
					skview.showsNodeCount = YES;
				}
				MyScene* scene = [MyScene sceneWithSize:CGSizeMake(ww, hh)];
				scene->ec = myself;
				UIView* cvv = [(__bridge UIViewController*)vc view];
				if(cvv != nil) {
					cv = (__bridge_retained void*)cvv;
				}
				[cvv addSubview:skview];
				[skview presentScene:scene];
				p = (__bridge_retained void*)skview;
				sp = (__bridge_retained void*)scene;
			}}}
			this.skview = p;
			this.skscene = sp;
			this.contentview = cv;
			this.viewcontroller = vc;
			this.started = true;
			Log.debug("Sprite Kit backend initialized.");
			return(this);
		}
	}

	public bool is_high_performance() {
		return(true);
	}

	public void start(SEScene scene) {
		base.start(scene);
		if(started) {
			return;
		}
		this.started = true;
		if(skview != null) {
			var sk = skview;
			embed {{{
				[(__bridge SKView*) sk setPaused:NO];
			}}}
		}
	}

	public void stop() {
		base.stop();
		if(started == false) {
			return;
		}
		this.started = false;
		if(skview != null) {
			var sk = skview;
			embed {{{
				[(__bridge SKView*) sk setPaused:YES];
			}}}
		}
	}

	public void cleanup() {
		stop();
		if(skview != null) {
			var p = skview;
			embed {{{
				SKView* sk = (__bridge_transfer SKView*)p;
				[sk removeFromSuperview];
			}}}
			skview = null;
		}
		if(skscene != null) {
			var p = skscene;
			embed {{{
				(__bridge_transfer MyScene*)p;
			}}}
			skscene = null;
		}
		IFDEF("target_osx") {
			var frame = this.get_frame() as NSWindowFrame;
			if(frame != null && contentview != null) {
				var cv = contentview;
				embed {{{
					NSView* cvv = (__bridge_transfer NSView*)cv;
				}}}
				var nsw = frame.get_nswindow();
				if(nsw != null) {
					embed {{{
						[(__bridge NSWindow*)nsw setContentView:cvv];
					}}}
				}
				contentview = null;
			}
			frame = null;
		}
		IFDEF("target_ios") {
			viewcontroller = null;
		}
		base.cleanup();
		Log.debug("Sprite Kit backend cleaned up.");
	}

	public SESprite add_sprite() {
		var v = new SESpriteKitSprite();
		v.set_rsc(get_resource_cache());
		v.set_parent(skscene);
		return(v);
	}

	public SESprite add_sprite_for_image(SEImage image) {
		var v = new SESpriteKitSprite();
		v.set_rsc(get_resource_cache());
		v.set_parent(skscene);
		v.set_image(image);
		return(v);
	}
	
	public SESprite add_sprite_for_text(String text, String fontid) {
		var v = new SESpriteKitSprite();
		v.set_rsc(get_resource_cache());
		v.set_parent(skscene);
		v.set_text(text, fontid);
		return(v);
	}
	
	public SESprite add_sprite_for_color(Color color, double width, double height) {
		var v = new SESpriteKitSprite();
		v.set_rsc(get_resource_cache());
		v.set_parent(skscene);
		v.set_color(color, width, height);
		return(v);
	}
	
	public SELayer add_layer(double x, double y, double width, double height, bool force_clipped) {
		SESpriteKitLayer v;
		if(force_clipped) {
			v = new SESpriteKitClippedLayer();
		}
		else {
			v = new SESpriteKitLayer();
		}
		v.set_rsc(get_resource_cache());
		v.set_parent(skscene);
		v.resize(width, height);
		v.move(x, y);
		return(v);
	}
}
