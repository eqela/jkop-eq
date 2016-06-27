
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

public class Transform
{
	public static Transform for_rotate_angle(double a) {
		return(new Transform().set_rotate_angle(a));
	}

	public static Transform for_alpha(double a) {
		return(new Transform().set_alpha(a));
	}

	public static Transform for_scale(double sx, double sy) {
		return(new Transform().set_scale_x(sx).set_scale_y(sy));
	}

	property double scale_x = 1.0;
	property double scale_y = 1.0;
	property double rotate_angle = 0.0;
	property double alpha = 1.0;
	property bool flip_horizontal = false;
	property bool flip_vertical = false;

	public Transform dup() {
		var v = new Transform();
		v.scale_x = scale_x;
		v.scale_y = scale_y;
		v.rotate_angle = rotate_angle;
		v.alpha = alpha;
		return(v);
	}

	public Transform merge(Transform vt) {
		var v = new Transform();
		if(vt != null) {
			v.scale_x = scale_x * vt.get_scale_x();
			v.scale_y = scale_y * vt.get_scale_y();
			v.rotate_angle = rotate_angle + vt.get_rotate_angle();
			v.alpha = alpha * vt.get_alpha();
		}
		return(v);
	}

	public Transform scale(double sx, double sy) {
		scale_x = scale_x * sx;
		scale_y = scale_y * sy;
		return(this);
	}

	public Transform rotate(double angle) {
		this.rotate_angle += rotate_angle;
		return(this);
	}

	public bool is_noop() {
		return(scale_x == 1.0 && scale_y == 1.0 && rotate_angle == 0.0 && alpha == 1.0);
	}
}
