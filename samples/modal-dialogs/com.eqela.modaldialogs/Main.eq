
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

public class Main : LayerWidget, EventReceiver
{
	public void initialize() {
		base.initialize();
		set_draw_color(Color.instance("black"));
		set_size_request_override(px("60mm"), px("80mm"));
		add(CanvasWidget.for_color(Color.instance("white")));
		var box = BoxWidget.vertical().set_spacing(px("1mm")).set_margin(px("1mm"));
		box.add(ButtonWidget.for_string("Message").set_event("message"));
		box.add(ButtonWidget.for_string("Error").set_event("error"));
		box.add(ButtonWidget.for_string("Yes / No").set_event("yesno"));
		box.add(ButtonWidget.for_string("OK / Cancel").set_event("okcancel"));
		box.add(ButtonWidget.for_string("Text Input").set_event("textinput"));
		add(box);
	}

	public void cleanup() {
		base.cleanup();
	}

	class MessageCloseListener : ModalDialogListener
	{
		public void on_dialog_closed() {
			ModalDialog.message("Dialog closed");
		}
	}

	class BooleanListener : ModalDialogBooleanListener
	{
		public void on_dialog_boolean_result(bool result) {
			if(result) {
				ModalDialog.message("You said YES or OK");
			}
			else {
				ModalDialog.message("You said NO or CANCEL");
			}
		}
	}

	class StringListener : ModalDialogStringListener
	{
		public void on_dialog_string_result(String result) {
			if(result == null) {
				ModalDialog.message("You cancelled the input");
			}
			else {
				ModalDialog.message("You wrote: `%s'".printf().add(result).to_string());
			}
		}
	}

	public void on_event(Object o) {
		if("message".equals(o)) {
			ModalDialog.message("This is a message", null, new MessageCloseListener());
			return;
		}
		if("error".equals(o)) {
			ModalDialog.error("This is an error", null, new MessageCloseListener());
			return;
		}
		if("yesno".equals(o)) {
			ModalDialog.yesno("This is a yes / no dialog", null, new BooleanListener());
			return;
		}
		if("okcancel".equals(o)) {
			ModalDialog.okcancel("This is an ok / cancel dialog", "Please tell us", new BooleanListener());
			return;
		}
		if("textinput".equals(o)) {
			ModalDialog.textinput("Input text", null, "This is it", new StringListener());
			return;
		}
	}
}
