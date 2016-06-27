
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

IFDEF("target_android") {
}
ELSE IFDEF("target_ios") {
}
ELSE IFDEF("target_uwpcs") {
}
ELSE IFDEF("target_j2se") {
}
ELSE {
class OpenFileDialogNative
{
	IFDEF("target_win32") {
		embed "c" {{{
			#include <windows.h>
			#include <shlobj.h>
			int CALLBACK BrowseCallbackProc(HWND hwnd,UINT uMsg, LPARAM lParam, LPARAM lpData) {
				switch (uMsg)
				{
					case BFFM_INITIALIZED: {
						if (NULL != lpData) {
							SendMessage(hwnd, BFFM_SETSELECTION, TRUE, lpData);
						}
					}
				}
				return 0;
			}
		}}}

		public static bool execute(Frame frame, File directory, String filter, bool choose_directories, OpenFileDialogListener listener) {
			int hWnd = 0;
			var f = frame as Direct2DWindowFrame;
			if(f != null) {
				hWnd = f.get_window_handle();
			}
			String ss;
			if(choose_directories) {
				strptr pp;
				strptr strini = null;
				if(directory != null) {
					strini = directory.get_native_path().to_strptr();
				}
				embed "c" {{{
					TCHAR path[MAX_PATH];
					BROWSEINFO bi;
					ZeroMemory(&bi, sizeof(bi));
					bi.hwndOwner = hWnd;
					bi.ulFlags = BIF_RETURNONLYFSDIRS | BIF_USENEWUI;
					bi.lpszTitle = "Choose a directory";
					bi.lpfn = BrowseCallbackProc;
					bi.lParam = strini;
					LPITEMIDLIST idlist = SHBrowseForFolder(&bi);
					if(idlist != 0) {
						if(SHGetPathFromIDList(idlist, path)) {
							pp = path;
						}
						CoTaskMemFree(idlist);
					}
				}}}
				ss = String.for_strptr(pp).dup();
			}
			else {
				strptr strini = null;
				if(directory != null) {
					strini = directory.get_native_path().to_strptr();
				}
				strptr strfil = null;
				if(filter!=null) {
					strfil = filter.to_strptr();
				}
				strptr pp;
				embed "c" {{{
					char file[1024];
					file[0] = 0;
					pp = file;
					OPENFILENAME ofn;
					memset(&ofn, 0, sizeof(ofn));
					ofn.lStructSize = sizeof(ofn);
					ofn.hwndOwner = hWnd;
					ofn.lpstrFile = file;
					ofn.nMaxFile = 1024;
					ofn.lpstrFilter = strfil;
					ofn.nFilterIndex = 0;
					ofn.lpstrFileTitle = NULL;
					ofn.nMaxFileTitle = NULL;
					ofn.lpstrInitialDir = strini;
					GetOpenFileName(&ofn);
				}}}
				ss = String.for_strptr(pp).dup();
			}
			if(ss == null || ss.get_length() < 1) {
				return(true);
			}
			if(listener != null) {
				listener.on_open_file_dialog_ok(File.for_native_path(ss));
			}
			return(true);
		}
	}

	ELSE IFDEF("target_osx") {
		embed {{{
			#import <AppKit/NSOpenPanel.h>
		}}}
		public static bool execute(Frame frame, File directory, String filter, bool choose_directories, OpenFileDialogListener listener) {
			if(directory == null) {
				return(false);
			}
			var dp = directory.get_native_path();
			if(dp == null) {
				return(false);
			}
			var dps = dp.to_strptr();
			if(dps == null) {
				return(false);
			}
			strptr pp = null;
			embed {{{
				@autoreleasepool {
				NSString* file;
				NSOpenPanel* dlg = [NSOpenPanel openPanel];
			}}}
			if(choose_directories) {
				embed {{{
					[dlg setCanChooseFiles:NO];
					[dlg setCanChooseDirectories:YES];
				}}}
			}
			else {
				embed {{{
					[dlg setCanChooseFiles:YES];
					[dlg setCanChooseDirectories:NO];
				}}}
			}
			bool ok = false;
			embed {{{
				[dlg setDirectoryURL:[NSURL fileURLWithPath:[[NSString alloc] initWithUTF8String:dps]]];
				if([dlg runModal] == NSOKButton) {
					ok = 1;
				}
			}}}
			if(ok) {
				embed {{{
					NSArray* files = [dlg filenames];
					file = [files objectAtIndex:0];
					if(file != nil) {
						pp = [file UTF8String];
					}
				}}}
			}
			if(pp != null && listener != null) {
				listener.on_open_file_dialog_ok(File.for_native_path(String.for_strptr(pp).dup()));
			}
			embed {{{
				} // close the autoreleasepool
			}}}
			return(true);
		}
	}
	ELSE IFDEF("target_linux") {
		embed "c" {{{
			#include <gtk/gtk.h>
		}}}

		public static bool execute(Frame aframe, File directory, String filter, bool choose_directories, OpenFileDialogListener listener) {
			var frame = aframe as GtkWindowFrame;
			ptr window = null;
			if(frame != null) {
				window = frame.get_gtk_window();
			}
			if(filter != null) {
				Log.debug("FIXME: filtered file dialog not implemented");
			}
			strptr filename = null;
			strptr directoryptr = null;
			String dir;
			if(directory != null && directory.is_directory()) {
				dir = directory.get_native_path();
				directoryptr = dir.to_strptr();
			}
			embed "c" {{{
				GtkWidget* filedialog = gtk_file_chooser_dialog_new("Open", window, GTK_FILE_CHOOSER_ACTION_OPEN, GTK_STOCK_OPEN, GTK_RESPONSE_ACCEPT, GTK_STOCK_CANCEL, GTK_RESPONSE_CANCEL, NULL);
				if(choose_directories) {
					gtk_file_chooser_set_action(GTK_FILE_CHOOSER(filedialog), GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER);
				}
				if(directoryptr != NULL) {
					gtk_file_chooser_set_current_folder(GTK_FILE_CHOOSER(filedialog), directoryptr);
				}
				int res = gtk_dialog_run(GTK_DIALOG(filedialog));
				if(res == GTK_RESPONSE_ACCEPT) {
					filename = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(filedialog));
				}
			}}}
			if(filename != null && listener != null) {
				listener.on_open_file_dialog_ok(File.for_native_path(String.for_strptr(filename).dup()));
				embed "c" {{{
					g_free(filename);
				}}}
			}
			embed "c" {{{
				gtk_widget_destroy(filedialog);
			}}}
			return(true);
		}
	}

	ELSE {
		public static bool execute(Frame frame, File directory, String filter, bool choose_directories, OpenFileDialogListener listener) {
			return(false);
		}
	}
}
}
