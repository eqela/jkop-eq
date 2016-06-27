
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

public class HTML5ElementSurface : Surface, SurfaceWithId, Size, Position
{
	property HTMLElement element;
	double x;
	double y;
	double w;
	double h;
	double _alpha = 1.0;
	double _scale_x = 1.0;
	double _scale_y = 1.0;
	double _rot = 0.0;

	public void set_surface_id(String id) {
		if(element == null) {
			return;
		}
		element.set_attribute("id", id);
	}

	public void append_to(HTMLElement parent) {
		if(parent == null) {
			return;
		}
		parent.append_child(element);
	}

	public void prepend_to(HTMLElement parent) {
		if(parent == null) {
			return;
		}
		parent.prepend_child(element);
	}

	public void remove() {
		element.remove_from_dom();
	}

	public double get_device_pixel_ratio() {
		return(1.0);
	}

	public void move(double x, double y) {
		if(x != this.x) {
			element.set_style("left", "%d".printf().add(x).to_string());
		}
		if(y != this.y) {
			element.set_style("top", "%d".printf().add(y).to_string());
		}
		this.x = x;
		this.y = y;
	}

	public void resize(double w, double h) {
		if(this.w != w) {
			element.set_style("width", "%dpx".printf().add((int)w).to_string());
		}
		if(this.h != h) {
			element.set_style("height", "%dpx".printf().add((int)h).to_string());
		}
		this.w = w;
		this.h = h;
	}

	public void move_resize(double x, double y, double w, double h) {
		move(x, y);
		resize(w, h);
	}

	public void set_scale(double sx, double sy) {
		// FIXME
		_scale_x = sx;
		_scale_y = sy;
	}

	public void set_alpha(double f) {
		_alpha = f;
		element.set_style("opacity", "%f".printf().add(f).to_string());
	}

	public void set_rotation_angle(double a) {
		var ang = a * 180.0 / MathConstant.M_PI;
		var str = "rotate(%ddeg)".printf().add(ang).to_string();
		element.set_style("transform", str);
		element.set_style("webkitTransform", str);
		element.set_style("msTransform", str);
		element.set_style("oTransform", str);
		element.set_style("mozTransform", str);
		_rot = a;
	}

	public double get_scale_x() {
		return(_scale_x);
	}

	public double get_scale_y() {
		return(_scale_y);
	}

	public double get_alpha() {
		return(_alpha);
	}

	public double get_rotation_angle() {
		return(_rot);
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
}
