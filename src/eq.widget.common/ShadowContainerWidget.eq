
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

public class ShadowContainerWidget : LayerWidget
{
	public static ShadowContainerWidget for_widget(Widget w) {
		return(new ShadowContainerWidget().add(w) as ShadowContainerWidget);
	}

	public static ShadowContainerWidget instance() {
		return(new ShadowContainerWidget());
	}

	String thickness = null;
	property Color color;
	property bool shadow_left = true;
	property bool shadow_right = true;
	property bool shadow_top = true;
	property bool shadow_bottom = true;
	property double solid_alpha = 0.5;

	public ShadowContainerWidget set_shadow_color(Color color) {
		this.color = color;
		update_view();
		return(this);
	}

	public ShadowContainerWidget set_shadow_thickness(String thick) {
		this.thickness = thick;
		update_margins();
		return(this);
	}

	private void update_margins() {
		if(is_initialized() == false) {
			return;
		}
		if(thickness == null) {
			thickness = "3mm";
		}
		var tt = px(thickness);
		int lm = tt, rm = tt, tm = tt, bm = tt;
		if(shadow_top == false) {
			tm = 0;
		}
		if(shadow_bottom == false) {
			bm = 0;
		}
		if(shadow_left == false) {
			lm = 0;
		}
		if(shadow_right == false) {
			rm = 0;
		}
		set_margins(lm, rm, tm, bm);
		update_view();
	}

	public void initialize() {
		base.initialize();
		update_margins();
	}

	public Collection render() {
		var v = LinkedList.create();
		var color = this.color;
		if(color == null) {
			color = Color.instance("black");
		}
		var color_solid = color.dup("100%");
		color_solid.set_a(solid_alpha);
		var color_alpha = color.dup("100%");
		color_alpha.set_a(0);
		var t = px(thickness);
		int wr = 0, wl = 0, wt = 0, wb = 0;
		if(shadow_left) {
			wl = t;
		}
		if(shadow_right) {
			wr = t;
		}
		if(shadow_top) {
			wt = t;
		}
		if(shadow_bottom) {
			wb = t;
		}
		if(shadow_top) {
			var rect = RectangleShape.create(0, 0, get_width()-wl-wr, t);
			v.add(new FillGradientOperation().set_x(wl).set_y(0)
				.set_shape(rect).set_type(FillGradientOperation.VERTICAL)
				.set_color1(color_alpha).set_color2(color_solid));
		}
		if(shadow_bottom) {
			var rect = RectangleShape.create(0, 0, get_width()-wl-wr, t);
			v.add(new FillGradientOperation().set_x(wl).set_y(get_height()-t)
				.set_shape(rect).set_type(FillGradientOperation.VERTICAL)
				.set_color1(color_solid).set_color2(color_alpha));
		}
		if(shadow_left) {
			var rect = RectangleShape.create(0, 0, t, get_height()-wt-wb);
			v.add(new FillGradientOperation().set_x(0).set_y(wt)
				.set_shape(rect).set_type(FillGradientOperation.HORIZONTAL)
				.set_color1(color_alpha).set_color2(color_solid));
		}
		if(shadow_right) {
			var rect = RectangleShape.create(0, 0, t, get_height()-wt-wb);
			v.add(new FillGradientOperation().set_x(get_width()-t).set_y(wt)
				.set_shape(rect).set_type(FillGradientOperation.HORIZONTAL)
				.set_color1(color_solid).set_color2(color_alpha));
		}
		var circle = CircleShape.create(0, 0, t);
		if(shadow_top && shadow_left) {
			v.add(new ClipOperation().set_shape(RectangleShape.create(0, 0, t, t)));
			v.add(new FillGradientOperation().set_x(t).set_y(t)
				.set_shape(circle).set_type(FillGradientOperation.RADIAL)
				.set_radius(t).set_color1(color_solid).set_color2(color_alpha));
			v.add(new ClipClearOperation());
		}
		if(shadow_top && shadow_right) {
			v.add(new ClipOperation().set_shape(RectangleShape.create(get_width()-t, 0, t, t)));
			v.add(new FillGradientOperation().set_x(get_width()-t).set_y(t)
				.set_shape(circle).set_type(FillGradientOperation.RADIAL)
				.set_radius(t).set_color1(color_solid).set_color2(color_alpha));
			v.add(new ClipClearOperation());
		}
		if(shadow_bottom && shadow_left) {
			v.add(new ClipOperation().set_shape(RectangleShape.create(0, get_height()-t, t, t)));
			v.add(new FillGradientOperation().set_x(t).set_y(get_height()-t)
				.set_shape(circle).set_type(FillGradientOperation.RADIAL)
				.set_radius(t).set_color1(color_solid).set_color2(color_alpha));
			v.add(new ClipClearOperation());
		}
		if(shadow_bottom && shadow_right) {
			v.add(new ClipOperation().set_shape(RectangleShape.create(get_width()-t, get_height()-t, t, t)));
			v.add(new FillGradientOperation().set_x(get_width()-t).set_y(get_height()-t)
				.set_shape(circle).set_type(FillGradientOperation.RADIAL)
				.set_radius(t).set_color1(color_solid).set_color2(color_alpha));
			v.add(new ClipClearOperation());
		}
		return(v);
	}
}

