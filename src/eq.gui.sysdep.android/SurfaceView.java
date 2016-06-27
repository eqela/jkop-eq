
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

import eq.gui.*;
import android.view.View;
import android.view.ViewGroup;
import android.view.MotionEvent;
import android.view.ViewParent;

public class SurfaceView extends android.view.View implements Surface, Size, Position
{
	SurfaceViewHelper helper;
	FrameViewGroup vg;

	public SurfaceView(android.content.Context ctx) {
		super(ctx);
		helper = new SurfaceViewHelper(this);
		vg = (FrameViewGroup)((FrameActivity)ctx).get_viewgroup();
	}

	public double get_width() { return(helper.get_width()); }
	public double get_height() { return(helper.get_height()); }
	public double get_x() { return(helper.get_x()); }
	public double get_y() { return(helper.get_y()); }
	public void move(double x, double y) { helper.move(x,y); }
	public void resize(double w, double h) { helper.resize(w,h); }
	public void move_resize(double x, double y, double w, double h) { helper.move_resize(x,y,w,h); }
	public void set_scale(double sx, double sy) { helper.set_scale(sx, sy); }
	public void set_alpha(double f) { helper.set_alpha(f); }
	public void set_rotation_angle(double aa) { helper.set_rotation_angle(aa); }
	public double get_scale_x() { return(helper.get_scale_x()); }
	public double get_scale_y() { return(helper.get_scale_y()); }
	public double get_alpha() { return(helper.get_alpha()); }
	public double get_rotation_angle() { return(helper.get_rotation_angle()); }

	public void onWindowFocusChanged(boolean hasWindowFocus) {
	}

	protected void onAttachedToWindow() {
		ViewParent vp = getParent();
		while(true) {
			if(vp instanceof FrameViewGroup || vp == null) {
				break;
			}
			vp = vp.getParent();
		}
		if(vp!=null) {
			vg = (FrameViewGroup)vp;
		}
	}

	protected void onDetachedFromWindow() {
	}

	protected void onWindowVisibilityChanged(int visibility) {
	}

	int[] vgpos = new int[2];

	public boolean onTouchEvent(MotionEvent event) {
		vg.getLocationOnScreen(vgpos);
		event.setLocation(event.getRawX()-vgpos[0], event.getRawY()-vgpos[1]);
		vg.onTouchEvent(event);
		return(true);
	}
}
