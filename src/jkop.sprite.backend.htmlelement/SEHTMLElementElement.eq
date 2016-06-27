
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

public class SEHTMLElementElement : SEElement
{
	double x;
	double y;
	double width;
	double height;
	double rotation;
	double alpha = 1.0;
	double scale_x = 1.0;
	double scale_y = 1.0;
	property ptr element;
	ptr parent;
	property SEResourceCache rsc;
	property ptr document;

	public void set_x(double x) {
		this.x = x;
	}

	public void set_y(double y) {
		this.y = y;
	}

	public void set_width(double width) {
		this.width = width;
	}

	public void set_height(double height) {
		this.height = height;
	}

	public void set_parent(ptr pp) {
		parent = pp;
	}

	public ptr get_parent() {
		return(parent);
	}

	public void move(double x, double y) {
		if(element != null) {
			var ee = element;
			var ix = (int)x;
			var iy = (int)y;
			embed {{{
				ee.style.left = "" + ix + "px";
				ee.style.top = "" + iy + "px";
			}}}
		}
		this.x = x;
		this.y = y;
	}

	void update_transform() {
		var ee = element;
		if(ee != null) {
			var ang = rotation * 180.0 / MathConstant.M_PI;
			var str = "rotate(%ddeg) scale(%f,%f)".printf().add(ang).add(scale_x).add(scale_y).to_string();
			var sp = str.to_strptr();
			embed {{{
				ee.style.transform = sp;
				ee.style.webkitTransform = sp;
				ee.style.msTransform = sp;
				ee.style.oTransform = sp;
				ee.style.mozTransform = sp;
			}}}
		}
	}

	public void set_rotation(double a) {
		rotation = a;
		update_transform();
	}

	public void set_scale(double sx, double sy) {
		scale_x = sx;
		scale_y = sy;
		update_transform();
	}

	public void set_alpha(double alpha) {
		var ee = element;
		if(ee != null) {
			embed {{{
				ee.style.opacity = alpha;
			}}}
		}
		this.alpha = alpha;
	}

	public double get_x() {
		return(x);
	}

	public double get_y() {
		return(y);
	}

	public double get_scale_x() {
		return(scale_x);
	}

	public double get_scale_y() {
		return(scale_y);
	}

	public double get_width() {
		return(width);
	}

	public double get_height() {
		return(height);
	}

	public double get_rotation() {
		return(rotation);
	}

	public double get_alpha() {
		return(alpha);
	}

	public void remove_from_container() {
		if(element == null) {
			return;
		}
		var ee = element;
		embed {{{
			if(ee.parentNode != null) {
				ee.parentNode.removeChild(ee);
			}
		}}}
		element = null;
	}

	IFDEF("enable_foreign_api") {
		public void setRotation(double angle) {
			set_rotation(angle);
		}
		public void setAlpha(double alpha) {
			set_alpha(alpha);
		}
		public void setScale(double scalex, double scaley) {
			set_scale(scalex, scaley);
		}
		public double getX() {
			return(get_x());
		}
		public double getY() {
			return(get_y());
		}
		public double getWidth() {
			return(get_width());
		}
		public double getHeight() {
			return(get_height());
		}
		public double getRotation() {
			return(get_rotation());
		}
		public double getAlpha() {
			return(get_alpha());
		}
		public double getScaleX() {
			return(get_scale_x());
		}
		public double getScaleY() {
			return(get_scale_y());
		}
		public void removeFromContainer() {
			remove_from_container();
		}
	}
}
