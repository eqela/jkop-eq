
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

public class ListSelectorWidget : LayerWidget
{
	public static int SELECT_NONE = 0;
	public static int SELECT_SINGLE = 1;
	public static int SELECT_MULTI = 2;

	public static ListSelectorWidget find_list_widget(Widget w) {
		var ww = w;
		while(ww != null) {
			if(ww is ListSelectorWidget) {
				return((ListSelectorWidget)ww);
			}
			ww = ww.get_parent() as Widget;
		}
		return(null);
	}

	public static ListSelectorWidget instance() {
		return(new ListSelectorWidget());
	}

	public static ListSelectorWidget for_items(Collection items) {
		return(new ListSelectorWidget().set_items(items));
	}

	property int select_mode = 0;
	property bool show_desc = true;
	property bool show_icon = true;
	property bool raise_events = true;
	property Font text_font;
	property Font title_font;
	property Font desc_font;
	property bool rounded_items = false;
	property bool adapt_to_content = true;
	ListContainerWidget container;
	Array items;
	Array actual_items;
	ListItemWidget selected_item;
	ListItemWidget last_clicked_item;
	int kb_selected = -1;
	property bool filterable = false;
	ListSelectorSearchBarWidget searchbar;
	property String icon_size;
	property String icon_margin;
	property Color kb_hover_outline_color;
	property Color hover_background_color;
	property Color hover_outline_color;
	property Color pressed_color;
	property Color focus_color;
	property Widget search_bar_widget;
	property int selection_limit = -1;
	property int selected_count = 0;

	public ListSelectorWidget() {
		container = new ListContainerWidget();
		text_font = Theme.font("eq.widget.selector.ListSelectorWidget.text_font");
		title_font = Theme.font("eq.widget.selector.ListSelectorWidget.title_font", "bold");
		desc_font = Theme.font("eq.widget.selector.ListSelectorWidget.desc_font");
		kb_hover_outline_color = Theme.get_highlight_color();
		hover_background_color = Color.instance("#80808080");
		hover_outline_color = null;
		pressed_color = Theme.get_pressed_color();
		focus_color = Theme.get_selected_color();
	}

	public bool is_focusable() {
		return(true);
	}

	public ListSelectorSearchBarWidget get_searchbar() {
		return(searchbar);
	}

	public ListSelectorWidget set_row_count_request(int rows) {
		container.set_row_count_request(rows);
		return(this);
	}

	public ActionItem get_selected_action_item() {
		if(selected_item == null) {
			return(null);
		}
		return(selected_item.get_item());
	}

	public Collection get_selected_action_items() {
		if(items == null) {
			return(null);
		}
		var v = LinkedList.create();
		foreach(ActionItem ai in items) {
			if(ai.get_selected()) {
				v.add(ai);
			}
		}
		return(v);
	}

	public ListSelectorWidget set_items(Collection ii) {
		kb_selected = -1;
		container.set_kb_selected(-1);
		items = Array.create();
		var has_icons = false;
		var has_descs = false;
		foreach(var o in ii) {
			var ai = ActionItem.as_action_item(o);
			if(ai != null) {
				items.add(ai);
				if(ai.get_icon() != null) {
					has_icons = true;
				}
				if(ai.get_desc() != null) {
					has_descs = true;
				}
			}
		}
		if(adapt_to_content) {
			set_show_desc(has_descs);
			set_show_icon(has_icons);
		}
		actual_items = items;
		if(searchbar != null) {
			searchbar.clear();
		}
		container.reset_item_widget_height();
		container.update_size_request();
		if(is_initialized()) {
			container.reset();
			container.update_children();
		}
		return(this);
	}

	bool action_item_matches(ActionItem ai, String str) {
		if(String.is_empty(str)) {
			return(true);
		}
		if(ai == null) {
			return(false);
		}
		var text = ai.get_text();
		if(String.is_empty(text) == false) {
			var tl = text.lowercase();
			if(tl != null && tl.str(str) >= 0) {
				return(true);
			}
		}
		var desc = ai.get_desc();
		if(String.is_empty(desc) == false) {
			var dl = desc.lowercase();
			if(dl != null && dl.str(str) >= 0) {
				return(true);
			}
		}
		return(false);
	}

	public void filter(String str) {
		if(String.is_empty(str)) {
			actual_items = items;
		}
		else {
			actual_items = Array.create();
			foreach(ActionItem ai in items) {
				if(action_item_matches(ai, str.lowercase())) {
					actual_items.append(ai);
				}
			}
		}
		kb_selected = -1;
		container.set_kb_selected(-1);
		container.update_size_request();
		if(is_initialized()) {
			container.reset();
			container.update_children();
		}
	}

	public virtual int get_item_count() {
		if(actual_items == null) {
			return(0);
		}
		return(actual_items.count());
	}

	public virtual ActionItem get_item(int n) {
		if(actual_items == null) {
			return(null);
		}
		return(actual_items.get(n) as ActionItem);
	}

	public virtual ListItemWidget create_widget_for_item() {
		return(new ListItemWidget());
	}

	public virtual ListItemWidget get_widget_for_item(ActionItem item) {
		var v = create_widget_for_item();
		if(v == null) {
			return(v);
		}
		v.set_icon_size(icon_size).set_icon_margin(icon_margin)
			.set_item(item).set_show_desc(show_desc).set_show_icon(show_icon)
			.set_text_font(text_font).set_title_font(title_font).set_desc_font(desc_font).set_rounded(rounded_items);
		v.set_kb_hover_outline_color(kb_hover_outline_color);
		v.set_hover_background_color(hover_background_color);
		v.set_hover_outline_color(hover_outline_color);
		v.set_pressed_color(pressed_color);
		v.set_focus_color(focus_color);
		if(select_mode == SELECT_SINGLE) {
			if(item.get_selected()) {
				if(selected_item != null) {
					selected_item.set_selected(false);
				}
				v.set_selected(true);
				selected_item = v;
			}
		}
		return(v);
	}

	public void initialize() {
		base.initialize();
		var scroller = new VScrollerWidget();
		scroller.set_enable_keyboard_control(false);
		scroller.add_scroller(container);
		if(filterable) {
			var b = BoxWidget.vertical().set_spacing(px("500um"));
			b.add_box(1, scroller);
			b.add_box(0, searchbar = new ListSelectorSearchBarWidget().set_list(this).set_widget(search_bar_widget));
			add(b);
		}
		else {
			add(scroller);
		}
	}

	public void cleanup() {
		base.cleanup();
		last_clicked_item = null;
		searchbar = null;
	}

	public void popup(Widget widget) {
		if(widget == null) {
			return;
		}
		Widget master = last_clicked_item;
		if(master == null) {
			master = this;
		}
		Popup.execute(get_engine(), PopupSettings.instance()
			.set_widget(widget).set_modal(false).set_master(master)
			.set_force_same_width(false));
	}

	public virtual void on_action_item_clicked(ActionItem ai) {
		if(ai == null) {
			return;
		}
		var action = ai.get_action();
		if(action != null) {
			action.execute();
			return;
		}
		if(raise_events) {
			var ee = ai.get_event();
			if(ee == null) {
				ee = ai;
			}
			raise_event(ee);
		}
	}

	public virtual void on_action_item_context(ActionItem ai) {
		var menu = ai.get_menu();
		if(menu != null) {
			var mw = MenuWidget.for_menu(menu);
			mw.set_event_handler(this);
			popup(mw);
		}
	}

	public virtual void on_item_clicked(ListItemWidget iw) {
		if(selected_count >= selection_limit && (selection_limit > -1) && iw.get_selected() == false) {
			return;
		}
		last_clicked_item = iw;
		if(iw == null) {
			return;
		}
		if(select_mode == SELECT_NONE) {
		}
		else if(select_mode == SELECT_SINGLE) {
			if(selected_item != iw && selected_item != null) {
				selected_item.set_selected(false);
				selected_item = null;
			}
			iw.set_selected(!iw.get_selected());
			if(iw.get_selected()) {
				selected_item = iw;
				selected_count = 1;
			}
			else if(selected_item == iw) {
				selected_item = null;
				selected_count = 0;
			}
		}
		else if(select_mode == SELECT_MULTI) {
			iw.set_selected(!iw.get_selected());
			if(iw.get_selected()) {
				selected_count++;
			}
			else {
				selected_count--;
			}
		}
		on_action_item_clicked(iw.get_item());
	}

	public virtual void on_item_context(ListItemWidget iw) {
		last_clicked_item = iw;
		if(iw == null) {
			return;
		}
		on_action_item_context(iw.get_item());
	}

	public void on_gain_focus() {
		base.on_gain_focus();
		if(kb_selected < 0) {
			kb_selected = 0;
		}
		container.set_kb_selected(kb_selected);
	}

	public void on_lose_focus() {
		base.on_lose_focus();
		container.set_kb_selected(-1);
	}

	void move_keyboard_selection(int n) {
		if(n < 0) {
			if(kb_selected > 0) {
				kb_selected--;
			}
		}
		else if(n > 0) {
			if(kb_selected < get_item_count() - 1) {
				kb_selected++;
			}
		}
		container.set_kb_selected(kb_selected);
	}

	public bool on_key_press(KeyEvent e) {
		if("up".equals(e.get_name())) {
			grab_focus();
			move_keyboard_selection(-1);
			return(true);
		}
		if("down".equals(e.get_name())) {
			grab_focus();
			move_keyboard_selection(1);
			return(true);
		}
		if("enter".equals(e.get_name()) || "return".equals(e.get_name()) || (filterable == false && "space".equals(e.get_name()))) {
			if(has_focus()) {
				var kbw = container.get_kb_selected_widget();
				if(kbw != null) {
					kbw.set_pressed(true);
				}
			}
			return(true);
		}
		if(searchbar != null) {
			if(String.is_empty(e.get_str()) == false && is_printable(e.get_str())) {
				searchbar.grab_focus();
				searchbar.on_key_press(e);
				return(true);
			}
		}
		return(base.on_key_press(e));
	}

	bool is_printable(String ss) {
		if(ss == null) {
			return(false);
		}
		var it = ss.iterate();
		while(true) {
			var c = it.next_char();
			if(c < 1) {
				break;
			}
			if(c < 33 || c > 126) {
				return(false);
			}
		}
		return(true);
	}

	public bool on_key_release(KeyEvent e) {
		if("enter".equals(e.get_name()) || "return".equals(e.get_name()) || (filterable == false && "space".equals(e.get_name()))) {
			if(has_focus()) {
				var kbw = container.get_kb_selected_widget();
				if(kbw != null && kbw.get_pressed()) {
					kbw.set_pressed(false);
					on_item_clicked(kbw);
				}
			}
			return(true);
		}
		return(base.on_key_release(e));
	}
}
