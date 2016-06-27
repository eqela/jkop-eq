
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

public class ComboButtonWidget : ButtonWidget, EventReceiver
{
	public static ComboButtonWidget instance() {
		return(new ComboButtonWidget());
	}

	property bool raise_selected_event = true;
	property int icon_align = 1;
	property String default_text;
	property Image default_icon;
	ActionItem selected;

	public ComboButtonWidget() {
		default_text = "(Choose Value)";
		set_popup(MenuWidget.instance().set_action_item_is_event(true));
		set_right_icon(IconCache.get("arrowdown"));
		set_symmetric_icons(false);
	}

	public void initialize() {
		base.initialize();
		update();
	}

	public ComboButtonWidget set_header_text(String text) {
		var mw = get_popup() as MenuWidget;
		if(mw != null) {
			mw.set_header_text(text);
		}
		return(this);
	}

	private void update() {
		var icon = default_icon;
		var text = default_text;
		if(selected != null) {
			icon = selected.get_icon();
			text = selected.get_text();
		}
		if(get_icon_align() == ButtonWidget.LEFT) {
			set_left_icon(icon);
			set_icon(null);
		}
		else {
			set_icon(icon);
			set_left_icon(null);
		}
		set_text(text);
	}

	public ComboButtonWidget set_items(Collection items) {
		clear();
		foreach(var item in items) {
			add_item(item);
		}
		return(this);
	}

	public Collection get_items() {
		var menu = get_popup() as MenuWidget;
		if(menu == null) {
			return(null);
		}
		return(menu.get_items());
	}

	public ComboButtonWidget select_item_by_string(String text) {
		var menu = get_popup() as MenuWidget;
		if(menu == null || text == null) {
			return(this);
		}
		var its = menu.get_items();
		if(its == null) {
			return(this);
		}
		foreach(ActionItem it in its) {
			if(it != null && text.equals(it.get_text())) {
				this.selected = it;
				update();
				break;
			}
		}
		return(this);
	}

	public ComboButtonWidget select_item(ActionItem item) {
		this.selected = item;
		update();
		return(this);
	}

	public ComboButtonWidget select_first_item() {
		var menu = get_popup() as MenuWidget;
		if(menu == null) {
			return(this);
		}
		var its = menu.get_items();
		if(its == null) {
			return(this);
		}
		var it = its.get(0) as ActionItem;
		if(it == null) {
			return(this);
		}
		if(it != null) {
			this.selected = it;
			update();
		}
		return(this);
	}

	public ComboButtonWidget add_item(Object oitem, bool selected = false) {
		var item = ActionItem.as_action_item(oitem);
		if(item == null) {
			return(this);
		}
		var menu = get_popup() as MenuWidget;
		if(menu == null) {
			return(this);
		}
		menu.add_action_item(item);
		if(selected || item.get_selected()) {
			this.selected = item;
			update();
		}
		return(this);
	}

	public ComboButtonWidget add_string(String item, bool selected = false) {
		return(add_item(item, selected));
	}

	public ComboButtonWidget add_separator() {
		var menu = get_popup() as MenuWidget;
		if(menu == null) {
			return(this);
		}
		menu.add_separator();
		return(this);
	}

	public void clear() {
		var menu = get_popup() as MenuWidget;
		if(menu != null) {
			menu.clear_entries();
		}
		selected = null;
		update();
	}

	public void on_clicked() {
		show_popup(get_popup_widget());
	}

	public override bool on_key_press(KeyEvent e) {
		if(base.on_key_press(e)) {
			return(true);
		}
		if(has_focus() && e != null) {
			if("down".equals(e.get_name())) {
				show_popup(get_popup_widget());
				return(true);
			}
		}
		return(false);
	}

	public virtual void on_selected(ActionItem i) {
		if(raise_selected_event) {
			var e = i.get_event();
			if(e != null) {
				raise_event(e, false);
			}
			else {
				raise_event(i, false);
			}
		}
	}

	public void on_event(Object o) {
		var ai = o as ActionItem;
		if(ai.get_action() == null) {
			selected = ai;
		}
		update();
		on_selected(selected);
	}

	public ActionItem get_selected() {
		return(selected);
	}

	public String get_selected_text() {
		var ai = get_selected();
		if(ai != null) {
			return(ai.get_text());
		}
		return(null);
	}
}
