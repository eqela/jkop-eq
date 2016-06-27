
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

public class SeparatorWidget : Widget
{
	public static SeparatorWidget instance() {
		return(new SeparatorWidget());
	}

	property bool horizontal = false;
	property bool vertical = false;
	property bool flat = false;
	property Color flat_color;
	property String thickness;

	public SeparatorWidget() {
		thickness = "3px";
	}

	bool is_hz() {
		var hz = false;
		int w = get_width();
		int h = get_height();
		if(horizontal == vertical) {
			if(w > h) {
				hz = true;
			}
		}
		else if(horizontal) {
			hz = true;
		}
		return(hz);
	}

	Collection render_flat() {
		var cc = flat_color;
		if(cc == null) {
			cc = get_draw_color();
		}
		var ww = px(get_thickness());
		if(ww < 1) {
			ww = 1;
		}
		var hz = is_hz();
		var v = LinkedList.create();
		if(hz) {
			v.add(new FillColorOperation()
				.set_color(cc).set_x(0).set_y(0)
				.set_shape(RectangleShape.create(0, 0, get_width(), ww))
			);
		}
		else {
			v.add(new FillColorOperation()
				.set_color(cc).set_x(0).set_y(0)
				.set_shape(RectangleShape.create(0, 0, ww, get_height()))
			);
		}
		return(v);
	}

	public Collection render() {
		if(flat) {
			return(render_flat());
		}
		var v = LinkedList.create();
		int w = get_width();
		int h = get_height();
		var hz = is_hz();
		var black_0p = Color.instance("#000000").set_a(0);
		var black_80p = Color.instance("#000000").set_a(0.8);
		var white_0p = Color.instance("#FFFFFF").set_a(0);
		var white_80p = Color.instance("#FFFFFF").set_a(0.8);
		if(hz) {
			v.add(new FillGradientOperation().set_x(0).set_y(0)
				.set_shape(RectangleShape.create(0, 0, w / 2, 1))
				.set_color1(black_0p).set_color2(black_80p)
				.set_type(FillGradientOperation.HORIZONTAL));
			v.add(new FillGradientOperation().set_x(0).set_y(0)
				.set_shape(RectangleShape.create(w / 2, 0, w / 2, 1))
				.set_color1(black_80p).set_color2(black_0p)
				.set_type(FillGradientOperation.HORIZONTAL));
			v.add(new FillGradientOperation().set_x(0).set_y(0)
				.set_shape(RectangleShape.create(0, 2, w / 2, 1))
				.set_color1(white_0p).set_color2(white_80p)
				.set_type(FillGradientOperation.HORIZONTAL));
			v.add(new FillGradientOperation().set_x(0).set_y(0)
				.set_shape(RectangleShape.create(w / 2, 2, w / 2, 1))
				.set_color1(white_80p).set_color2(white_0p)
				.set_type(FillGradientOperation.HORIZONTAL));
		}
		else {
			v.add(new FillGradientOperation().set_x(0).set_y(0)
				.set_shape(RectangleShape.create(0, 0, 1, h / 2))
				.set_color1(black_0p).set_color2(black_80p)
				.set_type(FillGradientOperation.VERTICAL));
			v.add(new FillGradientOperation().set_x(0).set_y(0)
				.set_shape(RectangleShape.create(0, h / 2, 1, h / 2))
				.set_color1(black_80p).set_color2(black_0p)
				.set_type(FillGradientOperation.VERTICAL));
			v.add(new FillGradientOperation().set_x(0).set_y(0)
				.set_shape(RectangleShape.create(2, 0, 1, h / 2))
				.set_color1(white_0p).set_color2(white_80p)
				.set_type(FillGradientOperation.VERTICAL));
			v.add(new FillGradientOperation().set_x(0).set_y(0)
				.set_shape(RectangleShape.create(2, h / 2, 1, h / 2))
				.set_color1(white_80p).set_color2(white_0p)
				.set_type(FillGradientOperation.VERTICAL));
		}
		return(v);
	}
}
