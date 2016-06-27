
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

public class FileEditorWindowWidget : FileAwareWidget, DesktopApplicationWindowWidget
{
	property File file;

	public FileEditorWindowWidget() {
		set_enable_save(true);
		set_enable_save_as(true);
	}

	public String desktop_window_confirm_close() {
		if(is_dirty()) {
			var name = "(new file)";
			if(file != null) {
				name = file.basename();
			}
			return("File \"%s\" has unsaved changes. If you close the file now, you will lose your changes. Are you sure you wish to proceed?"
				.printf().add(name).to_string());
		}
		return(null);
	}

	public virtual bool is_dirty() {
		return(false);
	}

	public virtual void save_to_file(File file, SaveFileListener listener) {
	}

	public void initialize() {
		base.initialize();
		update_title();
	}

	public void update_title() {
		String title;
		if(file != null) {
			title = file.basename();
		}
		else {
			title = "New File";
		}
		if(is_dirty()) {
			title = "* ".append(title);
		}
		set_frame_title(title);
	}

	class MySaveListener : SaveFileListener
	{
		public void on_save_file_complete(bool status, Error error) {
			if(status) {
				return;
			}
			var errs = String.as_string(error);
			if(String.is_empty(errs)) {
				errs = "Failed to save the file.";
			}
			ModalDialog.error(errs);
		}
	}

	public void on_save() {
		if(file == null) {
			on_save_as();
			return;
		}
		save_to_file(file, null);
	}

	class MySaveFileDialogListener : SaveFileDialogListener, SaveFileListener
	{
		property FileEditorWindowWidget widget;
		File file;
		public void on_save_file_dialog_ok(File file) {
			this.file = file;
			widget.save_to_file(file, this);
		}
		public void on_save_file_complete(bool status, Error error) {
			if(status == false) {
				var errs = String.as_string(error);
				if(String.is_empty(errs)) {
					errs = "Failed to save the file.";
				}
				ModalDialog.error(errs);
				return;
			}
			widget.set_file(file);
			widget.update_title();
		}
	}

	public virtual String get_default_file_name() {
		return(null);
	}

	public void on_save_as() {
		File dir;
		if(file != null) {
			dir = file.get_parent();
		}
		if(dir == null || dir.is_directory() == false) {
			dir = SystemEnvironment.get_home_dir();
		}
		SaveFileDialog.create(dir, get_default_file_name())
			.show(get_frame(), new MySaveFileDialogListener().set_widget(this));
	}

	public DesktopWindowMenuBar create_menubar() {
		var mb = new DesktopWindowMenuBar();
		return(mb);
	}

	public ToolBar create_toolbar() {
		var tb = base.create_toolbar();
		return(tb);
	}
}
