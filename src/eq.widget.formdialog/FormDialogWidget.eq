
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

public class FormDialogWidget : DialogWidget
{
	public static FormDialogWidget for_form(FormWidget form) {
		return(new FormDialogWidget().set_form(form));
	}

	property FormWidget form;
	property FormDialogListener form_dialog_listener;
	property bool enable_scrolling = true;

	public virtual Widget create_footer_widget() {
		return(ButtonSet.okcancel("ok", "cancel"));
	}

	public void initialize() {
		base.initialize();
		set_dialog_footer_widget(create_footer_widget());
		set_cancel_event("cancel");
		if(form == null) {
			form = FormWidget.instance();
		}
		initialize_form(form);
		Widget ww;
		if(enable_scrolling) {
			ww = VScrollerWidget.instance().add_scroller(form);
		}
		else {
			ww = form;
		}
		set_dialog_main_widget(LayerWidget.instance().set_margin(px("1mm")).add(ww));
	}

	public virtual void initialize_form(FormWidget form) {
	}

	public virtual bool on_ok(FormWidget form) {
		if(form_dialog_listener != null) {
			form_dialog_listener.on_form_ok(form);
		}
		return(true);
	}

	public virtual void on_cancel() {
	}

	public bool on_dialog_widget_event(Object o) {
		if("ok".equals(o)) {
			if(on_ok(form)) {
				close_popup();
			}
			return(true);
		}
		if("cancel".equals(o)) {
			close_popup();
			return(true);
		}
		return(false);
	}
}
