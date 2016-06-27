
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

public class SESurfaceElement : SEElement
{
	property SEResourceCache rsc;
	property Surface surface;
	property SurfaceContainer surface_container;
	double x;
	double y;
	double rotat;

	public double get_x() {
		return(x);
	}

	public double get_y() {
		return(y);
	}

	public double get_width() {
		if(surface == null) {
			return(0.0);
		}
		return(surface.get_width());
	}

	public double get_height() {
		if(surface == null) {
			return(0.0);
		}
		return(surface.get_height());
	}

	public void move(double x, double y) {
		if(surface != null) {
			surface.move(x,y);
			this.x = x;
			this.y = y;
		}
	}

	public void set_scale(double sx, double sy) {
		if(surface != null) {
			surface.set_scale(sx, sy);
		}
	}

	public void set_alpha(double f) {
		if(surface != null) {
			surface.set_alpha(f);
		}
	}

	public void set_rotation(double a) {
		if(surface != null) {
			surface.set_rotation_angle(a);
			rotat = a;
		}
	}

	public double get_scale_x() {
		if(surface == null) {
			return(0.0);
		}
		return(surface.get_scale_x());
	}

	public double get_scale_y() {
		if(surface == null) {
			return(0.0);
		}
		return(surface.get_scale_y());
	}

	public double get_alpha() {
		if(surface == null) {
			return(0.0);
		}
		return(surface.get_alpha());
	}

	public double get_rotation() {
		return(rotat);
	}

	public void remove_from_container() {
		if(surface == null || surface_container == null) {
			return;
		}
		surface_container.remove_surface(surface);
		surface = null;
		surface_container = null;
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
