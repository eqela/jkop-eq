
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

public class HyperLinkWidget : LayerWidget
{
	public static HyperLinkWidget instance() {
		return(new HyperLinkWidget());
	}

	public static HyperLinkWidget for_url(String url) {
		return(new HyperLinkWidget().set_url(url));
	}

	public static HyperLinkWidget for_event(Object event) {
		return(new HyperLinkWidget().set_event(event));
	}

	property Object event;
	property String url;
	property Color focus_color;
	property Font font_normal;
	property Font font_pressed;

	public HyperLinkWidget() {
		set_cursor(Cursor.for_stock_cursor(Cursor.STOCK_POINT));
		font_normal = Theme.font("eq.widget.common.HyperLinkWidget.font_normal", "color=#3030FF");
		font_pressed = Theme.font("eq.widget.common.HyperLinkWidget.font_pressed", "color=#3030FF");
	}

	public bool is_focusable() {
		return(true);
	}

	public void initialize() {
		base.initialize();
		if(is_margin_set() == false) {
			set_margin(px("1mm"));
		}
	}

	public HyperLinkWidget set_text(String text) {
		return(add(LabelWidget.for_string(text).set_font(Theme.font().modify("underline"))) as HyperLinkWidget);
	}

	bool _is_pressed = false;

	private void on_update_pressed() {
		foreach(Widget w in iterate_children()) {
			if(w is LabelWidget) {
				if(_is_pressed) {
					((LabelWidget)w).set_font(font_pressed);
				}
				else {
					((LabelWidget)w).set_font(font_normal);
				}
			}
		}
	}

	private void is_pressed(bool v) {
		if(v != _is_pressed) {
			_is_pressed = v;
			on_update_pressed();
		}
	}

	public void on_gain_focus() {
		base.on_gain_focus();
		update_view();
	}

	public void on_lose_focus() {
		base.on_lose_focus();
		is_pressed(false);
		update_view();
	}

	public override Widget get_hover_widget(int x, int y) {
		return(this);
	}

	public void on_pointer_leave(int id) {
		base.on_pointer_leave(id);
		is_pressed(false);
	}

	public bool on_key_press(KeyEvent e) {
		if(e == null) {
			return(false);
		}
		var name = e.get_name();
		var str = e.get_str();
		bool v = false;
		if(has_focus()) {
			if("enter".equals(name) || "return".equals(name)) {
				on_pointer_press(0, 0, 0, 0);
				v = true;
			}
			if(" ".equals(str) || "space".equals(str)) {
				on_pointer_press(0, 0, 0, 0);
				v = true;
			}
		}
		return(v);
	}

	public bool on_key_release(KeyEvent e) {
		if(e == null) {
			return(false);
		}
		var name = e.get_name();
		var str = e.get_str();
		bool v = false;
		if(has_focus()) {
			if("enter".equals(name) || "return".equals(name)) {
				on_pointer_release(0, 0, 0, 0);
				v = true;
			}
			if(" ".equals(str) || "space".equals(name)) {
				on_pointer_release(0, 0, 0, 0);
				v = true;
			}
		}
		return(v);
	}

	public bool on_pointer_press(int x, int y, int button, int id) {
		is_pressed(true);
		return(true);
	}

	public bool on_pointer_release(int x, int y, int button, int id) {
		bool click = false;
		if(_is_pressed == true) {
			click = true;
		}
		is_pressed(false);
		if(click) {
			on_pointer_click(x, y, button);
		}
		return(true);
	}

	public virtual bool on_pointer_click(int x, int y, int button) {
		if(url != null) {
			URLHandler.open(url);
		}
		else {
			var eee = event;
			if(eee == null) {
			       eee = this;
			}
			raise_event(eee);
		}
		return(true);
	}

	public bool on_pointer_cancel(int x, int y, int button, int id) {
		is_pressed(false);
		return(true);
	}

	public void on_child_added(Widget child) {
		base.on_child_added(child);
		on_update_pressed();
	}

	public Collection render() {
		if(has_focus()) {
			var fc = focus_color;
			if(fc == null) {
				fc = Theme.get_highlight_color();
			}
			return(LinkedList.create().add(new StrokeOperation()
				.set_shape(RectangleShape.create(0, 0, get_width(), get_height()))
				.set_color(focus_color).set_width(px("500um"))
			));
		}
		return(null);
	}
}
