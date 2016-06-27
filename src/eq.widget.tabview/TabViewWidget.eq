
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

public class TabViewWidget : VBoxWidget, EventReceiver
{
	class TabContainerWidget : LayerWidget
	{
		property String tab_title;
		property Image tab_icon;
		property Widget tab_widget;

		public void initialize() {
			base.initialize();
			add(tab_widget);
		}

		TabViewWidget find_tab_view() {
			var p = get_parent() as Widget;
			while(p != null) {
				if(p is TabViewWidget) {
					return((TabViewWidget)p);
				}
				p = p.get_parent() as Widget;
			}
			return(null);
		}

		public void set_title(String title, bool init) {
			this.tab_title = title;
			var tv = find_tab_view();
			if(tv != null) {
				tv.on_tab_changed(this);
			}
		}

		public void set_icon(Image icon, bool init) {
			this.tab_icon = icon;
			var tv = find_tab_view();
			if(tv != null) {
				tv.on_tab_changed(this);
			}
		}
	}

	class WideTabSelectorWidget : VBoxWidget
	{
		public void update(Iterator tabs, Widget current) {
			remove_children();
			var box = HBoxWidget.instance().set_margin(px("500um")).set_spacing(px("1500um"));
			add(HScrollerWidget.instance().add(box));
			Widget selected;
			foreach(TabContainerWidget tcw in tabs) {
				bool ss = false;
				if(tcw == current) {
					ss = true;
				}
				var ff = Theme.font();
				ff.set_color(get_draw_color());
				var ww = new FramelessButtonWidget();
				ww.set_icon_size("2500um");
				ww.set_text(tcw.get_tab_title());
				ww.set_icon(tcw.get_tab_icon());
				ww.set_font(ff);
				ww.set_event(tcw);
				ww.set_internal_margin("1mm");
				if(box.count() > 0) {
					box.add(VSeparatorWidget.instance().set_flat(true));
				}
				box.add(ww);
				if(ss) {
					selected = ww;
				}
			}
			if(selected != null) {
				selected.scroll_to_widget();
			}
		}
	}

	class NarrowTabSelectorWidget : ComboButtonWidget
	{
		public void initialize() {
			set_minimum_height_request(px("7mm"));
			base.initialize();
		}

		public void update(Iterator tabs, Widget current) {
			clear();
			foreach(TabContainerWidget tcw in tabs) {
				bool ss = false;
				if(tcw == current) {
					ss = true;
				}
				add_item(ActionItem.instance(tcw.get_tab_icon(), tcw.get_tab_title(), null, tcw), ss);
			}
		}
	}

	class TabSelectorWidget : ResponsiveWidthWidget
	{
		public TabSelectorWidget() {
			set_narrow_threshold("90mm");
		}

		public void initialize_narrow() {
			add(new NarrowTabSelectorWidget());
			update();
		}

		public void initialize_wide() {
			add(new WideTabSelectorWidget());
			update();
		}

		TabViewWidget find_tab_view() {
			var p = get_parent() as Widget;
			while(p != null) {
				if(p is TabViewWidget) {
					return((TabViewWidget)p);
				}
				p = p.get_parent() as Widget;
			}
			return(null);
		}

		public void update() {
			var tv = find_tab_view();
			if(tv != null) {
				var tcs = tv.iterate_tab_containers();
				var cc = get_child(0);
				if(cc != null && cc is NarrowTabSelectorWidget) {
					((NarrowTabSelectorWidget)cc).update(tcs, tv.get_selected_container_widget());
				}
				else if(cc != null && cc is WideTabSelectorWidget) {
					((WideTabSelectorWidget)cc).update(tcs, tv.get_selected_container_widget());
				}
				if(tv.get_control_window_title()) {
					var tcw = tv.get_selected_container_widget() as TabContainerWidget;
					if(tcw != null) {
						set_frame_title(tcw.get_tab_title());
						set_frame_icon(tcw.get_tab_icon());
					}
				}
			}
		}
	}

	public property bool control_window_title = false;
	TabSelectorWidget selector;
	ChangerWidget changer;
	HBoxWidget left_box;
	HBoxWidget right_box;
	Collection tabs;
	Widget current_widget;
	Widget selector_background;
	HBoxWidget mhb;

	public static TabViewWidget instance() {
		return(new TabViewWidget());
	}

	public TabViewWidget() {
		tabs = LinkedList.create();
	}

	public TabViewWidget set_selector_background(Widget w) {
		selector_background = w;
		/* FIXME
		if(mhb != null) {
			mhb.set_background(w);
		}
		*/
		return(this);
	}

	public void clear() {
		tabs = LinkedList.create();
		if(is_initialized()) {
			reinitialize();
		}
	}

	public void initialize() {
		base.initialize();
		mhb = (HBoxWidget)HBoxWidget.instance()
			.add_hbox(0, left_box = HBoxWidget.instance())
			.add_hbox(1, selector = new TabSelectorWidget())
			.add_hbox(0, right_box = HBoxWidget.instance());
		add_vbox(0, mhb);
		add_vbox(1, changer = new ChangerWidget());
		current_widget = null;
		foreach(TabContainerWidget tcw in tabs) {
			do_add_tab(tcw, false);
		}
		init_current();
	}

	public void cleanup() {
		base.cleanup();
		selector = null;
		changer = null;
		current_widget = null;
		mhb = null;
	}

	public HBoxWidget get_left_box() {
		return(left_box);
	}

	public HBoxWidget get_right_box() {
		return(right_box);
	}

	bool tab_change_timer = false;

	public void on_tab_changed(Widget wtab) {
		var tab = wtab as TabContainerWidget;
		schedule_update();
	}

	void schedule_update() {
		if(tab_change_timer) {
			return;
		}
		start_delay_timer(0);
		tab_change_timer = true;
	}

	public void on_delay_timer(Object o) {
		if(selector != null) {
			selector.update();
		}
		tab_change_timer = false;
	}

	void init_current() {
		if(changer == null) {
			return;
		}
		if(changer.get_active_widget() != null) {
			return;
		}
		foreach(Widget w in iterate_tab_containers()) {
			changer.activate(w, ChangerWidget.EFFECT_CROSSFADE);
			current_widget = w;
			on_current_changed();
			return;
		}
		// FIXME: Switch to default tab
	}

	public Widget get_selected_widget() {
		var cw = get_selected_container_widget() as TabContainerWidget;
		if(cw != null) {
			return(cw.get_tab_widget());
		}
		return(null);
	}

	public Widget get_selected_container_widget() {
		return(current_widget);
	}

	public TabViewWidget add_default(Widget w) {
		// FIXME
		return(this);
	}

	public TabViewWidget add_tab(Widget ao, String title = null, Image icon = null, bool switch_to = true) {
		var widget = ao;
		if(widget == null) {
			widget = new Widget();
		}
		var tt = title;
		if(String.is_empty(tt) && icon == null) {
			tt = "New tab";
		}
		var tcw = new TabContainerWidget().set_tab_widget(widget).set_tab_title(tt).set_tab_icon(icon);
		tabs.add(tcw);
		do_add_tab(tcw, switch_to);
		on_tab_added(widget);
		return(this);
	}

	void do_add_tab(TabContainerWidget tcw, bool switch_to) {
		if(changer != null) {
			changer.add_changer(tcw, false, ChangerWidget.EFFECT_NONE);
			if(switch_to) {
				changer.activate(tcw, ChangerWidget.EFFECT_CROSSFADE);
				current_widget = tcw;
				on_current_changed();
			}
		}
		schedule_update();
	}

	public void remove_tab(Widget aft) {
		if(aft == null) {
			return;
		}
		var tcw = aft as TabContainerWidget;
		if(tcw == null) {
			tcw = aft.get_parent() as TabContainerWidget;
		}
		if(tcw == null) {
			return;
		}
		int current_index = -1, n = 0;
		if(current_widget == tcw) {
			foreach(TabContainerWidget www in tabs) {
				if(www == tcw) {
					current_index = n;
					break;
				}
				n ++;
			}
		}
		tabs.remove(tcw);
		changer.remove(tcw);
		if(current_widget == tcw) {
			current_widget = null;
		}
		schedule_update();
		if(current_index >= 0) {
			int nx = 0;
			TabContainerWidget ll;
			foreach(TabContainerWidget www in tabs) {
				ll = www;
				if(nx == current_index) {
					break;
				}
				nx++;
			}
			if(ll != null) {
				changer.activate(ll, ChangerWidget.EFFECT_CROSSFADE);
				current_widget = ll;
				on_current_changed();
			}
		}
		if(current_widget == null) {
			init_current();
		}
		on_tab_removed(aft);
	}

	public void select_tab(Widget tw) {
		foreach(TabContainerWidget w in tabs) {
			if(w.get_tab_widget() == tw) {
				changer.activate(w, ChangerWidget.EFFECT_CROSSFADE);
				current_widget = w;
				on_current_changed();
				break;
			}
		}
	}

	public void select_next_tab() {
		if(current_widget == null) {
			init_current();
			return;
		}
		bool f = false;
		foreach(Widget w in tabs) {
			if(w == current_widget) {
				f = true;
			}
			else if(f) {
				changer.activate(w, ChangerWidget.EFFECT_CROSSFADE);
				current_widget = w;
				on_current_changed();
				break;
			}
		}
	}

	public void select_previous_tab() {
		if(current_widget == null) {
			init_current();
			return;
		}
		Widget ww;
		foreach(Widget w in tabs) {
			if(w == current_widget) {
				if(ww != null) {
					changer.activate(ww, ChangerWidget.EFFECT_CROSSFADE);
					current_widget = ww;
					on_current_changed();
				}
				break;
			}
			ww = w;
		}
	}

	public bool on_key_press(KeyEvent e) {
		if(e != null && e.get_alt()) {
			var k = e.get_name();
			if("left".equals(k)) {
				select_previous_tab();
				return(true);
			}
			else if("right".equals(k)) {
				select_next_tab();
				return(true);
			}
		}
		return(base.on_key_press(e));
	}

	public void on_event(Object o) {
		if(o != null && o is TabContainerWidget) {
			if(changer != null) {
				changer.activate((Widget)o, ChangerWidget.EFFECT_CROSSFADE);
				current_widget = (Widget)o;
				on_current_changed();
			}
		}
		else {
			raise_event(o, false);
		}
	}

	public virtual void on_current_changed() {
		schedule_update();
	}

	public virtual void on_tab_added(Widget widget) {
	}

	public virtual void on_tab_removed(Widget widget) {
	}

	public int count_tabs() {
		return(changer.count());
	}

	public Iterator iterate_tabs() {
		var v = LinkedList.create();
		foreach(TabContainerWidget tcw in changer.iterate_children()) {
			v.add(tcw.get_tab_widget());
		}
		return(v.iterate());
	}

	public Iterator iterate_tab_containers() {
		if(tabs == null) {
			return(LinkedList.create().iterate());
		}
		return(tabs.iterate());
	}
}
