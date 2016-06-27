
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

public class ToolBarWidget : LayerWidget, EventReceiver, ToolBarControl
{
	class ToolBarBackgroundWidget : CanvasWidget
	{
		property Color my_background_color;
		property Color my_outline_color;
		property String my_outline_width;
		property bool my_rounded = false;

		public ToolBarBackgroundWidget() {
			my_background_color = Theme.color("eq.widget.desktopapplication.ToolBarWidget.background_color", "#AAAAAA");
			my_outline_color = Theme.color("eq.widget.desktopapplication.ToolBarWidget.outline_color", "none");
			my_outline_width = Theme.string("eq.widget.desktopapplication.ToolBarWidget.outline_width", "333um");
			my_rounded = Theme.boolean("eq.widget.desktopapplication.ToolBarWidget.rounded", "false");
		}

		public void initialize() {
			base.initialize();
			set_color_gradient(my_background_color);
			set_outline_color(my_outline_color);
			set_outline_width(my_outline_width);
			set_rounded(my_rounded);
		}
	}

	class ToolBarButtonWidget : ButtonWidget
	{
		public ToolBarButtonWidget() {
			set_rounded(Theme.boolean("eq.widget.desktopapplication.ToolBarWidget.rounded", "false"));
			set_symmetric_icons(false);
			set_draw_frame(false);
			set_color(Theme.color("eq.widget.desktopapplication.ToolBarWidget.highlight_color", "#99999980"));
			set_margin(0);
			set_internal_margin("1mm");
			set_font(Theme.font("eq.widget.desktopapplication.ToolBarWidget.font", "2300um color=white"));
			set_pressed_font(Theme.font("eq.widget.desktopapplication.ToolBarWidget.font",
				"2300um color=white outline-color=%s".printf().add(Theme.get_highlight_color()).to_string()));
		}
	}

	HBoxWidget hbox;
	Collection entries;
	property bool show_text = false;
	property bool rounded = false;
	property Font label_font;
	property Widget background;
	property String icon_size;
	property String internal_margin;
	property bool scrollable = true;
	ToolBarControlListener listener;
	HashTable shortcuts;

	public static ToolBarWidget instance() {
		return(new ToolBarWidget());
	}

	public ToolBarWidget() {
		entries = LinkedList.create();
		rounded = Theme.boolean("eq.widget.desktopapplication.ToolBarWidget.rounded", "false");
		label_font = Theme.font("eq.widget.desktopapplication.ToolBarWidget.label_font", "bold 2500um color=white");
		background = new ToolBarBackgroundWidget();
		internal_margin = Theme.string("eq.widget.desktopapplication.ToolBarWidget.internal_margin", "500um");
	}

	public void initialize() {
		base.initialize();
		if(background != null) {
			add(background);
		}
		hbox = HBoxWidget.instance();
		if(scrollable) {
			var sc = HScrollerWidget.instance();
			add(sc);
			sc.add_scroller(hbox);
		}
		else {
			add(hbox);
		}
		set_height_request_override(0);
		hbox.set_margin(px(internal_margin));
		hbox.set_spacing(0);
		foreach(Object o in entries) {
			if(o is ActionItem) {
				add_entry_widget((ActionItem)o);
			}
			else if(o is SeparatorItem) {
				add_separator_widget();
			}
		}
	}

	public void cleanup() {
		base.cleanup();
		shortcuts = null;
	}

	public void finalize() {
		listener = null;
	}

	public Widget add_keyboard_shortcut(String shortcut, Object event) {
		if(String.is_empty(shortcut)) {
			return(this);
		}
		if(shortcuts == null) {
			shortcuts = HashTable.create();
		}
		shortcuts.set(shortcut, event);
		return(this);
	}

	public bool on_key_press(KeyEvent e) {
		if(shortcuts != null && e != null && e.is_shortcut()) {
			var str = e.get_str();
			if(str != null) {
				var ee = shortcuts.get(str);
				if(ee != null) {
					raise_event(ee);
					return(true);
				}
			}
		}
		return(base.on_key_press(e));
	}

	void on_item_added() {
		set_minimum_height_request(px("7mm"));
		set_height_request_override(-1);
	}

	Widget add_separator_widget() {
		Widget v;
		if(hbox != null) {
			hbox.add(v = BoxWidget.horizontal()
				.add(new Widget().set_width_request(px("1mm")))
				.add(VSeparatorWidget.instance())
				.add(new Widget().set_width_request(px("1mm")))
			);
			on_item_added();
		}
		return(v);
	}

	Widget add_wide_separator_widget() {
		Widget v;
		if(hbox != null) {
			hbox.add_box(1, v = new Widget());
			on_item_added();
		}
		return(v);
	}

	Widget add_entry_widget(ActionItem ee) {
		Widget v;
		if(ee != null && hbox != null) {
			var bb = new ToolBarButtonWidget();
			if(show_text) {
				bb.set_text(ee.get_text());
			}
			if(icon_size != null) {
				bb.set_icon_size(icon_size);
			}
			bb.set_icon(ee.get_icon());
			bb.set_event(ee);
			hbox.add(bb);
			v = bb;
			on_item_added();
		}
		if(v != null) {
			var shortcut = ee.get_shortcut();
			if(shortcut != null) {
				add_keyboard_shortcut(shortcut, v);
			}
		}
		return(v);
	}

	void clear_entries() {
		entries = LinkedList.create();
		if(hbox != null) {
			hbox.remove_children();
		}
		set_minimum_height_request(0);
		set_height_request_override(0);
	}

	public void initialize_toolbar(ToolBar tb, ToolBarControlListener listener) {
		this.listener = listener;
		clear_entries();
		if(tb == null) {
			return;
		}
		foreach(Object o in tb.get_items()) {
			if(o is ActionItem) {
				entries.add((ActionItem)o);
				if(is_initialized()) {
					add_entry_widget((ActionItem)o);
				}
			}
			else if(o is SeparatorItem) {
				entries.add((SeparatorItem)o);
				if(is_initialized()) {
					if(((SeparatorItem)o).get_weight() > 0) {
						add_wide_separator_widget();
					}
					else {
						add_separator_widget();
					}
				}
			}
		}
	}

	public void on_event(Object o) {
		if(o != null && o is ActionItem) {
			if(listener != null) {
				listener.on_toolbar_entry_selected((ActionItem)o);
			}
			return;
		}
		if(o != null && o is ButtonWidget) {
			((ButtonWidget)o).on_clicked();
			return;
		}
		forward_event(o);
	}
}
