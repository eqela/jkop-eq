
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

public class VgPathElement
{
	public static int OP_LINE = 1;
	public static int OP_CURVE = 2;
	public static int OP_ARC = 3;

	public static VgPathElement create(int operation) {
		var v = new VgPathElement();
		v.operation = operation;
		return(v);
	}

	int operation;
	int x1;
	int y1;
	int x2;
	int y2;
	int x3;
	int y3;
	int radius;
	double angle1;
	double angle2;

	public int get_operation() {
		return(operation);
	}
	public int get_x1() {
		return(x1);
	}
	public int get_y1() {
		return(y1);
	}
	public int get_x2() {
		return(x2);
	}
	public int get_y2() {
		return(y2);
	}
	public int get_x3() {
		return(x3);
	}
	public int get_y3() {
		return(y3);
	}
	public int get_radius() {
		return(radius);
	}
	public double get_angle1() {
		return(angle1);
	}
	public double get_angle2() {
		return(angle2);
	}
	public VgPathElement set_x1(int x) {
		x1 = x;
		return(this);
	}
	public VgPathElement set_y1(int x) {
		y1 = x;
		return(this);
	}
	public VgPathElement set_x2(int x) {
		x2 = x;
		return(this);
	}
	public VgPathElement set_y2(int x) {
		y2 = x;
		return(this);
	}
	public VgPathElement set_x3(int x) {
		x3 = x;
		return(this);
	}
	public VgPathElement set_y3(int x) {
		y3 = x;
		return(this);
	}
	public VgPathElement set_radius(int r) {
		radius = r;
		return(this);
	}
	public VgPathElement set_angle1(double a) {
		angle1 = a;
		return(this);
	}
	public VgPathElement set_angle2(double a) {
		angle2 = a;
		return(this);
	}
}

