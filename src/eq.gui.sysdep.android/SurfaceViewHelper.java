
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
import android.view.ViewParent;

public class SurfaceViewHelper
{
	public double myx = 0.0;
	public double myy = 0.0;
	public double mywidth = 0.0;
	public double myheight = 0.0;
	public double _alpha = 1.0;
	public double _rotat = 0.0;
	public boolean legacy_alpha = false;
	public boolean legacy_alpha_render = false;
	public View view;

	public SurfaceViewHelper(View view) {
		this.view = view;
	}

	public double get_width() {
	    return(mywidth);
	}

	public double get_height() {
	    return(myheight);
	}

	public double get_x() {
		return(myx);
	}

	public double get_y() {
		return(myy);
	}

	public void move(double x, double y) {
		if(android.os.Build.VERSION.SDK_INT >= 11) {
			if(x != myx) {
				view.setX((float)x);
			}
			if(y != myy) {
				view.setY((float)y);
			}
		}
		else {
			double w = get_width(), h = get_height();
			int right = (int)(x + w);
			int bottom = (int)(y + h);
			if((double)(right) < (x + w)) {
				right += 1;
			}
			if((double)(bottom) < (y + h)) {
				bottom += 1;
			}
			view.layout((int)x, (int)y, right, bottom);
		}
		myx = x;
		myy = y;
	}

	public void resize(double w, double h) {
		if(w == mywidth && h == myheight) {
			return;
		}
		if(android.os.Build.VERSION.SDK_INT >= 11) {
			view.layout(0,0,(int)w,(int)h);
		}
		else {
			view.layout((int)myx, (int)myy, (int)(myx + w), (int)(myy + h));
		}
		mywidth = w;
		myheight = h;
	}

	public void move_resize(double x, double y, double w, double h) {
		if(android.os.Build.VERSION.SDK_INT >= 11) {
			if(w != mywidth || h != myheight) {
				view.layout(0, 0, (int)w, (int)h);
			}
			if(myx != x) {
				view.setX((float)x);
			}
			if(myy != y) {
				view.setY((float)y);
			}
		}
		else {
			int right = (int)(x + w);
			int bottom = (int)(y + h);
			if((double)(right) < (x + w)) {
				right += 1;
			}
			if((double)(bottom) < (y + h)) {
				bottom += 1;
			}
			view.layout((int)x, (int)y, right, bottom);
		}
		myx = x;
		myy = y;
		mywidth = w;
		myheight = h;
	}

	public void set_scale(double sx, double sy) {
		try {
			view.setScaleX((float)sx);
			view.setScaleY((float)sy);
		}
		catch(NoSuchMethodError e) {
			if(sx != 1.0 || sy != 1.0) {
				System.err.println("setScale is not supported on this Android version.");
			}
		}
	}

	public void set_alpha(double af) {
		double f = af;
		if(f < 0) {
			f = 0;
		}
		if(f > 1) {
			f = 1;
		}
		if(f == _alpha) {
			return;
		}
		try {
			view.setAlpha((float)f);
		}
		catch(NoSuchMethodError e) {
			// on Androids with API level < 11, there is no feature for setting the alpha level of a view
			android.view.animation.AlphaAnimation aa = new android.view.animation.AlphaAnimation((float)f, (float)f);
			aa.setDuration(0);
			aa.setFillAfter(true);
			view.startAnimation(aa);
			legacy_alpha = true;
			if(legacy_alpha_render && _alpha >= 0.05) {
				view.invalidate();
				legacy_alpha_render = false;
			}
		}
		_alpha = f;
	}

	public void set_rotation_angle(double aa) {
		if(_rotat == aa) {
			return;
		}
		double a = aa * 180.0 / Math.PI;
		try {
			view.setRotation((float)a);
		}
		catch(NoSuchMethodError e) {
			android.view.animation.RotateAnimation ra = new android.view.animation.RotateAnimation(
			       (float)(_rotat*180.0/Math.PI), (float)a, android.view.animation.Animation.RELATIVE_TO_SELF, 0.5f, android.view.animation.Animation.RELATIVE_TO_SELF, 0.5f);
			ra.setInterpolator(new android.view.animation.LinearInterpolator());
			ra.setDuration(1);
			ra.setFillAfter(true);
			view.startAnimation(ra);
		}
		_rotat = aa;
	}

	public double get_scale_x() {
		return((double)view.getScaleX());
	}

	public double get_scale_y() {
		return((double)view.getScaleY());
	}

	public double get_alpha() {
		return(_alpha);
	}

	public double get_rotation_angle() {
		return(_rotat);
	}
}
