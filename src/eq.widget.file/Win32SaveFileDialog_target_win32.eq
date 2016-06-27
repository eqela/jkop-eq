
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

public class Win32SaveFileDialog
{
	property String title;
	property File directory;
	property String filename;
	property int overwrite_action;

	embed "c" {{{
		#include <windows.h>
		#include <shlobj.h>
		#include <stdio.h>
	}}}

	public bool execute(Frame frame, SaveFileDialogListener listener) {
		int hWnd = 0;
		int flag;
		bool has_file;
		strptr sp_file;
		strptr sp_dir = null;
		strptr sp_title = null;
		strptr sp_filename = null;
		int oa = overwrite_action;
		var f = frame as Direct2DWindowFrame;
		if(f != null) {
			hWnd = f.get_window_handle();
		}
		if(title != null) {
			sp_title = title.to_strptr();
		}
		if(directory != null) {
			sp_dir = directory.get_native_path().to_strptr();
		}
		if(filename != null) {
			sp_filename = filename.to_strptr();
		}
		embed "c" {{{
			char file[1024];
			file[0] = 0;
			sp_file = file;
			if(sp_filename != NULL) {
				strcpy(file, sp_filename);
			}
			if(oa == eq_widget_file_SaveFileDialog_OVERWRITE_IGNORE) {
			}
			else if(oa == eq_widget_file_SaveFileDialog_OVERWRITE_CONFIRM) {
				flag = OFN_OVERWRITEPROMPT;
			}
			OPENFILENAME ofn_savefiledialog;
			memset(&ofn_savefiledialog, 0, sizeof(ofn_savefiledialog));
			ofn_savefiledialog.lStructSize = sizeof(ofn_savefiledialog);
			ofn_savefiledialog.hwndOwner = hWnd;
			ofn_savefiledialog.lpstrFile = file;
			ofn_savefiledialog.lpstrFilter = NULL;
			ofn_savefiledialog.nMaxFile = 1024;
			ofn_savefiledialog.lpstrTitle = sp_title;
			ofn_savefiledialog.lpstrInitialDir = sp_dir;
			ofn_savefiledialog.Flags = flag;
			while(has_file = GetSaveFileName(&ofn_savefiledialog)) {
				DWORD fileAttr = GetFileAttributes(file);
				if(fileAttr != INVALID_FILE_ATTRIBUTES && oa == eq_widget_file_SaveFileDialog_OVERWRITE_DISALLOW) {
					char message[1024];
					sprintf(message, "File `%s' already exists.", file);
					MessageBox(NULL, message, "File already exists", MB_ICONERROR | MB_OK);
				}
				else {
					break;
				}
			}
		}}}
		if(has_file == false) {
			return(true);
		}
		var ss = String.for_strptr(sp_file).dup();
		if(ss == null || ss.get_length() < 1) {
			return(true);
		}
		if(listener != null) {
			listener.on_save_file_dialog_ok(File.for_native_path(ss));
		}
		return(true);
	}
}
