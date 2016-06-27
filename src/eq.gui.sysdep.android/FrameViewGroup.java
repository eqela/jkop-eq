
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

package eq.gui.sysdep.android;

import android.graphics.*;
import android.content.Context;
import android.view.View;
import android.view.Display;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.MotionEvent;
import eq.gui.*;

public class FrameViewGroup extends android.view.ViewGroup implements ClosableFrame, Frame, SurfaceContainer, Size 
{
	private android.widget.PopupWindow parentpopup;
	private FrameViewGroup parentview;
	private android.app.Activity myactivity;
	private FrameController controller;
	android.view.View bottomview = null;
	private java.util.LinkedList<FrameViewGroup> frame_children;
	private boolean lockbottomview = false;
	private android.view.ScaleGestureDetector sgd;
	private int dpi = -1;
	private boolean enable_android_measurements = true;

	public FrameViewGroup(android.app.Activity ctx) {
		super(ctx);
		myactivity = ctx;
	}

	public void set_enable_android_measurements(boolean v) {
		enable_android_measurements = v;
	}

	public int get_frame_type() {
		int sz = getResources().getConfiguration().screenLayout & android.content.res.Configuration.SCREENLAYOUT_SIZE_MASK;
		if(sz == android.content.res.Configuration.SCREENLAYOUT_SIZE_LARGE ||
			sz == android.content.res.Configuration.SCREENLAYOUT_SIZE_XLARGE) {
			return(eq.gui.Frame.Static.TYPE_TABLET);
		}
		return(eq.gui.Frame.Static.TYPE_PHONE);
	}

	public boolean has_keyboard() {
		return(false);
	}

	public void lock_bottom_view() {
		lockbottomview = true;
	}

	public void set_bottom_view(android.view.View bview) {
		if(lockbottomview) {
			return;
		}
		if(bottomview != null) {
			removeView(bottomview);
		}
		bottomview = bview;
		if(bottomview != null) {
			addView(bottomview);
			resize_bottomview();
		}
		onSizeChanged(getWidth(), getHeight(), getWidth(), getHeight());
	}

	public android.view.View get_bottom_view() {
		return(bottomview);
	}

	public void set_parent_popup(android.widget.PopupWindow parentpopup) {
		this.parentpopup = parentpopup;
	}

	public void set_parent_view(FrameViewGroup parentview) {
		this.parentview = parentview;
	}

	public boolean event(eq.api.Object e) {
		if(controller != null) {
			return(controller.on_event(e));
		}
		return(false);
	}

	void resize_bottomview() {
		if(bottomview == null) {
			return;
		}
		bottomview.measure(
			android.view.View.MeasureSpec.makeMeasureSpec(0, android.view.View.MeasureSpec.UNSPECIFIED),
			android.view.View.MeasureSpec.makeMeasureSpec(0, android.view.View.MeasureSpec.UNSPECIFIED)
		);
		int hr = bottomview.getMeasuredHeight();
		bottomview.layout(0, getHeight()-hr, getWidth(), getHeight());
	}

	class MyPopupDismissListener implements android.widget.PopupWindow.OnDismissListener
	{
		FrameViewGroup viewgroup;
		public MyPopupDismissListener(FrameViewGroup vg) {
			this.viewgroup = vg;
		}
		public void onDismiss() {
			this.viewgroup.on_dismiss_popup();
		}
	}

	static private class MyRect
	{
		public int x;
		public int y;
		public int w;
		public int h;
	}

	MyRect get_popup_dimensions() {
		if(controller == null || parentview == null) {
			return(null);
		}
		int x = 0;
		int y = 0;
		int w = 320;
		int h = 180;
		Size sz = controller.get_preferred_size();
		if(sz != null) {
			w = (int)sz.get_width();
			h = (int)sz.get_height();
		}
		boolean fs = false;
		Rect r = new Rect();
		parentview.getWindowVisibleDisplayFrame(r);
		int screen_width = r.right - r.left;
		int screen_height = r.bottom - r.top;
		if(get_frame_type() == eq.gui.Frame.Static.TYPE_PHONE) {
			fs = true;
		}
		else if(w > screen_width || h > screen_height) {
			fs = true;
		}
		if(fs) {
			x = r.left;
			y = r.top;
			w = r.right-r.left;
			h = r.bottom-r.top;
		}
		else {
			x = (r.right - r.left) / 2 - w/2;
			y = (r.bottom - r.top) / 2 - h/2;
		}
		MyRect v = new MyRect();
		v.x=x;
		v.y=y;
		v.w=w;
		v.h=h;
		return(v);
	}

	public boolean initialize(FrameController controller, FrameViewGroup parent) {
		if(controller == null) {
			return(false);
		}
		this.controller = controller;
		try {
			sgd = new android.view.ScaleGestureDetector(myactivity, new AndroidViewScaleGestureListener(controller));
		}
		catch(NoClassDefFoundError e) {
			AndroidLogger.error("Scale gesture detector could not be created. Perhaps this Android is an old version?");
			sgd = null;
		}
		AndroidLogger.debug("FrameViewGroup initializing controller. DPI = " + get_dpi());
		controller.initialize_frame(this);
		if(parent != null) {
			parentview = parent;
			parentview.add_child_frame(this);
			MyRect dims = get_popup_dimensions();
			parentpopup = new android.widget.PopupWindow(this, dims.w, dims.h, true);
			android.content.res.Resources res = eq.api.Android.context.getResources();
			if(res != null) {
				String resid = eq.api.Application.Static.get_name().to_strptr() + ":style/eqelapopupwindowanimation";
				int aid = res.getIdentifier(resid, null, null);
				if(aid >= 0) {
					parentpopup.setAnimationStyle(aid);
				}
				else {
					AndroidLogger.error("FAILED to find resource ID for PopupWindow animation: " + resid);
				}
			}
			parentpopup.setClippingEnabled(false);
			parentpopup.setOnDismissListener(new MyPopupDismissListener(this));
			parentpopup.showAtLocation(parentview, android.view.Gravity.NO_GRAVITY, dims.x, dims.y);
			controller.start();
		}
		return(true);
	}

	public FrameController get_controller() {
		return(controller);
	}

	private eq.api.Object eqstr(java.lang.String s) {
		return((eq.api.Object)eq.api.String.Static.for_strptr(s));
	}

	public boolean on_key_down(int keyCode, android.view.KeyEvent event) {
		if(frame_children != null) {
			for(FrameViewGroup fvg : frame_children) {
				if(fvg.on_key_down(keyCode, event)) {
					return(true);
				}
			}
		}
		KeyPressEvent e = new KeyPressEvent();
		key_event(keyCode, event, e);
		boolean h = event(e);
		if(h == false && keyCode == event.KEYCODE_BACK) {
		    myactivity.onBackPressed();
		    return(true);
		}
		return(h);
	}

	public boolean on_key_up(int keyCode, android.view.KeyEvent event) {
		if(frame_children != null) {
			for(FrameViewGroup fvg : frame_children) {
				if(fvg.on_key_up(keyCode, event)) {
					return(true);
				}
			}
		}
		KeyReleaseEvent e = new KeyReleaseEvent();
		key_event(keyCode, event, e);
		return(event(e));
	}

	private void key_event(int keyCode, android.view.KeyEvent event, KeyEvent e) {
		java.lang.String keyName = null;
		eq.api.String keyStr = (eq.api.String)eqstr(java.lang.Character.toString((char)event.getUnicodeChar()));
		if(keyCode == event.KEYCODE_BACK) {
			keyName = "back";
			keyStr = null;
		}
		else if(keyCode == event.KEYCODE_DEL) {
			keyName = "backspace";
			keyStr = null;
		}
		else if(keyCode == event.KEYCODE_ENTER) {
			keyName = "enter";
			keyStr = null;
		}
		else if(keyCode == event.KEYCODE_TAB) {
			keyName = "tab";
			keyStr = null;
		}
		else if(keyCode == event.KEYCODE_DPAD_RIGHT) {
			keyName = "right";
			keyStr = null;
		}
		else if(keyCode == event.KEYCODE_DPAD_LEFT) {
			keyName = "left";
			keyStr = null;
		}
		else if(keyCode == event.KEYCODE_DPAD_UP) {
			keyName = "up";
			keyStr = null;
		}
		else if(keyCode == event.KEYCODE_DPAD_DOWN) {
			keyName = "down";
			keyStr = null;
		}
		else if(keyCode == event.KEYCODE_VOLUME_DOWN) {
			keyName = "volume-down";
			keyStr = null;
		}
		else if(keyCode == event.KEYCODE_VOLUME_UP) {
			keyName = "volume-up";
			keyStr = null;
		}
		else if(keyCode == event.KEYCODE_SHIFT_LEFT || keyCode == event.KEYCODE_SHIFT_RIGHT) {
			keyStr = null;
		}
		e.set_name((eq.api.String)eqstr(keyName));
		e.set_str(keyStr);
		if(event.isShiftPressed()) {
			e.set_shift(true);
		}
	}

	public void close() {
		if(parentpopup!=null) {
			parentpopup.setOnDismissListener(null);
			on_dismiss_popup();
			parentpopup.dismiss();
		}
	}

	public void on_dismiss_popup() {
		if(controller != null) {
			controller.stop();
			controller.destroy();
			controller = null;
		}
		if(parentview != null) {
			parentview.remove_child_frame(this);
		}
	}

	public void stop() {
		if(controller != null) {
			controller.stop();
		}
	}

	public void start() {
		if(controller != null) {
			controller.start();
		}
	}

	public double get_width() {
		return((double)getWidth());
	}

	public double get_height() {
		return((double)get_effective_height());
	}

	public int get_dpi() {
		if(dpi < 0) {
			android.util.DisplayMetrics metrics = new android.util.DisplayMetrics();
			myactivity.getWindowManager().getDefaultDisplay().getMetrics(metrics);
			dpi = (int)metrics.xdpi;
		}
		return(dpi);
	}

	protected void onLayout(boolean changed, int l, int t, int r, int b) {
		if(enable_android_measurements) {
			int count = getChildCount();
			for (int i = 0; i < count; i++) {
				View child = getChildAt(i);
				if(child.getVisibility() != GONE) {
					child.layout(child.getLeft(), child.getTop(), child.getRight(), child.getBottom());
				}
			}
		}
		resize_bottomview();
	}

	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		if(enable_android_measurements) {
			int count = getChildCount();
			for (int i = 0; i < count; i++) {
				View child = getChildAt(i);
				measureChild(child, widthMeasureSpec, heightMeasureSpec);
			}
			setMeasuredDimension(MeasureSpec.getSize(widthMeasureSpec),
				MeasureSpec.getSize(heightMeasureSpec));
		}
		else {
			super.onMeasure(widthMeasureSpec, heightMeasureSpec);
		}
	}

	public void update_popup() {
		if(parentpopup != null) {
			MyRect dims = get_popup_dimensions();
			if(dims != null) {
				parentpopup.update(dims.x, dims.y, dims.w, dims.h, true);
			}
		}
	}

	public void add_child_frame(FrameViewGroup fvg) {
		if(frame_children  == null) {
			frame_children = new java.util.LinkedList<FrameViewGroup>();
		}
		frame_children.add(fvg);
	}

	public void remove_child_frame(FrameViewGroup fvg) {
		if(frame_children != null) {
			frame_children.remove(fvg);
		}
	}

	public double get_effective_height() {
		double hh = getHeight();
		if(bottomview != null) {
			hh -= bottomview.getHeight();
		}
		return(hh);
	}

	protected void onSizeChanged(int w, int h, int oldw, int oldh) {
		super.onSizeChanged(w,h,oldw,oldh);
		resize_bottomview();
		FrameResizeEvent e = new FrameResizeEvent();
		e.set_width((double)w);
		double hh = h;
		if(bottomview != null) {
			hh -= bottomview.getHeight();
		}
		e.set_height(hh);
		if(frame_children != null) {
			for(FrameViewGroup fvg : frame_children) {
				fvg.update_popup();
			}
		}
		event(e);
	}

	PointerPressEvent ppe = new PointerPressEvent();
	PointerReleaseEvent pre = new PointerReleaseEvent();
	PointerLeaveEvent ple = new PointerLeaveEvent();
	PointerMoveEvent pme = new PointerMoveEvent();

	public boolean onTouchEvent(android.view.MotionEvent event) {
		if(sgd != null) {
			try {
				// Funny. The gesture detector sometimes crashes
				// when tapping wildly. Prevent it from taking down
				// the app.
				if(sgd.onTouchEvent(event)) {
				}
			}
			catch(Exception e) {
				AndroidLogger.error("OnTouchEvent problems");
			}
		}
		int em = event.getActionMasked();
		int idx = event.getPointerId(event.getActionIndex());
		if(em == android.view.MotionEvent.ACTION_DOWN) {
			ppe.set_button(1);
			ppe.set_id(idx);
			ppe.set_x((int)event.getX());
			ppe.set_y((int)event.getY());
			ppe.set_pointer_type(PointerEvent.Static.TOUCH);
			event(ppe);
		}
		else if(em == android.view.MotionEvent.ACTION_UP) {
			pre.set_button(1);
			pre.set_id(idx);
			pre.set_x((int)event.getX());
			pre.set_y((int)event.getY());
			pre.set_pointer_type(PointerEvent.Static.TOUCH);
			event(pre);
			ple.set_id(idx);
			ple.set_x((int)event.getX());
			ple.set_y((int)event.getY());
			ple.set_pointer_type(PointerEvent.Static.TOUCH);
			event(ple);
		}
		else if(em == android.view.MotionEvent.ACTION_MOVE) {
			pme.set_id(idx);
			pme.set_x((int)event.getX());
			pme.set_y((int)event.getY());
			pme.set_pointer_type(PointerEvent.Static.TOUCH);
			event(pme);
		}
		return(true);
	}

	View create_surface_view(eq.gui.SurfaceOptions opts) {
		if(opts == null) {
			return(null);
		}
		eq.gui.Surface ss = opts.get_surface();
		if(ss != null && ss instanceof AndroidViewProvider) {
			return(((AndroidViewProvider)ss).get_android_view());
		}
		if(ss != null && ss instanceof View) {
			return((View)ss);
		}
		if(opts.get_surface_type() == eq.gui.SurfaceOptions.Static.SURFACE_TYPE_CONTAINER) {
			ContainerSurfaceView csv = new ContainerSurfaceView(myactivity);
			csv.enable_android_measurements = enable_android_measurements;
			return(csv);
		}
		return(new RenderableSurfaceView(myactivity));
	}

	public Surface add_surface(eq.gui.SurfaceOptions opts) {
		View vv = do_add_surface(opts);
		if(vv == null) {
			return(null);
		}
		if(vv instanceof Surface) {
			return((Surface)vv);
		}
		if(opts != null) {
			return(opts.get_surface());
		}
		return(null);		
	}

	View do_add_surface(eq.gui.SurfaceOptions opts) {
		if(opts.get_placement() == eq.gui.SurfaceOptions.Static.TOP) {
			return(add_surface_top(opts));
		}
		else if(opts.get_placement() == eq.gui.SurfaceOptions.Static.BOTTOM) {
			return(add_surface_bottom(opts));
		}
		else if(opts.get_placement() == eq.gui.SurfaceOptions.Static.ABOVE) {
			return(add_surface_above(opts.get_relative(), opts));
		}
		else if(opts.get_placement() == eq.gui.SurfaceOptions.Static.BELOW) {
			return(add_surface_below(opts.get_relative(), opts));
		}
		else if(opts.get_placement() == eq.gui.SurfaceOptions.Static.INSIDE) {
			return(add_surface_inside(opts.get_relative(), opts));
		}
		return(null);
	}

	View add_surface_top(eq.gui.SurfaceOptions opts) {
		View view = create_surface_view(opts);
		if(view == null) {
			return(null);
		}
		addView(view);
		return(view);
	}

	View add_surface_bottom(eq.gui.SurfaceOptions opts) {
		View view = create_surface_view(opts);
		if(view == null) {
			return(null);
		}
		addView(view, 0);
		return(view);
	}

	View add_surface_above(Surface ss, eq.gui.SurfaceOptions opts) {
		if(ss == null || ss instanceof View == false) {
			AndroidLogger.debug("Add surface above error 1");
			return(add_surface_top(opts));
		}
		ViewGroup vg = get_parent_view_group((View)ss);
		if(vg == null) {
			AndroidLogger.debug("Add surface above error 2");
			return(add_surface_top(opts));
		}
		int ssi = vg.indexOfChild((View)ss);
		if(ssi < 0) {
			AndroidLogger.debug("Add surface above error 3");
			return(add_surface_top(opts));
		}
		View view = create_surface_view(opts);
		if(view == null) {
			return(null);
		}
		vg.addView(view, ssi+1);
		return(view);
	}

	View add_surface_below(Surface ss, eq.gui.SurfaceOptions opts) {
		if(ss == null || ss instanceof View == false) {
			AndroidLogger.debug("Add surface below error 1");
			return(add_surface_top(opts));
		}
		ViewGroup vg = get_parent_view_group((View)ss);
		if(vg == null) {
			AndroidLogger.debug("Add surface below error 2");
			return(add_surface_top(opts));
		}
		int ssi = vg.indexOfChild((View)ss);
		if(ssi < 0) {
			return(add_surface_top(opts));
		}
		View view = create_surface_view(opts);
		if(view == null) {
			return(null);
		}
		vg.addView(view, ssi);
		return(view);
	}

	View add_surface_inside(Surface ss, eq.gui.SurfaceOptions opts) {
		if(ss == null || ss instanceof ViewGroup == false) {
			AndroidLogger.error("Attempted to add a surface inside a non-container surface. Adding above instead.");
			return(add_surface_above(ss, opts));
		}
		View view = create_surface_view(opts);
		if(view == null) {
			return(null);
		}
		((ViewGroup)ss).addView(view, 0);
		return(view);
	}

	public void remove_surface(Surface ss) {
		if(ss == null) {
			return;
		}
		if(ss instanceof View == false) {
			return;
		}
		ViewGroup vg = get_parent_view_group((View)ss);
		if(vg != null) {
			vg.removeView((View)ss);
		}
	}

	public ViewGroup get_parent_view_group(View vv) {
		if(vv == null) {
			return(null);
		}
		ViewParent vp = vv.getParent();
		if(vp == null) {
			return(null);
		}
		if(vp instanceof ViewGroup == false) {
			AndroidLogger.error("Surface view has a parent that is not a view group (?)");
			return(null);
		}
		return((ViewGroup)vp);
	}
}
