
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

public class TextInputDialogWidget : DialogWidget
{
	class MainWidget : LayerWidget, EventReceiver
	{
		property String text;
		property String placeholder;
		property String value;
		property TextInputWidget widget;
		property Font text_font;
		property int input_type = 0;
		property int input_text_align = 0;
		BoxWidget box;

		public void initialize() {
			base.initialize();
			var vb = BoxWidget.vertical();
			vb.set_margin(px("2mm"));
			vb.set_spacing(px("3mm"));
			if(String.is_empty(text) == false) {
				vb.add(LabelWidget.for_string(text).set_wrap(true).set_font(text_font));
			}
			vb.add(widget = TextInputWidget.instance().set_text(value).set_placeholder(placeholder)
				.set_input_type(input_type).set_text_align(input_text_align));
			widget.set_width_request_override(px("50mm"));
			widget.set_listener(this);
			add(VScrollerWidget.instance().add_scroller(vb));
			this.box = vb;
		}

		public void cleanup() {
			base.cleanup();
			widget = null;
			box = null;
		}

		public void set_box_spacing(String ss) {
			if(box != null) {
				box.set_spacing(px(ss));
			}
		}

		public void set_box_margin(String ss) {
			if(box != null) {
				box.set_margin(px(ss));
			}
		}

		public Widget get_default_focus_widget() {
			return(widget);
		}

		public void on_event(Object o) {
			forward_event(o);
		}
	}

	property Object event;
	MainWidget widget;
	property String prompt;
	property String value;
	property String placeholder;
	property bool include_cancel = true;
	property Font text_font;
	property int input_type = 0;
	property int input_text_align = 1;

	public static TextInputDialogWidget instance(String title, String prompt, String value, String placeholder, Object event, EventReceiver listener) {
		var v = new TextInputDialogWidget();
		var rtitle = title;
		if(rtitle == null) {
			rtitle = "Input";
		}
		v.set_event(event);
		v.set_title(rtitle);
		v.set_prompt(prompt);
		v.set_value(value);
		v.set_placeholder(placeholder);
		v.set_listener(listener);
		return(v);
	}

	/*
	// FIXME: These are using the old shortness system.
	// Perhaps it is time for this class to retire.
	public TextInputDialogWidget() {
		set_short_threshold("30mm");
	}
	public void on_shortness_changed() {
		var ll = get_dialog_footer_layer();
		if(ll == null || widget == null) {
			return;
		}
		if(is_short()) {
			ll.set_enabled(false);
			widget.set_box_spacing("500um");
			widget.set_box_margin("0px");
		}
		else {
			ll.set_enabled(true);
			widget.set_box_spacing("3mm");
			widget.set_box_margin("2mm");
		}
	}
	*/

	public void initialize() {
		base.initialize();
		set_dialog_main_widget(AlignWidget.instance().add_align(0, 0,
			widget = new MainWidget().set_text(prompt).set_value(value).set_placeholder(placeholder)
				.set_text_font(text_font).set_input_type(input_type).set_input_text_align(input_text_align)));
		if(include_cancel) {
			set_dialog_footer_widget(ButtonSet.okcancel());
			set_cancel_event("cancel");
		}
		else {
			set_dialog_footer_widget(ButtonSet.ok());
		}
	}

	void on_default_ok_cancel(String o) {
		var ter = new TextInputResult();
		if("ok".equals(o)) {
			ter.set_status(true);
		}
		else {
			ter.set_status(false);
		}
		ter.set_event(event);
		if(widget != null) {
			var tiw = widget.get_widget();
			if(tiw != null) {
				ter.set_text(tiw.get_text());
			}
		}
		close_popup();
		var listener = get_listener();
		if(listener != null) {
			listener.on_event(ter);
		}
	}

	String get_current_text() {
		String text;
		if(widget != null) {
			var tiw = widget.get_widget();
			if(tiw != null) {
				text = tiw.get_text();
			}
		}
		return(text);
	}

	public virtual void on_ok(String text) {
		on_default_ok_cancel("ok");
	}

	public virtual void on_cancel() {
		on_default_ok_cancel("cancel");
	}

	public void on_event(Object o) {
		if(o != null && o is TextInputWidgetEvent) {
			if(((TextInputWidgetEvent)o).get_selected()) {
				on_ok(get_current_text());
			}
		}
		else if("ok".equals(o)) {
			on_ok(get_current_text());
		}
		else if("cancel".equals(o)) {
			on_cancel();
		}
		else {
			base.on_event(o);
		}
	}
}
