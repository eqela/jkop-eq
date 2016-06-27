
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

public class VgPathRoundedRectangle : VgPath
{
	public static VgPathRoundedRectangle create(int x, int y, int w, int h, int radius) {
		var v = new VgPathRoundedRectangle();
		v.x = x;
		v.y = y;
		v.w = w;
		v.h = h;
		v.radius = radius;
		return(v);
	}

	int x;
	int y;
	int w;
	int h;
	int radius;

	public VgPathRoundedRectangle set_x(int v) {
		this.x = v;
		return(this);
	}

	public VgPathRoundedRectangle set_y(int v) {
		this.y = v;
		return(this);
	}

	public VgPathRoundedRectangle set_w(int v) {
		this.w = v;
		return(this);
	}

	public VgPathRoundedRectangle set_h(int v) {
		this.h = v;
		return(this);
	}

	public VgPathRoundedRectangle set_radius(int v) {
		this.radius = v;
		return(this);
	}

	public int get_x() {
		return(x);
	}

	public int get_y() {
		return(y);
	}

	public int get_w() {
		return(w);
	}

	public int get_h() {
		return(h);
	}

	public int get_radius() {
		return(radius);
	}
}
