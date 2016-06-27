
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

public class Matrix33
{
	public static Matrix33 for_zero() {
		return(for_values(
			0.0, 0.0, 0.0,
			0.0, 0.0, 0.0,
			0.0, 0.0, 0.0
		));
	}

	public static Matrix33 for_identity() {
		return(for_values(
			1.0, 0.0, 0.0,
			0.0, 1.0, 0.0,
			0.0, 0.0, 1.0
		));
	}

	public static Matrix33 invert_matrix(Matrix33 m) {
		double d =m.v1*m.v5*m.v9 +
			m.v4*m.v8*m.v3 +
			m.v7*m.v2*m.v6 -
			m.v1*m.v8*m.v6 -
			m.v4*m.v2*m.v9 -
			m.v7*m.v5*m.v3;
		var v = new Matrix33();
		v.v1 = (m.v5*m.v9 - m.v8*m.v6)/d;
		v.v4 = (m.v7*m.v6 - m.v4*m.v9)/d;
		v.v7 = (m.v4*m.v8 - m.v7*m.v5)/d;
		v.v2 = (m.v8*m.v3 - m.v2*m.v9)/d;
		v.v5 = (m.v1*m.v9 - m.v7*m.v3)/d;
		v.v8 = (m.v7*m.v2 - m.v1*m.v8)/d;
		v.v3 = (m.v2*m.v6 - m.v5*m.v3)/d;
		v.v6 = (m.v4*m.v3 - m.v1*m.v6)/d;
		v.v9 = (m.v1*m.v5 - m.v4*m.v2)/d;
		return(v);
	}

	public static Matrix33 for_translate(double translate_x, double translate_y) {
		return(Matrix33.for_values(
			1.0, 0.0, translate_x,
			0.0, 1.0, translate_y,
			0.0, 0.0, 1.0
		));
	}

	public static Matrix33 for_rotation(double angle) {
		var pi = MathConstant.M_PI;
		double c = Math.cos(angle);
		double s = Math.sin(angle);
		return(for_values(
			c, s, 0.0,
			-s, c, 0.0,
			0.0, 0.0, 1.0
		));
	}

	public static Matrix33 for_rotation_with_center(double angle, double center_x, double center_y) {
		var translate = for_translate(center_x, center_y);
		var rotate = for_rotation(angle);
		var translate_back = for_translate(-center_x, -center_y);
		var translated_rotated = multiply_matrix(translate, rotate);
		return(multiply_matrix(translated_rotated, translate_back));
	}

	public static Matrix33 for_skew(double skew_x, double skew_y) {
		return(for_values(
			1.0, skew_x, 0.0,
			skew_y, 1.0, 0.0,
			0.0, 0.0, 1.0
		));
	}

	public static Matrix33 for_scale(double scale_x, double scale_y) {
		return(for_values(
			scale_x, 0.0, 0.0,
			0.0, scale_y, 0.0,
			0.0, 0.0, 1.0
		));
	}

	public static Matrix33 for_flip(bool flip_x, bool flip_y) {
		var xmat33 = for_values(
			1.0, 0.0, 0.0,
			0.0, -1.0, 0.0,
			0.0, 0.0, 1.0
		);
		var ymat33 = for_values(
			-1.0, 0.0, 0.0,
			0.0, 1.0, 0.0,
			0.0, 0.0, 1.0
		);
		if(flip_x && flip_y) {
			return(multiply_matrix(xmat33, ymat33));
		}
		else if(flip_x) {
			return(xmat33);
		}
		else if(flip_y) {
			return(ymat33);
		}
		return(for_identity());
	}

	public static Matrix33 for_values(double mv1, double mv2, double mv3, double mv4, double mv5, double mv6, double mv7, double mv8, double mv9) {
		var v = new Matrix33();
		v.v1 = mv1;
		v.v2 = mv2;
		v.v3 = mv3;
		v.v4 = mv4;
		v.v5 = mv5;
		v.v6 = mv6;
		v.v7 = mv7;
		v.v8 = mv8;
		v.v9 = mv9;
		return(v);
	}

	public static Matrix33 multiply_scalar(double v, Matrix33 mm) {
		var mat33 = for_zero();
		mat33.v1 = mm.v1 * v;
		mat33.v2 = mm.v2 * v;
		mat33.v3 = mm.v3 * v;
		mat33.v4 = mm.v4 * v;
		mat33.v5 = mm.v5 * v;
		mat33.v6 = mm.v6 * v;
		mat33.v7 = mm.v7 * v;
		mat33.v8 = mm.v8 * v;
		mat33.v9 = mm.v9 * v;
		return(mat33);
	}

	public static Matrix33 multiply_matrix(Matrix33 a, Matrix33 b) {
		var matrix33 = new Matrix33();
		matrix33.v1 = a.v1 * b.v1 + a.v2 * b.v4 + a.v3 * b.v7;
		matrix33.v2 = a.v1 * b.v2 + a.v2 * b.v5 + a.v3 * b.v8;
		matrix33.v3 = a.v1 * b.v3 + a.v2 * b.v6 + a.v3 * b.v9;
		matrix33.v4 = a.v4 * b.v1 + a.v5 * b.v4 + a.v6 * b.v7;
		matrix33.v5 = a.v4 * b.v2 + a.v5 * b.v5 + a.v6 * b.v8;
		matrix33.v6 = a.v4 * b.v3 + a.v5 * b.v6 + a.v6 * b.v9;
		matrix33.v7 = a.v7 * b.v1 + a.v8 * b.v4 + a.v9 * b.v7;
		matrix33.v8 = a.v7 * b.v2 + a.v8 * b.v5 + a.v9 * b.v8;
		matrix33.v9 = a.v7 * b.v3 + a.v8 * b.v6 + a.v9 * b.v9;
		return(matrix33);
	}

	public static Vector2 multiply_vector(Matrix33 a, Vector2 b) {
		double x = a.v1 * b.x + a.v2 * b.y + a.v3 * 1.0;
		double y = a.v4 * b.x + a.v5 * b.y + a.v6 * 1.0;
		return(Vector2.create(x, y));
	}

	/*
	 * The following variables represent the matrix values as follows:
	 * | v1 v2 v3|
	 * | v4 v5 v6|
	 * | v7 v8 v9|
	 */

	public double v1;
	public double v2;
	public double v3;
	public double v4;
	public double v5;
	public double v6;
	public double v7;
	public double v8;
	public double v9;
}

