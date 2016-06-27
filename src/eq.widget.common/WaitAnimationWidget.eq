
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

public class WaitAnimationWidget : Widget
{
	public static WaitAnimationWidget icon() {
		return(new WaitAnimationWidget().set_is_icon(true));
	}

	public static WaitAnimationWidget instance() {
		return(new WaitAnimationWidget());
	}

	property bool is_icon = true;
	bool is_rotate_capable = true;
	property Color background_color;
	property Color foreground_color;

	public WaitAnimationWidget() {
		background_color = Theme.color("eq.widget.common.WaitAnimationWidget.background_color", "%s".printf().add(Theme.get_base_color()).to_string());
		foreground_color = Theme.color("eq.widget.common.WaitAnimationWidget.foreground_color",
			"%s".printf().add(Theme.get_highlight_color()).to_string());
	}

	public void initialize() {
		base.initialize();
		if(is_icon) {
			var sz = px(Theme.get_icon_size());
			set_size_request(sz, sz);
		}
		is_rotate_capable = CapabilityFrame.check(get_frame(), "rotation");
		// FIXME: when is_rotate_capable == false, the positioning of the circle is wrong!
		// To test: is_rotate_capable = false;
	}

	public void start() {
		base.start();
		spin_start(1000000);
	}

	public void on_rotate() {
		if(is_rotate_capable == false) {
			update_view();
		}
		else {
			base.on_rotate();
		}
	}

	public Collection render() {
		var w = get_width(), w2 = w/2, h = get_height(), h2 = h/2;
		var mm1 = px("1mm");
		var wrad = w2;
		if(h2 < wrad) {
			wrad = h2;
		}
		var mm = wrad / 5;
		if(mm < mm1) {
			mm = mm1;
		}
		var rad = (double)mm / 2;
		double x = w2, y = h2-wrad+rad;
		if(is_rotate_capable == false) {
			var ra = get_rotation();
			x = w2-rad + ((wrad-mm) * Math.cos(ra));
			y = h2-rad + ((wrad-mm) * Math.sin(ra));
		}
		return(LinkedList.create()
			.add(new StrokeOperation()
				.set_shape(CircleShape.create(w2,h2,wrad))
				.set_color(background_color)
				.set_width(mm))
			.add(new FillColorOperation().set_x(x).set_y(y)
				.set_shape(CircleShape.create(rad, rad, rad))
				.set_color(foreground_color))
		);
	}
}
