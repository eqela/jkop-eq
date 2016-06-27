
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

public class LinuxSaveFileDialog
{
	property String title;
	property String filename;
	property File directory;
	property int overwrite_action;

	embed "c" {{{
		#include <gtk/gtk.h>
	}}}

	public bool execute(Frame frame, SaveFileDialogListener listener) {
		var linux_frame = frame as GtkWindowFrame;
		ptr window = null;
		strptr spdir = null;
		strptr sptitle = null;
		strptr spfilename = null;
		strptr spfile = null;
		int oa = overwrite_action;
		bool has_accepted = true;
		if(directory != null && directory.is_directory()) {
			spdir = directory.get_native_path().to_strptr();
		}
		if(title != null) {
			sptitle = title.to_strptr();
		}
		if(filename != null) {
			spfilename = filename.to_strptr();
		}
		if(linux_frame != null) {
			window = linux_frame.get_gtk_window();
		}
		embed "c" {{{
			GtkWidget *save_dialog = gtk_file_chooser_dialog_new(sptitle, GTK_WINDOW(window), GTK_FILE_CHOOSER_ACTION_SAVE, ("_Cancel"), GTK_RESPONSE_CANCEL, ("_Save"), GTK_RESPONSE_ACCEPT, NULL);
			gtk_file_chooser_set_current_folder(GTK_FILE_CHOOSER(save_dialog), spdir);
			gtk_file_chooser_set_current_name(GTK_FILE_CHOOSER(save_dialog), spfilename);
			if(oa == eq_widget_file_SaveFileDialog_OVERWRITE_CONFIRM) {
				gtk_file_chooser_set_do_overwrite_confirmation(GTK_FILE_CHOOSER(save_dialog), TRUE);
			}
			while(gtk_dialog_run(GTK_DIALOG(save_dialog)) == GTK_RESPONSE_ACCEPT) {
				spfile = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(save_dialog));
				if(oa == eq_widget_file_SaveFileDialog_OVERWRITE_DISALLOW) {
					FILE *file = fopen(spfile, "r");
					if(file != NULL) {
						char txt[1024];
						sprintf(txt, "File `%s' already exists.", spfile);
						GtkWidget *message = gtk_message_dialog_new(GTK_WINDOW(GTK_WIDGET(save_dialog)), GTK_DIALOG_MODAL, GTK_MESSAGE_ERROR, GTK_BUTTONS_OK, txt);
						gtk_dialog_run(GTK_DIALOG(message));
						gtk_widget_destroy(message);
						g_free(spfile);
						spfile = NULL;
						fclose(file);
					}
					else {
						break;
					}
				}
				else {
					break;
				}
			}
		}}}
		if(spfile != null && listener != null) {
			listener.on_save_file_dialog_ok(File.for_native_path(String.for_strptr(spfile).dup()));
			embed "c" {{{
				g_free(spfile);
			}}}
		}
		embed "c" {{{
			gtk_widget_destroy(save_dialog);
		}}}
		return(true);
	}
}
