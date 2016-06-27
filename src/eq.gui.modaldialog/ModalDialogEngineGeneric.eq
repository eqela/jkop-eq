
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

IFDEF("target_osx") {
}

ELSE IFDEF("target_android") {
}

ELSE IFDEF("target_ios") {
}

ELSE IFDEF("target_linux") {
}

ELSE IFDEF("target_html5") {
}

ELSE IFDEF("target_wpcs") {
}

ELSE IFDEF("target_uwpcs") {
}

ELSE IFDEF("target_j2se") {
}

ELSE {
class ModalDialogEngineGeneric : ModalDialogEngine
{
	class GenericEventReceiver : EventReceiver
	{
		property ModalDialogListener listener;
		public void on_event(Object o) {
			if(listener != null) {
				listener.on_dialog_closed();
			}
		}
	}

	public void message(Frame frame, String text, String title, ModalDialogListener listener) {
		var dlg = MessageDialogWidget.for_message(text);
		dlg.set_title(title);
		dlg.set_listener(new GenericEventReceiver().set_listener(listener));
		Frame.open_as_popup(WidgetEngine.for_widget(dlg), frame);
	}

	public void error(Frame frame, String text, String title, ModalDialogListener listener) {
		var dlg = DialogWidget.error(text);
		dlg.set_title(title);
		dlg.set_listener(new GenericEventReceiver().set_listener(listener));
		Frame.open_as_popup(WidgetEngine.for_widget(dlg), frame);
	}

	class MyBooleanEventReceiver : EventReceiver
	{
		property ModalDialogBooleanListener listener;
		public void on_event(Object o) {
			if(listener == null) {
				return;
			}
			if("yes".equals(o) || "ok".equals(o)) {
				listener.on_dialog_boolean_result(true);
			}
			else {
				listener.on_dialog_boolean_result(false);
			}
		}
	}

	public void yesno(Frame frame, String text, String title, ModalDialogBooleanListener listener) {
		var ll = new MyBooleanEventReceiver().set_listener(listener);
		var dlg = YesNoDialogWidget.for_question(text);
		dlg.set_listener(ll);
		dlg.set_title(title);
		Frame.open_as_popup(WidgetEngine.for_widget(dlg), frame);
	}

	public void okcancel(Frame frame, String text, String title, ModalDialogBooleanListener listener) {
		var ll = new MyBooleanEventReceiver().set_listener(listener);
		var dlg = OKCancelDialogWidget.for_question(text);
		dlg.set_listener(ll);
		dlg.set_title(title);
		Frame.open_as_popup(WidgetEngine.for_widget(dlg), frame);
	}

	class MyStringEventReceiver : EventReceiver
	{
		property ModalDialogStringListener listener;
		public void on_event(Object o) {
			if(listener == null) {
				return;
			}
			var ter = o as TextInputResult;
			if(ter == null) {
				return;
			}
			if(ter.get_status() == false) {
				listener.on_dialog_string_result(null);
				return;
			}
			listener.on_dialog_string_result(ter.get_text());
		}
	}

	public void textinput(Frame frame, String text, String title, String initial_value, ModalDialogStringListener listener) {
		var ll = new MyStringEventReceiver().set_listener(listener);
		var ww = TextInputDialogWidget.instance(title, text, initial_value, null, null, ll);
		Frame.open_as_popup(WidgetEngine.for_widget(ww), frame);
	}
}
}
