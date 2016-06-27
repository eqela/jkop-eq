
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
import net.rim.device.api.ui.container.*;
import net.rim.device.api.ui.decor.*;

public class FieldSurface extends Field implements eq.gui.Surface, eq.gui.Size, eq.gui.Position, eq.gui.Renderable
{
	double _alpha = 1.0;
	double _scale_x = 1.0;
	double _scale_y = 1.0;
	double _rotation = 1.0;
	double x;
	double y;
	double width;
	double height;
	eq.api.Collection ops;
	
	public FieldSurface() {
	}
	
	protected void layout(int w, int h) {
		invalidate(0, 0, w, h);
		setExtent(w, h);
	}

	void invalidate_manager(double x, double y, double w, double h) {
		Manager m = getManager();
		if(m instanceof Invalidatable) {
			((Invalidatable)m)._invalidate((int)x, (int)y, (int)w, (int)h);
		}
	}
	
	protected void onFocus(int d) {
	}
	
	protected void onUnFocus() {
	}
	
	protected void onVisibilityChange(boolean v) {
	}

	public void render(eq.api.Collection ops) {
		this.ops = ops;
		invalidate();
	}

	protected void paint(Graphics graphics) {
		if(get_alpha() < 0.5) {
			return;
		}
		BBJavaGraphicsVgContext ctx = new BBJavaGraphicsVgContext(graphics);
		ctx.clear(0, 0, eq.gui.vg.VgPathRectangle.eq_gui_vg_VgPathRectangle_create(0, 0, (int)get_width(), (int)get_height()), null);
		eq.gui.vg.VgRenderer.eq_gui_vg_VgRenderer_render_to_vg_context(ops, ctx, 0, 0);
	}
	
	public int getPreferredWidth() {
		return((int)get_width());	
	}
	
	public int getPreferredHeight() {
		return((int)get_height());	
	}
	
	public double get_x() {
		return(x);
	}

	public double get_y() {
		return(y);
	}

	public double get_width() {
		return(width);
	}
	
	public double get_height() {
		return(height);
	}
	
	void update_layout() {
		layout((int)get_width(), (int)get_height());
	}

	public void resize(double w, double h) {
		if(w < 0 || h < 0) {
			System.out.println("Encountered invalid width and height: `" + w + "x" + h + "`");
			return;
		} 
		double ox = get_x(), oy = get_y(), ow = get_width(), oh = get_height();
		this.width = w;
		this.height = h;
		update_layout();
		setExtent((int)w, (int)h);
		invalidate_manager(ox, oy, ow, oh);
		invalidate_manager(get_x(), get_y(), get_width(), get_height());
	}

	public void move(double x, double y) {
		double ox = get_x(), oy = get_y(), ow = get_width(), oh = get_height();
		this.x = x;
		this.y = y;
		update_layout();
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
		_scale_y = sy;
	}

	public double get_scale_x() {
		return(_scale_x);
	}

	public double get_scale_y() {
		return(_scale_y);
	}

	public void set_alpha(double f) {
		//Not available for BBJava
		if(_alpha == f) {
			return;
		}
		invalidate();
		_alpha = f;
	}

	public void set_rotation_angle(double a) {
		//Not available for BBJava
		_rotation = a;
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
