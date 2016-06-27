
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

public class ClickWidget : LayerWidget
{
	bool pressed = false;
	bool click_widget_disabled = false;
	bool hover = false;
	bool focus = false;
	property Object event = null;
	property Widget popup = null;
	property Widget context_popup;
	property bool popup_force_same_width = false;
	property Executable action;
	property bool focusable = true;

	public static ClickWidget for_event(Object event) {
		return(new ClickWidget().set_event(event));
	}

	public static ClickWidget instance() {
		return(new ClickWidget());
	}

	public ClickWidget() {
		set_cursor(Cursor.for_stock_cursor(Cursor.STOCK_POINT));
	}

	public bool is_focusable() {
		return(focusable);
	}

	public Widget get_hover_widget(int x, int y) {
		return(this);
	}

	public virtual void on_changed() {
	}

	public virtual void on_pressed_changed(bool v) {
		on_changed();
	}

	public virtual void on_disabled_changed(bool v) {
		if(click_widget_disabled) {
			set_focusable(false);
			hover = false;
			focus = false;
			pressed = false;
			set_cursor(null);
		}
		else {
			set_focusable(true);
			set_cursor(Cursor.for_stock_cursor(Cursor.STOCK_POINT));
		}
		on_changed();
	}

	public virtual void on_hover_changed(bool v) {
		on_changed();
	}

	public virtual void on_focus_changed(bool v) {
		on_changed();
	}

	public ClickWidget set_pressed(bool v) {
		if(pressed != v) {
			pressed = v;
			on_pressed_changed(v);
		}
		return(this);
	}

	public bool get_pressed() {
		return(pressed);
	}

	public ClickWidget set_click_widget_disabled(bool v) {
		if(click_widget_disabled != v) {
			click_widget_disabled = v;
			on_disabled_changed(v);
		}
		return(this);
	}

	public bool get_click_widget_disabled() {
		return(click_widget_disabled);
	}

	ClickWidget set_hover(bool v) {
		if(hover != v) {
			hover = v;
			on_hover_changed(v);
		}
		return(this);
	}

	public bool get_hover() {
		return(hover);
	}

	ClickWidget set_focus(bool v) {
		if(focus != v) {
			focus = v;
			on_focus_changed(v);
		}
		return(this);
	}

	public bool get_focus() {
		return(focus);
	}

	public void initialize() {
		base.initialize();
	}

	public void on_gain_focus() {
		base.on_gain_focus();
		set_focus(true);
	}

	public void on_lose_focus() {
		base.on_lose_focus();
		set_pressed(false);
		set_focus(false);
	}

	public void on_pointer_leave(int id) {
		base.on_pointer_leave(id);
		set_hover(false);
		set_pressed(false);
	}

	public void on_pointer_enter(int id) {
		base.on_pointer_enter(id);
		if(click_widget_disabled) {
			return;
		}
		set_hover(true);
	}

	public bool on_key_press(KeyEvent e) {
		if(e == null || click_widget_disabled) {
			return(false);
		}
		bool v = false;
		if(has_focus()) {
			var name = e.get_name();
			var str = e.get_str();
			if("enter".equals(name) || "return".equals(name) || " ".equals(str) || "space".equals(name)) {
				on_pointer_press(0, 0, 0, 0);
				v = true;
			}
		}
		return(v);
	}

	public bool on_key_release(KeyEvent e) {
		if(e == null || click_widget_disabled) {
			return(false);
		}
		bool v = false;
		if(has_focus()) {
			var name = e.get_name();
			var str = e.get_str();
			if("enter".equals(name) || "return".equals(name) || " ".equals(str) || "space".equals(name)) {
				on_pointer_release(0, 0, 0, 0);
				v = true;
			}
		}
		return(v);
	}

	public bool on_pointer_press(int x, int y, int button, int id) {
		if(click_widget_disabled || button != 0) {
			return(false);
		}
		set_pressed(true);
		return(true);
	}

	public bool on_pointer_release(int x, int y, int button, int id) {
		if(click_widget_disabled || button != 0) {
			return(false);
		}
		bool click = false;
		if(pressed == true) {
			click = true;
		}
		set_pressed(false);
		if(click) {
			on_pointer_click(x, y, button);
		}
		return(true);
	}

	public virtual void on_clicked() {
		if(show_popup(get_popup_widget())) {
			return;
		}
		if(action != null) {
			action.execute();
		}
		var eee = event;
		if(eee == null) {
		       eee = this;
		}
		if(eee is ActionItem) {
			if(((ActionItem)eee).execute()) {
				return;
			}
		}
		if(eee != null) {
			raise_event(eee);
		}
	}

	class PopupEventForwarder : EventReceiver
	{
		property Widget target;
		public void on_event(Object o) {
			if(target != null) {
				target.raise_event(o);
			}
		}
	}

	public virtual Widget get_popup_widget() {
		return(popup);
	}

	public virtual Widget get_context_popup_widget() {
		return(context_popup);
	}

	public bool show_popup(Widget popup) {
		if(popup != null) {
			popup.set_event_handler(new PopupEventForwarder().set_target(this));
			Popup.execute(get_engine(), PopupSettings.instance().set_widget(popup).set_modal(false).set_master(this)
				.set_focus(this).set_force_same_width(popup_force_same_width));
			return(true);
		}
		return(false);
	}

	public virtual bool on_pointer_click(int x, int y, int button) {
		if(click_widget_disabled || button != 0) {
			return(false);
		}
		on_clicked();
		return(true);
	}

	public bool on_context(int x, int y) {
		if(show_popup(get_context_popup_widget())) {
			return(true);
		}
		return(base.on_context(x, y));
	}

	public bool on_pointer_cancel(int x, int y, int button, int id) {
		if(button != 0) {
			return(false);
		}
		set_pressed(false);
		return(true);
	}
}
