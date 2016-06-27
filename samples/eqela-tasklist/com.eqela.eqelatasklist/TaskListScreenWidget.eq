
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

class TaskListScreenWidget : TwoLayerContainerWidget
{
	class ClearEvent
	{
	}

	class AboutEvent
	{
	}

	class MainMenuWidget : LayerWidget
	{
		class MyButtonWidget : ButtonWidget
		{
			public MyButtonWidget() {
				set_color(Color.instance("#444488"));
				set_font(Theme.font().modify("Jawbreaker_Hard_BRK.ttf 4mm color=white"));
				set_pressed_font(Theme.font().modify("Jawbreaker_Hard_BRK.ttf 4mm color=#CCCCCC"));
			}
		}
		
		public void initialize() {
			base.initialize();
			add(CanvasWidget.for_color(Color.instance("#202050")));
			var box = BoxWidget.vertical();
			box.set_margin(px("1mm"));
			box.set_spacing(px("1mm"));
			box.add(LayerWidget.instance().set_margin(px("3mm")).add(ImageWidget.for_image(IconCache.get("eqela_splash_logo")).set_image_height(px("10mm"))));
			box.add(new MyButtonWidget().set_text("Clear").set_event(new ClearEvent()));
			box.add(new MyButtonWidget().set_text("About").set_event(new AboutEvent()));
			add(box);
		}
	}

	public TaskListScreenWidget() {
		set_background(new MainMenuWidget());
		set_foreground(new TaskListWidget());
	}

	public void on_event(Object o) {
		if(o is ClearEvent) {
			hide_background();
			var tl = get_foreground() as TaskListWidget;
			if(tl != null) {
				tl.on_clear_request();
			}
			return;
		}
		if(o is AboutEvent) {
			hide_background();
			Popup.widget(get_engine(), new AboutDialogWidget());
			return;
		}
		base.on_event(o);
	}
}
