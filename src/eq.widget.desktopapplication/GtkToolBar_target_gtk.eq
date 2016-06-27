
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

public class GtkToolBar : ToolBarControl
{
	embed "c" {{{
		#include <gtk/gtk.h>
	}}}

	public static GtkToolBar for_frame(Frame frame) {
		var ff = frame as GtkWindowFrame;
		if(ff == null) {
			return(null);
		}
		return(new GtkToolBar().set_frame(ff));
	}

	static void execute_action(ptr widget, DataParameter params) {
		if(params != null) {
			var ai = params.get_action_item();
			if(ai != null) {
				if(ai.execute()) {
					return;
				}
				var rv = params.get_event_handler() as ToolBarControlListener;
				if(rv != null) {
					rv.on_toolbar_entry_selected(ai);
				}
			}
		}
	}

	property GtkWindowFrame frame;
	ToolBar tb;
	LinkedList list;

	public GtkToolBar() {
		list = LinkedList.create();
	}

	public void initialize_toolbar(ToolBar tb, ToolBarControlListener listener) {
		if(tb == null) {
			return;
		}
		this.tb = tb;
		ptr container = frame.get_toolbar_container();
		frame.clear_container(container);
		list.clear();
		ptr toolbar;
		ptr tool_item;
		ptr icon_widget;
		embed "c" {{{
			toolbar = gtk_toolbar_new();
			gtk_toolbar_set_style(toolbar, GTK_TOOLBAR_BOTH);
		}}}
		int dpi = frame.get_dpi();
		foreach(Object item in tb.get_items()) {
			if(item is SeparatorItem) {
				embed "c" {{{
					tool_item = gtk_separator_tool_item_new();
				}}}
				if(((SeparatorItem)item).get_weight() > 0) {
					embed "c" {{{
						gtk_tool_item_set_expand(tool_item, TRUE);
						gtk_separator_tool_item_set_draw(tool_item, FALSE);
					}}}
				}
			}
			else if(item is ActionItem) {
				ptr textptr = null;
				var ai = (ActionItem)item;
				var text = ai.get_text();
				if(!String.is_empty(text)) {
					textptr = text.to_strptr();
				}
				ptr gtk_image = null;
				var icon = ai.get_icon();
				if(icon != null) {
					var gtk_icon = icon as GtkFileImage;
					if(gtk_icon != null) {
						int fh = Length.to_pixels("5mm", dpi);
						var resized_image = gtk_icon.resize(-1, fh) as GtkFileImage;
						gtk_image = resized_image.get_gtk_image();
					}
				}
				var params = new DataParameter()
					.set_action_item(ai)
					.set_event_handler(listener);
				embed "c" {{{
					icon_widget = gtk_image_new_from_pixbuf(gtk_image);
					tool_item = gtk_tool_button_new(icon_widget, textptr);
					g_signal_connect(
						tool_item,
						"clicked",
						G_CALLBACK(eq_widget_desktopapplication_GtkToolBar_execute_action),
						params
					);
				}}}
				list.add(params);
			}
			embed "c" {{{
				gtk_toolbar_insert(toolbar, tool_item, -1);
			}}}
		}
		embed "c" {{{
			gtk_container_add(container, toolbar);
			gtk_widget_show_all(container);
		}}}
	}

	public void finalize() {
		frame = null;
		tb = null;
		list.clear();
	}
}
