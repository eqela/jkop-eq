
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

public class Direct2DRenderableWindow
{
	embed {{{
		#include <windows.h>
		#include <windowsx.h>
		#include <d2d1.h>
		#include <stdio.h>
	}}}

	ptr handle = null;
	property bool input_disabled = false;
	property VgSurfaceList surfaces;
	FrameController controller;
	Direct2DCustomRenderer renderer;
	ptr d2dtarget;
	ptr d2dfactory;

	public static Direct2DRenderableWindow create(ptr phWnd, FrameController controller) {
		var v = new Direct2DRenderableWindow();
		v.controller = controller;
		if(v.initialize(phWnd) == false) {
			v = null;
		}
		return(v);
	}

	void event(Object e) {
		var c = controller;
		if(c != null) {
			c.on_event(e);
		}
	}

	public void on_mouse_down(int btn, int mouse_pos_x, int mouse_pos_y) {
		if(input_disabled) {
			return;
		}
		event(new PointerPressEvent().set_button(btn).set_x(mouse_pos_x)
			.set_y(mouse_pos_y).set_pointer_type(PointerEvent.MOUSE).set_id(0));
	}

	public void on_mouse_up(int btn, int mouse_pos_x, int mouse_pos_y) {
		if(input_disabled) {
			return;
		}
		event(new PointerReleaseEvent().set_button(btn).set_x(mouse_pos_x).set_y(mouse_pos_y)
			.set_pointer_type(PointerEvent.MOUSE).set_id(0));
	}

	public void on_mouse_move(int mouse_pos_x, int mouse_pos_y) {
		if(input_disabled) {
			return;
		}
		event(new PointerMoveEvent().set_x(mouse_pos_x).set_y(mouse_pos_y)
			.set_pointer_type(PointerEvent.MOUSE).set_id(0));
	}

	public Direct2DRenderableWindow set_renderer(Direct2DCustomRenderer renderer) {
		this.renderer = renderer;
		invalidate(0, 0, get_width(), get_height());
		return(this);
	}

	public ptr get_current_target() {
		return(d2dtarget);
	}

	private void recreate_target() {
		ptr d2dtarget = this.d2dtarget;
		ptr d2dfactory = Direct2DFactory.instance();
		var hWnd = handle;
		int width;
		int height;
		embed "c" {{{
			RECT rect;
			if(GetClientRect((HWND)hWnd, &rect)) {
				width = rect.right - rect.left;
				height = rect.bottom - rect.top;
			}
		}}}
		embed "c++" {{{
			if(d2dtarget!=NULL) {
				((ID2D1HwndRenderTarget*)d2dtarget)->Release();
				d2dtarget = NULL;
			}
			((ID2D1Factory*)d2dfactory)->CreateHwndRenderTarget(
				D2D1::RenderTargetProperties(D2D1_RENDER_TARGET_TYPE_DEFAULT, D2D1::PixelFormat(DXGI_FORMAT_UNKNOWN, D2D1_ALPHA_MODE_PREMULTIPLIED)),
				D2D1::HwndRenderTargetProperties((HWND)hWnd, D2D1::SizeU(width,height)),
				(ID2D1HwndRenderTarget**)&d2dtarget);
			((ID2D1RenderTarget*)d2dtarget)->SetDpi(96, 96);
		}}}
		this.d2dtarget = d2dtarget;
	}

	bool painted = false;
	public void erase_window() {
		if(painted == false && d2dtarget != null) {
			var d2dtarget = this.d2dtarget;
			embed "c++" {{{
				((ID2D1RenderTarget*)d2dtarget)->BeginDraw();
				((ID2D1RenderTarget*)d2dtarget)->SetTransform(D2D1::Matrix3x2F::Identity());
				((ID2D1RenderTarget*)d2dtarget)->Clear(D2D1::ColorF(D2D1::ColorF(0, 0.0f)));
				((ID2D1RenderTarget*)d2dtarget)->EndDraw();
			}}}
		}
	}

	public void paint_hdc(int rx, int ry, int rw, int rh) {
		painted = true;
		if(d2dtarget == null) {
			return;
		}
		ptr d2dtarget = this.d2dtarget;
		ptr d2dfactory = this.d2dfactory;
		embed "c++" {{{
			((ID2D1RenderTarget*)d2dtarget)->BeginDraw();
			((ID2D1RenderTarget*)d2dtarget)->SetTransform(D2D1::Matrix3x2F::Identity());
		}}}
		var crr = renderer;
		if(crr != null) {
			crr.render();
			invalidate(0,0, get_width(), get_height());
		}
		else {
			var ctx = Direct2DVgContext.create(d2dtarget, d2dfactory);
			if(ctx != null) {
				var rr = VgPathRectangle.create(rx,ry,rw,rh);
				ctx.clip(0, 0, rr, null);
				var clips = Stack.create();
				clips.push(rr);
				surfaces.draw(ctx, rx, ry, rw, rh, clips);
				ctx.clip_clear();
			}
		}
		bool recreate = false;
		int res;
		embed "c++" {{{
			HRESULT r = (int)((ID2D1RenderTarget*)d2dtarget)->EndDraw();
			if(r == D2DERR_RECREATE_TARGET) {
				recreate = 1;
			}
			res = (int)r;
		}}}
		if(recreate) {
			recreate_target();
		}
	}

	embed {{{
		LRESULT CALLBACK RenderableWndProcedure(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam) {
			int v = 0;
			void* ptr = (void*)GetProp(hWnd, "__eq_window");
			switch(Msg) {
				case WM_DESTROY:
					unref_eq_api_Object(ptr);
					SetProp((HWND)hWnd, "__eq_window", (void*)0);
					break;
				case WM_ERASEBKGND:
					eq_gui_sysdep_direct2d_Direct2DRenderableWindow_erase_window(ptr);
					v = 1;
					break;
				case WM_CREATE:
					ref_eq_api_Object((void*)((LPCREATESTRUCT)lParam)->lpCreateParams);
					SetProp((HWND)hWnd, "__eq_window", (void*)((LPCREATESTRUCT)lParam)->lpCreateParams);
					break;
				case WM_PAINT:
					if(ptr) {
						PAINTSTRUCT ps;
						HDC hdc = BeginPaint(hWnd, &ps);
						eq_gui_sysdep_direct2d_Direct2DRenderableWindow_paint_hdc(ptr, ps.rcPaint.left, ps.rcPaint.top,
							ps.rcPaint.right-ps.rcPaint.left, ps.rcPaint.bottom-ps.rcPaint.top);
						EndPaint(hWnd, &ps);
					}
					break;
				case WM_LBUTTONDOWN:
					if(ptr) {				
						POINTS pt = MAKEPOINTS(lParam);
						int xpos = pt.x;
						int ypos = pt.y;
						eq_gui_sysdep_direct2d_Direct2DRenderableWindow_on_mouse_down(ptr, 1, xpos, ypos);
					}
					break;
				case WM_LBUTTONUP:
					if(ptr) {
						POINTS pt = MAKEPOINTS(lParam);
						int xpos = pt.x;
						int ypos = pt.y;						
						eq_gui_sysdep_direct2d_Direct2DRenderableWindow_on_mouse_up(ptr, 1, xpos, ypos);
					}
					break;
				case WM_MBUTTONDOWN:
					if(ptr) {				
						POINTS pt = MAKEPOINTS(lParam);
						int xpos = pt.x;
						int ypos = pt.y;						
						eq_gui_sysdep_direct2d_Direct2DRenderableWindow_on_mouse_down(ptr, 2, xpos, ypos);
					}
					break;
				case WM_MBUTTONUP:
					if(ptr) {				
						POINTS pt = MAKEPOINTS(lParam);
						int xpos = pt.x;
						int ypos = pt.y;						
						eq_gui_sysdep_direct2d_Direct2DRenderableWindow_on_mouse_up(ptr, 2, xpos, ypos);
					}
					break;
				case WM_RBUTTONDOWN:
					if(ptr) {				
						POINTS pt = MAKEPOINTS(lParam);
						int xpos = pt.x;
						int ypos = pt.y;						
						eq_gui_sysdep_direct2d_Direct2DRenderableWindow_on_mouse_down(ptr, 3, xpos, ypos);
					}
					break;
				case WM_RBUTTONUP:
					if(ptr) {				
						POINTS pt = MAKEPOINTS(lParam);
						int xpos = pt.x;
						int ypos = pt.y;						
						eq_gui_sysdep_direct2d_Direct2DRenderableWindow_on_mouse_up(ptr, 3, xpos, ypos);
					}
					break;
				case WM_MOUSEMOVE:
					if(ptr) {				
						POINTS pt = MAKEPOINTS(lParam);
						int xpos = pt.x;
						int ypos = pt.y;
						eq_gui_sysdep_direct2d_Direct2DRenderableWindow_on_mouse_move(ptr, xpos, ypos);
					}
					break;
				default:
					v = DefWindowProc(hWnd, Msg, wParam, lParam);
					break;
			}
			return(v);
		}
	}}}

	bool initialize(ptr hWnd) {
		ptr handle = null;
		embed {{{
			WNDCLASSEX WndClsEx;
			WndClsEx.cbSize = sizeof(WNDCLASSEX);
			WndClsEx.lpfnWndProc = RenderableWndProcedure;
			WndClsEx.cbClsExtra = 0;
			WndClsEx.cbWndExtra = 0;
			WndClsEx.style = 0;
			WndClsEx.lpszClassName = "EqelaRenderer";
			WndClsEx.hIcon = LoadIcon(NULL, IDI_APPLICATION);
			WndClsEx.hCursor = LoadCursor(NULL, IDC_ARROW);
			WndClsEx.hbrBackground = 0;
			WndClsEx.lpszMenuName = NULL;
			WndClsEx.hInstance = GetModuleHandle(NULL);
			WndClsEx.hIconSm = LoadIcon(NULL, IDI_APPLICATION);
			RegisterClassEx(&WndClsEx);
			handle = (void*)CreateWindowEx(0, "EqelaRenderer", NULL, WS_CHILD | WS_CLIPSIBLINGS,
					0, 0, CW_USEDEFAULT, CW_USEDEFAULT,
					(HWND)hWnd, NULL, GetModuleHandle(NULL), self);
			ShowWindow((HWND)handle, SW_SHOWNORMAL);
			UpdateWindow((HWND)handle);
		}}}
		this.handle = handle;
		if(handle != 0) {
			recreate_target();
			return(true);
		}
		return(false);
	}

	public void set_cursor(Cursor cursor) {
		int hwnd = handle;
		int cid = Cursor.STOCK_DEFAULT;
		if(cursor != null) {
			cid = cursor.get_stock_cursor_id();
		}
		embed {{{
			HCURSOR hc;
			if(cid == eq_gui_Cursor_STOCK_DEFAULT) {
				hc = LoadCursor(NULL, IDC_ARROW);
			}
			else if(cid == eq_gui_Cursor_STOCK_NONE) {
				hc = NULL;
			}
			else if(cid == eq_gui_Cursor_STOCK_EDITTEXT) {
				hc = LoadCursor(NULL, IDC_IBEAM);
			}
			else if(cid == eq_gui_Cursor_STOCK_POINT) {
				hc = LoadCursor(NULL, IDC_HAND);
			}
			else if(cid == eq_gui_Cursor_STOCK_RESIZE_HORIZONTAL) {
				hc = LoadCursor(NULL, IDC_SIZENS);
			}
			else if(cid == eq_gui_Cursor_STOCK_RESIZE_VERTICAL) {
				hc = LoadCursor(NULL, IDC_SIZEWE);
			}
			else {
				hc = LoadCursor(NULL, IDC_ARROW);
			}
			SetCursor(hc);
		}}}
		IFDEF("target_win7m64") {
			embed {{{
				SetClassLong(hwnd, GCLP_HCURSOR, hc);
			}}}
		}
		ELSE {
			embed {{{
				SetClassLong(hwnd, GCL_HCURSOR, hc);
			}}}
		}
	}

	public void invalidate(int x, int y, int w, int h) {
		int hWnd = handle;
		embed "c" {{{
			RECT rect;
			rect.left = x;
			rect.top = y;
			rect.right = x + w;
			rect.bottom = y + h;
			InvalidateRect((HWND)hWnd, &rect, FALSE);
		}}}
	}

	public double get_width() {
		int v = 0;
		var hwnd = handle;
		embed {{{
			RECT r;
			GetClientRect((HWND)hwnd, &r);
			v = r.right-r.left;
		}}}
		return(v);
	}

	public int get_height() {
		int v = 0;
		var hwnd = handle;
		embed {{{
			RECT r;
			GetClientRect((HWND)hwnd, &r);
			v = r.bottom-r.top;
		}}}
		return(v);
	}

	public void move_resize(int x, int y, int width, int height) {
		var hwnd = handle;
		var d2dtarget = this.d2dtarget;
		if(d2dtarget != null) {
			embed "c++" {{{
				((ID2D1HwndRenderTarget*)d2dtarget)->Resize(D2D1::SizeU(width, height));
				MoveWindow(hwnd, x, y, width, height, FALSE);
			}}}
		}
		embed {{{
			InvalidateRect((HWND)hwnd, NULL, FALSE);
		}}}
		event(new FrameResizeEvent().set_width(width).set_height(height));
	}
}
