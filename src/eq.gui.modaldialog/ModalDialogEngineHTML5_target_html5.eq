
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

public class ModalDialogEngineHTML5 : ModalDialogEngine
{
	public void on_ok_button_clicked(ModalDialogListener listener) {
		listener.on_dialog_closed();
	}

	public void on_yesno_okcancel_button_clicked(ModalDialogBooleanListener listener, bool response) {
		listener.on_dialog_boolean_result(response);
	}

	public void on_input_submitted(ModalDialogStringListener listener, strptr inputted_text) {
		if(inputted_text == null) {
			listener.on_dialog_string_result(null);
			return;
		}
		listener.on_dialog_string_result(String.for_strptr(inputted_text).dup());
	}

	public void message(Frame frame, String text, String title, ModalDialogListener listener) {
		var textptr = String.as_strptr(text);
		var hm = frame as HTML5Frame;
		ptr parent = null;
		if(hm != null) {
			parent = ((HTML5Frame)hm).get_window();
		}
		if(parent == null) {
			embed "js" {{{
				window.alert(textptr);
			}}}
		}
		else {
			embed "js" {{{
				parent.alert(textptr);
			}}}
		}
		if(listener) {
			embed "js" {{{
				this.on_ok_button_clicked(listener);
			}}}
		}
	}

	public void error(Frame frame, String text, String title, ModalDialogListener listener) {
		var textptr = String.as_strptr(text);
		var hm = frame as HTML5Frame;
		ptr parent = null;
		if(hm != null) {
			parent = ((HTML5Frame)hm).get_window();
		}
		if(parent == null) {
			embed "js" {{{
				window.alert(textptr);
			}}}
		}
		else {
			embed "js" {{{
				parent.alert(textptr);
			}}}
		}
		if(listener) {
			embed "js" {{{
				this.on_ok_button_clicked(listener);
			}}}
		}
	}

	public void yesno(Frame frame, String text, String title, ModalDialogBooleanListener listener) {
		var textptr = String.as_strptr(text);
		var hm = frame as HTML5Frame;
		ptr parent = null;
		if(hm != null) {
			parent = ((HTML5Frame)hm).get_window();
		}
		bool result;
		if(parent == null) {
			embed "js" {{{
				result = window.confirm(textptr);
			}}}
		}
		else {
			embed "js" {{{
				result = parent.confirm(textptr);
			}}}
		}
		embed "js" {{{
			if(listener) {
				this.on_yesno_okcancel_button_clicked(listener, result);
			}
		}}}
	}

	public void okcancel(Frame frame, String text, String title, ModalDialogBooleanListener listener) {
		var textptr = String.as_strptr(text);
		var hm = frame as HTML5Frame;
		ptr parent = null;
		if(hm != null) {
			parent = ((HTML5Frame)hm).get_window();
		}
		bool result;
		if(parent == null) {
			embed "js" {{{
				result = window.confirm(textptr);
			}}}
		}
		else {
			embed "js" {{{
				result = parent.confirm(textptr);
			}}}
		}
		embed "js" {{{
			if(listener) {
				this.on_yesno_okcancel_button_clicked(listener, result);
			}
		}}}
	}

	public void textinput(Frame frame, String text, String title, String initial_value, ModalDialogStringListener listener) {
		var textptr = String.as_strptr(text);
		var init_val = String.as_strptr(initial_value);
		var hm = frame as HTML5Frame;
		ptr parent = null;
		var inputted_text = null;
		if(hm != null) {
			parent = ((HTML5Frame)hm).get_window();
		}
		if(parent == null) {
			embed "js" {{{
				inputted_text = window.prompt(textptr, init_val);
			}}}
		}
		else {
			embed "js" {{{
				inputted_text = parent.prompt(textptr, init_val);
			}}}
		}
		embed "js" {{{
			if(listener) {
				this.on_input_submitted(listener, inputted_text);
			}
		}}}
	}
}
