
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

public class ActivityManagerWidget : ResponsiveWidget, ActivityContainer, EventReceiver
{
	public static ActivityManagerWidget find(Widget w) {
		var c = w;
		while(c != null) {
			if(c is ActivityManagerWidget) {
				return((ActivityManagerWidget)c);
			}
			c = c.get_parent() as Widget;
		}
		return(null);
	}

	property Widget background;
	property Widget topbar;
	property Widget bottombar;
	ContainerWidget activityarea;
	ActivityWidget active_activity;
	int crossfade_duration;
	Widget default_activity;
	property bool default_activity_has_frame = false;
	property bool default_activity_is_fullscreen = true;

	public virtual Widget create_topbar() {
		return(null);
	}

	public virtual Widget create_bottombar() {
		return(null);
	}

	class MyContainerWidget : ContainerWidget {
		public void on_move_diff(double diffx, double diffy) {
		}
	}

	public virtual Widget create_background_widget() {
		return(null);
	}

	public void initialize() {
		base.initialize();
		crossfade_duration = 0;
		add(background = create_background_widget());
		if(background != null) {
			background.set_alpha(0.0);
		}
		topbar = create_topbar();
		if(topbar != null) {
			add(AlignWidget.instance().set_maximize_width(true).add_align(0, -2, topbar));
		}
		bottombar = create_bottombar();
		if(bottombar != null) {
			add(AlignWidget.instance().set_maximize_width(true).add_align(0, 2, bottombar));
		}
		add(new ContainerWidget().add(activityarea = new MyContainerWidget()));
		on_narrowness_changed();
		check_active_activity(true);
	}

	public void first_start() {
		base.first_start();
		check_active_activity(true);
	}

	public void update_bars() {
		if(topbar != null && topbar is ActivityManagerMenubarWidget) {
			((ActivityManagerMenubarWidget)topbar).on_active_activity_update(active_activity);
		}
		if(bottombar != null && bottombar is ActivityManagerMenubarWidget) {
			((ActivityManagerMenubarWidget)bottombar).on_active_activity_update(active_activity);
		}
	}

	public void on_narrowness_changed() {
		base.on_narrowness_changed();
		update_activityarea_position();
		update_bars();
	}

	public void on_new_child_size_params(Widget w) {
		base.on_new_child_size_params(w);
	}

	public void update_activityarea_position() {
		if(activityarea == null) {
			return;
		}
		var margin = 0;
		int mh = 0, bb = 0;
		if(topbar != null) {
			mh = topbar.get_height();
		}
		if(bottombar != null) {
			bb = bottombar.get_height();
		}
		activityarea.move_resize(margin, mh + margin, get_width()-margin-margin, get_height()-mh-bb-margin-margin);
		if(active_activity != null) {
			var aax = activityarea.get_x(),
				aay = activityarea.get_y(),
				aaw = activityarea.get_width(),
				aah = activityarea.get_height();
			var wr = active_activity.get_width_request(), hr = active_activity.get_height_request();
			if(wr < 1 || hr < 1 || wr > aaw || hr > aah) {
				active_activity.set_maximized_mode(true);
				active_activity.move_resize(aax, aay, aaw, aah);
			}
			else {
				active_activity.set_maximized_mode(false);
				active_activity.move_resize(aax + (aaw - wr) / 2, aay + (aah - hr) / 2, wr, hr);
			}
		}
	}

	public void cleanup() {
		base.cleanup();
		topbar = null;
		bottombar = null;
		activityarea = null;
		default_activity = null;
	}

	public void start() {
		base.start();
		if(topbar != null) {
			topbar.set_align_y(-1, 750000);
		}
		if(bottombar != null) {
			bottombar.set_align_y(1, 750000);
		}
		if(background != null) {
			background.set_alpha(1.0, 750000);
		}
	}

	public void on_resize() {
		base.on_resize();
		update_activityarea_position();
	}

	public ActivityWidget add_activity(Widget aw, Image icon, String title, bool switchto, bool visible_frame = true, bool fullscreen = false, bool closable = true) {
		if(activityarea == null || aw == null) {
			return(null);
		}
		if(aw.is_initialized()) {
			return(null);
		}
		var w = new ActivityWidget();
		if(fullscreen) {
			w.set_size_request_override(10000, 10000);
		}
		w.set_closable(closable);
		w.set_visible_frame(visible_frame);
		w.set_main_widget(aw);
		w.set_icon(icon);
		w.set_title(title);
		w.set_enabled(false);
		w.set_alpha(0.0);
		activityarea.add(w);
		if(switchto) {
			switch_to_activity(w);
		}
		return(w);
	}

	class WidgetDisabler : AnimationListener
	{
		property Widget widget;
		public void on_animation_listener_end(bool aborted) {
			widget.set_enabled(false);
			widget.set_alpha(0.0);
		}
	}

	public void switch_to_activity(Widget aaw) {
		var aw = aaw as ActivityWidget;
		if(aw == null) {
			aw = ActivityWidget.find(aaw);
		}
		if(activityarea == null || active_activity == aw) {
			return;
		}
		if(active_activity != null) {
			active_activity.set_alpha(0.0, crossfade_duration, new WidgetDisabler().set_widget(active_activity));
			active_activity = null;
		}
		activityarea.make_child_first(aw);
		active_activity = aw;
		if(active_activity != null) {
			active_activity.set_enabled(true);
			active_activity.set_alpha(1.0, crossfade_duration);
		}
		update_activityarea_position();
		update_bars();
		check_active_activity(false);
	}

	public void on_activity_title_changed(ActivityWidget aw) {
		if(aw == active_activity) {
			update_bars();
		}
	}

	public void remove_activity(Widget w) {
		if(w == null) {
			return;
		}
		var aw = ActivityWidget.find(w);
		if(activityarea != null && aw != null) {
			activityarea.remove(aw);
			if(active_activity == aw) {
				active_activity = null;
			}
		}
		check_active_activity(true);
		if(active_activity == null) {
			update_bars();
		}
	}

	class CloseActivityListener : CloseAwareWidgetListener
	{
		property ActivityManagerWidget amw;
		property Widget widget;
		public void on_close_request_status(bool status) {
			if(amw == null || widget == null) {
				return;
			}
			if(status) {
				amw.remove_activity(widget);
			}
		}
	}

	public void close_activity(Widget w) {
		if(w == null) {
			return;
		}
		var aw = ActivityWidget.find(w);
		if(aw == null) {
			return;
		}
		var mw = aw.get_main_widget();
		if(mw != null && mw is CloseAwareWidget) {
			((CloseAwareWidget)mw).on_close_request(new CloseActivityListener().set_amw(this).set_widget(aw));
			return;
		}
		remove_activity(aw);
	}

	public void popup(Widget popup) {
		Popup.widget(get_engine(), popup);
	}

	public virtual Widget create_default_activity() {
		return(null);
	}

	public virtual void execute_default_activity() {
		if(default_activity != null && default_activity.is_initialized() == false) {
			default_activity = null;
		}
		if(default_activity == null) {
			default_activity = create_default_activity();
			if(default_activity != null) {
				add_activity(default_activity, null, null, true, default_activity_has_frame, default_activity_is_fullscreen, false);
			}
		}
		else {
			switch_to_activity(default_activity);
		}
	}

	void check_active_activity(bool allow_first) {
		if(active_activity != null) {
			return;
		}
		if(activityarea == null) {
			return;
		}
		if(allow_first) {
			var first = activityarea.get_first_child() as ActivityWidget;
			if(first != null) {
				switch_to_activity(first);
				return;
			}
		}
		execute_default_activity();
	}

	public Collection get_activity_widgets() {
		if(activityarea == null) {
			return(null);
		}
		return(LinkedList.for_iterator(activityarea.iterate_children()));
	}

	public ActivityWidget get_active_activity() {
		return(active_activity);
	}

	public virtual void on_about_application() {
		var msg = "%s %s, running on %s".printf().add(Application.get_display_name())
			.add(Application.get_version()).add(VALUE("target_platform")).to_string();
		var cr = Application.get_copyright();
		if(String.is_empty(cr) == false) {
			msg = msg.append("; ".append(cr));
		}
		var ll = Application.get_license();
		if(String.is_empty(ll) == false) {
			msg = msg.append(". ".append(ll));
		}
		MessageDialog.show(get_engine(), msg, "About");
	}

	public void close_current_activity() {
		if(active_activity != null) {
			close_activity(active_activity);
		}
	}

	public virtual Object get_documentation_event() {
		return(null);
	}

	public virtual bool on_escape_pressed() {
		return(false);
	}

	public virtual bool on_ctrl_capq_pressed() {
		close_current_activity();
		return(true);
	}

	public bool on_key_press(KeyEvent e) {
		if(e.is_shortcut("Q")) {
			if(on_ctrl_capq_pressed()) {
				return(true);
			}
		}
		else if(e.get_alt() || e.get_ctrl() || e.get_command()) {
			if("tab".equals(e.get_name()) || "`".equals(e.get_str())) {
				var next = activityarea.get_child(1) as ActivityWidget;
				if(next != null) {
					switch_to_activity(next);
				}
				return(true);
			}
			if("escape".equals(e.get_name())) {
				var mb = topbar as ActivityManagerMenubarWidget;
				if(mb != null) {
					mb.on_activity_list_request();
				}
		  		return(true);
			}
		}
		else if(e.has_modifiers() == false && "escape".equals(e.get_name())) {
			if(on_escape_pressed()) {
				return(true);
			}
		}
		return(base.on_key_press(e));
	}

	public void on_event(Object o) {
		if(o == null) {
		}
		else if(o is ActivityWidget) {
			switch_to_activity((ActivityWidget)o);
		}
		else if(o is WindowFrameCloseEvent) {
			close_activity(((WindowFrameCloseEvent)o).get_widget());
		}
		else if("close-current-activity".equals(o)) {
			close_current_activity();
		}
		else if("activities-home".equals(o)) {
			switch_to_activity(null);
		}
		else if("exit-application".equals(o)) {
			Popup.widget(get_engine(), DialogWidget.yesno("Are you sure you would want to exit the application?",
				"Confirm exit", "exit-application-confirmed", null).set_listener(this));
		}
		else if("exit-application-confirmed".equals(o)) {
			close_frame();
		}
		else if("about-application".equals(o)) {
			on_about_application();
		}
		else {
			raise_event(o, false);
		}
	}
}
