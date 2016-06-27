
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

public class WizardWidget : LayerWidget, EventReceiver
{
	public static WizardWidget for_first_page(WizardPageWidget wpw) {
		return(new WizardWidget().set_first_page(wpw));
	}

	StackChangerWidget changer;
	property Color background_color;
	property Color foreground_color;
	property Color title_background_color;
	property Color title_foreground_color;
	property WizardPageWidget first_page;
	property bool landscape = false;
	ButtonWidget button_back;
	ButtonWidget button_next;
	ButtonWidget button_cancel;
	ButtonWidget button_done;
	LabelWidget title;

	WizardWidget() {
		background_color = Color.instance("#BBBBBB");
		foreground_color = Color.instance("black");
		title_background_color = Color.instance("black");
		title_foreground_color = Color.instance("white");
	}

	WizardPageWidget get_current_page() {
		if(changer == null) {
			return(null);
		}
		return(changer.get_active_widget() as WizardPageWidget);
	}

	public bool on_key_press(KeyEvent e) {
		if(base.on_key_press(e)) {
			return(true);
		}
		var nn = e.get_name();
		if("escape".equals(nn) || "back".equals(nn)) {
			var pp = get_current_page();
			if(pp == first_page) {
				on_cancel();
			}
			else {
				on_back();
			}
			return(true);
		}
		return(false);
	}

	void on_page_changed() {
		var top = get_current_page();
		if(top == first_page) {
			button_back.set_enabled(false);
			button_cancel.set_enabled(true);
		}
		else {
			button_back.set_enabled(true);
			button_cancel.set_enabled(false);
		}
		if(top == null || top.is_last()) {
			button_next.set_enabled(false);
			button_done.set_enabled(true);
		}
		else {
			button_next.set_enabled(true);
			button_done.set_enabled(false);
		}
		if(title != null) {
			String tt;
			if(top != null) {
				tt = top.get_title();
			}
			title.set_text(tt);
		}
	}

	public void initialize() {
		base.initialize();
		if(landscape) {
			set_size_request_override(px("90mm"), px("70mm"));
		}
		else {
			set_size_request_override(px("70mm"), px("90mm"));
		}
		set_draw_color(foreground_color);
		if(background_color != null) {
			add(CanvasWidget.for_color(background_color));
		}
		var box = BoxWidget.vertical();
		var ll = LayerWidget.instance();
		ll.add(CanvasWidget.for_color(title_background_color));
		ll.set_draw_color(title_foreground_color);
		ll.add(title = LabelWidget.instance());
		title.set_font(Theme.font().modify("bold 4mm"));
		ll.set_height_request_override(px("8mm"));
		box.add(ll);
		box.add_box(1, LayerWidget.instance().set_margin(px("1mm")).add(changer = new StackChangerWidget()));
		box.add_box(0, HSeparatorWidget.instance());
		var buttons = BoxWidget.horizontal();
		buttons.set_margin(px("1mm"));
		buttons.set_spacing(px("1mm"));
		buttons.add_box(1, LayerWidget.instance()
			.add(button_cancel = (ButtonWidget)ButtonWidget.for_string("Cancel").set_event("cancel"))
			.add(button_back = (ButtonWidget)ButtonWidget.for_string("< Back").set_event("back"))
		);
		buttons.add_box(1, LayerWidget.instance()
			.add(button_done = (ButtonWidget)ButtonWidget.for_string("Done").set_event("done"))
			.add(button_next = (ButtonWidget)ButtonWidget.for_string("Next >").set_event("next"))
		);
		box.add(buttons);
		add(box);
		if(first_page != null) {
			changer.push(first_page);
		}
		on_page_changed();
	}

	public void cleanup() {
		base.cleanup();
		button_back = null;
		button_next = null;
		title = null;
	}

	void on_cancel() {
		close_frame();
	}

	void on_back() {
		if(changer != null) {
			changer.pop(ChangerWidget.EFFECT_SCROLL_RIGHT);
			on_page_changed();
		}
	}

	public void on_event(Object o) {
		if(changer == null) {
			return;
		}
		if("cancel".equals(o)) {
			on_cancel();
			return;
		}
		if("back".equals(o)) {
			on_back();
			return;
		}
		if("next".equals(o)) {
			var cp = get_current_page();
			if(cp == null) {
				return;
			}
			var next = cp.get_next_page();
			if(next == null) {
				return;
			}
			changer.push(next, ChangerWidget.EFFECT_SCROLL_LEFT);
			on_page_changed();
		}
		if("done".equals(o)) {
			var cp = get_current_page();
			if(cp != null) {
				cp.on_done();
			}
			return;
		}
	}
}
