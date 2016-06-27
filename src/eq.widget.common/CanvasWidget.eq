
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

public class CanvasWidget : Widget
{
	Color color;
	Color color2;
	Color outline_color;
	String outline_width;
	bool rounded;
	String rounding_radius;

	public static CanvasWidget instance() {
		return(new CanvasWidget());
	}

	public static CanvasWidget for_color_gradient(Color color) {
		return(new CanvasWidget().set_color_gradient(color));
	}

	public static CanvasWidget for_color(Color color) {
		return(new CanvasWidget().set_color(color));
	}

	public static CanvasWidget for_colors(Color a, Color b) {
		return(new CanvasWidget().set_color(a).set_color2(b));
	}

	public CanvasWidget() {
		rounding_radius = "1000um";
		outline_width = Theme.string("eq.widget.common.outline_width", "333um");
	}

	public CanvasWidget set_color(Color color) {
		this.color = color;
		update_view();
		return(this);
	}

	public CanvasWidget set_colors(Color color1, Color color2) {
		this.color = color1;
		this.color2 = color2;
		update_view();
		return(this);
	}

	public CanvasWidget set_color_gradient(Color color) {
		if(color == null) {
			this.color = null;
			this.color2 = null;
		}
		else {
			this.color = color.dup("125%");
			this.color2 = color.dup("75%");
		}
		update_view();
		return(this);
	}

	public Color get_color() {
		return(color);
	}

	public CanvasWidget set_color2(Color color2) {
		this.color2 = color2;
		update_view();
		return(this);
	}

	public Color get_color2() {
		return(color2);
	}

	public CanvasWidget set_outline_color(Color outline_color) {
		this.outline_color = outline_color;
		update_view();
		return(this);
	}

	public Color get_outline_color() {
		return(outline_color);
	}

	public CanvasWidget set_outline_width(String outline_width) {
		this.outline_width = outline_width;
		update_view();
		return(this);
	}

	public String get_outline_width() {
		return(outline_width);
	}

	public CanvasWidget set_rounded(bool rounded) {
		this.rounded = rounded;
		update_view();
		return(this);
	}

	public bool get_rounded() {
		return(rounded);
	}

	public CanvasWidget set_rounding_radius(String rounding_radius) {
		this.rounding_radius = rounding_radius;
		update_view();
		return(this);
	}

	public String get_rounding_radius() {
		return(rounding_radius);
	}

	public Collection render() {
		if(color == null && outline_color == null) {
			return(null);
		}
		Shape shape;
		if(rounded) {
			shape = RoundedRectangleShape.create(0, 0, get_width(), get_height(), px(rounding_radius));
		}
		else {
			shape = RectangleShape.create(0, 0, get_width(), get_height());
		}
		var v = LinkedList.create();
		if(color != null) {
			if(color2 == null) {
				v.add(new FillColorOperation().set_shape(shape).set_color(color));
			}
			else {
				v.add(new FillGradientOperation().set_shape(shape)
					.set_color1(color).set_color2(color2).set_type(FillGradientOperation.VERTICAL));
			}
		}
		if(outline_color != null && String.is_empty(outline_width) == false) {
			v.add(new StrokeOperation().set_shape(shape).set_color(outline_color).set_width(px(outline_width)));
		}
		return(v);
	}
}
