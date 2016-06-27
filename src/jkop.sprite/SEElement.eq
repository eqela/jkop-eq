
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

public interface SEElement
{
	public static SEElement remove(SEElement ee) {
		if(ee != null) {
			ee.remove_from_container();
		}
		return(null);
	}

	public void move(double x, double y);
	public void set_rotation(double angle);
	public void set_alpha(double alpha);
	public void set_scale(double scalex, double scaley);
	public double get_x();
	public double get_y();
	public double get_width();
	public double get_height();
	public double get_rotation();
	public double get_alpha();
	public double get_scale_x();
	public double get_scale_y();
	public void remove_from_container();

	IFDEF("enable_foreign_api") {
		public void setRotation(double angle);
		public void setAlpha(double alpha);
		public void setScale(double scalex, double scaley);
		public double getX();
		public double getY();
		public double getWidth();
		public double getHeight();
		public double getRotation();
		public double getAlpha();
		public double getScaleX();
		public double getScaleY();
		public void removeFromContainer();
	}
}
