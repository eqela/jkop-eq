
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

class MenuScreenWidget : MobileApplicationScreenWidget
{
	class AboutAction : Executable
	{
		public void execute() {
			AboutDialog.show();
		}
	}

	public Collection get_mobile_app_menu_items() {
		var v = LinkedList.create();
		var about_item = ActionItem.for_text("About "
			.append(Application.get_display_name()));
		about_item.set_action(new AboutAction());
		v.add(about_item);
		return(v);
	}

	public void initialize() {
		base.initialize();
		set_draw_color(Color.white());
		add(CanvasWidget.for_color(Color.black()));
		var box = BoxWidget.vertical();
		box.set_margin(px("1mm"));
		box.set_spacing(px("1mm"));
		box.add(LayerWidget.for_widget(LabelWidget.for_string("Please choose one of the entries below")
			.scale_font(1.5).set_color(Color.instance("yellow")), px("3mm")));
		box.add(ButtonWidget.for_string("Form Sample").set_event("formsample"));
		box.add(ButtonWidget.for_string("Carousel").set_event("carousel"));
		box.add(ButtonWidget.for_string("Animation").set_event("animation"));
		add(VScrollerWidget.for_widget(box));
	}

	public void cleanup() {
		base.cleanup();
	}

	public void on_event(Object o) {
		if("formsample".equals(o)) {
			push_screen(new FormScreenWidget());
		}
		else if("carousel".equals(o)) {
			push_screen(new CarouselSampleScreenWidget());
		}
		else if("animation".equals(o)) {
			push_screen(new AnimationScreenWidget());
		}
	}
}
