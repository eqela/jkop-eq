
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

public class ActivityManagerDefaultMenubarWidget : ResponsiveWidget, ActivityManagerMenubarWidget
{
	FramelessButtonWidget close_activity_button;
	ActivityListButtonWidget activity_list;
	property bool enable_clock = false;
	property bool enable_clock_narrow = false;
	property bool enable_home_button = true;
	ClockWidget clock;

	class MainMenuWidget : FramelessButtonWidget
	{
		property ActivityManagerDefaultMenubarWidget amgr;
		public MainMenuWidget() {
			set_square_icons(false);
			set_internal_margin("1mm");
			set_rounded(true);
		}
		public void initialize() {
			base.initialize();
			var mm = amgr.get_main_menu_image();
			set_icon(mm);
			if(mm == null) {
				set_text("Start ..");
			}
		}
		public Widget get_popup_widget() {
			if(amgr != null) {
				return(amgr.create_main_menu_popup());
			}
			return(null);
		}
	}

	public virtual Image get_main_menu_image() {
		return(IconCache.get("mainmenu"));
	}

	public virtual Image get_close_window_image() {
		return(IconCache.get("close_window"));
	}

	public virtual Collection get_main_menu_items() {
		return(null);
	}

	public virtual Widget create_main_menu_popup() {
		var v = new MenuWidget();
		v.add_entry(IconCache.get("home"), "Return to Home Screen", "Back to the main home screen", "activities-home");
		v.add_separator();
		v.set_header_text("%s ..".printf().add(Application.get_display_name()).to_string());
		int n = 0;
		foreach(var o in get_main_menu_items()) {
			if("separator".equals(o)) {
				v.add_separator();
			}
			else if(o is ActionItem) {
				v.add_action_item((ActionItem)o);
			}
			n ++;
		}
		if(n > 0) {
			v.add_separator();
		}
		v.add_entry(IconCache.get("appicon"), "About %s ..".printf().add(Application.get_display_name()).to_string(), null, "about-application");
		var amw = ActivityManagerWidget.find(this);
		if(amw != null) {
			var dd = amw.get_documentation_event();
			if(dd != null) {
				v.add_entry(IconCache.get("help"), "Help and documentation ..", null, dd);
			}
		}
		var plat = VALUE("target_platformid");
		if(plat != null && ("osx".equals(plat) || plat.has_prefix("linux") || plat.has_prefix("win7"))) {
			v.add_entry(IconCache.get("close"), "Exit Application ..", null, "exit-application");
		}
		return(v);
	}

	public virtual void add_custom_right_widgets(ContainerWidget cw) {
		if(enable_clock) {
			cw.add(clock = new ClockWidget());
		}
	}

	public virtual Widget create_right_widget() {
		var right = BoxWidget.horizontal();
		right.set_spacing(px("1mm"));
		add_custom_right_widgets(right);
		var cic = get_close_window_image();
		String ctx;
		if(cic == null) {
			ctx = "Close";
		}
		right.add(close_activity_button = (FramelessButtonWidget)FramelessButtonWidget.create(cic, ctx)
			.set_rounded(true).set_internal_margin("1mm").set_event("close-current-activity"));
		close_activity_button.set_enabled(false);
		return(right);
	}

	public void initialize() {
		base.initialize();
		add(new ActivityManagerMenubarBackgroundWidget());
		var hbox = BoxWidget.horizontal();
		hbox.set_margins(px("1mm"), px("1mm"), px("1mm"), px("1mm"));
		var left = BoxWidget.horizontal();
		left.set_spacing(px("1mm"));
		left.add(new MainMenuWidget().set_amgr(this));
		left.add(VSeparatorWidget.instance());
		if(enable_home_button) {
			left.add(FramelessButtonWidget.create(IconCache.get("home"), null).set_rounded(true).set_internal_margin("1mm").set_event("activities-home"));
		}
		left.add(activity_list = new ActivityListButtonWidget().set_amgr(ActivityManagerWidget.find(this)));
		hbox.add_box(1, left);
		var right = create_right_widget();
		if(right != null) {
			hbox.add_box(0, right);
		}
		add(hbox);
	}

	public void cleanup() {
		base.cleanup();
		close_activity_button = null;
		activity_list = null;
		clock = null;
	}

	public void on_narrowness_changed() {
		base.on_narrowness_changed();
		if(clock != null) {
			if(is_narrow()) {
				clock.set_narrow_mode(true);
				if(enable_clock_narrow == false) {
					clock.set_enabled(false);
				}
			}
			else {
				clock.set_enabled(true);
				clock.set_narrow_mode(false);
			}
		}
	}

	public void on_activity_list_request() {
		if(activity_list != null) {
			activity_list.show_popup(activity_list.get_popup_widget());
		}
	}

	public void on_active_activity_update(ActivityWidget active_activity) {
		if(close_activity_button != null) {
			if(active_activity == null) {
				close_activity_button.set_enabled(false);
			}
			else if(active_activity.get_maximized_mode() && active_activity.get_closable()) {
				close_activity_button.set_enabled(true);
			}
			else {
				close_activity_button.set_enabled(false);
			}
		}
		if(activity_list != null) {
			activity_list.on_active_activity(active_activity);
		}
	}
}
