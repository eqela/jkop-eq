
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

public class DialogWidget : WindowFrameWidget, EventReceiver
{
	public static DialogWidget yesno(String question, String title = null, Object eyes = null Object eno = null) {
		var dd = YesNoDialogWidget.for_question(question);
		if(title != null) {
			dd.set_title(title);
		}
		if(eyes != null) {
			dd.set_event_yes(eyes);
		}
		if(eno != null) {
			dd.set_event_no(eno);
		}
		return(dd);
	}

	public static DialogWidget okcancel(String question, String title = null, Object eok = null, Object ecancel = null) {
		var dd = OKCancelDialogWidget.for_question(question);
		if(title != null) {
			dd.set_title(title);
		}
		if(eok != null) {
			dd.set_event_ok(eok);
		}
		if(ecancel != null) {
			dd.set_event_cancel(ecancel);
		}
		return(dd);
	}

	public static DialogWidget message(String txt, String title = null, Object eok = null, bool buttons = true) {
		var dd = MessageDialogWidget.for_message(txt);
		dd.set_title("Notification");
		if(title != null) {
			dd.set_title(title);
		}
		if(buttons == false) {
			dd.set_event_ok(null);
		}
		else if(eok != null) {
			dd.set_event_ok(eok);
		}
		return(dd);
	}

	public static DialogWidget warning(String txt, String title = null, Object eok = null) {
		var dd = MessageDialogWidget.for_message(txt);
		dd.set_title("Warning");
		if(title != null) {
			dd.set_title(title);
		}
		if(eok != null) {
			dd.set_event_ok(eok);
		}
		return(dd);
	}

	public static DialogWidget error(String txt, String title = null, Object eok = null) {
		var dd = MessageDialogWidget.for_message(txt);
		dd.set_title("Error");
		if(title != null) {
			dd.set_title(title);
		}
		if(eok != null) {
			dd.set_event_ok(eok);
		}
		return(dd);
	}

	public static DialogWidget instance() {
		return(new DialogWidget());
	}

	property EventReceiver listener = null;
	property Object cancel_event;
	property bool cancellable = true;
	Widget dialog_main_widget;
	Widget dialog_footer_widget;
	LayerWidget dialog_main_layer;
	LayerWidget dialog_footer_layer;
	property String dialog_width;
	property String dialog_box_spacing;
	property String dialog_content_margin;

	public DialogWidget() {
		set_minimum_content_height(Theme.string("eq.widget.dialog.DialogWidget.minimum_content_height", "35mm"));
		dialog_width = Theme.string("eq.widget.dialog.DialogWidget.dialog_width", "100mm");
		dialog_box_spacing = Theme.string("eq.widget.dialog.DialogWidget.box_spacing", "1mm");
		dialog_content_margin = Theme.string("eq.widget.dialog.DialogWidget.content_margin", "0mm");
	}

	public LayerWidget get_dialog_footer_layer() {
		return(dialog_footer_layer);
	}

	public virtual bool on_enter_pressed() {
		return(false);
	}

	public virtual void on_dialog_cancel() {
		if(cancel_event != null) {
			raise_event(cancel_event);
		}
		close_popup();
	}

	public bool on_key_press(KeyEvent e) {
		if("escape".equals(e.get_name()) || "back".equals(e.get_name())) {
			if(cancellable) {
				on_dialog_cancel();
				return(true);
			}
		}
		else if("return".equals(e.get_name()) || "enter".equals(e.get_name())) {
			if(on_enter_pressed()) {
				return(true);
			}
		}
		return(base.on_key_press(e));
	}

	public void close_popup() {
		if(Popup.is_popup(this)) {
			Popup.close(this);
		}
		else {
			Frame.close(get_frame());
		}
	}

	public void on_event(Object o) {
		if(o is WindowFrameCloseEvent) {
			if(cancellable) {
				on_dialog_cancel();
			}
			return;
		}
		if(on_dialog_widget_event(o) == false) {
			close_popup();
			if(listener != null) {
				listener.on_event(o);
			}
			else {
				raise_event(o, false);
			}
		}
	}

	public DialogWidget set_dialog_main_widget(Widget widget) {
		dialog_main_widget = widget;
		if(dialog_main_layer != null) {
			dialog_main_layer.remove_children();
			if(widget != null) {
				dialog_main_layer.add(widget);
			}
		}
		return(this);
	}

	public DialogWidget set_dialog_footer_widget(Widget widget) {
		dialog_footer_widget = widget;
		if(dialog_footer_layer != null) {
			dialog_footer_layer.remove_children();
			if(widget != null) {
				dialog_footer_layer.add(widget);
			}
		}
		return(this);
	}

	public virtual bool on_dialog_widget_event(Object o) {
		return(false);
	}

	public void initialize() {
		base.initialize();
		set_width_request_override(px(dialog_width));
		set_main_widget(BoxWidget.vertical().set_margin(px(dialog_content_margin))
			.set_spacing(px(dialog_box_spacing))
			.add_box(1, dialog_main_layer = LayerWidget.instance())
			.add_box(0, dialog_footer_layer = LayerWidget.instance())
		);
		if(dialog_main_widget != null) {
			dialog_main_layer.add(dialog_main_widget);
		}
		if(dialog_footer_widget != null) {
			dialog_footer_layer.add(dialog_footer_widget);
		}
	}

	public void cleanup() {
		base.cleanup();
		dialog_main_layer = null;
		dialog_footer_layer = null;
	}
}
