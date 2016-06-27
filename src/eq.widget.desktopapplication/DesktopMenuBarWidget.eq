
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

public class DesktopMenuBarWidget : LayerWidget, MenuBarControl
{
	class MenuBarButtonWidget : FramelessButtonWidget
	{
		class CustomMenuWidget : MenuWidget
		{
			property EventReceiver listener;

			public static CustomMenuWidget instance(EventReceiver listener) {
				return(new CustomMenuWidget().set_listener(listener));
			}
			public bool check_shortcut_hit(KeyEvent ke) {
				var items = get_items();
				foreach(ActionItem item in items) {
					var sc = item.get_shortcut();
					if(sc != null && ke.is_shortcut(sc)) {
						on_action_item_selected(item);
						return(true);
					}
				}
				return(false);
			}
			public override void on_action_item_selected(ActionItem item) {
				if(item != null) {
					if(item.execute()) {
						return;
					}
					var event = item.get_event();
					if(listener != null) {
						listener.on_event(event);
					}
				}
			}
			public bool on_key_press(KeyEvent ke) {
				base.on_key_press(ke);
				return(check_shortcut_hit(ke));
			}
		}

		property EventReceiver listener;

		public MenuBarButtonWidget() {
			set_draw_frame(false);
			set_draw_outline(false);
			set_rounded(false);
			set_font(Font.instance("Arial 2500um color=black"));
			set_internal_margin("500um");
		}

		public bool on_key_press(KeyEvent ke) {
			base.on_key_press(ke);
			var mw = get_popup() as CustomMenuWidget;
			if(mw != null) {
				return(mw.check_shortcut_hit(ke));
			}
			return(false);
		}

		public MenuBarButtonWidget set_items(Collection items) {
			if(Collection.is_empty(items)) {
				return(this);
			}
			var menu = CustomMenuWidget.instance(listener);
			foreach(var item in items) {
				if(item is ActionItem) {
					var ai = (ActionItem)item;
					var sc = ai.get_shortcut();
					if(String.is_empty(sc) == false) {
						var name = "%s \t \t Ctrl+%s".printf().add(ai.get_text()).add(sc).to_string();
						var nai = ActionItem.instance(ai.get_icon(), name, ai.get_desc(), ai.get_event(), ai.get_data(), ai.get_selected());
						nai.set_shortcut(sc);
						nai.set_action(ai.get_action());
						ai = nai;
					}
					menu.add_action_item(ai);
				}
				else if(item is SeparatorItem) {
					menu.add_separator();
				}
			}
			set_popup(menu);
			return(this);
		}
	}

	HBoxWidget hbox;

	public static DesktopMenuBarWidget instance() {
		return(new DesktopMenuBarWidget());
	}

	public void initialize() {
		base.initialize();
		hbox = HBoxWidget.instance();
		hbox.set_spacing(px("1mm"));
		set_height_request_override(px("4mm"));
		add(CanvasWidget.for_colors(Color.instance("#EEEEEE"), Color.instance("#BBBBBB")));
		add(hbox);
	}

	Widget create_menu_entry(String menu_name, Collection items, EventReceiver event) {
		Widget v;
		if(menu_name != null) {
			var mbw = new MenuBarButtonWidget();
			mbw.set_text(menu_name);
			mbw.set_items(items);
			mbw.set_listener(event);
			v = mbw;
		}
		return(v);
	}

	public void initialize_menubar(DesktopWindowMenuBar menu, EventReceiver evr) {
		if(menu == null || hbox == null) {
			return;
		}
		hbox.remove_children();
		var menus = menu.as_non_mac_menus() as Collection;
		foreach(Menu menu_entry in menus) {
			var me = create_menu_entry((String)menu_entry.get_title(), menu_entry.get_items(), evr);
			if(me != null) {
				hbox.add(me);
			}
		}
	}

	public void finalize() {
		hbox.remove_children();
		hbox = null;
	}
}
