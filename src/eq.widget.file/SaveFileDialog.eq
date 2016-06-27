
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

public class SaveFileDialog
{
	public static int OVERWRITE_IGNORE = 0;
	public static int OVERWRITE_CONFIRM = 1;
	public static int OVERWRITE_DISALLOW = 2;

	public static SaveFileDialog create(File directory = null, String filename = null) {
		return(new SaveFileDialog().set_directory(directory).set_filename(filename));
	}

	property File directory;
	property String filename;
	property bool allow_native = true;
	property int overwrite_action = 1;
	property String title;
	property String prompt;
	property String directory_label;
	property String file_label;
	property bool save_as_directory = false;

	public void show(Frame frame, SaveFileDialogListener listener) {
		var title = this.title;
		var prompt = this.prompt;
		if(String.is_empty(title)) {
			if(save_as_directory) {
				title = "Save in directory ..";
			}
			else {
				title = "Save as ..";
			}
		}
		if(String.is_empty(prompt)) {
			if(save_as_directory) {
				prompt = "Please enter the full name of the directory to save in";
			}
			else {
				prompt = "Please enter the full name of the file to save";
			}
		}
		if(directory == null) {
			directory = SystemEnvironment.get_current_dir();
		}
		if(directory == null) {
			directory = File.for_native_path(File.for_eqela_path("/my").get_native_path());
		}
		if(allow_native) {
			IFDEF("target_win32") {
				if(save_as_directory == false) {
					var save_filedialog = new Win32SaveFileDialog();
					save_filedialog.set_directory(directory);
					save_filedialog.set_filename(filename);
					save_filedialog.set_title(title);
					save_filedialog.set_overwrite_action(overwrite_action);
					if(save_filedialog.execute(frame, listener) == true) {
						return;
					}
				}
			}
			ELSE IFDEF("target_osx") {
				var save_filedialog = new OSXSaveFileDialog();
				save_filedialog.set_directory(directory);
				save_filedialog.set_filename(filename);
				save_filedialog.set_title(title);
				save_filedialog.set_overwrite_action(overwrite_action);
				if(save_filedialog.execute(frame, listener) == true) {
					return;
				}
			}
			ELSE IFDEF("target_gtk") {
				var save_filedialog = new LinuxSaveFileDialog();
				save_filedialog.set_directory(directory);
				save_filedialog.set_filename(filename);
				save_filedialog.set_title(title);
				save_filedialog.set_overwrite_action(overwrite_action);
				if(save_filedialog.execute(frame, listener) == true) {
					return;
				}
			}
		}
		var ww = new SaveFileDialogWidget();
		ww.set_overwrite_action(overwrite_action);
		ww.set_directory(directory);
		if(directory_label != null) {
			ww.set_directory_label(directory_label);
		}
		ww.set_filename(filename);
		if(file_label != null) {
			ww.set_file_label(file_label);
		}
		ww.set_save_listener(listener);
		ww.set_prompt(prompt);
		ww.set_title(title);
		Frame.open_as_popup(WidgetEngine.for_widget(ww), frame);
	}
}
