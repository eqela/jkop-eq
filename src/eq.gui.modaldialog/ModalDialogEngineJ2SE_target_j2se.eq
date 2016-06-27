
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

public class ModalDialogEngineJ2SE : ModalDialogEngine
{
	embed {{{
		public java.awt.Window get_java_window(eq.gui.Frame frame) {
			java.awt.Window jwindow = null;
			if(frame != null && frame instanceof eq.gui.sysdep.swing.SwingFrame) {
				jwindow = ((eq.gui.sysdep.swing.SwingFrame)frame).get_java_window();
			}
			return(jwindow);
		}
	}}}

	void open_message_dialog(int type, Frame frame, String text, String title, ModalDialogListener listener) {
		var jtext = String.as_strptr(text);
		var jtitle = String.as_strptr(title);
		embed {{{
			javax.swing.JOptionPane.showMessageDialog(get_java_window(frame), jtext, jtitle, type);
			if(listener != null) {
				listener.on_dialog_closed();
			}
		}}}
	}

	public void message(Frame frame, String text, String title, ModalDialogListener listener) {
		embed {{{
			open_message_dialog(javax.swing.JOptionPane.INFORMATION_MESSAGE, frame, text, title, listener);
		}}}
	}

	public void error(Frame frame, String text, String title, ModalDialogListener listener) {
		embed {{{
			open_message_dialog(javax.swing.JOptionPane.ERROR_MESSAGE, frame, text, title, listener);
		}}}
	}

	public void yesno(Frame frame, String text, String title, ModalDialogBooleanListener listener) {
		var jtext = String.as_strptr(text);
		var jtitle = String.as_strptr(title);
		embed {{{
			int choice = javax.swing.JOptionPane.showConfirmDialog(get_java_window(frame), jtext, jtitle, javax.swing.JOptionPane.YES_NO_OPTION);
			if(listener != null) {
				if(choice == javax.swing.JOptionPane.YES_OPTION) {
					listener.on_dialog_boolean_result(true);
				}
				if(choice == javax.swing.JOptionPane.NO_OPTION) {
					listener.on_dialog_boolean_result(false);
				}
			}
		}}}
	}

	public void okcancel(Frame frame, String text, String title, ModalDialogBooleanListener listener) {
		var jtext = String.as_strptr(text);
		var jtitle = String.as_strptr(title);
		embed {{{
			int choice = javax.swing.JOptionPane.showConfirmDialog(get_java_window(frame), jtext, jtitle, javax.swing.JOptionPane.OK_CANCEL_OPTION);
			if(listener != null) {
				if(choice == javax.swing.JOptionPane.OK_OPTION) {
					listener.on_dialog_boolean_result(true);
				}
				if(choice == javax.swing.JOptionPane.CANCEL_OPTION) {
					listener.on_dialog_boolean_result(false);
				}
			}
		}}}
	}

	public void textinput(Frame frame, String text, String title, String initial_value, ModalDialogStringListener listener) {
		var jtext = String.as_strptr(text);
		var jtitle = String.as_strptr(title);
		var jinitial = String.as_strptr(initial_value);
		embed {{{
			java.lang.String result = (java.lang.String)javax.swing.JOptionPane.showInputDialog(get_java_window(frame), jtext, jtitle, javax.swing.JOptionPane.INFORMATION_MESSAGE, null, null, jinitial);
			if(listener != null) {
				if(result != null) {
					listener.on_dialog_string_result(_S(result));
				}
				else {
					listener.on_dialog_string_result(null);
				}
			}
		}}}
	}
}
