
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

public class GtkMenuBar : MenuBarControl
{
	embed "c" {{{
		#include <gtk/gtk.h>
	}}}

	public static GtkMenuBar for_frame(Frame frame) {
		var ff = frame as GtkWindowFrame;
		if(ff == null) {
			return(null);
		}
		return(new GtkMenuBar().set_frame(ff));
	}

	static void execute_action(ptr widget, DataParameter params) {
		if(params != null) {
			var ai = params.get_action_item();
			if(ai != null) {
				if(ai.execute()) {
					return;
				}
				var rv = params.get_event_handler() as EventReceiver;
				if(rv != null) {
					var event = ai.get_event();
					rv.on_event(event);
				}
			}
		}
	}

	property GtkWindowFrame frame;
	DesktopWindowMenuBar menu;
	LinkedList list;

	public GtkMenuBar() {
		list = LinkedList.create();
	}

	public void initialize_menubar(DesktopWindowMenuBar menu, EventReceiver evr) {
		if(menu == null) {
			return;
		}
		this.menu = menu;
		ptr container = frame.get_menubar_container();
		frame.clear_container(container);
		list.clear();
		ptr menu_bar;
		ptr menu_item;
		ptr accel_group;
		ptr menu_item_entry;
		ptr menu_item_container;
		ptr gtk_window = frame.get_gtk_window();
		var submenus = menu.as_non_mac_menus() as Collection;
		embed "c" {{{
			menu_bar = gtk_menu_bar_new();
			accel_group = gtk_accel_group_new();
		}}}
		foreach(Menu menu_entries in submenus) {
			if(menu_entries == null) {
				continue;
			}
			var title = menu_entries.get_title();
			if(String.is_empty(title)) {
				continue;
			}
			var titleptr = title.to_strptr();
			embed "c" {{{
				menu_item = gtk_menu_item_new_with_label(titleptr);
				menu_item_container = gtk_menu_new();
			}}}
			var menu_items = menu_entries.get_items();
			foreach(Object item in menu_items) {
				if(item is SeparatorItem) {
					embed "c" {{{
						menu_item_entry = gtk_separator_menu_item_new();
					}}}
				}
				else if(item is ActionItem) {
					var ai = (ActionItem)item;
					var item_txt = ai.get_text();
					var item_txt_ptr = item_txt.to_strptr();
					embed "c" {{{
						menu_item_entry = gtk_menu_item_new_with_label(item_txt_ptr);
					}}}
					var sc = ai.get_shortcut();
					if(!String.is_empty(sc)) {
						int shortcut = sc.get_char(0);
						embed "c" {{{
							int type = GDK_CONTROL_MASK;	
						}}}
						if(shortcut >= 'A' && shortcut <= 'Z') {
							embed "c" {{{
								type |= GDK_SHIFT_MASK;
							}}}
						}
						embed "c" {{{
							gtk_widget_add_accelerator(
								menu_item_entry,
								"activate",
								accel_group,
								shortcut,
								type,
								GTK_ACCEL_VISIBLE
							);
						}}}
					}
					var params = new DataParameter()
						.set_action_item(ai)
						.set_event_handler(evr);
					embed "c" {{{
						g_signal_connect(
							menu_item_entry,
							"activate",
							G_CALLBACK(eq_widget_desktopapplication_GtkMenuBar_execute_action),
							params
						);
					}}}
					list.add(params);
				}
				embed "c" {{{
					gtk_menu_shell_append(menu_item_container, menu_item_entry);
				}}}
			}
			embed "c" {{{
				gtk_menu_item_set_submenu(menu_item, menu_item_container);
				gtk_menu_shell_append(menu_bar, menu_item);
			}}}
		}
		embed "c" {{{
			gtk_container_add(container, menu_bar);
			gtk_widget_show_all(container);
			gtk_window_add_accel_group(gtk_window, accel_group);
		}}}
	}

	public void finalize() {
		frame = null;
		menu = null;
		list.clear();
	}
}
