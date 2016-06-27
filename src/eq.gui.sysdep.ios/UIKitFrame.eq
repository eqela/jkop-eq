
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

public class UIKitFrame : Frame, Size, SurfaceContainer
{
	embed "objc" {{{
		#import <UIKit/UIKit.h>
	}}}

	public static UIKitFrame create(FrameController fc) {
		var v = new UIKitFrame();
		if(v.do_create(fc) == false) {
			v = null;
		}
		return(v);
	}

	embed "objc" {{{
		@interface MyContainerView : UIView
		@end
		@implementation MyContainerView
		@end
	}}}

	property FrameController controller;
	int dpi = 0;
	int width = 0;
	int height = 0;
	double scale;
	property int frame_width;
	property int frame_height;
	property ptr myview;
	ptr bottom_element;
	property bool is_popup = false;
	property bool is_ipad = false;
	property bool is_popup_fullscreen = false;

	~UIKitFrame() {
		destroy();
	}

	public int get_frame_type() {
		if(is_ipad) {
			return(Frame.TYPE_TABLET);
		}
		return(Frame.TYPE_PHONE);
	}

	public bool has_keyboard() {
		return(false);
	}

	public void destroy() {
		if(myview != null) {
			var uw = myview;
			embed {{{
				(__bridge_transfer UIView*)uw;
			}}}
			myview = null;
		}
		controller = null;
	}

	public void event(Object o) {
		if(controller != null) {
			controller.on_event(o);
		}
	}

	public bool do_create(FrameController fc) {
		if(controller != null || fc == null) {
			return(false);
		}
		controller = fc;
		int w, h;
		// FIXME: Move the device detection from here to somewhere that only executes
		// once. No need to detect on the opening of every frame.
		double w2, h2, tdpi = 0, ss;
		embed "objc" {{{
			CGRect screenBounds = [[UIScreen mainScreen] bounds];
			CGFloat scale = [[UIScreen mainScreen] scale];
			w = (int)(screenBounds.size.width * scale);
			h = (int)(screenBounds.size.height * scale);
			ss = (double)scale;
		}}}
		this.scale = ss;
		String dev;
		if((w == 320 && h == 480) || (w == 480 && h == 320)) { // iPhone 3
			dpi = 163;
			dev = "iPhone 3 or earlier";
		}
		else if((w == 640 && h == 960) || (w == 960 && h == 640)) { // iPhone 4 / 4S
			dpi = 326;
			dev = "iPhone 4 / 4S";
		}
		else if((w == 640 && h == 1136) || (w == 1136 && h == 640)) { // iPhone 5 / 5S / 5C
			dpi = 326;
			dev = "iPhone 5 / 5S / 5C";
		}
		else if((w == 1024 && h == 768) || (w == 768 && h == 1024)) { // iPad 1 / 2
			dpi = 132;
			dev = "iPad 1 / 2 / Mini";
			// FIXME: iPad Mini is also 1024x768, but dpi is 163
			set_is_ipad(true);
		}
		else if((w == 2048 && h == 1536) || (w == 1536 && h == 2048)) { // iPad 3 / 4 / Air
			dpi = 264;
			dev = "iPad 3 / 4 / Air";
			set_is_ipad(true);
		}
		else {
			dpi = 326;
			dev = "iUnknown";
		}
		Log.debug("Device assumed to be `%s' (%d DPI, %dx%d pixels; scale factor %f)".printf().add(dev).add(dpi).add(w).add(h).add(scale));
		ptr uw;
		embed {{{
			UIView* myvv = [[MyContainerView alloc] init];
			myvv.autoresizesSubviews = NO;
			uw = (__bridge_retained void*)myvv;
		}}}
		this.myview = uw;
		return(true);
	}

	int kbwidth = 0;
	int kbheight = 0;

	void do_update_frame_size() {
		int w, h;
		var scale = this.scale;
		var myview = this.myview;
		embed {{{
			CGRect frameBounds = [(__bridge UIView*)myview bounds];
			w = (int)(frameBounds.size.width * scale);
			h = (int)(frameBounds.size.height * scale);
		}}}
		this.frame_width = (int)w;
		this.frame_height = (int)h;
	}

	public void update_frame_size() {
		var w = frame_width, h = frame_height;
		do_update_frame_size();
		if(w != frame_width || h != frame_height) {
			on_size_changed();
		}
	}

	void apply_preferred_size() {
		if(is_popup && is_popup_fullscreen == false && is_ipad && controller != null) {
			var prefsize = controller.get_preferred_size();
			if(prefsize != null) {
				var vc = get_view_controller();
				var szw = prefsize.get_width(), szh = prefsize.get_height();
				var scale = this.scale;
				embed {{{
					UIViewController* uvc = (__bridge UIViewController*)vc;
					uvc.view.superview.bounds = CGRectMake(0, 0, szw / scale, szh / scale);
				}}}
			}
		}
	}

	bool _controller_initialized = false;
	public void initialize() {
		if(controller == null) {
			return;
		}
		apply_preferred_size();
		do_update_frame_size();
		controller.initialize_frame(this);
		_controller_initialized = true;
		apply_preferred_size();
		do_update_frame_size();
		on_size_changed();
	}

	 void on_size_changed() {
		if(_controller_initialized == false) {
			return;
		}
		var w = frame_width;
		var h = frame_height;
		if(bottom_element != null) {
			var be = bottom_element;
			var scale = this.scale;
			embed {{{
				UIView* bev = (__bridge UIView*)be;
				h -= (bev.bounds.size.height * scale);
			}}}
		}
		Log.debug("UIKitFrame size changed: Now %dx%d pixels".printf().add(frame_width).add(frame_height));
		this.width = w;
		this.height = h;
		var mv = myview;
		var scale = this.scale;
		var hh = frame_height;
		embed {{{
			UIView* vv = (__bridge UIView*)mv;
			vv.bounds = CGRectMake(0, 0, w/scale, hh/scale);
		}}}
		int rh = h;
		if(is_ipad == false || is_popup == false || is_popup_fullscreen == true) {
			int kbh;
			if(orientation_is_landscape) {
				kbh = kbwidth;
			}
			else {
				kbh = kbheight;
			}
			rh -= kbh;
		}
		position_bottom_element();
		event(new FrameResizeEvent().set_width(w).set_height(rh));
	}

	public double get_content_height() {
		return(height);
	}

	public double get_content_width() {
		return(width);
	}

	public void set_bottom_element(ptr element) {
		if(bottom_element != null) {
			var be = bottom_element;
			embed {{{
				UIView* v = (__bridge_transfer UIView*)be;
				[v removeFromSuperview];
			}}}
			bottom_element = null;
		}
		if(element == null || myview == null) {
			return;
		}
		var mv = myview;
		embed {{{
			UIView* mvs = (__bridge UIView*)mv;
			[mvs addSubview:(__bridge UIView*)element];
		}}}
		bottom_element = element;
		on_size_changed();
	}

	void position_bottom_element() {
		if(bottom_element == null) {
			return;
		}
		var w = frame_width;
		var h = frame_height;
		var be = bottom_element;
		var scale = this.scale;
		embed {{{
			UIView* bev = (__bridge UIView*)be;
			double hh = bev.bounds.size.height;
			[bev setFrame:CGRectMake(0, h/scale-hh, w/scale, hh)];
		}}}
	}

	bool orientation_is_landscape = false;

	public void on_orientation_change(bool landscape) {
		orientation_is_landscape = landscape;
		update_frame_size();
	}

	public void on_keyboard_shown(int kbwidth, int kbheight) {
		if(this.kbwidth > 0 && this.kbheight > 0) {
			return;
		}
		var scale = this.scale;
		this.kbwidth = kbwidth * scale;
		this.kbheight = kbheight * scale;
		do_update_frame_size();
		on_size_changed();
	}

	public void on_keyboard_hidden() {
		if(kbwidth < 1 && kbheight < 1) {
			return;
		}
		this.kbwidth = 0;
		this.kbheight = 0;
		on_size_changed();
	}

	public void start() {
		if(controller != null) {
			controller.start();
		}
	}

	public void stop() {
		if(controller != null) {
			controller.stop();
		}
	}

	public double get_width() {
	       return(width);
	}

	public double get_height() {
	       return(height);
	}

	public int get_dpi() {
		return(dpi);
	}

	public Surface add_surface(SurfaceOptions opts) {
		if(opts == null) {
			return(null);
		}
		var sss = opts.get_surface();
		if(sss == null) {
			sss = new UIViewQuartzSurface();
		}
		var ss = sss as UIViewSurface;
		if(ss == null) {
			return(null);
		}
		if(ss.initialize(this) == false) {
			Log.error("Failed to initialize surface");
			return(null);
		}
		var uiview = ss.get_uiview();
		var uiw = myview;
		embed {{{
			UIView* vv = (__bridge UIView*)uiw;
		}}}
		if(opts.get_placement() == SurfaceOptions.TOP) {
			embed {{{
				[vv addSubview:(__bridge UIView*)uiview];
			}}}
		}
		else if(opts.get_placement() == SurfaceOptions.BOTTOM) {
			embed {{{
				NSArray* subviews = [vv subviews];
				if(subviews == nil || [subviews count] < 1) {
					[vv addSubview:(__bridge UIView*)uiview];
				}
				else {
					UIView* bottom = (UIView*)[subviews objectAtIndex:0];
					if(bottom == nil) {
						[vv addSubview:(__bridge UIView*)uiview];
					}
					else {
						[vv insertSubview:(__bridge UIView*)uiview belowSubview:bottom];
					}
				}
			}}}
		}
		else if(opts.get_placement() == SurfaceOptions.ABOVE) {
			var os = opts.get_relative();
			if(os as UIViewSurface == null) {
				return(add_surface(SurfaceOptions.top()));
			}
			var osview = ((UIViewSurface)os).get_uiview();
			if(osview == null) {
				return(add_surface(SurfaceOptions.top()));
			}
			embed {{{
				UIView* sv = [(__bridge UIView*)osview superview];
				[sv insertSubview:(__bridge UIView*)uiview aboveSubview:(__bridge UIView*)osview];
			}}}
		}
		else if(opts.get_placement() == SurfaceOptions.BELOW) {
			var os = opts.get_relative();
			if(os as UIViewSurface == null) {
				return(add_surface(SurfaceOptions.bottom()));
			}
			var osview = ((UIViewSurface)os).get_uiview();
			if(osview == null) {
				return(add_surface(SurfaceOptions.bottom()));
			}
			embed {{{
				UIView* sv = [(__bridge UIView*)osview superview];
				[sv insertSubview:(__bridge UIView*)uiview belowSubview:(__bridge UIView*)osview];
			}}}
		}
		else if(opts.get_placement() == SurfaceOptions.INSIDE) {
			var os = opts.get_relative();
			if(os as UIViewSurface == null) {
				return(add_surface(SurfaceOptions.top()));
			}
			var osview = ((UIViewSurface)os).get_uiview();
			if(osview == null) {
				return(add_surface(SurfaceOptions.top()));
			}
			embed {{{
				UIView* pv = (__bridge UIView*)osview;
				pv.layer.masksToBounds = YES;
				NSArray* subviews = [pv subviews];
				if([subviews count] > 0) {
					UIView* bottom = (UIView*)[subviews objectAtIndex:0];
					[pv insertSubview:(__bridge UIView*)uiview belowSubview:bottom];
				}
				else {
					[pv addSubview:(__bridge UIView*)uiview];
				}
			}}}
		}
		return(ss);
	}

	public void remove_surface(Surface ss) {
		if(ss as UIViewSurface != null) {
			((UIViewSurface)ss).destroy();
		}
	}

	property ptr eqela_view_controller;

	public ptr get_view_controller() {
		if(eqela_view_controller != null) {
			return(eqela_view_controller);
		}
		var mv = myview;
		ptr uivc;
		embed {{{
			UIResponder* r = (__bridge UIView*)mv;
			while(true) {
				if(r == nil) {
					break;
				}
				if([r isKindOfClass:[UIViewController class]]) {
					break;
				}
				r = [r nextResponder];
			}
			if(r != nil) {
				uivc = (__bridge void*)r;
			}
		}}}
		return(uivc);
	}
}
