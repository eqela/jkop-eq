
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

class D2DElement : SEElement
{
	embed {{{
		#include <d2d1.h>
		#define MATRIX(x,y) ((jkop_sprite_backend_direct2d_D2DMatrix3x2F*)x)->y
	}}}

	property SEResourceCache rsc;
	double pos_x;
	double pos_y;
	double _alpha = 1.0;
	double _rot = 0.0;
	double _scale_x = 1.0;
	double _scale_y = 1.0;
	D2DElementList mycontainer;
	D2DElement parent;
	public D2DMatrix3x2F matrix;

	public void move(double x, double y) {
		if(pos_x == x && pos_y == y) {
			return;
		}
		pos_x = x;
		pos_y = y;
		update_matrix();
	}

	public void set_mycontainer(D2DElementList container) {
		mycontainer = container;
		if(container is D2DElement) {
			parent = (D2DElement)container;
		}
	}

	public void set_rotation(double angle) {
		if(_rot == angle) {
			return;
		}
		_rot = angle;
		update_matrix();
	}

	public void set_alpha(double alpha) {
		if(_alpha == alpha) {
			return;
		}
		_alpha = alpha;
	}

	public void set_scale(double sx, double sy) {
		_scale_x = sx;
		_scale_y = sy;
		update_matrix();
	}

	public double get_x() {
		return(pos_x);
	}

	public double get_y() {
		return(pos_y);
	}

	public double get_scale_x() {
		return(_scale_x);
	}

	public double get_scale_y() {
		return(_scale_y);
	}

	public void update_matrix() {
		double px, py, sx = get_scale_x(), sy = get_scale_y(), angle = get_rotation() * 180.0 / MathConstant.M_PI;
		var x = pos_x, y = pos_y;
		if(parent != null) {
			x = x + parent.get_x();
			y = y + parent.get_y();
		}
		if(matrix == null) {
			matrix = new D2DMatrix3x2F();
		}
		var mat = matrix;
		double w2 = get_width()/2, h2 = get_height()/2;
		embed {{{
			D2D1::Matrix3x2F m = D2D1::Matrix3x2F::Identity();
			if(x != 0 || y != 0) {
				m = m.operator*(D2D1::Matrix3x2F::Translation(D2D1::Size(x, y)));
			}
			if(angle != 0) {
				m = m.operator*(D2D1::Matrix3x2F::Rotation(angle,  D2D1::Point2F(x+w2, y+h2)));
			}
			if(sx != 1.0 || sy != 1.0) {
				m = m.operator*(D2D1::Matrix3x2F::Scale(D2D1::SizeF(sx, sy), D2D1::Point2F(x+w2, y+h2)));
			}
			MATRIX(mat, m11) = m._11;
			MATRIX(mat, m12) = m._12;
			MATRIX(mat, m21) = m._21;
			MATRIX(mat, m22) = m._22;
			MATRIX(mat, m31) = m._31;
			MATRIX(mat, m32) = m._32;
		}}}
	}

	public D2DMatrix3x2F get_matrix() {
		return(matrix);
	}

	public double get_width() {
		return(0);
	}

	public double get_height() {
		return(0);
	}

	public double get_rotation() {
		return(_rot);
	}

	public double get_alpha() {
		return(_alpha);
	}

	public void remove_from_container() {
		if(mycontainer != null) {
			mycontainer.remove_element(this);
		}
	}
}
