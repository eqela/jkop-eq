
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

class IntroScreenWidget : MobileApplicationScreenWidget
{
	public Object get_mobile_app_title() {
		return(null);
	}

	ImageWidget logo;

	public void initialize() {
		base.initialize();
		set_draw_color(Color.instance("white"));
		add(CanvasWidget.for_color_gradient(Color.instance("#003333")));
		var box = BoxWidget.vertical();
		box.set_margin(px("2mm"));
		box.set_spacing(px("2mm"));
		box.add(logo = ImageWidget.for_resource("eqelagray"));
		box.add(LabelWidget.for_string("Tap to continue")
			.set_font(Theme.font().modify("4mm bold color=white outline-color=#99FFFF")));
		add(AlignWidget.for_widget(box));
	}

	public void on_resize() {
		base.on_resize();
		logo.set_image_width(get_width() * 0.75);
	}

	public bool on_pointer_release(int x, int y, int button, int id) {
		push_screen(new MenuScreenWidget());
		return(true);
	}
}
