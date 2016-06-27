
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

package eq.gui.sysdep.bbjava;

import net.rim.device.api.ui.*;
import net.rim.device.api.ui.decor.*;
import net.rim.device.api.ui.component.*;
import net.rim.device.api.ui.container.*;

class ContainerFieldSurface extends Manager implements eq.gui.Position, eq.gui.Size, eq.gui.Surface, Invalidatable
{
	double _alpha = 1.0;
	double _scale_x = 1.0;
	double _scale_y = 1.0;
	double _rotation = 1.0;
	double x;
	double y;
	double width;
	double height;
	
	public ContainerFieldSurface() {
		super(0);
	}

	public ContainerFieldSurface(long s) {
		super(s);
	}

	void invalidate_manager(double x, double y, double w, double h) {
		Manager m = getManager();
		if(m instanceof Invalidatable) {
			((Invalidatable)m)._invalidate((int)x, (int)y, (int)w, (int)h);
		}
	}

	public void _invalidate(int x, int y, int w, int h) {
		invalidate(x, y, w, h);
	}
	
	public void sublayout(int w, int h) {
		setExtent(w, h);
		int c = getFieldCount();
		for(int i = 0; i < c; i++) {
			Field wf = getField(i);
			if(wf != null) {
				int pw = wf.getPreferredWidth(), ph = wf.getPreferredHeight();
				layoutChild(wf, pw, ph);
			}
		}
		invalidate();
	}
	
	public int getPreferredWidth() {
		return((int)get_width());
	}

	public int getPreferredHeight() {
		return((int)get_height());
	}	

	public double get_x() {
		return(getLeft());
	}

	public double get_y() {
		return(getTop());
	}

	public double get_width() {
		return(width);
	}
	
	public double get_height() {
		return(height);
	}

	public void resize(double w, double h) {
		if(w < 0 || h < 0) {
			System.out.println("Encountered invalid width and height: `" + w + "x" + h + "`");
			return;
		} 
		double ox = get_x(), oy = get_y(), ow = get_width(), oh = get_height();
		this.width = w;
		this.height = h;
		setExtent((int)w, (int)h);
		invalidate_manager(ox, oy, ow, oh);
		invalidate_manager(get_x(), get_y(), get_width(), get_height());
	}

	public void move(double x, double y) {
		double ox = get_x(), oy = get_y(), ow = get_width(), oh = get_height();
		this.x = x;
		this.y = y;
		setPosition((int)x, (int)y);
		invalidate_manager(ox, oy, ow, oh);
		invalidate_manager(get_x(), get_y(), get_width(), get_height());
	}

	public void move_resize(double x, double y, double w, double h) {
		move(x, y);
		resize(w, h);
	}

	public void set_scale(double sx, double sy) {
		//Not available for BBJava
		_scale_x = sx;
		_scale_x = sx;
	}
	public void set_alpha(double f) {
		//Not available for BBJava
		_alpha = f;
	}

	public void set_rotation_angle(double a) {
		//Not available for BBJava
		_rotation = a;
	}

	public double get_scale_x() {
		//Not available for BBJava
		return(_scale_x);
	}

	public double get_scale_y() {
		//Not available for BBJava
		return(_scale_y);
	}

	public double get_alpha() {
		//Not available for BBJava
		return(_alpha);
	}

	public double get_rotation_angle() {
		//Not available for BBJava
		return(_rotation);
	}
}
