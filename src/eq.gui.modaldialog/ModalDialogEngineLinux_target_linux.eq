
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

class ModalDialogEngineLinux : ModalDialogEngine
{
	embed "c" {{{
		#include <gtk/gtk.h>
	}}}

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
		listener.on_dialog_string_result(String.for_strptr(inputted_text));
	}

	public void message(Frame frame, String text, String title, ModalDialogListener listener) {
		var text_ptr = String.as_strptr(text);
		var title_ptr = String.as_strptr(title);
		var mw = frame as GtkWindowFrame;
		ptr gtk_window = null;
		if(mw != null) {
			gtk_window = mw.get_gtk_window();
		}
		embed "c" {{{
			GtkWidget* popup_dialog;
			popup_dialog = gtk_message_dialog_new(
				gtk_window,
				GTK_DIALOG_MODAL,
				GTK_MESSAGE_INFO,
				GTK_BUTTONS_NONE,
				text_ptr,
				NULL
			);
			gtk_window_set_title(GTK_WINDOW(popup_dialog), title_ptr);
			gtk_dialog_add_button(GTK_DIALOG(popup_dialog), GTK_STOCK_OK, GTK_RESPONSE_OK);
			gtk_widget_show(popup_dialog);
			gint response = gtk_dialog_run(GTK_DIALOG(popup_dialog));
			if(listener && response == GTK_RESPONSE_OK) {
				eq_gui_modaldialog_ModalDialogEngineLinux_on_ok_button_clicked(self, listener);
			}
			gtk_widget_destroy(popup_dialog);
		}}}
	}

	public void error(Frame frame, String text, String title, ModalDialogListener listener) {
		var text_ptr = String.as_strptr(text);
		var title_ptr = String.as_strptr(title);
		var mw = frame as GtkWindowFrame;
		ptr gtk_window = null;
		if(mw != null) {
			gtk_window = mw.get_gtk_window();
		}
		embed "c" {{{
			GtkWidget* popup_dialog;
			popup_dialog = gtk_message_dialog_new(
				GTK_WINDOW(gtk_window),
				GTK_DIALOG_MODAL,
				GTK_MESSAGE_ERROR,
				GTK_BUTTONS_NONE,
				text_ptr,
				NULL
			);
			gtk_window_set_title(GTK_WINDOW(popup_dialog), title_ptr);
			gtk_dialog_add_button(GTK_DIALOG(popup_dialog), GTK_STOCK_OK, GTK_RESPONSE_OK);
			gtk_widget_show(popup_dialog);
			gint response = gtk_dialog_run(GTK_DIALOG(popup_dialog));
			if(listener && response == GTK_RESPONSE_OK) {
				eq_gui_modaldialog_ModalDialogEngineLinux_on_ok_button_clicked(self, listener);
			}
			gtk_widget_destroy(popup_dialog);
		}}}
	}

	public void yesno(Frame frame, String text, String title, ModalDialogBooleanListener listener) {
		var text_ptr = String.as_strptr(text);
		var title_ptr = String.as_strptr(title);
		var mw = frame as GtkWindowFrame;
		ptr gtk_window = null;
		if(mw != null) {
			gtk_window = mw.get_gtk_window();
		}
		embed "c" {{{
			GtkWidget* popup_dialog;
			popup_dialog = gtk_message_dialog_new(
				GTK_WINDOW(gtk_window),
				GTK_DIALOG_MODAL,
				GTK_MESSAGE_QUESTION,
				GTK_BUTTONS_NONE,
				text_ptr,
				NULL
			);
			gtk_window_set_title(GTK_WINDOW(popup_dialog), title_ptr);
			gtk_dialog_add_buttons(GTK_DIALOG(popup_dialog), GTK_STOCK_NO, GTK_RESPONSE_NO, GTK_STOCK_YES, GTK_RESPONSE_YES, NULL);
			gtk_widget_show(popup_dialog);
			gint response = gtk_dialog_run(GTK_DIALOG(popup_dialog));
			if(listener) {
				if(response == GTK_RESPONSE_YES) {
					eq_gui_modaldialog_ModalDialogEngineLinux_on_yesno_okcancel_button_clicked(self, listener, TRUE);
				}
				else if(response == GTK_RESPONSE_NO) {
					eq_gui_modaldialog_ModalDialogEngineLinux_on_yesno_okcancel_button_clicked(self, listener, FALSE);
				}
			}
			gtk_widget_destroy(popup_dialog);
		}}}
	}

	public void okcancel(Frame frame, String text, String title, ModalDialogBooleanListener listener) {
		var text_ptr = String.as_strptr(text);
		var title_ptr = String.as_strptr(title);
		var mw = frame as GtkWindowFrame;
		ptr gtk_window = null;
		if(mw != null) {
			gtk_window = mw.get_gtk_window();
		}
		embed "c" {{{
			GtkWidget* popup_dialog;
			popup_dialog = gtk_message_dialog_new(
				GTK_WINDOW(gtk_window),
				GTK_DIALOG_MODAL,
				GTK_MESSAGE_QUESTION,
				GTK_BUTTONS_NONE,
				text_ptr,
				NULL
			);
			gtk_window_set_title(GTK_WINDOW(popup_dialog), title_ptr);
			gtk_dialog_add_buttons(GTK_DIALOG(popup_dialog), GTK_STOCK_CANCEL, GTK_RESPONSE_CANCEL, GTK_STOCK_OK, GTK_RESPONSE_OK, NULL);
			gtk_widget_show(popup_dialog);
			gint response = gtk_dialog_run(GTK_DIALOG(popup_dialog));
			if(listener) {
				if(response == GTK_RESPONSE_OK) {
					eq_gui_modaldialog_ModalDialogEngineLinux_on_yesno_okcancel_button_clicked(self, listener, TRUE);
				}
				else if(response == GTK_RESPONSE_CANCEL) {
					eq_gui_modaldialog_ModalDialogEngineLinux_on_yesno_okcancel_button_clicked(self, listener, FALSE);
				}
			}
			gtk_widget_destroy(popup_dialog);
		}}}
	}

	public void textinput(Frame frame, String text, String title, String initial_value, ModalDialogStringListener listener) {
		var text_ptr = String.as_strptr(text);
		var title_ptr = String.as_strptr(title);
		var mw = frame as GtkWindowFrame;
		ptr gtk_window = null;
		if(mw != null) {
			gtk_window = mw.get_gtk_window();
		}
		embed "c" {{{
			GtkWidget* popup_dialog;
			GtkWidget* gtk_entry;
			popup_dialog = gtk_message_dialog_new(
				GTK_WINDOW(gtk_window),
				GTK_DIALOG_MODAL,
				GTK_MESSAGE_INFO,
				GTK_BUTTONS_NONE,
				text_ptr,
				NULL
			);
			gtk_window_set_title(GTK_WINDOW(popup_dialog), title_ptr);
			gtk_entry = gtk_entry_new();
			gtk_entry_set_editable(GTK_ENTRY(gtk_entry), TRUE);
			gtk_entry_set_alignment(GTK_ENTRY(gtk_entry), 0.5);
			gtk_dialog_add_buttons(GTK_DIALOG(popup_dialog), GTK_STOCK_CANCEL, GTK_RESPONSE_CANCEL, GTK_STOCK_OK, GTK_RESPONSE_OK, NULL);
			gtk_container_add(GTK_CONTAINER(GTK_DIALOG(popup_dialog)->vbox), gtk_entry);
			gtk_widget_show_all(popup_dialog);
			gint response = gtk_dialog_run(GTK_DIALOG(popup_dialog));
			if(listener) {
				if(response == GTK_RESPONSE_OK) {
					const gchar* it = gtk_entry_get_text(GTK_ENTRY(gtk_entry));
					eq_gui_modaldialog_ModalDialogEngineLinux_on_input_submitted(self, listener, (void*)it);
				}
				else if(response == GTK_RESPONSE_CANCEL) {
					eq_gui_modaldialog_ModalDialogEngineLinux_on_input_submitted(self, listener, NULL);
				}
			}
			gtk_widget_destroy(popup_dialog);
		}}}
	}
}
