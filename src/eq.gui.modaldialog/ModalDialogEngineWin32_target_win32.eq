
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

public class ModalDialogEngineWin32 : ModalDialogEngine
{
	embed "c++" {{{
		#include <windows.h>

		LRESULT CALLBACK CBTProc(INT code, WPARAM handle, LPARAM lparam) {
			if(code == HCBT_ACTIVATE) {
				RECT rp, rc;
				HWND child_window = (HWND)handle;
				HWND parent_window = GetParent(child_window);
				if((parent_window != NULL) && (child_window != NULL) && 
						(GetWindowRect(parent_window, &rp)) && 
						(GetWindowRect(child_window, &rc))) {
					POINT cp, sp;
					int w = rc.right - rc.left;
					int h = rc.bottom - rc.top;
					cp.x = rp.left + ((rp.right - rp.left) * 0.5);
					cp.y = rp.top + ((rp.bottom - rp.top) * 0.5);
					sp.x = (cp.x - (w * 0.5));
					sp.y = (cp.y - (h * 0.5));
					MoveWindow(child_window, sp.x, sp.y, w, h, FALSE);
				}
				HHOOK hook = (HHOOK)GetProp(parent_window, "__eq_dialog_hook");
				if(hook != NULL) {
					UnhookWindowsHookEx(hook);
					SetFocus(child_window);
					SetProp(parent_window, "__eq_dialog_hook", (void*)0);
				}
				return(TRUE);
			}
			return(FALSE);
		}

		INT CustomMessageBox(HWND hwnd, LPSTR text, LPSTR title, UINT type) {
			if(hwnd == NULL) {
				return(MessageBox(hwnd, text, title, type));
			}
			SetProp(hwnd, "__eq_dialog_hook", SetWindowsHookEx(WH_CBT, &CBTProc, 0, GetCurrentThreadId()));
			return(MessageBox(hwnd, text, title, type));
		}
	}}}

	class InputDialogReceiver : EventReceiver
	{
		property ModalDialogStringListener listener;

		public void on_event(Object o) {
			if(listener == null) {
				return;
			}
			var r = o as TextInputResult;
			if(r.get_status()) {
				listener.on_dialog_string_result(r.get_text());
			}
			else {
				listener.on_dialog_string_result(null);
			}
		}
	}

	public void on_ok_button_clicked(ModalDialogListener listener) {
		listener.on_dialog_closed();
	}

	public void on_yesno_okcancel_button_clicked(ModalDialogBooleanListener listener, bool response) {
		listener.on_dialog_boolean_result(response);
	}

	public void message(Frame frame, String text, String title, ModalDialogListener listener) {
		var textptr = text.to_strptr();
		var titleptr = title.to_strptr();
		ptr wh = null;
		var wf = frame as Direct2DWindowFrame;
		if(wf != null) {
			wh = wf.get_window_handle();
		}
		embed "c++" {{{
			int response = CustomMessageBox(
				(HWND)wh,
				textptr,
				titleptr,
				MB_ICONINFORMATION | MB_OK | MB_APPLMODAL
			);
			if(listener && response == IDOK) {
				eq_gui_modaldialog_ModalDialogEngineWin32_on_ok_button_clicked(self, listener);
			}
		}}}
	}

	public void error(Frame frame, String text, String title, ModalDialogListener listener) {
		var textptr = text.to_strptr();
		var titleptr = title.to_strptr();
		ptr wh = null;
		var wf = frame as Direct2DWindowFrame;
		if(wf != null) {
			wh = wf.get_window_handle();
		}
		embed "c++" {{{
			int response = CustomMessageBox(
				(HWND)wh,
				textptr,
				titleptr,
				MB_ICONERROR | MB_OK | MB_APPLMODAL
			);
			if(listener && response == IDOK) {
				eq_gui_modaldialog_ModalDialogEngineWin32_on_ok_button_clicked(self, listener);
			}
		}}}
	}

	public void yesno(Frame frame, String text, String title, ModalDialogBooleanListener listener) {
		var textptr = text.to_strptr();
		var titleptr = title.to_strptr();
		ptr wh = null;
		var wf = frame as Direct2DWindowFrame;
		if(wf != null) {
			wh = wf.get_window_handle();
		}
		embed "c++" {{{
			int response = CustomMessageBox(
				(HWND)wh,
				textptr,
				titleptr,
				MB_ICONQUESTION | MB_YESNO | MB_APPLMODAL
			);
			if(listener) {
				if(response == IDYES) {
					eq_gui_modaldialog_ModalDialogEngineWin32_on_yesno_okcancel_button_clicked(self, listener, TRUE);
				}
				else if(response == IDNO) {
					eq_gui_modaldialog_ModalDialogEngineWin32_on_yesno_okcancel_button_clicked(self, listener, FALSE);
				}
			}
		}}}
	}

	public void okcancel(Frame frame, String text, String title, ModalDialogBooleanListener listener) {
		var textptr = text.to_strptr();
		var titleptr = title.to_strptr();
		ptr wh = null;
		var wf = frame as Direct2DWindowFrame;
		if(wf != null) {
			wh = wf.get_window_handle();
		}
		embed "c++" {{{
			int response = CustomMessageBox(
				(HWND)wh,
				textptr,
				titleptr,
				MB_ICONQUESTION | MB_OKCANCEL | MB_APPLMODAL
			);
			if(listener) {
				if(response == IDOK) {
					eq_gui_modaldialog_ModalDialogEngineWin32_on_yesno_okcancel_button_clicked(self, listener, TRUE);
				}
				else if(response == IDCANCEL) {
					eq_gui_modaldialog_ModalDialogEngineWin32_on_yesno_okcancel_button_clicked(self, listener, FALSE);
				}
			}
		}}}
	}

	public void textinput(Frame frame, String text, String title, String initial_value, ModalDialogStringListener listener) {
		var result = new TextInputResult().set_text(initial_value);
		var event_listener = new InputDialogReceiver().set_listener(listener);
		var input_dialog = new TextInputDialogWidget()
			.set_prompt(text)
			.set_listener(event_listener);
		input_dialog.set_title(title);
		Frame.open_as_popup(WidgetEngine.for_widget(input_dialog), frame);
	}
}

