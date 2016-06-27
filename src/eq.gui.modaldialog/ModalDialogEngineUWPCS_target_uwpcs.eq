
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

public class ModalDialogEngineUWPCS : ModalDialogEngine
{
	void open_ok_message_dialog(strptr content, strptr title, ModalDialogListener listener) {
		if(content == null || title == null) {
			return;
		}
		embed {{{
			var md = new Windows.UI.Popups.MessageDialog(content, title);
			md.Commands.Add(new Windows.UI.Popups.UICommand("OK", (ui) => {
				if(listener != null) {
					listener.on_dialog_closed();
				}
			}));
			md.ShowAsync();
		}}}
	}

	void on_dialog_boolean_result(ModalDialogBooleanListener listener, bool res) {
		if(listener != null) {
			listener.on_dialog_boolean_result(res);
		}
	}

	void on_dialog_string_result(ModalDialogStringListener listener, String res) {
		if(listener != null) {
			listener.on_dialog_string_result(res);
		}
	}

	void open_boolean_message_dialog(strptr content, strptr title, ModalDialogBooleanListener listener, String p, String n) {
		if(content == null || title == null) {
			return;
		}
		embed {{{
			var md = new Windows.UI.Popups.MessageDialog(content, title);
			md.Commands.Add(new Windows.UI.Popups.UICommand(p.to_strptr(), (ui) => {
				on_dialog_boolean_result(listener, true);
			}));
			md.Commands.Add(new Windows.UI.Popups.UICommand(n.to_strptr(), (ui) => {
				on_dialog_boolean_result(listener, false);
			}));
			md.ShowAsync();			
		}}}
	}

	public void message(Frame frame, String text, String title, ModalDialogListener listener) {
		open_ok_message_dialog(String.as_strptr(text), String.as_strptr(title), listener);
	}

	public void error(Frame frame, String text, String title, ModalDialogListener listener) {
		open_ok_message_dialog(String.as_strptr(text), String.as_strptr(title), listener);
	}

	public void yesno(Frame frame, String text, String title, ModalDialogBooleanListener listener) {
		open_boolean_message_dialog(String.as_strptr(text), String.as_strptr(title), listener, "Yes", "No");
	}

	public void okcancel(Frame frame, String text, String title, ModalDialogBooleanListener listener) {
		open_boolean_message_dialog(String.as_strptr(text), String.as_strptr(title), listener, "OK", "Cancel");
	}

	public void textinput(Frame frame, String text, String title, String initial_value, ModalDialogStringListener listener) {
		var tiptr = String.as_strptr(title);
		var txptr = String.as_strptr(text);
		embed {{{
			var content = new Windows.UI.Xaml.Controls.StackPanel();
			var txt = new Windows.UI.Xaml.Controls.TextBox();
			content.Children.Add(new Windows.UI.Xaml.Controls.TextBlock() { Text = txptr });
			content.Children.Add(txt);
			var dialog = new Windows.UI.Xaml.Controls.ContentDialog();
			dialog.Title = tiptr;
			dialog.Content = content;
			dialog.PrimaryButtonText = "OK";
			var xf = eq.gui.sysdep.xamlcs.XamlPanelFrame.find_current_panel_frame();
			if(xf != null) {
				xf.disable_inputs();
			}
			dialog.PrimaryButtonClick += delegate {
				on_dialog_string_result(listener, eq.api.CString.for_strptr(txt.Text));
				if(xf != null) {
					xf.enable_inputs();
				}
			};
			dialog.SecondaryButtonText = "Cancel";
			dialog.SecondaryButtonClick += delegate {
				on_dialog_string_result(listener, null);
				if(xf != null) {
					xf.enable_inputs();
				}
			};
			dialog.ShowAsync();
		}}}
	}
}
