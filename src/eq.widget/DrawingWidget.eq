
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

public class DrawingWidget : Widget, DrawingContext
{
	DrawingOperationRecorder recorder;

	public DrawingContext get_render_contextr() {
		return(recorder);
	}

	public void draw_operation(Object op) {
		if(recorder == null || op == null) {
			return;
		}
		recorder.add_operation(op);
	}

	public void fill_background(Object color) {
		fill_rectangle(0, 0, get_width(), get_height(), color);
	}

	public virtual void draw() {
	}

	public Collection render() {
		recorder = DrawingOperationRecorder.for_frame(get_frame());
		draw();
		var v = recorder.get_operations();
		recorder = null;
		return(v);
	}

	public void set_drawing_rotation(double angle) {
		if(recorder != null) {
			recorder.set_drawing_rotation(angle);
		}
	}

	public void set_drawing_scaling(double sx, double sy) {
		if(recorder != null) {
			recorder.set_drawing_scaling(sx, sy);
		}
	}

	public void set_drawing_opacity(double alpha) {
		if(recorder != null) {
			recorder.set_drawing_opacity(alpha);
		}
	}

	public void clear_transforms() {
		if(recorder != null) {
			recorder.clear_transforms();
		}
	}

	public void add_clip_rectangle(double x, double y, double width, double height) {
		if(recorder != null) {
			recorder.add_clip_rectangle(x, y, width, height);
		}
	}

	public void clear_clips() {
		if(recorder != null) {
			recorder.clear_clips();
		}
	}

	public void clear_rectangle(double x, double y, double width, double height) {
		if(recorder != null) {
			recorder.clear_rectangle(x, y, width, height);
		}
	}

	public void fill_shape(double x, double y, Shape shape, Object color) {
		if(recorder != null) {
			recorder.fill_shape(x, y, shape, color);
		}
	}

	public void fill_rectangle(double x, double y, double width, double height, Object color) {
		if(recorder != null) {
			recorder.fill_rectangle(x, y, width, height, color);
		}
	}

	public void fill_rounded_rectangle(double x, double y, double width, double height, double rounding, Object color) {
		if(recorder != null) {
			recorder.fill_rounded_rectangle(x, y, width, height, rounding, color);
		}
	}

	public void fill_circle(double x, double y, double radius, Object color) {
		if(recorder != null) {
			recorder.fill_circle(x, y, radius, color);
		}
	}

	public void fill_shape_gradient(double x, double y, Shape shape, Object color, Object color2 = null, int direction = 0) {
		if(recorder != null) {
			recorder.fill_shape_gradient(x, y, shape, color, color2, direction);
		}
	}

	public void fill_rectangle_gradient(double x, double y, double width, double height, Object color, Object color2 = null, int direction = 0) {
		if(recorder != null) {
			recorder.fill_rectangle_gradient(x, y, width, height, color, color2, direction);
		}
	}

	public void fill_rounded_rectangle_gradient(double x, double y, double width, double height, double rounding, Object color, Object color2 = null, int direction = 0) {
		if(recorder != null) {
			recorder.fill_rounded_rectangle_gradient(x, y, width, height, rounding, color, color2, direction);
		}
	}

	public void fill_circle_gradient(double x, double y, double radius, Object color, Object color2 = null, int direction = 0) {
		if(recorder != null) {
			recorder.fill_circle_gradient(x, y, radius, color, color2, direction);
		}
	}

	public void draw_shape(double x, double y, Shape shape, Object color, double thickness = 1) {
		if(recorder != null) {
			recorder.draw_shape(x, y, shape, color, thickness);
		}
	}

	public void draw_rectangle(double x, double y, double width, double height, Object color, double thickness = 1) {
		if(recorder != null) {
			recorder.draw_rectangle(x, y, width, height, color, width);
		}
	}

	public void draw_rounded_rectangle(double x, double y, double width, double height, double rounding, Object color, double thickness = 1) {
		if(recorder != null) {
			recorder.draw_rounded_rectangle(x, y, width, height, rounding, color, width);
		}
	}

	public void draw_circle(double x, double y, double radius, Object color, double thickness = 1) {
		if(recorder != null) {
			recorder.draw_circle(x, y, radius, color, thickness);
		}
	}

	public void draw_line(double x1, double y1, double x2, double y2, Object color, double thickness = 1) {
		if(recorder != null) {
			recorder.draw_line(x1, y1, x2, y2, color, thickness);
		}
	}

	public void draw_curve(double x1, double y1, double x2, double y2, double x3, double y3, Object color, double thickness = 1) {
		if(recorder != null) {
			recorder.draw_curve(x1, y1, x2, y3, x3, y3, color, thickness);
		}
	}

	public void draw_arc(double x, double y, double radius, double angle1, double angle2, Object color, double thickness = 1) {
		if(recorder != null) {
			recorder.draw_arc(x, y, radius, angle1, angle2, color, thickness);
		}
	}

	public void draw_text(double x, double y, String text, Object font = null) {
		if(recorder != null) {
			recorder.draw_text(x, y, text, font);
		}
	}

	public void draw_object(double x, double y, Object object) {
		if(recorder != null) {
			recorder.draw_object(x, y, object);
		}
	}

	public void draw_image(double x, double y, Object image) {
		if(recorder != null) {
			recorder.draw_image(x, y, image);
		}
	}
}
