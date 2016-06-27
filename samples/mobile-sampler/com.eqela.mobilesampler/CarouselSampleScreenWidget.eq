
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

class CarouselSampleScreenWidget : MobileApplicationScreenWidget
{
	public Object get_mobile_app_title() {
		return("Carousel");
	}

	public void initialize() {
		base.initialize();
		add(ImageWidget.for_resource("scenery").set_mode("fill"));
		add(CanvasWidget.for_color(Color.instance("#00000080")));
		var carousel = CarouselWidget.instance();
		carousel.add_page(ImageWidget.for_resource("eqela_e").set_mode("fit"), px("10mm"));
		carousel.add_page(ImageWidget.for_resource("eqela_q").set_mode("fit"), px("10mm"));
		carousel.add_page(ImageWidget.for_resource("eqela_el").set_mode("fit"),px("10mm"));
		carousel.add_page(ImageWidget.for_resource("eqela_a").set_mode("fit"), px("10mm"));
		var box = BoxWidget.vertical();
		box.set_spacing(px("1mm"));
		box.add_box(1, carousel);
		box.add(LayerWidget.instance()
			.set_margin(px("1mm"))
			.add(CanvasWidget.for_color(Color.instance("#FFFFFF40")).set_rounded(true))
			.add(LayerWidget.for_widget(LabelWidget.for_string("< Swipe left & right >")
				.modify_font("bold 3500um color=orange"), px("2mm")))
			.set_draw_color(Color.black())
		);
		add(box);
	}
}
