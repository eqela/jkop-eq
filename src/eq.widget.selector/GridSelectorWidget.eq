
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

public class GridSelectorWidget : LayerWidget
{
	public static int SELECT_NONE = 0;
	public static int SELECT_SINGLE = 1;
	public static int SELECT_MULTI = 2;

	public static GridSelectorWidget find_grid_widget(Widget w) {
		var ww = w;
		while(ww != null) {
			if(ww is GridSelectorWidget) {
				return((GridSelectorWidget)ww);
			}
			ww = ww.get_parent() as Widget;
		}
		return(null);
	}

	public static GridSelectorWidget instance() {
		return(new GridSelectorWidget());
	}

	public static GridSelectorWidget for_items(Collection items) {
		return(new GridSelectorWidget().set_items(items));
	}

	property bool raise_events = true;
	property int select_mode = 0;
	property Color hover_background_color;
	property Color pressed_color;
	property Color focus_color;
	Collection items;
	GridSelectorContainerWidget container;
	GridSelectorItemWidget last_clicked_item;
	GridSelectorItemWidget selected_item;

	public GridSelectorWidget() {
		container = new GridSelectorContainerWidget();
		hover_background_color = Color.instance("#80808080");
		pressed_color = Theme.get_pressed_color();
		focus_color = Theme.get_selected_color();
	}

	public GridSelectorWidget add_item(Image icon, String title, Object event_object) {
		if(items == null) {
			items = LinkedList.create();
		}
		items.add(ActionItem.instance(icon, title, null, event_object));
		return(this);
	}

	public GridSelectorItemWidget get_item_widget(ActionItem ai) {
		var gs = get_widget_for_item(ai);
		if(gs != null) {
			gs.set_hover_background_color(hover_background_color);
			gs.set_pressed_color(pressed_color);
			gs.set_focus_color(focus_color);
		}
		return(gs);
	}

	public virtual GridSelectorItemWidget get_widget_for_item(ActionItem ai) {
		return(new GridSelectorItemWidget().set_item(ai));
	}

	public void initialize() {
		base.initialize();
		if(ScrollerWidget.find(this) == null) {
			add(VScrollerWidget.instance().add(container));
		}
		else {
			add(container);
		}
	}

	public int get_item_count() {
		if(items != null) {
			return(items.count());
		}
		return(0);
	}

	public GridSelectorWidget set_items(Collection ii) {
		items = Array.create();
		var has_icons = false;
		var has_descs = false;
		foreach(var o in ii) {
			var ai = ActionItem.as_action_item(o);
			if(ai != null) {
				items.add(ai);
			}
		}
		container.update_size_request();
		if(is_initialized()) {
			container.reset();
			container.update_children();
		}
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

	public virtual void on_item_clicked(GridSelectorItemWidget iw) {
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
			}
			else if(selected_item == iw) {
				selected_item = null;
			}
		}
		else if(select_mode == SELECT_MULTI) {
			iw.set_selected(!iw.get_selected());
		}
		on_action_item_clicked(iw.get_item());
	}

	public ActionItem get_selector_item(int n) {
		if(items == null) {
			return(null);
		}
		return(items.get(n) as ActionItem);
	}
}
