
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

public class MobileApplicationControllerWidget : LayerWidget, WidgetStack
{
	public static MobileApplicationControllerWidget for_first_screen(Widget widget, bool allow_native = true) {
		return(new MobileApplicationControllerWidget().set_allow_native_implementation(true).set_first_screen(widget));
	}

	public static MobileApplicationControllerWidget instance(bool allow_native = true) {
		return(new MobileApplicationControllerWidget().set_allow_native_implementation(true));
	}

	public static MobileApplicationControllerWidget find(Widget w) {
		var v = w;
		while(v != null) {
			if(v is MobileApplicationControllerWidget) {
				return((MobileApplicationControllerWidget)v);
			}
			v = v.get_parent() as Widget;
		}
		return(null);
	}

	public static int MENU_OVERLAY = 0;
	public static int MENU_DROPDOWN = 1;
	public static int MENU_POPUP = 2;

	property Color overlay_menu_background_color;
	property Color overlay_menu_foreground_color;
	property Image menu_image;
	property bool enable_back_button = true;
	property Color frame_background_color;
	property Color frame_foreground_color;
	property Color title_background_color;
	property Color title_foreground_color;
	property Font title_font;
	property int menu_type_preference = 0;
	property bool allow_native_implementation = true;
	property Widget first_screen;
	MobileApplicationControllerWidgetImplementation impl;

	public MobileApplicationControllerWidget() {
		overlay_menu_background_color = Color.instance("#000000CC");
		overlay_menu_foreground_color = Color.instance("white");
		menu_image = IconCache.get("appicon");
		title_background_color = Color.instance("#00000080");
		title_foreground_color = Color.instance("white");
		title_font = Theme.font().modify("bold 4mm");
		frame_background_color = Theme.get_base_color();
		frame_foreground_color = Theme.get_base_draw_color();
	}

	public void initialize() {
		base.initialize();
		set_size_request_override(px("75mm"), px("100mm"));
		impl = create_implementation();
		if(impl != null) {
			add(impl);
		}
		if(first_screen != null) {
			push_widget(first_screen);
		}
	}

	public void cleanup() {
		base.cleanup();
		impl = null;
	}

	public virtual MobileApplicationControllerWidgetImplementation create_implementation() {
		if(allow_native_implementation == false) {
			return(new MobileApplicationControllerWidgetImplementationGeneric());
		}
		IFDEF("target_android") {
			embed "java" {{{
				int currentapiVersion = android.os.Build.VERSION.SDK_INT;
				if(currentapiVersion >= android.os.Build.VERSION_CODES.ICE_CREAM_SANDWICH){
					eq.gui.sysdep.android.FrameActivity.get_instance().setTheme(android.R.style.Theme_Holo);
					return(new MobileApplicationControllerWidgetImplementationAndroid());
				}
			}}}
			return(new MobileApplicationControllerWidgetImplementationGeneric());
		}
		ELSE IFDEF("target_wp8") {
			// FIXME: Windows Phone 8 implementation
			return(new MobileApplicationControllerWidgetImplementationGeneric());
		}
		ELSE IFDEF("target_ios") {
			// FIXME: iOS implementation
			return(new MobileApplicationControllerWidgetImplementationGeneric());
		}
		ELSE {
			return(new MobileApplicationControllerWidgetImplementationGeneric());
		}
	}

	public void push_widget(Widget widget) {
		if(impl != null) {
			impl.push_widget(widget);
		}
	}

	public bool pop_widget() {
		if(impl != null) {
			return(impl.pop_widget());
		}
		return(false);
	}
}
