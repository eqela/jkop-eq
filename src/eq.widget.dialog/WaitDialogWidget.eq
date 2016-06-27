
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

public class WaitDialogWidget : WindowFrameWidget, EventReceiver
{
	public static WaitDialogWidget show(String title, String text, WidgetEngine engine, BackgroundTask op = null) {
		if(engine == null) {
			return(null);
		}
		var v = new WaitDialogWidget().set_text(text).set_op(op);
		v.set_title(title);
		Popup.widget(engine, v);
		return(v);
	}

	public static WaitDialogWidget hide(WaitDialogWidget widget) {
		if(widget != null) {
			Popup.close(widget);
		}
		return(null);
	}

	String text;
	LabelWidget text_widget;
	WaitAnimationWidget waw;
	BackgroundTask op;
	ButtonWidget abortbutton;
	property Font font;

	public WaitDialogWidget() {
		font = Theme.font("eq.widget.dialog.WaitDialogWidget.font", "bold 133% color=white shadow-color=black");
	}

	public WaitDialogWidget set_op(BackgroundTask task) {
		op = task;
		if(is_initialized()) {
			update_abort_button();
		}
		return(this);
	}

	public BackgroundTask get_op() {
		return(op);
	}

	public WaitDialogWidget set_text(String t) {
		this.text = t;
		if(text_widget != null) {
			text_widget.set_text(t);
		}
		return(this);
	}

	public void initialize() {
		base.initialize();
		set_size_request_override(px("85mm"), px("55mm"));
		var vb = BoxWidget.vertical();
		var lw = LayerWidget.instance();
		lw.add(CanvasWidget.for_color(Color.instance("#00000080")));
		vb.add(lw);
		var midbox = LayerWidget.instance();
		midbox.set_margin(px("2mm"));
		midbox.add(waw = new WaitAnimationWidget() as WaitAnimationWidget);
		midbox.add(text_widget = LabelWidget.for_string(text).set_wrap(true).set_font(font));
		vb.add_box(1, midbox);
		vb.add(abortbutton = (ButtonWidget)ButtonWidget.for_string("Cancel").set_color(ButtonSet.nocolor()).set_event("abort"));
		set_main_widget(vb);
		update_abort_button();
	}

	public void cleanup() {
		base.cleanup();
		text_widget = null;
		abortbutton = null;
		op = null;
	}

	void update_abort_button() {
		if(abortbutton == null) {
			return;
		}
		if(op == null) {
			abortbutton.set_enabled(false);
			set_closable(false);
		}
		else {
			abortbutton.set_enabled(true);
			set_closable(true);
		}
	}

	public bool on_key_press(KeyEvent e) {
		if("escape".equals(e.get_name()) || "back".equals(e.get_name())) {
			raise_event("abort");
			return(true);
		}
		return(base.on_key_press(e));
	}

	public void on_event(Object o) {
		if("abort".equals(o) || o is WindowFrameCloseEvent) {
			if(op == null) {
				set_title("Abort failed");
				set_text("Aborting operation, but there is no operation!");
			}
			else if(op.abort() == false) {
				set_title("Abort failed");
				set_text("Failed to abort the operation");
			}
			else {
				set_title("Aborting ..");
				set_text("Waiting for the operation to end..");
			}
		}
	}
}
