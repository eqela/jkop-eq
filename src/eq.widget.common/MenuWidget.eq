
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

public class MenuWidget : LayerWidget, EventReceiver
{
	class MenuSelectedEvent
	{
		property ActionItem item;
	}

	class MenuItemWidget : LayerWidget
	{
		property ActionItem item;
		property CanvasWidget bg;
		LabelWidget label;
		bool pressed = false;
		bool hover = false;
		bool kb_hover = false;
		property Font normal_font;
		property Font highlight_font;

		public void initialize() {
			base.initialize();
			var mm = px(Theme.get_icon_size());
			var icon = item.get_icon();
			bg = CanvasWidget.instance();
			add(bg);
			var hb = HBoxWidget.instance();
			hb.set_spacing(px("1mm"));
			hb.set_margin(px("500um"));
			ImageWidget iconwidget;
			if(icon != null) {
				hb.add_hbox(0, iconwidget = ImageWidget.for_image(item.get_icon()).set_image_size(mm, mm));
			}
			else {
				hb.add_hbox(0, new Widget().set_size_request(mm, mm));
			}
			hb.add_hbox(1, label = LabelWidget.for_string(item.get_text()).set_text_align(LabelWidget.LEFT));
			if(item.get_disabled()) {
				if(label != null) {
					label.set_alpha(0.5);
				}
				if(iconwidget != null) {
					iconwidget.set_alpha(0.5);
				}
			}
			hb.add_hbox(0, new Widget().set_size_request(mm, mm));
			add(hb);
			update();
		}

		public Widget get_hover_widget(int x, int y) {
			return(this);
		}

		public void cleanup() {
			base.cleanup();
			bg = null;
			label = null;
		}

		void update() {
			if(item.get_disabled()) {
				return;
			}
			if(bg == null || label == null) {
				return;
			}
			bool highlight = false;
			if(kb_hover) {
				bg.set_outline_color(Theme.get_highlight_color());
			}
			else {
				bg.set_outline_color(null);
			}
			if(pressed) {
				bg.set_color_gradient(Theme.get_pressed_color());
				highlight = true;
			}
			else if(kb_hover) {
				bg.set_color_gradient(Theme.get_hover_color());
				highlight = true;
			}
			else if(hover) {
				bg.set_color_gradient(Theme.get_hover_color());
				highlight = true;
			}
			else {
				bg.set_color_gradient(null);
			}
			if(highlight) {
				label.set_font(highlight_font);
			}
			else {
				label.set_font(normal_font);
			}
		}

		public void on_kb_enter() {
			kb_hover = true;
			update();
		}

		public void on_kb_leave() {
			kb_hover = false;
			update();
		}

		public void on_kb_press() {
			pressed = true;
			update();
		}

		public void on_kb_release() {
			if(pressed) {
				pressed = false;
				update();
				on_click();
			}
		}

		public void on_pointer_enter(int id) {
			hover = true;
			update();
		}

		public void on_pointer_leave(int id) {
			hover = false;
			pressed = false;
			update();
		}

		public bool on_pointer_press(int x, int y, int button, int id) {
			pressed = true;
			update();
			return(true);
		}

		public bool on_pointer_release(int x, int y, int button, int id) {
			if(pressed) {
				pressed = false;
				update();
				on_click();
			}
			return(true);
		}

		public void on_click() {
			if(item.get_disabled()) {
				return;
			}
			raise_event(new MenuSelectedEvent().set_item(item));
		}
	}

	Collection items;
	VBoxWidget itemcontainer;
	property String header_text;
	property String shadow_thickness;
	property Color header_background_color;
	property Font header_font;
	property Font normal_font;
	property Font highlight_font;
	property String minimum_width;
	property bool action_item_is_event = false;

	public static MenuWidget instance() {
		return(new MenuWidget());
	}

	public static MenuWidget for_header_text(String text) {
		return(new MenuWidget().set_header_text(text));
	}

	public static MenuWidget for_menu(Menu menu) {
		if(menu == null) {
			return(null);
		}
		return(MenuWidget.for_action_items(menu.get_items()));
	}

	public static MenuWidget for_action_items(Collection items) {
		var v = new MenuWidget();
		foreach(ActionItem item in items) {
			v.add_action_item(item);
		}
		return(v);
	}

	public MenuWidget() {
		items = Array.create();
		minimum_width = "50mm";
		shadow_thickness = "1mm";
		header_background_color = Theme.get_base_color();
		header_font = Theme.font("eq.widget.common.MenuWidget.header_font", "bold color=white shadow-color=black outline-color=none");
		normal_font = Theme.font("eq.widget.common.MenuWidget.normal_font", "color=black shadow-color=white outline-color=none");
		highlight_font = Theme.font("eq.widget.common.MenuWidget.highlight_font",
			"color=white shadow-color=none outline-color=%s".printf().add(Theme.get_highlight_color()).to_string());
	}

	public bool is_focusable() {
		return(true);
	}

	public void initialize() {
		base.initialize();
		if(minimum_width != null) {
			set_minimum_width_request(px(minimum_width));
		}
		var cw = CanvasWidget.for_colors(Color.instance("#EEEEEE"), Color.instance("#BBBBBB")).set_rounded(false);
		set_draw_color(Color.instance("black"));
		var l2 = LayerWidget.instance();
		var ss = new VScrollerWidget();
		var vb = new VBoxWidget();
		ss.add_scroller(vb);
		if(String.is_empty(header_text) == false) {
			vb.add(LayerWidget.instance()
				.add(CanvasWidget.for_color(header_background_color))
				.add(LayerWidget.instance().set_margin(px("1250um"))
					.add(LabelWidget.for_string(header_text).set_text_align(LabelWidget.LEFT).set_font(header_font))
				)
			);
		}
		vb.add(new Widget().set_height_request_override(px("1mm")));
		foreach(var o in items) {
			if(o is ActionItem) {
				vb.add(new MenuItemWidget().set_item((ActionItem)o).set_normal_font(normal_font).set_highlight_font(highlight_font));
			}
			else if("__separator__".equals(o)) {
				vb.add(LayerWidget.instance().set_margin(px("1mm")).add(HSeparatorWidget.instance()));
			}
		}
		vb.add(new Widget().set_height_request_override(px("1mm")));
		itemcontainer = vb;
		l2.add(ss);
		if(String.is_empty(shadow_thickness) == false) {
			var ll = LayerWidget.instance();
			ll.add(cw);
			ll.add(l2);
			add(ShadowContainerWidget.for_widget(ll).set_shadow_thickness(shadow_thickness));
		}
		else {
			add(cw);
			add(l2);
		}
		kb_selected = -1;
	}

	public void cleanup() {
		base.cleanup();
		itemcontainer = null;
		kb_selected = -1;
	}

	public Collection get_items() {
		return(items);
	}

	public int count_items() {
		if(items == null) {
			return(0);
		}
		return(items.count());
	}

	public MenuWidget clear_entries() {
		items.clear();
		return(this);
	}

	public MenuWidget add_action_item(ActionItem ai) {
		if(ai == null) {
			return(this);
		}
		items.append(ai);
		return(this);
	}

	public MenuWidget add_entry(Image icon, String text, String desc, Object event, Executable action = null) {
		items.append(new ActionItem().set_icon(icon).set_text(text).set_desc(desc).set_event(event)
			.set_action(action));
		return(this);
	}

	public MenuWidget add_separator() {
		items.append("__separator__");
		return(this);
	}

	int kb_selected = -1;

	int find_previous_item(int c) {
		if(itemcontainer == null) {
			return(-1);
		}
		int n;
		if(c < 0) {
			n = itemcontainer.count();
		}
		else {
			n = c - 1;
		}
		while(n >= 0) {
			if(itemcontainer.get_child(n) as MenuItemWidget != null) {
				return(n);
			}
			n --;
		}
		return(-1);
	}

	int find_next_item(int c) {
		if(itemcontainer == null) {
			return(-1);
		}
		var n = c + 1;
		while(true) {
			var cc = itemcontainer.get_child(n);
			if(cc == null) {
				break;
			}
			if(cc is MenuItemWidget) {
				return(n);
			}
			n++;
		}
		return(-1);
	}

	void move_kb_selection(int n) {
		if(itemcontainer == null) {
			return;
		}
		if(kb_selected >= 0) {
			var ww = itemcontainer.get_child(kb_selected) as MenuItemWidget;
			if(ww != null) {
				ww.on_kb_leave();
			}
		}
		if(n < 0) {
			var pi = find_previous_item(kb_selected);
			if(pi >= 0) {
				kb_selected = pi;
			}
		}
		if(n > 0) {
			var ni = find_next_item(kb_selected);
			if(ni >= 0) {
				kb_selected = ni;
			}
		}
		if(kb_selected >= 0) {
			var ww = itemcontainer.get_child(kb_selected) as MenuItemWidget;
			if(ww != null) {
				ww.scroll_to_widget();
				ww.on_kb_enter();
			}
		}
	}

	public bool on_key_press(KeyEvent e) {
		if(e == null) {
		}
		else if("escape".equals(e.get_name()) || "menu".equals(e.get_name())) {
			close();
			return(true);
		}
		else if("up".equals(e.get_name())) {
			move_kb_selection(-1);
			return(true);
		}
		else if("down".equals(e.get_name())) {
			move_kb_selection(1);
			return(true);
		}
		else if("enter".equals(e.get_name()) || "return".equals(e.get_name()) || "space".equals(e.get_name())) {
			var ww = itemcontainer.get_child(kb_selected) as MenuItemWidget;
			if(ww != null) {
				ww.on_kb_press();
			}
			return(true);
		}
		return(base.on_key_press(e));
	}

	public bool on_key_release(KeyEvent e) {
		if("enter".equals(e.get_name()) || "return".equals(e.get_name()) || "space".equals(e.get_name())) {
			var ww = itemcontainer.get_child(kb_selected) as MenuItemWidget;
			if(ww != null) {
				ww.on_kb_release();
			}
			return(true);
		}
		return(base.on_key_release(e));
	}

	void close() {
		if(Popup.is_popup(this)) {
			Popup.close(this);
		}
	}

	public virtual void on_action_item_selected(ActionItem item) {
		if(item == null) {
			return;
		}
		var action = item.get_action();
		if(action != null) {
			action.execute();
		}
		if(action_item_is_event) {
			raise_event(item);
		}
		else {
			var ee = item.get_event();
			if(ee != null) {
				raise_event(ee);
			}
		}
	}

	public void on_event(Object o) {
		if(o is MenuSelectedEvent) {
			var tt = this;
			close();
			var item = ((MenuSelectedEvent)o).get_item();
			if(item != null) {
				on_action_item_selected(item);
			}
			return;
		}
	}

	public void popup(Widget master, bool force_same_width = false) {
		if(master == null) {
			return;
		}
		var engine = master.get_engine();
		if(engine == null) {
			return;
		}
		Popup.execute(engine, PopupSettings.instance().set_widget(this).set_modal(false).set_master(master)
			.set_force_same_width(force_same_width));
	}
}
