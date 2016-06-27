
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

public class Matrix44
{
	public static Matrix44 for_zero() {
		return(for_values(
			0.0, 0.0, 0.0, 0.0,
			0.0, 0.0, 0.0, 0.0,
			0.0, 0.0, 0.0, 0.0,
			0.0, 0.0, 0.0, 0.0
		));
	}

	public static Matrix44 for_identity() {
		return(for_values(
			1.0, 0.0, 0.0, 0.0,
			0.0, 1.0, 0.0, 0.0,
			0.0, 0.0, 1.0, 0.0,
			0.0, 0.0, 0.0, 1.0
		));
	}

	public static Matrix44 for_translate(double translate_x, double translate_y, double translate_z) {
		return(for_values(
			1.0, 0.0, 0.0, translate_x,
			0.0, 1.0, 0.0, translate_y,
			0.0, 0.0, 1.0, translate_z,
			0.0, 0.0, 0.0, 1.0
		));
	}

	public static Matrix44 for_x_rotation(double angle) {
		double c = Math.cos(angle);
		double s = Math.sin(angle);
		return(for_values(
			1.0, 0.0, 0.0, 0.0,
			0.0, c, -s, 0.0,
			0.0, s, c, 0.0,
			0.0, 0.0, 0.0, 1.0
		));
	}

	public static Matrix44 for_y_rotation(double angle) {
		double c = Math.cos(angle);
		double s = Math.sin(angle);
		return(for_values(
			c, 0.0, s, 0.0,
			0.0, 1.0, 0.0, 0.0,
			-s, 0.0, c, 0.0,
			0.0, 0.0, 0.0, 1.0
		));
	}

	public static Matrix44 for_z_rotation(double angle) {
		double c = Math.cos(angle);
		double s = Math.sin(angle);
		return(for_values(
			c, -s, 0.0, 0.0,
			s, c, 0.0, 0.0,
			0.0, 0.0, 1.0, 0.0,
			0.0, 0.0, 0.0, 1.0
		));
	}

	public static Matrix44 for_skew(double vx, double vy, double vz) {
		return(for_values(
			1.0, vx, vx, 0.0,
			vy, 1.0, vy, 0.0,
			vz, vz, 1.0, 0.0,
			0.0, 0.0, 0.0, 1.0
		));
	}

	public static Matrix44 for_x_rotation_with_center(double angle, double center_x, double center_y, double center_z) {
		var translate = for_translate(center_x, center_y, center_z);
		var rotate = for_x_rotation(angle);
		var translate_back = for_translate(-center_x, -center_y, -center_z);
		var translated_rotated = multiply_matrix(translate, rotate);
		return(multiply_matrix(translated_rotated, translate_back));
	}

	public static Matrix44 for_y_rotation_with_center(double angle, double center_x, double center_y, double center_z) {
		var translate = for_translate(center_x, center_y, center_z);
		var rotate = for_y_rotation(angle);
		var translate_back = for_translate(-center_x, -center_y, -center_z);
		var translated_rotated = multiply_matrix(translate, rotate);
		return(multiply_matrix(translated_rotated, translate_back));
	}

	public static Matrix44 for_z_rotation_with_center(double angle, double center_x, double center_y, double center_z) {
		var translate = for_translate(center_x, center_y, center_z);
		var rotate = for_z_rotation(angle);
		var translate_back = for_translate(-center_x, -center_y, -center_z);
		var translated_rotated = multiply_matrix(translate, rotate);
		return(multiply_matrix(translated_rotated, translate_back));
	}

	public static Matrix44 for_scale(double scale_x, double scale_y, double scale_z) {
		return(for_values(
			scale_x, 0.0, 0.0, 0.0,
			0.0, scale_y, 0.0, 0.0,
			0.0, 0.0, scale_z, 0.0,
			0.0, 0.0, 0.0, 1.0
		));
	}

	public static Matrix44 for_flip_xy(bool flip_xy) {
		if(flip_xy) {
			return(for_values(
				1.0, 0.0, 0.0, 0.0,
				0.0, 1.0, 0.0, 0.0,
				0.0, 0.0, -1.0, 0.0,
				0.0, 0.0, 0.0, 1.0
			));
		}
		return(for_identity());
	}

	public static Matrix44 for_flip_xz(bool flip_xz) {
		if(flip_xz) {
			return(for_values(
				1.0, 0.0, 0.0, 0.0,
				0.0, -1.0, 0.0, 0.0,
				0.0, 0.0, 1.0, 0.0,
				0.0, 0.0, 0.0, 1.0
			));
		}
		return(for_identity());
	}

	public static Matrix44 for_flip_yz(bool flip_yz) {
		if(flip_yz) {
			return(for_values(
				-1.0, 0.0, 0.0, 0.0,
				0.0, 1.0, 0.0, 0.0,
				0.0, 0.0, 1.0, 0.0,
				0.0, 0.0, 0.0, 1.0
			));
		}
		return(for_identity());
	}

	public static Matrix44 for_values(double mv1, double mv2, double mv3, double mv4, double mv5, double mv6, double mv7, double mv8, double mv9, double mv10, double mv11, double mv12, double mv13, double mv14, double mv15, double mv16) {
		var v = new Matrix44();
		v.v1 = mv1;
		v.v2 = mv2;
		v.v3 = mv3;
		v.v4 = mv4;
		v.v5 = mv5;
		v.v6 = mv6;
		v.v7 = mv7;
		v.v8 = mv8;
		v.v9 = mv9;
		v.v10 = mv10;
		v.v11 = mv11;
		v.v12 = mv12;
		v.v13 = mv13;
		v.v14 = mv14;
		v.v15 = mv15;
		v.v16 = mv16;
		return(v);
	}

	public static Matrix44 multiply_scalar(double v, Matrix44 mm) {
		return(for_values(
			mm.v1 * v, mm.v2 * v, mm.v3 * v, mm.v4 * v,
			mm.v5 * v, mm.v6 * v, mm.v7 * v, mm.v8 * v,
			mm.v9 * v, mm.v10 * v, mm.v11 * v, mm.v12 * v,
			mm.v13 * v, mm.v14 * v, mm.v15 * v, mm.v16 * v
		));
	}

	public static Matrix44 multiply_matrix(Matrix44 a, Matrix44 b) {
		var matrix44 = new Matrix44();
		matrix44.v1 = a.v1 * b.v1 + a.v2 * b.v5 + a.v3 * b.v9 + a.v4 * b.v13;
		matrix44.v2 = a.v1 * b.v2 + a.v2 * b.v6 + a.v3 * b.v10 + a.v4 * b.v14;
		matrix44.v3 = a.v1 * b.v3 + a.v2 * b.v7 + a.v3 * b.v11 + a.v4 * b.v15;
		matrix44.v4 = a.v1 * b.v4 + a.v2 * b.v8 + a.v3 * b.v12 + a.v4 * b.v16;
		matrix44.v5 = a.v5 * b.v1 + a.v6 * b.v5 + a.v7 * b.v9 + a.v8 * b.v13;
		matrix44.v6 = a.v5 * b.v2 + a.v6 * b.v6 + a.v7 * b.v10 + a.v8 * b.v14;
		matrix44.v7 = a.v5 * b.v3 + a.v6 * b.v7 + a.v7 * b.v11 + a.v8 * b.v15;
		matrix44.v8 = a.v5 * b.v4 + a.v6 * b.v8 + a.v7 * b.v12 + a.v8 * b.v16;
		matrix44.v9 = a.v9 * b.v1 + a.v10 * b.v5 + a.v11 * b.v9 + a.v12 * b.v13;
		matrix44.v10 = a.v9 * b.v2 + a.v10 * b.v6 + a.v11 * b.v10 + a.v12 * b.v14;
		matrix44.v11 = a.v9 * b.v3 + a.v10 * b.v7 + a.v11 * b.v11 + a.v12 * b.v15;
		matrix44.v12 = a.v9 * b.v4 + a.v10 * b.v8 + a.v11 * b.v12 + a.v12 * b.v16;
		matrix44.v13 = a.v13 * b.v1 + a.v14 * b.v5 + a.v15 * b.v9 + a.v16 * b.v13;
		matrix44.v14 = a.v13 * b.v2 + a.v14 * b.v6 + a.v15 * b.v10 + a.v16 * b.v14;
		matrix44.v15 = a.v13 * b.v3 + a.v14 * b.v7 + a.v15 * b.v11 + a.v16 * b.v15;
		matrix44.v16 = a.v13 * b.v4 + a.v14 * b.v8 + a.v15 * b.v12 + a.v16 * b.v16;
		return(matrix44);
	}

	public static Vector3 multiply_vector(Matrix44 a, Vector3 b) {
		double x = a.v1 * b.x + a.v2 * b.y + a.v3 * b.z + a.v4 * 1.0;
		double y = a.v5 * b.x + a.v6 * b.y + a.v7 * b.z + a.v8 * 1.0;
		double z = a.v9 * b.x + a.v10 * b.y + a.v11 * b.z + a.v12 * 1.0;
		return(Vector3.create(x, y, z));
	}

	/*
	 * The following variables represent the matrix values as follows:
	 * | v1  v2  v3  v4 |
	 * | v5  v6  v7  v8 |
	 * | v9  v10 v11 v12|
	 * | v13 v14 v15 v16|
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
	public double v10;
	public double v11;
	public double v12;
	public double v13;
	public double v14;
	public double v15;
	public double v16;
}
