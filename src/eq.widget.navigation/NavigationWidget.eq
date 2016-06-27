
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

public class NavigationWidget : LayerWidget, TitledFrame, EventReceiver, WidgetStack
{
	public static NavigationWidget find(Widget ref) {
		var rr = ref;
		while(rr != null) {
			if(rr is NavigationWidget) {
				return((NavigationWidget)rr);
			}
			rr = rr.get_parent() as Widget;
		}
		return(null);
	}

	public static void push(Widget ref, Widget topush, int effect = 0) {
		var nv = find(ref);
		if(nv != null) {
			nv.push_page(topush, effect);
		}
	}

	public static void pop(Widget ref, int effect = 0) {
		var nv = find(ref);
		if(nv != null) {
			nv.pop_page(effect);
		}
	}

	property bool enable_visible_bar = true;
	StackChangerWidget changer;
	NavigationBarWidget bar;
	String mytitle;
	int barheight;
	int pagecount = 0;
	property int default_push_effect = ChangerWidget.EFFECT_SCROLL_LEFT;
	property int default_pop_effect = ChangerWidget.EFFECT_SCROLL_RIGHT;
	property bool animate_navigation_bar = false;

	public virtual NavigationBarWidget create_navigation_bar_widget() {
		return(new DefaultNavigationBarWidget());
	}

	public void initialize() {
		base.initialize();
		add(changer = new StackChangerWidget());
		if(enable_visible_bar) {
			int ya = -2;
			if(animate_navigation_bar == false) {
				ya = -1;
			}
			add(AlignWidget.instance().set_maximize_width(true).set_maximize_empty(false).add_align(0, ya, bar = create_navigation_bar_widget()));
		}
		if(bar != null) {
			barheight = bar.get_height_request();
		}
		else {
			barheight = 0;
		}
	}

	public void cleanup() {
		base.cleanup();
		changer = null;
		bar = null;
	}

	public void set_icon(Image icon) {
		set_frame_icon(icon, false);
	}

	public void set_title(String title) {
		set_frame_title(title, false);
		mytitle = title;
		update_navigation_bar();
	}

	class MyContainerWidget : BoxWidget
	{
		property int barheight;
		property Widget widget;
		public MyContainerWidget() {
			set_direction(BoxWidget.VERTICAL);
		}
		public void initialize() {
			base.initialize();
			if(barheight > 0) {
				add(new Widget().set_height_request(barheight));
			}
			add_box(1, widget);
		}
	}

	public void push_widget(Widget widget) {
		push_page(widget);
	}

	public bool pop_widget() {
		return(pop_page());
	}

	public void push_page(Widget widget, int effect = -1) {
		if(changer == null || widget == null) {
			return;
		}
		bool hasbar = true;
		if(widget is NavigationAwareWidget) {
			hasbar = ((NavigationAwareWidget)widget).is_navigation_bar_enabled();
		}
		var ww = widget;
		if(hasbar) {
			ww = new MyContainerWidget().set_barheight(barheight).set_widget(widget);
		}
		var f = effect;
		if(f < 0) {
			f = default_push_effect;
		}
		if(is_started() == false) {
			f = 0;
		}
		changer.push(ww, f);
		pagecount ++;
		on_changed();
	}

	public bool pop_page(int effect = -1) {
		if(changer == null) {
			return(false);
		}
		bool v = false;
		var f = effect;
		if(f < 0) {
			f = default_pop_effect;
		}
		if(is_started() == false) {
			f = 0;
		}
		if(changer.pop(f)) {
			pagecount --;
			v = true;
		}
		on_changed();
		return(v);
	}

	public bool on_key_press(KeyEvent e) {
		if("back".equals(e.get_name())) {
			return(pop_page());
		}
		return(base.on_key_press(e));
	}

	public Widget get_active_widget() {
		if(changer == null) {
			return(null);
		}
		return(changer.get_active_widget());
	}

	public virtual void on_changed() {
		update_navigation_bar();
	}

	public void update_navigation_bar() {
		if(bar == null || changer == null) {
			return;
		}
		var enabled = true;
		int align = 1;
		String text;
		ActionItem rightitem;
		var ww = changer.get_active_widget() as NavigationAwareWidget;
		if(ww == null) {
			var aw = changer.get_active_widget() as MyContainerWidget;
			if(aw != null) {
				ww = aw.get_widget() as NavigationAwareWidget;
			}
		}
		if(ww != null) {
			enabled = ww.is_navigation_bar_enabled();
			text = ww.get_back_label();
			rightitem = ww.get_right_action();
			align = ww.get_title_align();
			mytitle = ww.get_title();
		}
		if(enabled) {
			bar.set_align_y(-1, 750000);
			bar.set_back_button_label(text);
			bar.set_title(mytitle);
			if(pagecount < 2) {
				bar.set_back_button_enabled(false);
			}
			else {
				bar.set_back_button_enabled(true);
			}
			bar.set_right_button(rightitem);
			bar.set_title_align(align);
		}
		else {
			bar.set_align_y(-2, 750000);
		}
		set_frame_title(mytitle, false);
	}

	public void on_event(Object o) {
		if("back".equals(o)) {
			pop_page();
			return;
		}
		forward_event(o);
	}
}
