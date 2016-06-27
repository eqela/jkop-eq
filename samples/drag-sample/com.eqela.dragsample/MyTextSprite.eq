
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

class MyTextSprite : SESpriteEntity, SEPointerListener, EventReceiver
{
	String text;

	public void initialize(SEResourceCache rsc) {
		base.initialize(rsc);
		set_text(text = "Drag the logos", "myfont");
	}

	public void on_pointer_move(SEPointerInfo pi) {
	}

	public void on_pointer_press(SEPointerInfo pi) {
		if(pi.is_inside(get_x(), get_y(), get_width(), get_height())) {
			Popup.execute_in_frame(get_scene().get_frame(), PopupSettings.for_widget(TextInputDialogWidget.instance(
				"Enter new text", "Please enter a new text label", text, "Enter text here ..", null, this)));
		}
	}

	public void on_pointer_release(SEPointerInfo pi) {
	}

	public void on_event(Object o) {
		if(o != null && o is TextInputResult && ((TextInputResult)o).get_status()) {
			set_text(text = ((TextInputResult)o).get_text());
		}
	}
}
