
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

public class GoogleCustomLogin : LayerWidget, EventReceiver
{
	class CloseButton : ClickWidget
	{
		property Image close_icon;

		public void initialize() {
			base.initialize();
			if(close_icon != null) {
				add(ImageWidget.for_image(close_icon).set_size_request_override(px("6mm"), px("6mm")));
			}
			else {
				add(ImageWidget.for_icon("close_window").set_size_request_override(px("6mm"), px("6mm")));
			}
			set_event("close_btn_clicked");
		}
	}

	property Widget login_widget;
	property GoogleLoginListener listener;
	property Image close_icon;

	public void initialize() {
		base.initialize();
		var bg = LayerWidget.instance().add(CanvasWidget.for_color(Color.instance("#50524f")));
		bg.set_alpha(0.9);
		add(bg);
		var layer = LayerWidget.instance();
		layer.set_margin(px("3mm"));
		layer.add(login_widget);
		add(layer);
		var align_btn = AlignWidget.instance();
		add(align_btn);
		align_btn.add_align(-1, -1, new CloseButton().set_close_icon(close_icon));
	}

	public void on_event(Object o) {
		if("close_btn_clicked".equals(o)) {
			Popup.close(this);
		}
	}
}
