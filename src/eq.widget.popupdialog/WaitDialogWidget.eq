
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

public class WaitDialogWidget : PopupDialogWidget, WaitDialog
{
	property BackgroundTask task;
	LabelWidget label;
	String text;

	public void set_text(String text) {
		this.text = text;
		if(label != null) {
			label.set_text(text);
		}
	}

	public void initialize() {
		base.initialize();
		set_maximum_width_request(px("60mm"));
		set_draw_color(Color.black());
		add(CanvasWidget.for_color(Color.white()));
		var box = BoxWidget.vertical().set_margin(px("5mm")).set_spacing(px("5mm"));
		box.add_box(1, new WaitAnimationWidget().set_size_request_override(px("50mm"), px("50mm")));
		box.add(label = LabelWidget.for_string(text).set_wrap(true));
		add(box);
	}

	public void cleanup() {
		base.cleanup();
		label = null;
	}
}
