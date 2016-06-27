
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

public class AboutDialog
{
	class AboutWidget : LayerWidget, EventReceiver
	{
		public void initialize() {
			base.initialize();
			set_frame_title("About ".append(Application.get_display_name()));
			set_size_request_override(px("90mm"), px("45mm"));
			add(CanvasWidget.for_color_gradient(Color.instance("#DDDDDD")));
			set_draw_color(Color.instance("black"));
			var box = BoxWidget.vertical();
			box.set_margin(px("1mm"));
			box.set_spacing(px("2mm"));
			box.add(LabelWidget.for_string("%s %s".printf()
				.add(Application.get_display_name())
				.add(Application.get_version()).to_string())
				.set_wrap(true)
				.set_font(Theme.font().modify("color=#222288 bold 5mm")));
			var desc = Application.get_description();
			if(String.is_empty(desc) == false) {
				box.add(LabelWidget.for_string(desc).set_wrap(true));
			}
			var cp = Application.get_copyright();
			if(String.is_empty(cp) == false) {
				box.add(LabelWidget.for_string(cp));
			}
			var b2 = BoxWidget.vertical();
			b2.set_margin(px("1mm"));
			b2.set_spacing(px("1mm"));
			b2.add_box(1, AlignWidget.for_widget(VScrollerWidget.for_widget(box)));
			b2.add(ButtonWidget.for_string("OK").set_color(Color.instance("lightgreen")).set_event("ok"));
			add(b2);
		}

		public void on_event(Object o) {
			if("ok".equals(o)) {
				close_frame();
			}
		}
	}

	public static void show(Frame frame = null) {
		Frame.open_as_popup(WidgetEngine.for_widget(new AboutWidget()), frame);
	}
}
