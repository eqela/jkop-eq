
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

public interface DrawingContext
{
	public void set_drawing_rotation(double angle);
	public void set_drawing_scaling(double sx, double sy);
	public void set_drawing_opacity(double alpha);
	public void clear_transforms();
	public void add_clip_rectangle(double x, double y, double width, double height);
	public void clear_clips();
	public void clear_rectangle(double x, double y, double width, double height);
	public void fill_shape(double x, double y, Shape shape, Object color);
	public void fill_rectangle(double x, double y, double width, double height, Object color);
	public void fill_rounded_rectangle(double x, double y, double width, double height, double rounding, Object color);
	public void fill_circle(double x, double y, double radius, Object color);
	public void fill_shape_gradient(double x, double y, Shape shape, Object color, Object color2 = null, int direction = 0);
	public void fill_rectangle_gradient(double x, double y, double width, double height, Object color, Object color2 = null, int direction = 0);
	public void fill_rounded_rectangle_gradient(double x, double y, double width, double height, double rounding, Object color, Object color2 = null, int direction = 0);
	public void fill_circle_gradient(double x, double y, double radius, Object color, Object color2 = null, int direction = 0);
	public void draw_shape(double x, double y, Shape shape, Object color, double thickness = 1);
	public void draw_rectangle(double x, double y, double width, double height, Object color, double thickness = 1);
	public void draw_rounded_rectangle(double x, double y, double width, double height, double rounding, Object color, double thickness = 1);
	public void draw_circle(double x, double y, double radius, Object color, double thickness = 1);
	public void draw_line(double x1, double y1, double x2, double y2, Object color, double thickness = 1);
	public void draw_curve(double x1, double y1, double x2, double y2, double x3, double y3, Object color, double thickness = 1);
	public void draw_arc(double x, double y, double radius, double angle1, double angle2, Object color, double thickness = 1);
	public void draw_object(double x, double y, Object object);
	public void draw_text(double x, double y, String text, Object font = null);
	public void draw_image(double x, double y, Object image);
}
