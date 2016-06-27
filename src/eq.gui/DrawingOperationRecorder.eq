
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

public class DrawingOperationRecorder : DrawingContext
{
	public static DrawingOperationRecorder for_frame(Frame frame) {
		return(new DrawingOperationRecorder().set_frame(frame));
	}

	property Frame frame;
	Collection operations;
	Transform transform;

	public DrawingOperationRecorder() {
		operations = LinkedList.create();
	}

	public Collection get_operations() {
		return(operations);
	}

	public void add_operation(Object op) {
		if(op == null) {
			return;
		}
		operations.add(op);
	}

	void create_new_transform() {
		Transform t;
		if(transform != null) {
			t = transform.dup();
		}
		else {
			t = new Transform();
		}
		transform = t;
	}

	public void set_drawing_rotation(double angle) {
		create_new_transform();
		transform.set_rotate_angle(angle);
	}

	public void set_drawing_scaling(double sx, double sy) {
		create_new_transform();
		transform.set_scale_x(sx);
		transform.set_scale_y(sy);
	}

	public void set_drawing_opacity(double alpha) {
		create_new_transform();
		transform.set_alpha(alpha);
	}

	public void clear_transforms() {
		transform = null;
	}

	public void add_clip_rectangle(double x, double y, double width, double height) {
		add_operation(new ClipOperation().set_x(x).set_y(y)
			.set_shape(RectangleShape.create(0, 0, width, height))
			.set_transform(transform));
	}

	public void clear_clips() {
		add_operation(new ClipClearOperation());
	}

	public void clear_rectangle(double x, double y, double width, double height) {
		add_operation(new ClearOperation().set_x(x).set_y(y)
			.set_shape(RectangleShape.create(0, 0, width, height))
			.set_transform(transform));
	}

	public void fill_shape(double x, double y, Shape shape, Object color) {
		add_operation(new FillColorOperation().set_x(x).set_y(y)
			.set_shape(shape).set_color(Color.as_color(color))
			.set_transform(transform));
	}

	public void fill_rectangle(double x, double y, double width, double height, Object color) {
		fill_shape(x, y, RectangleShape.create(0, 0, width, height), color);
	}

	public void fill_rounded_rectangle(double x, double y, double width, double height, double rounding, Object color) {
		fill_shape(x, y, RoundedRectangleShape.create(0, 0, width, height, rounding), color);
	}

	public void fill_circle(double x, double y, double radius, Object color) {
		fill_shape(0, 0, CircleShape.create(x, y, radius), color);
	}

	public void fill_shape_gradient(double x, double y, Shape shape, Object color, Object color2, int direction) {
		var c1 = Color.as_color(color);
		Color c2;
		if(color2 != null) {
			c2 = Color.as_color(color2);
		}
		else if(c1 != null) {
			c1 = c1.dup("135%");
			c2 = c1.dup("65%");
		}
		double radius = 0;
		if(shape != null) {
			var w = shape.get_width();
			var h = shape.get_height();
			if(w < h) {
				radius = w / 2.0;
			}
			else {
				radius = h / 2.0;
			}
		}
		add_operation(new FillGradientOperation().set_x(x).set_y(y).set_shape(shape).set_color1(c1)
			.set_color2(c2).set_radius(radius).set_type(direction).set_transform(transform));
	}

	public void fill_rectangle_gradient(double x, double y, double width, double height, Object color, Object color2, int direction) {
		fill_shape_gradient(x, y, RectangleShape.create(0, 0, width, height), color, color2, direction);
	}

	public void fill_rounded_rectangle_gradient(double x, double y, double width, double height, double rounding, Object color, Object color2, int direction) {
		fill_shape_gradient(x, y, RoundedRectangleShape.create(0, 0, width, height, rounding), color, color2, direction);
	}

	public void fill_circle_gradient(double x, double y, double radius, Object color, Object color2, int direction) {
		fill_shape_gradient(0, 0, CircleShape.create(x, y, radius), color, color2, direction);
	}

	public void draw_shape(double x, double y, Shape shape, Object color, double thickness) {
		add_operation(new StrokeOperation().set_x(x).set_y(y)
			.set_shape(shape).set_color(Color.as_color(color))
			.set_width(thickness).set_transform(transform));
	}

	public void draw_rectangle(double x, double y, double width, double height, Object color, double thickness) {
		draw_shape(x, y, RectangleShape.create(0, 0, width, height), color, thickness);
	}

	public void draw_rounded_rectangle(double x, double y, double width, double height, double rounding, Object color, double thickness) {
		draw_shape(x, y, RoundedRectangleShape.create(0, 0, width, height, rounding), color, thickness);
	}

	public void draw_circle(double x, double y, double radius, Object color, double thickness) {
		draw_shape(0, 0, CircleShape.create(x, y, radius), color, thickness);
	}

	public void draw_line(double x1, double y1, double x2, double y2, Object color, double thickness) {
		draw_shape(0, 0, CustomShape.create(x1, y1).line(x2, y2), color, thickness);
	}

	public void draw_curve(double x1, double y1, double x2, double y2, double x3, double y3, Object color, double thickness) {
		draw_shape(0, 0, CustomShape.create(x1,x2).curve(x1,y1,x2,y2,x3,y3), color, thickness);
	}

	public void draw_arc(double x, double y, double radius, double angle1, double angle2, Object color, double thickness) {
		draw_shape(0, 0, CustomShape.create(x,y).arc(x, y, radius, angle1, angle2), color, thickness);
	}

	public void draw_object(double x, double y, Object object) {
		add_operation(new DrawObjectOperation().set_x(x).set_y(y)
			.set_transform(transform).set_object(object));
	}

	public void draw_text(double x, double y, String text, Object font = null) {
		var props = TextProperties.for_string(text);
		Color cc;
		var ff = font as Font;
		if(ff == null) {
			cc = font as Color;
		}
		if(cc == null && ff == null) {
			var ss = String.as_string(font);
			if(ss == null) {
				ss = "black";
			}
			cc = Color.instance(ss);
			if(cc == null && ss != null) {
				ff = Font.instance(ss);
			}
		}
		if(ff == null) {
			ff = Font.instance("2500um");
		}
		props.set_font(ff);
		props.set_color(cc);
		int dpi = 96;
		if(frame != null) {
			dpi = frame.get_dpi();
		}
		draw_object(x, y, TextLayout.for_properties(props, frame, dpi));
	}

	public void draw_image(double x, double y, Object image) {
		var img = image as Image;
		if(img == null && image != null) {
			if(image is File) {
				img = Image.for_file((File)image);
			}
			else {
				var ss = String.as_string(image);
				if(ss != null) {
					img = Image.for_resource(ss);
				}
			}
		}
		draw_object(x, y, img);
	}
}
