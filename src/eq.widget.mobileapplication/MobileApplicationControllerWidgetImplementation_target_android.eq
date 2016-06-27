
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

public class MobileApplicationControllerWidgetImplementationAndroid : LayerWidget,
	EventReceiver, MobileApplicationControllerWidgetImplementation
{
	Color background_color;
	Image background_image;
	String background_image_mode;
	ChangerWidget background_color_container;
	ChangerWidget background_image_container;
	StackChangerWidget main_changer;

	public MobileApplicationControllerWidgetImplementationAndroid() {
		background_image_mode = "fill";
	}

	public void initialize() {
		base.initialize();
		var maw = MobileApplicationControllerWidget.find(this);
		if(maw == null) {
			return;
		}
		set_background_color(maw.get_frame_background_color());
		set_draw_color(maw.get_frame_foreground_color());
		add(background_image_container = ChangerWidget.instance());
		background_image_container.add_changer(ImageWidget.for_image(background_image).set_mode(background_image_mode), true, ChangerWidget.EFFECT_NONE);
		add(background_color_container = ChangerWidget.instance());
		background_color_container.add_changer(CanvasWidget.for_color(background_color), true, ChangerWidget.EFFECT_NONE);
		var vbox = BoxWidget.vertical();
		vbox.add_box(1, main_changer = StackChangerWidget.instance());
		add(vbox);
	}

	void create_title_widget(MobileApplicationScreenWidget asw) {
		embed "java" {{{
			android.app.Activity activity = eq.gui.sysdep.android.FrameActivity.get_instance();
			android.app.ActionBar action_bar = activity.getActionBar();
		}}}
		Image img;
		String ts;
		Collection mis;
		if(asw != null) {
			var tt = asw.get_mobile_app_title();
			img = tt as Image;
			ts = String.as_string(tt);
			mis = asw.get_mobile_app_menu_items();
		}
		if(ts == null && img == null) {
			embed {{{
				action_bar.hide();
			}}}
			return;
		}
		// title image
		if(img != null) {
			AndroidBitmapImage abi = img as AndroidBitmapImage;
			if(abi != null) {
				embed "java" {{{
					android.graphics.drawable.BitmapDrawable drawable = new android.graphics.drawable.BitmapDrawable(eq.api.Android.context.getResources(), abi.get_android_bitmap());
					if(drawable != null && action_bar != null) {
						action_bar.setDisplayShowHomeEnabled(true);
						action_bar.setIcon(drawable);
						action_bar.setDisplayShowTitleEnabled(false);
					}
				}}}
			}
		}
		// title label
		else {
			if(String.is_empty(ts)) {
				ts = Application.get_display_name();
			}
			embed "java" {{{
				if(action_bar != null) {
					action_bar.setDisplayShowTitleEnabled(true);
					activity.setTitle(ts.to_strptr());
					action_bar.setDisplayShowHomeEnabled(false);
				}
			}}}
		}
		create_title_menu();
		embed {{{
			action_bar.show();
		}}}
	}

	Collection menu_items;

	void create_title_menu() {
		var screen = get_current_screen_widget();
		if(screen == null) {
			return;
		}
		menu_items = screen.get_mobile_app_menu_items();
		var mtp = MobileApplicationControllerWidget.MENU_DROPDOWN;
		var maw = MobileApplicationControllerWidget.find(this);
		if(maw != null) {
			mtp = maw.get_menu_type_preference();
		}
		if(mtp == MobileApplicationControllerWidget.MENU_DROPDOWN) {
			create_dropdown_menu_widget(menu_items);
		}
		else if(mtp == MobileApplicationControllerWidget.MENU_POPUP) {
			// FIXME! Must be a POPUP menu
			create_dropdown_menu_widget(menu_items);
		}
		else { // overlay
			// FIXME! Must be a OVERLAY menu
			create_dropdown_menu_widget(menu_items);
		}
	}

	public void cleanup() {
		base.cleanup();
		background_image_container = null;
		background_color_container = null;
		main_changer = null;
	}

	public void set_foreground_color(Color c) {
		set_draw_color(c);
	}

	public bool go_back() {
		if(main_changer.count() > 1) {
			return(pop_widget());
		}
		var pp = get_parent() as Widget;
		if(pp != null) {
			return(pp.widget_stack_pop());
		}
		return(false);
	}

	public bool on_key_press(KeyEvent e) {
		if("escape".equals(e.get_name()) || "back".equals(e.get_name())) {
			if(go_back()) {
				return(true);
			}
		}
		return(base.on_key_press(e));
	}

	public virtual void create_overlay_menu_widget(Collection items) {
	}

	embed "java" {{{
		private class DropdownMenuFragment extends android.app.Fragment {

			public DropdownMenuFragment(java.util.ArrayList<eq.gui.ActionItem> items) {
				this.items = items;
			}

			private java.util.ArrayList<eq.gui.ActionItem> items;

			public void setItems(java.util.ArrayList<eq.gui.ActionItem> items) {
				this.items = items;
			}

			public void onCreate(android.os.Bundle savedInstanceState) {
				super.onCreate(savedInstanceState);
				setHasOptionsMenu(true);
			}

			public void onCreateOptionsMenu(android.view.Menu menu, android.view.MenuInflater inflater) {
				menu.clear();
				int counter = 0;
				for(eq.gui.ActionItem aitem : items) {
					eq.api.String text = aitem.get_text();
					eq.gui.Image img = aitem.get_icon();
					android.view.MenuItem mitem = null;
					if(text != null) {
						mitem = menu.add(0, counter, 0, text.to_strptr());
						mitem.setShowAsAction(android.view.MenuItem.SHOW_AS_ACTION_NEVER);
					}
					// FIXME! Use custom view to show icon and text?
					counter++;
				}
			}

			public boolean onOptionsItemSelected(android.view.MenuItem item) {
				on_item_clicked(item.getItemId());
				return(true);
			}
		}

		private void showOverflowMenu() {
			try {
				android.view.ViewConfiguration config = android.view.ViewConfiguration.get(eq.api.Android.context);
				java.lang.reflect.Field menuKeyField = android.view.ViewConfiguration.class.getDeclaredField("sHasPermanentMenuKey");
				if(menuKeyField != null) {
					menuKeyField.setAccessible(true);
					menuKeyField.setBoolean(config, false);
				}
			} catch(java.lang.Exception e) {
			}
		}
	}}}

	void create_dropdown_menu_widget(Collection items) {
		embed "java" {{{
			showOverflowMenu();
			java.util.ArrayList<eq.gui.ActionItem> list = new java.util.ArrayList<eq.gui.ActionItem>();
		}}}
		foreach(ActionItem item in items) {
			embed "java" {{{
				list.add(item);
			}}}
		}
		embed "java" {{{
			android.app.Activity activity = eq.gui.sysdep.android.FrameActivity.get_instance();
			android.app.FragmentManager fragmentManager = activity.getFragmentManager();
			android.app.Fragment fragment = fragmentManager.findFragmentByTag("dfragment");
			if(fragment == null) {
				android.app.FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
				fragmentTransaction.add(new DropdownMenuFragment(list), "dfragment");
				fragmentTransaction.commit();
			}
			else {
				DropdownMenuFragment dfragment = (DropdownMenuFragment)fragment;
				dfragment.setItems(list);
				activity.invalidateOptionsMenu();
			}
		}}}
	}

	void on_item_clicked(int pos) {
		if(Collection.is_empty(menu_items)) {
			return;
		}
		var action_item = menu_items.get(pos) as ActionItem;
		if(action_item == null) {
			return;
		}
		if(action_item.execute()) {
			return;
		}
		var eee = action_item.get_event();
		if(eee != null) {
			var screen = get_current_screen_widget();
			if(screen != null) {
				screen.raise_event(eee);
			}
		}
	}

	public void on_event(Object o) {
		if("previous".equals(o)) {
			go_back();
			return;
		}
		forward_event(o);
	}

	public MobileApplicationScreenWidget get_current_screen_widget() {
		if(main_changer == null) {
			return(null);
		}
		return(main_changer.get_active_widget() as MobileApplicationScreenWidget);
	}

	void on_widget_changed() {
		Collection toolbar_items;
		var asw = get_current_screen_widget();
		create_title_widget(asw);
	}

	public void push_widget(Widget widget) {
		if(main_changer != null) {
			var ef = ChangerWidget.EFFECT_SCROLL_LEFT;
			if(main_changer.count() < 1) {
				ef = ChangerWidget.EFFECT_NONE;
			}
			main_changer.push_widget(widget, ef);
			on_widget_changed();
		}
	}

	public bool pop_widget() {
		var v = false;
		if(main_changer != null && main_changer.count() > 1) {
			v = main_changer.pop_widget(ChangerWidget.EFFECT_SCROLL_RIGHT);
			on_widget_changed();
		}
		return(v);
	}

	public void set_background_color(Color color) {
		background_color = color;
		if(background_color_container != null) {
			background_color_container.replace_with(CanvasWidget.for_color(color), ChangerWidget.EFFECT_CROSSFADE);
		}
	}

	public void set_background_image(Image image, String mode = null) {
		background_image = image;
		if(mode != null) {
			background_image_mode = mode;
		}
		if(background_image_container != null) {
			background_image_container.replace_with(ImageWidget.for_image(background_image).set_mode(background_image_mode), ChangerWidget.EFFECT_CROSSFADE);
		}
	}

	public StackChangerWidget get_main_changer() {
		return(main_changer);
	}
}
