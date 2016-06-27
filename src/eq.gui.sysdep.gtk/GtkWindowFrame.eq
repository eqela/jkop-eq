
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

public class GtkWindowFrame : VgFrame, Frame, TitledFrame, ResizableFrame, HidableFrame, ClosableFrame,
      CursorFrame, DesktopWindowFrame, Size, SurfaceContainer, StrutsFrame, SizeConstrainedFrame
{
	embed "c" {{{
		#include <gtk/gtk.h>
		#include <gdk/gdk.h>
		#include <cairo.h>
		#include <gdk/gdkkeysyms.h>
	}}}

	public static int window_count = 0;

	FrameController controller;
	int dpi;
	int width;
	int height;
	ptr window;
	ptr menu_bar_container;
	ptr tool_bar_container;
	ptr menu_tool_bar_container;
	ptr drawing_area;
	ptr main_container;
	property int frametype = 0;
	bool size_set = false;
	property ptr surface;
	property ptr cr;
	VgSurfaceList surfaces;
	Array frame_children;
	GtkWindowFrame parent;
	Cursor current_cursor;

	public GtkWindowFrame() {
		surfaces = new VgSurfaceList();
		if("yes".equals(SystemEnvironment.get_env_var("EQ_WINDOW_MAXIMIZED"))) {
			set_frametype(CreateFrameOptions.TYPE_MAXIMIZED);
		}
	}

	public ~GtkWindowFrame() {
		destroy_surface();
	}

	public int get_frame_type() {
		return(Frame.TYPE_DESKTOP);
	}

	public bool has_keyboard() {
		return(true);
	}

	public int get_dpi() {
		return(dpi);
	}

	public Cursor get_current_cursor() {
		return(current_cursor);
	}

	public void set_current_cursor(Cursor cursor) {
		if(current_cursor == cursor) {
			return;
		}
		current_cursor = cursor;
		var window = this.window;
		int cid = Cursor.STOCK_DEFAULT;
		if(cursor != null) {
			cid = cursor.get_stock_cursor_id();
		}
		embed {{{
			GdkCursor* gc = NULL;
			if(cid == eq_gui_Cursor_STOCK_DEFAULT) {
				gc = gdk_cursor_new(GDK_LEFT_PTR);
			}
			else if(cid == eq_gui_Cursor_STOCK_NONE) {
				gc = gdk_cursor_new(GDK_BLANK_CURSOR);
			}
			else if(cid == eq_gui_Cursor_STOCK_EDITTEXT) {
				gc = gdk_cursor_new(GDK_XTERM);
			}
			else if(cid == eq_gui_Cursor_STOCK_POINT) {
				gc = gdk_cursor_new(GDK_HAND2);
			}
			else if(cid == eq_gui_Cursor_STOCK_RESIZE_HORIZONTAL) {
				gc = gdk_cursor_new(GDK_SB_H_DOUBLE_ARROW);
			}
			else if(cid == eq_gui_Cursor_STOCK_RESIZE_VERTICAL) {
				gc = gdk_cursor_new(GDK_SB_V_DOUBLE_ARROW);
			}
			else {
				gc = gdk_cursor_new(GDK_LEFT_PTR);
			}
			gdk_window_set_cursor(((GtkWidget*)window)->window, gc);
		}}}
	}

	public ptr get_gtk_window() {
		return(window);
	}

	public ptr get_menubar_container() {
		return(menu_bar_container);
	}

	public ptr get_toolbar_container() {
		return(tool_bar_container);
	}

	public void draw(ptr cr, int x, int y, int w, int h) {
		var context = new GtkVgContext().set_cr(cr);
		var rr = VgPathRectangle.create(x,y,w,h);
		context.clip(0, 0, rr, null);
		var clips = Stack.create();
		clips.push(rr);
		surfaces.draw(context, x, y, w, h, clips);
		context.clip_clear();
	}

	public void on_move(int x, int y) {
		var c = frame_children;
		if(c != null) {
			int mw = get_width(), mh = get_height();
			foreach(GtkWindowFrame gtkwin in c) {
				var cww = gtkwin.get_gtk_window();
				int cw = (int)gtkwin.get_width(), ch = (int)gtkwin.get_height();
				// FIXME: Probably we could rather do gtk_window_set_position(GTK_WIN_POS_CENTER_ON_PARENT)
				embed {{{
					gtk_window_move(GTK_WINDOW(cww), x+mw/2-cw/2, y+mh/2-ch/2);
				}}}
			}
		}
	}

	public void on_resize(int w, int h) {
		if(w == this.width && h == this.height) {
			return;
		}
		this.width = w;
		this.height = h;
		destroy_surface();
		event(new FrameResizeEvent().set_width(w).set_height(h));
	}

	public FrameController get_controller() {
		return(controller);
	}

	public void close() {
		var window = this.window;
		if(window == null) {
			return;
		}
		embed "c" {{{
			gtk_widget_destroy(GTK_WIDGET(window));
		}}}
		this.window = null;
	}

	void destroy_surface() {
		if(cr != null) {
			var cr = this.cr;
			embed "c" {{{
				cairo_destroy(cr);
			}}}
			this.cr = null;
		}
		if(surface != null) {
			var surface = this.surface;
			embed "c" {{{
				cairo_surface_destroy(surface);
			}}}
			this.surface = null;
		}
	}

	public void clear_container(ptr container) {
		embed "c" {{{
			GList *children, *iter;
			children = gtk_container_get_children(GTK_CONTAINER(container));
			if(children) {
				for(iter = children; iter != NULL; iter = g_list_next(children)) {
					gtk_widget_destroy(GTK_WIDGET(iter->data));
				}
				g_list_free(children);
			}
		}}}
	}

	public void destroy_window() {
		if(controller != null) {
			controller.stop();
			controller.destroy();
			controller = null;
		}
		ptr menu_bar_container = this.menu_bar_container;
		if(menu_bar_container != null) {
			clear_container(menu_bar_container);
			embed "c" {{{
				gtk_widget_destroy(GTK_WIDGET(menu_bar_container));
			}}}
			this.menu_bar_container = null;
		}
		ptr tool_bar_container = this.tool_bar_container;
		if(tool_bar_container != null) {
			clear_container(tool_bar_container);
			embed "c" {{{
				gtk_widget_destroy(GTK_WIDGET(tool_bar_container));
			}}}
			this.tool_bar_container = null;
		}
		ptr menu_tool_bar_container = this.menu_tool_bar_container;
		if(menu_tool_bar_container != null) {
			embed "c" {{{
				gtk_widget_destroy(GTK_WIDGET(menu_tool_bar_container));
			}}}
			this.menu_tool_bar_container = null;
		}
		ptr drawing_area = this.drawing_area;
		if(drawing_area != null) {
			embed "c" {{{
				gtk_widget_destroy(GTK_WIDGET(drawing_area));
			}}}
			this.drawing_area = null;
		}
		ptr main_container = this.main_container;
		if(main_container != null) {
			embed "c" {{{
				gtk_widget_destroy(GTK_WIDGET(main_container));
			}}}
			this.main_container = null;
		}
		if(parent != null) {
			parent.remove_frame_child(this);
		}
		frame_children = null;
		destroy_surface();
	}

	void add_frame_child(GtkWindowFrame child) {
		if(frame_children == null) {
			frame_children = Array.create();
		}
		frame_children.add(child);
	}

	void remove_frame_child(GtkWindowFrame child) {
		if(frame_children != null) {
			frame_children.remove(child);
		}
	}

	bool event(Object o) {
		bool v = false;
		if(controller != null && o != null) {
			v = controller.on_event(o);
		}
		return(v);
	}

	public bool on_delete_event() {
		var ce = new FrameCloseRequestEvent();
		event(ce);
		return(!ce.get_accepted());
	}

	public void on_leave_notify() {
		event(new PointerLeaveEvent().set_pointer_type(PointerEvent.MOUSE).set_id(0));
	}

	embed "c" {{{
		void on_destroy(GtkWidget *widget, gpointer data) {
			eq_gui_sysdep_gtk_GtkWindowFrame_destroy_window(data);
			eq_gui_sysdep_gtk_GtkWindowFrame_window_count --;
			if(eq_gui_sysdep_gtk_GtkWindowFrame_window_count < 1) {
				gtk_main_quit();
			}
		}

		void on_leave_notify_event(GtkWidget* widget, GdkEvent* event, gpointer user_data) {
			eq_gui_sysdep_gtk_GtkWindowFrame_on_leave_notify(user_data);
		}

		gboolean on_delete_event(GtkWidget *widget, GdkEvent* event, gpointer data) {
			return((gboolean)eq_gui_sysdep_gtk_GtkWindowFrame_on_delete_event(data));
		}
		 
		static gboolean on_expose_event(GtkWidget *widget, GdkEventExpose *event, gpointer data) {
			cairo_surface_t *surface = eq_gui_sysdep_gtk_GtkWindowFrame_get_surface(data);
			cairo_t *cr = eq_gui_sysdep_gtk_GtkWindowFrame_get_cr(data);
			cairo_t *ctx;
			int x ,y ,w, h;
			x = event->area.x;
			y = event->area.y;
			w = event->area.width;
			h = event->area.height;
			if(surface == NULL) {
				surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32,
					eq_gui_sysdep_gtk_GtkWindowFrame_get_width(data), eq_gui_sysdep_gtk_GtkWindowFrame_get_height(data));
				eq_gui_sysdep_gtk_GtkWindowFrame_set_surface(data, surface);
			}
			if(cr == NULL) {
				cr = cairo_create(surface);
				eq_gui_sysdep_gtk_GtkWindowFrame_set_cr(data, cr);
			}
			eq_gui_sysdep_gtk_GtkWindowFrame_draw(data, cr, x, y, w, h);
			ctx = gdk_cairo_create(widget->window);
			cairo_set_source_surface(ctx, surface, 0, 0);
			cairo_paint(ctx);
			cairo_destroy(ctx);
			return FALSE;
		}
		
		void on_configure_event(GtkWindow *window, GdkEvent *event, gpointer data) {
			int x, y;
			x = event->configure.x;
			y = event->configure.y;
			eq_gui_sysdep_gtk_GtkWindowFrame_on_move(data, x, y);
			int w, h;
			w = event->configure.width;
			h = event->configure.height;
			eq_gui_sysdep_gtk_GtkWindowFrame_on_resize(data, w, h);
		}
		
		void on_visible(GtkWindow *window, GdkEventVisibility *event, gpointer data) {
			gtk_widget_queue_draw(GTK_WIDGET(window));
		}

		void on_scroll_event(GtkWidget* widget, GdkEventScroll* event, gpointer data) {
			int dir = 0;
			if(event->direction == GDK_SCROLL_UP) {
				dir = 0;
			}
			else if(event->direction == GDK_SCROLL_DOWN) {
				dir = 1;
			}
			else if(event->direction == GDK_SCROLL_LEFT) {
				dir = 2;
			}
			else if(event->direction == GDK_SCROLL_RIGHT) {
				dir = 3;
			}
			int shift = 0;
			int ctrl = 0;
			if(event->state & GDK_SHIFT_MASK) {
				shift = 1;
			}
			if(event->state & GDK_CONTROL_MASK) {
				ctrl = 1;
			}
			eq_gui_sysdep_gtk_GtkWindowFrame_scroll_event(data, dir, (int)event->x, (int)event->y, (int)event->x_root, (int)event->y_root, (int)event->time, shift, ctrl);
		}
		
		void on_pointer(GtkWidget* widget, GdkEventButton * event, gpointer data) {
			int x, y, bt;
			if(event->type == GDK_BUTTON_PRESS) {
				bt = event->button;
				x = event->x;
				y = event->y;
				eq_gui_sysdep_gtk_GtkWindowFrame_pointer_press(data, bt, x, y);
			}
			if(event->type == GDK_BUTTON_RELEASE) {
				bt = event->button;
				x = event->x;
				y = event->y;
				eq_gui_sysdep_gtk_GtkWindowFrame_pointer_release(data, bt, x, y);
			}
			if(event->type == GDK_MOTION_NOTIFY) {
				x = event->x;
				y = event->y;
				eq_gui_sysdep_gtk_GtkWindowFrame_pointer_move(data, x, y);
			}
		}
		
		gboolean on_key(GtkWidget *widget, GdkEventKey *event, gpointer data) {
			int flag, keycode;
			if(event->type == GDK_KEY_PRESS) {
				keycode = event->keyval;
				flag = event->state;
				return(eq_gui_sysdep_gtk_GtkWindowFrame_key_press(data, keycode, flag));
			}
			if(event->type == GDK_KEY_RELEASE) {
				keycode = event->keyval;
				flag = event->state;
				return(eq_gui_sysdep_gtk_GtkWindowFrame_key_release(data, keycode, flag));
			}
			return(FALSE);
		}
	}}}

	public void scroll_event(int dir, int x, int y, int root_x, int root_y, int time, bool shift, bool ctrl) {
		if(ctrl) {
			var ev = new ZoomEvent();
			ev.set_x(x);
			ev.set_y(y);
			if(dir == 0 || dir == 2) {
				ev.set_dz(-1);
			}
			else {
				ev.set_dz(1);
			}
			event(ev);
		}
		else {
			var ev = new ScrollEvent();
			ev.set_x(x);
			ev.set_y(y);
			if(dir == 0) {
				ev.set_dx(0);
				ev.set_dy(32);
			}
			else if(dir == 1) {
				ev.set_dx(0);
				ev.set_dy(-32);
			}
			else if(dir == 2) {
				ev.set_dx(32);
				ev.set_dy(0);
			}
			else if(dir == 3) {
				ev.set_dx(-32);
				ev.set_dy(0);
			}
			event(ev);
		}
	}

	public void pointer_press(int btn, int mouse_pos_x, int mouse_pos_y) {
		event(new PointerPressEvent().set_button(btn).set_x(mouse_pos_x)
			.set_y(mouse_pos_y).set_pointer_type(PointerEvent.MOUSE).set_id(0));
	}

	public void pointer_move(int mouse_pos_x, int mouse_pos_y) {
		event(new PointerMoveEvent().set_x(mouse_pos_x).set_y(mouse_pos_y)
			.set_pointer_type(PointerEvent.MOUSE).set_id(0));
	}

	public void pointer_release(int btn, int mouse_pos_x, int mouse_pos_y) {
		event(new PointerReleaseEvent().set_button(btn).set_x(mouse_pos_x).set_y(mouse_pos_y)
			.set_pointer_type(PointerEvent.MOUSE).set_id(0));
	}

	embed {{{
		#ifndef GDK_MenuKB
		# define GDK_MenuKB 0x1008ff65
		#endif
		#ifndef GDK_MenuPB
		# define GDK_MenuPB 0x1008ff66
		#endif
	}}}

	public KeyEvent key_event(int keycode, int flag, KeyEvent ke) {
		int kstr;
		String keystr = null;
		strptr kname = null;
		embed "c" {{{
			kstr = gdk_keyval_to_unicode(keycode);
			if(keycode == GDK_Return || keycode == GDK_KP_Enter) {
				kname = "enter";
				kstr = 0;
			}
			else if(keycode == GDK_space) {
				kname = "space";
			}
			else if(keycode == GDK_Tab || keycode == GDK_ISO_Left_Tab) {
				kname = "tab";
				kstr = 0;
			}
			else if(keycode == GDK_Escape) {
				kname = "escape";
				kstr = 0;
			}
			else if(keycode == GDK_BackSpace) {
				kname = "backspace";
				kstr = 0;
			}
			else if(keycode == GDK_Caps_Lock) {
				kname = "capslock";
				kstr = 0;
			}
			else if(keycode == GDK_Num_Lock) {
				kname = "numlock";
				kstr = 0;
			}
			else if(keycode == GDK_Left) {
				kname = "left";
				kstr = 0;
			}
			else if(keycode == GDK_Up) {
				kname = "up";
				kstr = 0;
			}
			else if(keycode == GDK_Right) {
				kname = "right";
				kstr = 0;
			}
			else if(keycode == GDK_Down) {
				kname = "down";
				kstr = 0;
			}
			else if(keycode == GDK_Insert) {
				kname = "insert";
				kstr = 0;
			}
			else if(keycode == GDK_Delete) {
				kname = "delete";
				kstr = 0;
			}
			else if(keycode == GDK_Home) {
				kname = "home";
				kstr = 0;
			}
			else if(keycode == GDK_End) {
				kname = "end";
				kstr = 0;
			}
			else if(keycode == GDK_Page_Up) {
				kname = "pageup";
				kstr = 0;
			}
			else if(keycode == GDK_Page_Down) {
				kname = "pagedown";
				kstr = 0;
			}
			else if(keycode == GDK_F1) {
				kname = "f1";
				kstr = 0;
			}
			else if(keycode == GDK_F2) {
				kname = "f2";
				kstr = 0;
			}
			else if(keycode == GDK_F3) {
				kname = "f3";
				kstr = 0;
			}
			else if(keycode == GDK_F4) {
				kname = "f4";
				kstr = 0;
			}
			else if(keycode == GDK_F5) {
				kname = "f5";
				kstr = 0;
			}
			else if(keycode == GDK_F6) {
				kname = "f6";
				kstr = 0;
			}
			else if(keycode == GDK_F7) {
				kname = "f7";
				kstr = 0;
			}
			else if(keycode == GDK_F8) {
				kname = "f8";
				kstr = 0;
			}
			else if(keycode == GDK_F9) {
				kname = "f9";
				kstr = 0;
			}
			else if(keycode == GDK_F10) {
				kname = "f10";
				kstr = 0;
			}
			else if(keycode == GDK_F11) {
				kname = "f11";
				kstr = 0;
			}
			else if(keycode == GDK_F12) {
				kname = "f12";
				kstr = 0;
			}
			else if(keycode == GDK_Super_L) {
				kname = "super_left";
				kstr = 0;
			}
			else if(keycode == GDK_Super_R) {
				kname = "super_right";
				kstr = 0;
			}
			else if(keycode == GDK_Menu) {
				kname = "menu";
				kstr = 0;
			}
			else if(keycode == GDK_MenuKB) {
				kname = "menu_kb";
				kstr = 0;
			}
			else if(keycode == GDK_MenuPB) {
				kname = "menu_pb";
				kstr = 0;
			}
		}}}
		if(kstr != 0) {
			keystr = String.for_character(kstr);
		}
		bool shift = false;
		bool ctrl = false;
		bool alt = false;
		embed "c" {{{
			if(flag & GDK_SHIFT_MASK) {
				shift = 1;
			}
			if(flag & GDK_CONTROL_MASK) {
				ctrl = 1;
			}
			if(flag & GDK_MOD1_MASK) {
				alt = 1;
			}
		}}}
		var v = (KeyEvent)ke;
		if(kname != null || keystr != null) {
			v.set_name(String.for_strptr(kname));
			v.set_str(keystr);
			v.set_keycode(keycode);
			v.set_shift(shift);
			v.set_ctrl(ctrl);
			v.set_alt(alt);
		}
		else {
			v = null;
		}
		return(v);
	}

	public bool key_press(int keycode, int flag) {
		var v = key_event(keycode, flag, new KeyPressEvent());
		return(event(v));
	}

	public bool key_release(int keycode, int flag) {
		var v = key_event(keycode, flag, new KeyReleaseEvent());
		return(event(v));
	}

	public void initialize(FrameController wa, CreateFrameOptions aopts = null) {
		if(controller != null || wa == null) {
			return;
		}
		controller = wa;
		var opts = aopts;
		if(opts == null && controller != null) {
			opts = controller.get_frame_options();
		}
		if(opts == null) {
			opts = new CreateFrameOptions();
		}
		int screenindex = -1;
		var wmscreen = opts.get_screen() as GtkWindowManagerScreen;
		if(wmscreen != null) {
			screenindex = wmscreen.get_index();
		}
		frametype = opts.get_type();
		int dpi;
		int w,h;
		ptr window;
		ptr menu_bar_container;
		ptr tool_bar_container;
		ptr menu_tool_bar_container;
		ptr drawing_area;
		ptr main_container;
		Gtk.init();
		embed {{{
			GdkColor bg_color;
			GdkScreen *screen;
			GtkWidget *gtkwindow = gtk_window_new(GTK_WINDOW_TOPLEVEL);
			window = gtkwindow;
			gdk_color_parse ("#cccccc", &bg_color);
			gtk_widget_modify_bg(gtkwindow, GTK_STATE_NORMAL, &bg_color);
			menu_bar_container = gtk_vbox_new(FALSE, 0);
			tool_bar_container = gtk_vbox_new(FALSE, 0);
			menu_tool_bar_container = gtk_vbox_new(FALSE, 0);
			drawing_area = gtk_drawing_area_new();
			main_container = gtk_vbox_new(FALSE, 0);
			gtk_container_add(menu_tool_bar_container, menu_bar_container);
			gtk_container_add(menu_tool_bar_container, tool_bar_container);
			gtk_box_pack_start(main_container, menu_tool_bar_container, FALSE, FALSE, 0);
			gtk_container_add(main_container, drawing_area);
			gtk_container_add(GTK_CONTAINER(gtkwindow), main_container);
		}}}
		this.menu_bar_container = menu_bar_container;
		this.tool_bar_container = tool_bar_container;
		this.menu_tool_bar_container = menu_tool_bar_container;
		this.drawing_area = drawing_area;
		this.main_container = main_container;
		this.window = window;
		if(frametype == CreateFrameOptions.TYPE_DESKTOP) {
			var dt_win = this.window;
			embed "c" {{{
				gtk_window_set_type_hint(GTK_WINDOW(dt_win), GDK_WINDOW_TYPE_HINT_DESKTOP);
			}}}
		}
		else if(frametype == CreateFrameOptions.TYPE_INVISIBLE) {
			var inv_win = this.window;
			embed "c" {{{
				gtk_window_set_type_hint(GTK_WINDOW(inv_win), GDK_WINDOW_TYPE_HINT_DOCK);
				gtk_window_set_decorated(GTK_WINDOW(inv_win), FALSE);
			}}}
		}
		else if(frametype == CreateFrameOptions.TYPE_DOCK_BOTTOM ||
			frametype == CreateFrameOptions.TYPE_DOCK_TOP ||
			frametype == CreateFrameOptions.TYPE_DOCK_LEFT ||
			frametype == CreateFrameOptions.TYPE_DOCK_RIGHT) {
			var dock_win = this.window;
			embed "c" {{{
				gtk_window_set_type_hint(GTK_WINDOW(dock_win), GDK_WINDOW_TYPE_HINT_DOCK);
				gtk_window_set_decorated(GTK_WINDOW(dock_win), FALSE);
				gtk_window_stick(GTK_WINDOW(dock_win));
			}}}
		}
		else if(frametype == CreateFrameOptions.TYPE_MAXIMIZED) {
			var max_win = this.window;
			embed "c" {{{
				gtk_window_set_decorated(GTK_WINDOW(max_win), FALSE);
				gtk_window_maximize(GTK_WINDOW(max_win));
			}}}
		}
		else if(frametype == CreateFrameOptions.TYPE_FULLSCREEN) {
		}
		else if(frametype == CreateFrameOptions.TYPE_NORMAL) {
		}
		else if(frametype == CreateFrameOptions.TYPE_SPLASH) {
		}
		else {
			Log.error("Unknown window type encountered: %d".printf().add(frametype));
		}
		int width;
		int height;
		int width_mm;
		int height_mm;
		embed "c" {{{
			eq_gui_sysdep_gtk_GtkWindowFrame_window_count ++;
			gtk_window_set_title(GTK_WINDOW(gtkwindow), "Eqela Window");
			screen = gdk_screen_get_default();
			dpi = gdk_screen_get_resolution(screen);
			width = gdk_screen_get_width(screen);
			height = gdk_screen_get_height(screen);
			width_mm = gdk_screen_get_width_mm(screen);
			height_mm = gdk_screen_get_height_mm(screen);
			gtk_widget_add_events(drawing_area, GDK_ALL_EVENTS_MASK);
			gtk_widget_set_can_focus(drawing_area, TRUE);
			gtk_widget_grab_focus(drawing_area);
			g_signal_connect(drawing_area, "expose-event", G_CALLBACK(on_expose_event), self);
			g_signal_connect(gtkwindow, "scroll-event", G_CALLBACK(on_scroll_event), self);
			g_signal_connect(gtkwindow, "button-press-event", G_CALLBACK(on_pointer), self);
			g_signal_connect(gtkwindow, "button-release-event", G_CALLBACK(on_pointer), self);
			g_signal_connect(gtkwindow, "key-press-event", G_CALLBACK(on_key), self);
			g_signal_connect(gtkwindow, "key-release-event", G_CALLBACK(on_key), self);
			g_signal_connect(gtkwindow, "visibility-notify-event", G_CALLBACK(on_visible), self);
			g_signal_connect(gtkwindow, "motion-notify-event", G_CALLBACK(on_pointer), self);
			g_signal_connect(drawing_area, "configure-event", G_CALLBACK(on_configure_event), self);
			g_signal_connect(gtkwindow, "delete-event", G_CALLBACK(on_delete_event), self);
			g_signal_connect(gtkwindow, "destroy", G_CALLBACK(on_destroy), self);
			g_signal_connect(gtkwindow, "leave-notify-event", G_CALLBACK(on_leave_notify_event), self);
		}}}
		int dpi_computed = (int)(((double)height / (double)height_mm) * 25.4);
		Log.debug("Screen size from GDK: %dx%dpx (%dx%dmm); computed DPI: %d".printf().add(width).add(height)
			.add(width_mm).add(height_mm).add(dpi_computed));
		Log.debug("Screen resolution reported by GDK to be %d (ignoring it)".printf().add(Primitive.for_integer(dpi)));
		dpi = 0;
		var eqdpi = SystemEnvironment.get_env_var("EQ_DPI");
		if(String.is_empty(eqdpi) == false) {
			dpi = eqdpi.to_integer();
			Log.debug("DPI set to %d via environment variable EQ_DPI".printf().add(dpi));
		}
		if(dpi < 1) {
			if(width > 800) {
				dpi = 120;
			}
			else {
				dpi = 96;
			}
			dpi = dpi * 1.2;
			Log.debug("Forcing hard coded DPI of %d".printf().add(Primitive.for_integer(dpi)));
		}
		this.dpi = dpi;
		controller.initialize_frame(this);
		_minimum_size = opts.get_minimum_size();
		_maximum_size = opts.get_maximum_size();
		update_size_constraints();
		int rw = 0, rh = 0;
		var psz = opts.get_default_size();
		if(psz == null) {
			psz = controller.get_preferred_size();
		}
		if(psz != null) {
			rw = psz.get_width();
			rh = psz.get_height();
		}
		String screeninfo;
		if(screenindex < 0) {
			screeninfo = "default display";
		}
		else if(screenindex == 0) {
			screeninfo = "main display";
		}
		else {
			screeninfo = "on external display %d".printf().add(screenindex).to_string();
		}
		if(frametype == CreateFrameOptions.TYPE_DESKTOP) {
			embed "c" {{{
				gtk_window_set_default_size(GTK_WINDOW(gtkwindow), width, height);
			}}}
			size_set = true;
		}
		else if(frametype == CreateFrameOptions.TYPE_INVISIBLE) {
			embed "c" {{{
				gtk_window_set_default_size(GTK_WINDOW(gtkwindow), 0, 0);
			}}}
			size_set = true;
		}
		if(frametype == CreateFrameOptions.TYPE_FULLSCREEN) {
			Log.debug("Creating a full screen window on ".append(screeninfo));
			rw = width;
			rh = height;
			embed "c" {{{
				GdkRectangle dest;
				gdk_screen_get_monitor_geometry(screen, screenindex, &dest);
				gtk_window_move(GTK_WINDOW(gtkwindow), dest.x, dest.y);
				gtk_window_fullscreen(GTK_WINDOW(gtkwindow));
			}}}
		}
		else if(frametype == CreateFrameOptions.TYPE_SPLASH) {
			Log.debug("Creating a splash window on ".append(screeninfo));
			embed "c" {{{
				gtk_window_set_default_size(GTK_WINDOW(gtkwindow), rw, rh);
				GdkGeometry windowProperties;
				windowProperties.min_width = rw;
				windowProperties.min_height = rh;
				gtk_window_set_geometry_hints(GTK_WINDOW(gtkwindow), NULL, &windowProperties, GDK_HINT_MIN_SIZE);
				gtk_window_set_resizable(GTK_WINDOW(gtkwindow), FALSE);
				gtk_window_set_decorated(GTK_WINDOW(gtkwindow), FALSE);
				gtk_window_set_type_hint(GTK_WINDOW(gtkwindow), GDK_WINDOW_TYPE_HINT_SPLASHSCREEN);
				// FIXME: For some reason, the gtk_window_set_position doesn't work properly (the gravity
				// is not in the center of the window). So we center manually ..
				//gtk_window_set_position(GTK_WINDOW(gtkwindow), GTK_WIN_POS_CENTER_ALWAYS);
				gtk_window_move(GTK_WINDOW(gtkwindow), width/2-rw/2, height/2-rh/2);
			}}}
			size_set = true;
		}
		else if(opts != null && opts.get_parent() != null) {
			var pp = opts.get_parent() as GtkWindowFrame;
			if(pp != null) {
				int px, py, pw = (int)pp.get_width(), ph = (int)pp.get_height();
				pp.add_frame_child(this);
				this.parent = pp;
				var parent_gtkwin = pp.get_gtk_window();
				var child_gtkwin = this.window;
				embed "c" {{{
					gtk_window_get_position(GTK_WINDOW(parent_gtkwin), &px, &py);
					gtk_window_set_decorated(GTK_WINDOW(child_gtkwin), FALSE);
					gtk_window_set_modal(GTK_WINDOW(child_gtkwin), TRUE);
					gtk_window_set_transient_for(GTK_WINDOW(child_gtkwin), GTK_WINDOW(parent_gtkwin));
					// FIXME: Probably we could rather do gtk_window_set_position(GTK_WIN_POS_CENTER_ON_PARENT)
					gtk_window_move(GTK_WINDOW(child_gtkwin), px+pw/2-rw/2, py+ph/2-rh/2);
				}}}
			}
		}
		else {
			Log.debug("Creating a normal window on ".append(screeninfo));
			if(rw > 0 && rh > 0) {
				size_set = true;
			}
			else {
				rw = 0;
				rh = 0;
			}
			if(frametype == CreateFrameOptions.TYPE_DOCK_TOP || frametype == CreateFrameOptions.TYPE_DOCK_BOTTOM) {
				rw = width;
			}
			else if(frametype == CreateFrameOptions.TYPE_DOCK_LEFT || frametype == CreateFrameOptions.TYPE_DOCK_RIGHT) {
				rh = height;
			}
			embed "c" {{{
				gtk_window_set_default_size(GTK_WINDOW(gtkwindow), rw, rh);
			}}}
			if(opts.get_resizable() == false) {
				embed {{{
					GdkGeometry windowProperties;
					windowProperties.min_width = rw;
					windowProperties.min_height = rh;
					gtk_window_set_geometry_hints(GTK_WINDOW(gtkwindow), NULL, &windowProperties, GDK_HINT_MIN_SIZE);
					gtk_window_set_resizable(GTK_WINDOW(gtkwindow), FALSE);
				}}}
			}
		}
		embed "c" {{{
			gtk_window_get_size(GTK_WINDOW(gtkwindow), &w, &h);
			gtk_widget_set_app_paintable(gtkwindow, TRUE);
		}}}
		if(size_set == false) {
			resize(640, 480);
			size_set = true;
		}
		controller.start();
	}

	Size _minimum_size;
	Size _maximum_size;

	public void set_minimum_size(int w, int h) {
		if(w < 0 || h < 0) {
			_minimum_size = null;
		}
		else {
			_minimum_size = Size.instance(w,h);
		}
		update_size_constraints();
	}

	public void set_maximum_size(int w, int h) {
		if(w < 0 || h < 0) {
			_maximum_size = null;
		}
		else {
			_maximum_size = Size.instance(w,h);
		}
		update_size_constraints();
	}

	void update_size_constraints() {
		var gtkwindow = this.window;
		var minsz = _minimum_size;
		var maxsz = _maximum_size;
		if(minsz != null || maxsz != null) {
			int mask = 0;
			embed {{{
				GdkGeometry windowProperties;
			}}}
			if(minsz != null) {
				var mw = minsz.get_width(), mh = minsz.get_height();
				embed {{{
					windowProperties.min_width = mw;
					windowProperties.min_height = mh;
					mask |= GDK_HINT_MIN_SIZE;
				}}}
			}
			if(maxsz != null) {
				var mw = maxsz.get_width(), mh = maxsz.get_height();
				embed {{{
					windowProperties.max_width = mw;
					windowProperties.max_height = mh;
					mask |= GDK_HINT_MAX_SIZE;
				}}}
			}
			embed {{{
				gtk_window_set_geometry_hints(GTK_WINDOW(gtkwindow), NULL, &windowProperties, mask);
			}}}
		}
	}

	public double get_width() {
		return(width);
	}

	public double get_height() {
		return(height);
	}

	public void invalidate(int x, int y, int w, int h) {
		ptr drawing_area = this.drawing_area;
		if(drawing_area != null) {
			embed "c" {{{
				gtk_widget_queue_draw_area(drawing_area, x, y, w, h);
			}}}
		}
	}

	public void set_title(String atitle) {
		var title = atitle;
		if(title == null) {
			title = "";
		}
		var window = this.window;
		if(window == null) {
			return;
		}
		var tptr = title.to_strptr();
		embed "c" {{{
			gtk_window_set_title(GTK_WINDOW(window), tptr);
		}}}
	}

	public void set_icon(Image icon) {
		if(icon == null) {
			return;
		}
		var img = icon as GtkFileImage;
		if(img == null) {
			return;
		}
		var gdkpixbuf = img.get_gtk_image();
		if(gdkpixbuf == null) {
			Log.warning("GtkWindowFrame.set_icon: null GdkPixbuf");
			return;
		}
		var window = this.window;
		if(window != null) {
			embed "c" {{{
				gtk_window_set_icon(GTK_WINDOW(window), (GdkPixbuf*)gdkpixbuf);
			}}}
		}
	}

	public void set_struts(int left, int right, int top, int bottom) {
		var window = this.window;
		if(window == null) {
			return;
		}
		embed "c" {{{
			GdkAtom atom;
			long vals[4];
			vals[0] = left;
			vals[1] = right;
			vals[2] = top;
			vals[3] = bottom;
			atom = gdk_atom_intern("_NET_WM_STRUT", FALSE);
			gdk_property_change(gtk_widget_get_window(GTK_WIDGET(window)), atom,
				gdk_atom_intern("CARDINAL", FALSE), 32, GDK_PROP_MODE_REPLACE,
				(guchar*)vals, 4);
		}}}
	}

	public void resize(int w, int h) {
		if(frametype == CreateFrameOptions.TYPE_INVISIBLE) {
			return;
		}
		var window = this.window;
		if(window != null) {
			int xw, xh;
			int rw = w, rh = h;
			if(frametype == CreateFrameOptions.TYPE_DOCK_TOP || frametype == CreateFrameOptions.TYPE_DOCK_BOTTOM) {
				rw = width;
			}
			else if(frametype == CreateFrameOptions.TYPE_DOCK_LEFT || frametype == CreateFrameOptions.TYPE_DOCK_RIGHT) {
				rh = height;
			}
			embed "c" {{{
				gtk_window_resize(GTK_WINDOW(window), rw, rh);
				gtk_window_get_size(GTK_WINDOW(window),  &xw, &xh);
			}}}
			if(frametype == CreateFrameOptions.TYPE_DOCK_BOTTOM) {
				int th;
				embed "c" {{{
					th = gdk_screen_get_height(gdk_screen_get_default());
					gtk_window_move(GTK_WINDOW(window), 0, th-rh);
				}}}
			}
			else if(frametype == CreateFrameOptions.TYPE_DOCK_TOP) {
				embed "c" {{{
					gtk_window_move(GTK_WINDOW(window), 0, 0);
				}}}
			}
			else if(frametype == CreateFrameOptions.TYPE_DOCK_RIGHT) {
				int tw;
				embed "c" {{{
					tw = gdk_screen_get_width(gdk_screen_get_default());
					gtk_window_move(GTK_WINDOW(window), tw-rw, 0);
				}}}
			}
			else if(frametype == CreateFrameOptions.TYPE_DOCK_LEFT) {
				embed "c" {{{
					gtk_window_move(GTK_WINDOW(window), 0, 0);
				}}}
			}
		}
	}

	public void request_size(int w, int h) {
		if(size_set == false && w > 0 && h > 0) {
			resize(w, h);
			size_set = true;
		}
	}

	public void hide() {
		set_visible(false);
	}

	public void show() {
		set_visible(true);
	}

	void set_visible(bool state) {
		var window = this.window;
		if(window == null) {
			return;
		}
		if(state) {
			embed "c" {{{
				gtk_widget_show_all(GTK_WIDGET(window));
			}}}
		}
		else {
			embed "c" {{{
				gtk_widget_hide(GTK_WIDGET(window));
			}}}
		}
	}

	public VgSurface create_surface() {
		var v = new VgSurface();
		v.set_parent(this);
		return(v);
	}

	public Surface add_surface(SurfaceOptions opts) {
		if(opts == null) {
			return(null);
		}
		var v = create_surface();
		if(v == null) {
			return(null);
		}
		if(opts.get_placement() == SurfaceOptions.TOP) {
			return(surfaces.add_surface_top(v));
		}
		else if(opts.get_placement() == SurfaceOptions.BOTTOM) {
			return(surfaces.add_surface_bottom(v));
		}
		else if(opts.get_placement() == SurfaceOptions.ABOVE) {
			return(surfaces.add_surface_above(opts.get_relative() as VgSurface, v));
		}
		else if(opts.get_placement() == SurfaceOptions.BELOW) {
			return(surfaces.add_surface_below(opts.get_relative() as VgSurface, v));
		}
		else if(opts.get_placement() == SurfaceOptions.INSIDE) {
			return(surfaces.add_surface_inside(opts.get_relative() as VgSurface, v));
		}
		return(null);
	}

	public void remove_surface(Surface ss) {
		surfaces.remove_surface(ss as VgSurface);
	}
}
