
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

public class Direct2DWindowFrame : VgFrame, Frame, TitledFrame, ResizableFrame, HidableFrame, ClosableFrame,
	CursorFrame, DesktopWindowFrame, Size, SurfaceContainer, SizeConstrainedFrame
{
	embed "c" {{{
		#include <stdio.h>
		#include <windows.h>
		#include <windowsx.h>
		#include <commctrl.h>
		#include <gdiplus.h>
		#include <d2d1.h>
		#include <wincodec.h>

		LRESULT CALLBACK WndProcedure(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam) {
			int v = 0;
			void* ptr = (void*)GetProp(hWnd, "__eq_window");
			switch(Msg) {
				case WM_GETMINMAXINFO:
					if(ptr != NULL) {
						MINMAXINFO* mmi = (MINMAXINFO*)lParam;
						if(mmi != NULL) {
							int minw = eq_gui_sysdep_direct2d_Direct2DWindowFrame_get_minimum_width(ptr);
							int minh = eq_gui_sysdep_direct2d_Direct2DWindowFrame_get_minimum_height(ptr);
							int maxw = eq_gui_sysdep_direct2d_Direct2DWindowFrame_get_maximum_width(ptr);
							int maxh = eq_gui_sysdep_direct2d_Direct2DWindowFrame_get_maximum_height(ptr);
							if(minw > 0 && minh > 0) {
								mmi->ptMinTrackSize.x = minw;
								mmi->ptMinTrackSize.y = minh;
							}
							if(maxw > 0 && maxh > 0) {
								mmi->ptMaxTrackSize.x = maxw;
								mmi->ptMaxTrackSize.y = maxh;
								mmi->ptMaxSize.x = maxw;
								mmi->ptMaxSize.y = maxh;
							}
						}
					}
					break;
				case WM_CLOSE:
					eq_gui_sysdep_direct2d_Direct2DWindowFrame_on_close_request(ptr);
					break;
				case WM_DESTROY:
					eq_gui_sysdep_direct2d_Direct2DWindowFrame_on_destroy(ptr);
					unref_eq_api_Object(ptr);
					SetProp((HWND)hWnd, "__eq_window", (void*)0);
					break;
				case WM_CREATE:
					ref_eq_api_Object((void*)((LPCREATESTRUCT)lParam)->lpCreateParams);
					eq_gui_sysdep_direct2d_Direct2DWindowFrame_on_create(((LPCREATESTRUCT)lParam)->lpCreateParams, (void*)hWnd);
					break;
				case WM_SIZE:
					if(ptr) {
						eq_gui_sysdep_direct2d_Direct2DWindowFrame_on_resize(ptr);
					}
					break;
				case WM_COMMAND:
					if(eq_gui_sysdep_direct2d_Direct2DWindowFrame_exists_in_menus(ptr, (void*)wParam)) {
						eq_gui_sysdep_direct2d_Direct2DWindowFrame_do_command(ptr, (void*)wParam);
					}
					else {
						eq_gui_sysdep_direct2d_Direct2DWindowFrame_do_action_for_action_index(ptr, (int)wParam);
					}
					break;
				case WM_MOUSEWHEEL:
					if(ptr) {
						eq_gui_sysdep_direct2d_Direct2DWindowFrame_on_mouse_wheel(ptr, GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam),
							0, GET_WHEEL_DELTA_WPARAM(wParam), GetAsyncKeyState(VK_CONTROL));
					}
					break;
				case WM_SYSKEYDOWN:
					if(ptr) {
						eq_gui_sysdep_direct2d_Direct2DWindowFrame_on_key_down(ptr, wParam);
					}
				break;
				case WM_KEYDOWN:
					if(ptr) {
						eq_gui_sysdep_direct2d_Direct2DWindowFrame_on_key_down(ptr, wParam);
					}
					break;
				case WM_KEYUP:
					if(ptr) {						
						eq_gui_sysdep_direct2d_Direct2DWindowFrame_on_key_up(ptr, wParam);
					}
					break;
				default:
					v = DefWindowProc(hWnd, Msg, wParam, lParam);
					break;
			}
			return(v);
		}
	}}}

	static int window_count = 0;

	property Direct2DWindowFrame parent_frame;
	Direct2DRenderableWindow render_window;
	FrameController controller;
	ptr handle = null;
	int dpi;
	int create_frame_type;
	bool size_set = false;
	ptr d2dtarget;
	ptr d2dfactory;
	VgSurfaceList surfaces;
	LinkedList frame_children;
	Cursor cursor;
	bool input_disabled;
	Collection menus;
	EventReceiver menulistener;
	Collection tb;
	EventReceiver tbeventreceiver;
	int offset_x;
	int offset_y;
	int width;
	int height;
	ptr hMenu;
	ptr hSubMenu;
	Direct2DCustomRenderer renderer;
	Win32ToolBar toolbar;
	Win32WindowManagerScreen my_screen;
	Size default_size;
	Size minimum_size;
	Size maximum_size;

	public Direct2DWindowFrame() {
		surfaces = new VgSurfaceList();
	}

	~Direct2DWindowFrame() {
		ptr d2dtarget = this.d2dtarget;
		embed "c++" {{{
			if(d2dtarget) {
				((ID2D1RenderTarget*)d2dtarget)->Release();
			}
		}}}
		this.d2dtarget = null;
		this.d2dfactory = null;
	}

	public int get_minimum_width() {
		if(minimum_size == null) {
			return(0);
		}
		return(minimum_size.get_width());
	}

	public int get_minimum_height() {
		if(minimum_size == null) {
			return(0);
		}
		return(minimum_size.get_height());
	}

	public int get_maximum_width() {
		if(maximum_size == null) {
			return(0);
		}
		return(maximum_size.get_width());
	}

	public int get_maximum_height() {
		if(maximum_size == null) {
			return(0);
		}
		return(maximum_size.get_height());
	}

	public int get_frame_type() {
		return(Frame.TYPE_DESKTOP);
	}

	public bool has_keyboard() {
		return(true);
	}

	public FrameController get_controller() {
		return(controller);
	}

	public ptr get_window_handle() {
		return(handle);
	}

	public int get_dpi() {
		return(dpi);
	}

	public Direct2DWindowFrame set_renderer(Direct2DCustomRenderer r) {
		if(render_window != null) {
			render_window.set_renderer(r);
		}
		return(this);
	}

	public ptr get_current_target() {
		if(render_window != null) {
			return(render_window.get_current_target());
		}
		return(null);
	}

	public bool get_input_disabled() {
		return(input_disabled);
	}

	public Direct2DWindowFrame set_input_disabled(bool v) {
		input_disabled = v;
		if(v == false && (frame_children != null && frame_children.count() > 0)) {
			input_disabled = true;
		}
		if(render_window != null) {
			render_window.set_input_disabled(input_disabled);
		}
		return(this);
	}

	public void on_destroy() {
		var c = controller;
		if(c != null) {
			c.stop();
			c.destroy();
			controller = null;
		}
		var pf = parent_frame;
		if(pf != null) {
			pf.remove_child_frame(this);
			pf.set_input_disabled(false);
		}
		set_current_cursor(null);
		var hm = hMenu;
		embed "c++" {{{
			DestroyMenu((HMENU)hm);
		}}}
		window_count --;
		if(window_count < 1) {
			embed {{{
				PostQuitMessage(0);
			}}}
		}
	}

	public void on_close_request() {
		if(input_disabled) {
			return;
		}
		var ce = new FrameCloseRequestEvent();
		event(ce);
		if(ce.get_accepted()) {
			close();
		}
	}

	void event(Object o) {
		var c = controller;
		if(c != null && o != null) {
			c.on_event(o);
		}
	}

	public void on_resize() {
		if(size_set == false || render_window == null) {
			return;
		}
		var hWnd = handle;
		int width, height;
		ptr d2dtarget = this.d2dtarget;
		embed "c" {{{
			RECT rect;
			if(GetClientRect((HWND)hWnd, &rect)) {
				width = rect.right - rect.left;
				height = rect.bottom - rect.top;
			}
		}}}
		if(width == this.width && height == this.height) {
			return;
		}
		if(create_frame_type == CreateFrameOptions.TYPE_SPLASH) {
			var mg = get_monitor_geometry();
			if(mg != null) {
				int monx = mg.get_x(), mony = mg.get_y(), monw = mg.get_width(), monh = mg.get_height();
				embed {{{
					MoveWindow((HWND)hWnd, monx + monw/2 - width/2, mony + monh/2 - height/2, width, height, FALSE);
				}}}
			}
		}
		int tbh = 0;
		if(toolbar != null) {
			var thwnd = toolbar.get_toolbar_handle();
			embed {{{
				if(thwnd) {
					if(GetClientRect((HWND)thwnd, &rect)) {
						tbh = rect.bottom - rect.top;
						MoveWindow((HWND)thwnd, 0, 0, width, tbh, FALSE);
					}
				}
			}}}
		}
		this.width = width;
		this.height = height;
		if(render_window != null) {
			render_window.move_resize(0, tbh, width, height-tbh);
		}
		update_children_position();
	}

	public void update_children_position() {
		var fc = frame_children;
		int width = get_window_width(), height = get_window_height();
		var hWnd = handle;
		if(fc != null) {
			foreach(Direct2DWindowFrame wf in fc) {
				var chwnd = wf.get_window_handle();
				int wfw = wf.get_window_width(), wfh = wf.get_window_height();
				int ox = offset_x, oy = offset_y;
				if(chwnd != null) {
					embed {{{
						RECT rect;
						if(GetWindowRect((HWND)hWnd, &rect)) {
							MoveWindow((HWND)chwnd, ox+rect.left+(width/2-wfw/2), oy+rect.top+(height/2-wfh/2), wfw, wfh, FALSE);
						}
					}}}
				}
			}
		}
	}

	void set_enable_top_window(bool v) {
		var fc = frame_children;
		if(fc == null) {
			return;
		}
		var next = fc.get(fc.count() - 1) as Direct2DWindowFrame;
		if(next != null) {
			var hwnd = next.get_window_handle();
			if(hwnd != null) {
				embed {{{
					EnableWindow((HWND)hwnd, v);
				}}}
			}
		}
	}

	public void set_windows_toolbar(Win32ToolBar toolbar) {
		this.toolbar = toolbar;
	}

	void add_child_frame(Direct2DWindowFrame wf) {
		if(frame_children == null) {
			frame_children = LinkedList.create();
		}
		var fc = frame_children;
		if(fc != null) {
			set_enable_top_window(false);
			fc.append(wf);
		}
	}

	void remove_child_frame(Direct2DWindowFrame wf) {
		var fc = frame_children;
		if(fc != null) {
			fc.remove(wf);
			set_enable_top_window(true);
		}
	}

	public KeyEvent on_key_event(int kcode, KeyEvent ev) {
		strptr kname =  null;
		int c;
		embed "c" {{{
			char result[3];
			byte ks[256];
			GetKeyboardState(ks);
			ks[VK_CONTROL] = 0;
			ks[VK_LCONTROL] = 0;
			ks[VK_RCONTROL] = 0;
			ks[VK_MENU] = 0;
			ks[VK_LMENU] = 0;
			ks[VK_RMENU] = 0;
			result[0] = 0;
			c = ToAscii(kcode, MapVirtualKey(kcode, MAPVK_VSC_TO_VK_EX), ks, (LPWORD)result, 0);
			if(c == 1) {
				c = result[0];
			}
		}}}
		embed "c" {{{
			switch((WPARAM)kcode) {
				case VK_SPACE:
					kname = (char*)"space";
					break;
				case VK_RETURN:
					kname = (char*)"enter";
					c = 0;
					break;
				case VK_TAB:
					kname = (char*)"tab";
					c = 0;
					break;
				case VK_ESCAPE:
					kname = (char*)"escape";
					c = 0;
					break;
				case VK_BACK:
					kname = (char*)"backspace";
					c = 0;
					break;
				case VK_CAPITAL:
					kname = (char*)"capslock";
					c = 0;
					break;
				case VK_NUMLOCK:
					kname = (char*)"numlock";
					c = 0;				
					break;
				case VK_LEFT:
					kname = (char*)"left";
					c = 0;
					break;
				case VK_UP:
					kname = (char*)"up";
					c = 0;
					break;
				case VK_RIGHT:
					kname = (char*)"right";
					c = 0;
					break;
				case VK_DOWN:
					kname = (char*)"down";
					c = 0;
					break;
				case VK_INSERT:
					kname = (char*)"insert";
					c = 0;
					break;
				case VK_DELETE:
					kname = (char*)"delete";
					c = 0;
					break;
				case VK_HOME:
					kname = (char*)"home";
					c = 0;
					break;
				case VK_END:
					kname = (char*)"end";
					c = 0;
					break;
				case VK_PRIOR:
					kname = (char*)"pageup";
					c = 0;
					break;
				case VK_NEXT:
					kname = (char*)"pagedown";
					c = 0;
					break;
				case VK_F1:
					kname = (char*)"f1";
					c = 0;
					break;
				case VK_F2:
					kname = (char*)"f2";
					c = 0;
					break;
				case VK_F3:
					kname = (char*)"f3";
					c = 0;
					break;	
				case VK_F4:
					kname = (char*)"f4";
					c = 0;
					break;
				case VK_F5:
					kname = (char*)"f5";
					c = 0;
					break;
				case VK_F6:
					kname = (char*)"f6";
					c = 0;
					break;
				case VK_F7:
					kname = (char*)"f7";
					c = 0;
					break;
				case VK_F8:
					kname = (char*)"f8";
					c = 0;
					break;
				case VK_F9:
					kname = (char*)"f9";
					c = 0;
					break;
				case VK_F10:
					kname = (char*)"f10";
					c = 0;
					break;
				case VK_F11:
					kname = (char*)"f11";
					c = 0;
					break;
				case VK_F12:
					kname = (char*)"f12";
					c = 0;
					break;
			}
		}}}
		String kstr;
		if(c > 0) {
			kstr = String.for_character(c);
		}
		if(kstr == null && kname == null) {
			return(null);
		}
		ev.set_name(String.for_strptr(kname));
		ev.set_str(kstr);
		ev.set_keycode(kcode);
		bool shift = false;
		bool alt = false;
		bool ctrl = false;
		bool altgr = false;
		embed "c" {{{
			if(GetKeyState(VK_LSHIFT) & 0x80 || GetKeyState(VK_RSHIFT) & 0x80 ) {
				shift = 1;
			}
			if(GetKeyState(VK_LMENU) & 0x80 || GetKeyState(VK_RMENU) & 0x80) {
				alt = 1;
			}
			if(GetKeyState(VK_LCONTROL) & 0x80 || GetKeyState(VK_RCONTROL) & 0x80) {
				ctrl = 1;
			}
			altgr = (GetKeyState(VK_LCONTROL) & 0x80) != 0 && (GetKeyState(VK_RMENU) & 0x80) != 0;
		}}}
		if(altgr && "2".equals(ev.get_str())) {
			ev.set_str("@");
		}
		else if(altgr && "7".equals(ev.get_str())) {
			ev.set_str("{");
		}
		else if(altgr && "8".equals(ev.get_str())) {
			ev.set_str("[");
		}
		else if(altgr && "9".equals(ev.get_str())) {
			ev.set_str("]");
		}
		else if(altgr && "0".equals(ev.get_str())) {
			ev.set_str("}");
		}
		else {
			ev.set_alt(alt);
			ev.set_ctrl(ctrl);
		}
		ev.set_shift(shift);
		ev.set_keycode(kcode);
		ev.set_command(false); // FIXME: Is it possible to detect this (if running Windows on a Mac)?
		return(ev);
	}

	public void on_mouse_wheel(int ax, int ay, int dx, int dy, int ctrlb) {
		int x, y;
		var hWnd = handle;
		embed "c" {{{
			POINT orig;
			orig.x = (LONG)ax;
			orig.y = (LONG)ay;
			ScreenToClient((HWND)hWnd, &orig);
			x = (int)orig.x;
			y = (int)orig.y;
		}}}
		if(ctrlb & 0x8000 != 0) {
			var ev = new ZoomEvent();
			ev.set_x(x);
			ev.set_y(y);
			if(dx > 0 || dy > 0) {
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
			ev.set_dx(0);
			ev.set_dy(0);
			if(dy > 0) {
				ev.set_dy(32);
			}
			else if(dy < 0) {
				ev.set_dy(-32);
			}
			if(dx > 0) {
				ev.set_dx(32);
			}
			else if(dx < 0) {
				ev.set_dx(-32);
			}
			event(ev);
		}
	}

	public void on_key_down(int kcode) {
		if(input_disabled) {
			return;
		}
		var v = new KeyPressEvent();
		v = (KeyPressEvent)on_key_event(kcode, v);
		if(v != null && v.get_ctrl() && menus != null) {
			if(perform_shortcut(v)) {
				return;
			}
		}
		event(v);
	}

	bool perform_shortcut(KeyEvent e) {
		foreach(Menu mm in menus) {
			foreach(ActionItem ai in mm.get_items()) {
				var s = ai.get_shortcut();
				if(String.is_empty(s)) {
					continue;
				}
				if(e.is_shortcut(s)) {
					if(ai.execute() == false) {
						var evt = ai.get_event();
						var receiver = menulistener;
						if(evt != null && receiver != null) {
							receiver.on_event(evt);
						}
					}
					return(true);
				}
			}
		}
		return(false);
	}

	public void on_key_up(int kcode) {
		if(input_disabled) {
			return;
		}
		var v = new KeyReleaseEvent();
		v = (KeyReleaseEvent)on_key_event(kcode, v);
		event(v);
	}

	public void on_create(ptr hWnd) {
		window_count ++;
		var c = controller;
		if(c == null) {
			return;
		}
		this.handle = hWnd;
		int width, height;
		int width_mm = 0;
		int height_mm = 0;
		int width_px = 0;
		int height_px = 0;
		int dpix = 0;
		int dpiy = 0;
		embed "c" {{{
			HDC hdc = GetDC(NULL);
			if(hdc) {
				width_mm = GetDeviceCaps(hdc, HORZSIZE);
				height_mm = GetDeviceCaps(hdc, VERTSIZE);
				width_px = GetDeviceCaps(hdc, HORZRES);
				height_px = GetDeviceCaps(hdc, VERTRES);
				dpix = GetDeviceCaps(hdc, LOGPIXELSX);
				dpiy = GetDeviceCaps(hdc, LOGPIXELSY);
				ReleaseDC(NULL, hdc);
			}
			RECT rect;
			if(GetClientRect((HWND)hWnd, &rect)) {
				width = rect.right - rect.left;
				height = rect.bottom - rect.top;
			}
		}}}
		Log.debug("Screen DPI reported by Windows is %dx%d".printf().add(Primitive.for_integer(dpix)).add(Primitive.for_integer(dpiy)));
		Log.debug("Screen size reported by Windows is %dx%d mm (%dx%d px)".printf().add(Primitive.for_integer(width_mm))
			.add(Primitive.for_integer(height_mm))
			.add(Primitive.for_integer(width_px)).add(Primitive.for_integer(height_px)));
		this.dpi = 0;
		var eqdpi = SystemEnvironment.get_env_var("EQ_DPI");
		if(String.is_empty(eqdpi) == false) {
			this.dpi = eqdpi.to_integer();
			Log.debug("DPI set to %d via environment variable EQ_DPI".printf().add(this.dpi));
		}
		if(this.dpi < 1) {
			if(dpix <= 120) {
				if(width_px <= 800) {
					this.dpi = 96;
				}
				else {
					this.dpi = 120;
				}
			}
			else if(dpix <= 144) {
				this.dpi = 160;
			}
			else {
				this.dpi = 240;
			}
			this.dpi = this.dpi * 1.2;
			Log.debug("Based on %d, configuring DPI as %d".printf().add(dpix).add(this.dpi));
		}
		Log.debug("DPI determined to be %d".printf().add(this.dpi));
		controller.initialize_frame(this);
		int rw = 0, rh = 0;
		var psz = default_size;;
		if(psz == null) {
			psz = controller.get_preferred_size();
		}
		if(psz != null) {
			rw = psz.get_width();
			rh = psz.get_height();
		}
		if(create_frame_type == CreateFrameOptions.TYPE_FULLSCREEN) {
			size_set = true;
		}
		else if(rw > 0 && rh > 0) {
			resize(rw, rh);
			size_set = true;
		}
		if(size_set == false) {
			resize(640, 480);
			size_set = true;
		}
		controller.start();
	}

	public void set_minimum_size(int w, int h) {
		minimum_size = Size.instance(w,h);
	}

	public void set_maximum_size(int w, int h) {
		maximum_size = Size.instance(w,h);
	}

	Rectangle get_monitor_geometry() {
		ptr hmonitor = null;
		if(my_screen != null) {
			hmonitor = my_screen.get_monitor();
		}
		int x, y, w, h;
		embed {{{
			HMONITOR hmon = NULL;
			if(hmonitor == NULL) {
				HWND pp = FindWindow(NULL, NULL);
				hmon = MonitorFromWindow(pp, MONITOR_DEFAULTTONEAREST);
			}
			else {
				hmon = (HMONITOR)hmonitor;
			}
			MONITORINFO mi;
			mi.cbSize = sizeof(mi);
			if(!GetMonitorInfo((HMONITOR)hmon, &mi)) {
				mi.rcMonitor.left = 0;
				mi.rcMonitor.top = 0;
				mi.rcMonitor.right = 1024;
				mi.rcMonitor.bottom = 768;
			}
			x = mi.rcMonitor.left;
			y = mi.rcMonitor.top;
			w = mi.rcMonitor.right - mi.rcMonitor.left;
			h = mi.rcMonitor.bottom - mi.rcMonitor.top;
		}}}
		return(Rectangle.instance(x, y, w, h));
	}

	public bool initialize(FrameController wa, CreateFrameOptions aopts = null) {
		if(controller != null || wa == null) {
			return(false);
		}
		controller = wa;
		var opts = aopts;
		if(opts == null && controller != null) {
			opts = controller.get_frame_options();
		}
		if(opts == null) {
			opts = new CreateFrameOptions();
		}
		create_frame_type = opts.get_type();
		if(create_frame_type == CreateFrameOptions.TYPE_DESKTOP) {
			Log.error("Desktop windows are not supported on Windows. Creating a normal window instead.");
			create_frame_type = CreateFrameOptions.TYPE_NORMAL;
		}
		if(create_frame_type == CreateFrameOptions.TYPE_FULLSCREEN) {
		}
		else if(create_frame_type == CreateFrameOptions.TYPE_NORMAL) {
		}
		else if(create_frame_type == CreateFrameOptions.TYPE_SPLASH) {
		}
		else {
			Log.error("Unknown frame type encountered: %d. Creating a normal window instead.".printf().add(create_frame_type));
			create_frame_type = CreateFrameOptions.TYPE_NORMAL;
		}
		var minsz = opts.get_minimum_size();
		if(minsz != null) {
			set_minimum_size(minsz.get_width(), minsz.get_height());
		}
		var maxsz = opts.get_maximum_size();
		if(maxsz != null) {
			set_maximum_size(maxsz.get_width(), maxsz.get_height());
		}
		my_screen = opts.get_screen() as Win32WindowManagerScreen;
		ptr phwnd = null;
		if(opts!=null && opts.get_parent() !=null) {
			var parent = opts.get_parent() as Direct2DWindowFrame;
			if(parent!=null) {
				var pp = parent;
				while(pp != null) {
					var px = pp.get_parent_frame() as Direct2DWindowFrame;
					if(px != null) {
						pp = px;
						continue;
					}
					break;
				}
				phwnd = pp.get_window_handle();
				parent_frame = pp;
				parent_frame.add_child_frame(this);
			}
		}
		int oy, ox;
		ptr hWnd;
		var frametype = create_frame_type;
		var type_fullscreen = CreateFrameOptions.TYPE_FULLSCREEN;
		var type_splash = CreateFrameOptions.TYPE_SPLASH;
		int monx = 0, mony = 0, monw = 1024, monh = 768;
		var mg = get_monitor_geometry();
		if(mg != null) {
			monx = mg.get_x();
			mony = mg.get_y();
			monw = mg.get_width();
			monh = mg.get_height();
		}
		var resizable = opts.get_resizable();
		embed "c" {{{
			WNDCLASSEX WndClsEx;
			WndClsEx.cbSize = sizeof(WNDCLASSEX);
			WndClsEx.style = 0;
			WndClsEx.lpfnWndProc = WndProcedure;
			WndClsEx.cbClsExtra = 0;
			WndClsEx.cbWndExtra = 0;
			WndClsEx.hIcon = LoadIcon(NULL, IDI_APPLICATION);
			WndClsEx.hCursor = LoadCursor(NULL, IDC_ARROW);
			WndClsEx.hbrBackground = NULL;
			WndClsEx.lpszMenuName = NULL;
			WndClsEx.lpszClassName = "EqelaApplication";
			WndClsEx.hInstance = GetModuleHandle(NULL);
			WndClsEx.hIconSm = LoadIcon(NULL, IDI_APPLICATION);
			RegisterClassEx(&WndClsEx);
			if(frametype == type_fullscreen) {
				hWnd = (void*)CreateWindow("EqelaApplication", "Eqela Window", WS_POPUP | WS_CLIPCHILDREN,
					monx, mony, monw, monh,
					phwnd, NULL, GetModuleHandle(NULL), self);
			}
			else if(frametype == type_splash) {
				hWnd = (void*)CreateWindow("EqelaApplication", "Eqela Window", WS_POPUP | WS_CLIPCHILDREN | WS_EX_TOPMOST,
					monx, mony, CW_USEDEFAULT, CW_USEDEFAULT,
					phwnd, NULL, GetModuleHandle(NULL), self);
			}
			else {
				int mask = WS_OVERLAPPEDWINDOW | WS_CLIPCHILDREN;
				if(resizable == 0) {
					mask = WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX | WS_CLIPCHILDREN;
				}
				hWnd = (void*)CreateWindow("EqelaApplication", "Eqela Window", mask,
					monx, mony, CW_USEDEFAULT, CW_USEDEFAULT,
					phwnd, NULL, GetModuleHandle(NULL), self);
				oy = GetSystemMetrics(SM_CYCAPTION)+GetSystemMetrics(SM_CYFRAME);
				ox = GetSystemMetrics(SM_CXFRAME);
			}
		}}}
		if(hWnd == null) {
			Log.error("Unknown error in creating window. (1)");
			return(false);
		}
		embed "c" {{{
			SetProp((HWND)hWnd, "__eq_window", (HANDLE)self);
		}}}
		render_window = Direct2DRenderableWindow.create(hWnd, controller);
		if(render_window == null) {
			Log.error("Unknown error in creating window. (2)");
			return(false);
		}
		render_window.set_surfaces(surfaces);
		on_resize();
		if(parent_frame != null) {
			int prw = 640, prh = 480;
			var ps = opts.get_default_size();
			if(ps == null) {
				ps = controller.get_preferred_size();
			}
			default_size = ps;
			if(ps != null) {
				prw = ps.get_width();
				prh = ps.get_height();
			}
			int pw = parent_frame.get_window_width(), ph = parent_frame.get_window_height();
			if(prw > pw && pw > 0) {
				prw = pw;
			}
			if(prh > ph && ph > 0) {
				prh = ph;
			}
			embed {{{
				HWND pphwnd = (HWND)phwnd;
				RECT rect;
				GetWindowRect(pphwnd, &rect);
				if(GetWindowLongPtr(pphwnd, GWL_STYLE) & WS_POPUP) {
					ox = 0;
					oy = 0;
				}
				SetWindowLongPtr((HWND)hWnd, GWL_STYLE, WS_POPUP);
				SetWindowPos((HWND)hWnd, HWND_TOP, ox+rect.left+(pw/2-prw/2), oy+rect.top+(ph/2-prh/2), prw, prh, 0);
				ShowWindow((HWND)hWnd, SW_SHOW);
				UpdateWindow((HWND)hWnd);
			}}}
			this.width = prw;
			this.height = prh;
			parent_frame.set_input_disabled(true);
		}
		offset_x = ox;
		offset_y = oy;
		if(parent_frame == null) {
			embed "c" {{{
				ShowWindow((HWND)hWnd, SW_SHOW);
				UpdateWindow((HWND)hWnd);
			}}}
		}
		return(true);
	}

	bool exists_in_menus(ptr wparam) {
		if(menus != null) {
			foreach(Menu m in menus) {
				foreach(ActionItem ai in m.get_items()) {
					if(wparam == ai) {
						return(true);
					}
				}
			}
		}
		return(false);
	}

	public void set_menus(Collection menus, EventReceiver evr) {
		this.menus = menus;
		this.menulistener = evr;
		update_menubar();
	}

	public void do_command(ActionItem ai) {
		if(ai != null) {
			if(ai.execute()) {
				return;
			}
			if(menulistener != null) {
				var ee = ai.get_event();
				if(ee != null) {
					menulistener.on_event(ee);
					return;
				}
			}
		}
	}

	public void set_actions_for_toolbar(Collection items, EventReceiver e) {
		if(items != null) {
			tb = items;
			tbeventreceiver = e;
		}
	}

	public void do_action_for_action_index(int i) {
		if(tb != null && i > -1 && i < tb.count()) {
			var action = tb.get_index(i) as ActionItem;
			if(action != null) {
				var exe = action.get_action();
				if(exe != null) {
					exe.execute();
					return;
				}
				else {
					if(tbeventreceiver != null) {
						var evt = action.get_event();
						if(evt != null) {
							tbeventreceiver.on_event(action);
							return;
						}
					}
				}
			}
		}
	}

	void update_menubar() {
		Iterator mt;
		var hm = hMenu, hsm = hSubMenu;
		if(hMenu == null && hSubMenu == null) {
			embed "c++" {{{
				hm = (void*)CreateMenu();
			}}}
		}
		if(menus != null) {
			mt = menus.iterate();
			Menu mm;
			while((mm = mt.next() as Menu) != null) {
				var et = mm.get_title();
				embed "c++" {{{
					hsm = (void*)CreatePopupMenu();
				}}}
				if(String.is_empty(et)) {
					et = Application.get_display_name();
				}
				foreach(Object o in mm.get_items()) {
					if(o is ActionItem) {
						var ai = (ActionItem)o;
						var at = ai.get_text();
						var sh = ai.get_shortcut();
						var exe = ai.get_action();
						if(String.is_empty(at) == false) {
							if(String.is_empty(sh) == false) {
								at = at.append("\tCtrl+%s".printf().add(sh).to_string());
							}
							var att = at.to_strptr();
							embed "c++" {{{
								AppendMenu((HMENU)hsm, MF_STRING, (UINT_PTR)ai, att);
							}}}
						}
					}
					else {
						if(o is SeparatorItem) {
							embed "c++" {{{
								AppendMenu((HMENU)hsm, MF_SEPARATOR, 0, 0);
							}}}
						}
					}
				}
				var etptr = et.to_strptr();
				embed "c++" {{{
					AppendMenu((HMENU)hm, MF_STRING | MF_POPUP, (UINT_PTR)hsm, etptr);
				}}}
			}
			if(hm != null) {
				var hwnd = handle;
				embed "c++" {{{
					SetMenu((HWND)hwnd, (HMENU)hm);
				}}}
			}
		}
	}

	public double get_window_width() {
		return(width);
	}

	public double get_window_height() {
		return(height);
	}

	public double get_width() {
		if(render_window != null) {
			return(render_window.get_width());
		}
		return(0);
	}

	public double get_height() {
		if(render_window != null) {
			return(render_window.get_height());
		}
		return(0);
	}

	public void set_title(String title) {
		strptr tt;
		if(title != null) {
			tt = title.to_strptr();
		}
		var hWnd = handle;
		embed "c" {{{
			if(tt == NULL) {
				tt = (char*)"";
			}
			SetWindowText((HWND)hWnd, (LPCTSTR)tt);
		}}}
	}

	bool icon_set;

	public void set_icon(Image icon) {
		if(icon_set) {
			return;
		}
		var d2dimage = icon as Direct2DImage;
		if(d2dimage == null) {
			return;
		}
		var bmp = d2dimage.get_bitmapsource();
		if(bmp == null) {
			return;
		}
		var hWnd = handle;
		int width = d2dimage.get_width(), height = d2dimage.get_height();
		int stride = width * 4;
		int res;
		embed {{{
			int sz = width*height*4;
			BYTE* data = new BYTE[sz];
			HRESULT hr = ((IWICBitmapSource*)bmp)->CopyPixels(0, stride, sz, data);
			res = (int)hr;
			if(SUCCEEDED(hr)) {
				Gdiplus::Bitmap* gb = new Gdiplus::Bitmap(width, height, stride, PixelFormat32bppARGB, data);
				if(gb != NULL) {
					HICON hbm;
					gb->GetHICON(&hbm);
					SendMessage((HWND)hWnd, (UINT)WM_SETICON, (WPARAM)ICON_BIG, (LPARAM)hbm);
					SendMessage((HWND)hWnd, (UINT)WM_SETICON, (WPARAM)ICON_SMALL, (LPARAM)hbm);
					DeleteObject((HGDIOBJ)hbm);
					delete(gb);
				}
			}
			delete[] data;
		}}}
		icon_set = true;
	}

	public void request_size(int w, int h) {
		if(size_set == false && w > 0 && h > 0) {
			resize(w, h);
			size_set = true;
		}
	}

	public void resize(int w, int h) {
		var hWnd = handle;
		embed "c" {{{
			RECT rect;
			RECT crect;
			GetWindowRect((HWND)hWnd, &rect);
			GetClientRect((HWND)hWnd, &crect);
			int diffx = (rect.right - rect.left) - crect.right;
			int diffy = (rect.bottom - rect.top) - crect.bottom;
			MoveWindow((HWND)hWnd, rect.left, rect.top, w+diffx, h+diffy, TRUE);
		}}}
	}

	public void close() {
		var hWnd = handle;
		embed "c" {{{
			DestroyWindow((HWND)hWnd);
		}}}
	}

	public void show() {
		set_visible(true);
	}

	public void hide() {
		set_visible(false);
	}

	public void set_visible(bool state) {
		var hWnd = handle;
		if(state) {
			embed "c" {{{
				ShowWindow((HWND)hWnd, SW_SHOW);
				SetForegroundWindow((HWND)hWnd);
			}}}
		}
		else {
			embed "c" {{{
				ShowWindow((HWND)hWnd, SW_HIDE);
			}}}
		}
	}

	public Cursor get_current_cursor() {
		return(cursor);
	}

	public void set_current_cursor(Cursor cursor) {
		if(this.cursor == cursor) {
			return;
		}
		if(render_window != null) {
			render_window.set_cursor(cursor);
		}
		this.cursor = cursor;
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

	public void invalidate(int x, int y, int w, int h) {
		if(render_window != null) {
			render_window.invalidate(x, y, w, h);
		}
	}
}
