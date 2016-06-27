
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

class AnimationScreenWidget : MobileApplicationScreenWidget
{
	public Object get_mobile_app_title() {
		return("Widget Animation");
	}

	ButtonWidget button;
	LabelWidget label;

	public void initialize() {
		base.initialize();
		add(CanvasWidget.for_color_gradient(Color.instance("#8080FF")));
		var w = AlignWidget.instance();
		w.set_margin(px("2mm"));
		button = ButtonWidget.for_string("Click me");
		button.set_font(Theme.font().modify("5mm bold"));
		button.set_pressed_font(Theme.font().modify("5mm bold outline-color=%s".printf().add(Theme.get_highlight_color()).to_string()));
		button.set_margin(px("2mm"));
		w.add_align(0, 0, button);
		label = LabelWidget.for_string("Hello world!");
		label.set_font(Theme.font().modify("6mm bold"));
		w.add_align(0, -2.0, label);
		label.set_alpha(0.0);
		w.add_align(1,1,LabelWidget.for_string("Powered by Eqela 3.0")
			.set_font(Theme.font().modify("5mm bold"))
			.set_color(Color.instance("#FF0000")).set_outline_color(Color.instance("#FFFFFF")));
		add(w);
	}

	public void start() {
		base.start();
		button.spin_start(3000000);
	}

	public void cleanup() {
		base.cleanup();
		button = null;
		label = null;
	}

	public void on_event(Object o) {
		if(label.get_align_y() < -1.0) {
			label.set_align(0, -1.0, 500000);
			label.set_alpha(1.0, 500000);
			button.set_align(0.0, 1.0, 500000);
		}
		else {
			label.set_align(0, -2.0, 500000);
			label.set_alpha(0.0, 500000);
			button.set_align(0.0, 0.0, 500000);
		}
	}
}
