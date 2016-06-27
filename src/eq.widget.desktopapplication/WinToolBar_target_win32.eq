
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

public class WinToolBar : ToolBarControl, Win32ToolBar
{
	public static WinToolBar for_frame(Frame frame) {
		return(new WinToolBar().set_frame(frame));
	}

	embed "c++" {{{
		#include <windows.h>
		#include <commctrl.h>
		#include <gdiplus.h>
		#include <d2d1.h>
		#include <wincodec.h>
	}}}

	property Frame frame;
	Collection toolbar_actions;
	ptr toolbar_hwnd;
	ptr imagelist_ptr;

	class ToolbarEventReceiver : EventReceiver
	{
		property ToolBarControlListener listener;

		public void on_event(Object o) {
			listener.on_toolbar_entry_selected(o as ActionItem);
		}
	}

	public void initialize_toolbar(ToolBar tb, ToolBarControlListener listener) {
		if(tb != null) {
			var frm = frame as Direct2DWindowFrame;
			if(frm == null) {
				return;
			}
			toolbar_actions = tb.get_items();
			if(toolbar_actions == null || toolbar_actions.count() < 1) {
				return;
			}
			destroy_toolbar();
			var hWnd = frm.get_window_handle();
			ptr tbhwnd;
			embed "c++" {{{
				tbhwnd = CreateWindowEx(0, TOOLBARCLASSNAME, NULL, WS_CHILD | CCS_NODIVIDER, 0, 0, 0, 0, hWnd, NULL, GetModuleHandle(NULL), NULL);
			}}}
			toolbar_hwnd = tbhwnd;
			create_toolbar();
			frm.set_actions_for_toolbar(toolbar_actions, new ToolbarEventReceiver().set_listener(listener));
			frm.set_windows_toolbar(this);
		}
	}

	public ptr get_toolbar_handle() {
		return(toolbar_hwnd);
	}

	void destroy_toolbar() {
		var tbhwnd = toolbar_hwnd;
		if(tbhwnd == null) {
			return;
		}
		ptr ilptr = imagelist_ptr;
		embed "c++" {{{
			DestroyWindow(tbhwnd);
			ImageList_Destroy(ilptr);
		}}}
	}

	void create_toolbar() {
		ptr tbhwnd = toolbar_hwnd;
		ptr ilptr;
		int count = 0;
		Collection items = toolbar_actions;
		if(items != null) {
			int numButtons = items.count();
			var frm = (Direct2DWindowFrame)frame;
			var hWnd = frm.get_window_handle();
			var sz = Length.to_pixels("5mm", frm.get_dpi());
			embed "c++" {{{
				ilptr = ImageList_Create(sz, sz, ILC_COLOR32 | ILC_MASK, 0, numButtons);
			}}}
			foreach(Object o in items) {
				ptr iicn;
				if(o is ActionItem) {
					var ai = (ActionItem)o;
					var icn = ai.get_icon();
					if(icn != null) {
						icn = icn.resize(-1, sz);
					}
					iicn = button_icon(icn);
					embed "c++" {{{
						ImageList_Add(ilptr, iicn, NULL);
						DeleteObject((HGDIOBJ)iicn);
					}}}
				}
			}
			embed "c++" {{{
				SendMessage(tbhwnd, TB_SETIMAGELIST, 0, (LPARAM)ilptr);
			}}}
			this.imagelist_ptr = ilptr;
			var sep_sz = Length.to_pixels("5mm", frm.get_dpi());
			var numicon = -1;
			foreach(Object o in items) {
				ActionItem ai;
				if(o is ActionItem) {
					 ai = (ActionItem)o;
					if(ai.get_icon() != null) {
						numicon++;
					}
				}
				if(ai != null) {
					var at = ai.get_text();
					strptr att;
					if(at != null) {
						att = at.to_strptr();
					}
					embed "c++" {{{
						TBBUTTON tbButtons[] =
						{
							{ numicon, count, TBSTATE_ENABLED, BTNS_BUTTON, {0}, 0, att },
						};
						SendMessage(tbhwnd, TB_ADDBUTTONS, (WPARAM)1, (LPARAM)&tbButtons);
					}}}
				}
				else if(o is SeparatorItem) {
					var sep = ((SeparatorItem)o).get_weight();
					embed "c++" {{{
						TBBUTTON tbButtons[] =
						{
							{ sep_sz, 0, TBSTATE_ENABLED, BTNS_SEP, {0}, 0, NULL },
						};
						SendMessage(tbhwnd, TB_ADDBUTTONS, (WPARAM)1, (LPARAM)&tbButtons);
					}}}
				}
				count++;
			}
			embed "c++" {{{
				SendMessage(tbhwnd, TB_AUTOSIZE, 0, 0);
				ShowWindow(tbhwnd, SW_SHOW);
 			}}}
		}
	}

	public void finalize() {
		destroy_toolbar();
	}

	ptr button_icon(Image icon) {
		var d2dimage = icon as Direct2DImage;
		if(d2dimage == null) {
			return(null);
		}
		var bmp = d2dimage.get_bitmapsource();
		if(bmp == null) {
			return(null);
		}
		int width = d2dimage.get_width(), height = d2dimage.get_height();
		int stride = width * 4;
		ptr v;
		embed {{{
			int sz = width*height*4;
			BYTE* data = new BYTE[sz];
			HRESULT hr = ((IWICBitmapSource*)bmp)->CopyPixels(0, stride, sz, data);
			if(SUCCEEDED(hr)) {
				Gdiplus::Bitmap* gb = new Gdiplus::Bitmap(width, height, stride, PixelFormat32bppARGB, data);
				if(gb != NULL) {
					HBITMAP hbm;
					gb->GetHBITMAP(NULL, &hbm);
					v = hbm;
				}
			}
		}}}
		return(v);
	}
}
