
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

public class SaveFileDialogWidget : FormDialogWidget
{
	class OverwriteConfirmHandler : EventReceiver {
		property SaveFileDialogListener save_listener;
		property SaveFileDialogWidget dialog;
		property File file;
		public void on_event(Object o) {
			if("yes".equals(o)) {
				if(dialog != null) {
					Popup.close(dialog);
				}
				save_listener.on_save_file_dialog_ok(file);
			}
		}
	}

	property File directory;
	property String filename;
	property SaveFileDialogListener save_listener;
	property int overwrite_action;
	property String prompt;
	property String directory_label;
	property String file_label;

	public SaveFileDialogWidget() {
		directory_label = "Directory";
		file_label = "File name";
	}

	class MyTextInputWidgetReceiver : EventReceiver
	{
		property SaveFileDialogWidget widget;

		public void on_event(Object o) {
			if(widget == null) {
				return;
			}
			if(o != null && o is TextInputWidgetEvent && ((TextInputWidgetEvent)o).get_selected()) {
				if(widget.on_ok(widget.get_form())) {
					Popup.close(widget);
				}
			}
		}
	}

	public void initialize_form(FormWidget form) {
		String dirdefault;
		if(directory != null) {
			dirdefault = directory.to_string();
		}
		form.add_text_field("directory", directory_label, null, dirdefault);
		form.add_field("filename", file_label, null, TextInputWidget.instance().set_text(filename).set_listener(new MyTextInputWidgetReceiver().set_widget(this)));
		form.set_default_field_id("filename");
	}

	public bool on_ok(FormWidget form) {
		var vdir = form.get_form_field_value_string("directory");
		var vfil = form.get_form_field_value_string("filename");
		var file = File.for_native_path(vdir).entry(vfil);
		if(file.exists()) {
			if(overwrite_action == SaveFileDialog.OVERWRITE_CONFIRM) {
				Popup.widget(get_engine(), DialogWidget.yesno(
					"`%s' already exists. Do you want to overwrite it?".printf().add(file.basename()).to_string(), "Confirmation")
						.set_listener(new OverwriteConfirmHandler().set_save_listener(save_listener).set_dialog(this).set_file(file)));
				return(false);
			}
			if(overwrite_action == SaveFileDialog.OVERWRITE_DISALLOW) {
				ErrorDialog.show(get_engine(), "`%s' already exists.".printf().add(file.basename()).to_string(), "Already exists");
				return(false);
			}
		}
		if(save_listener != null) {
			save_listener.on_save_file_dialog_ok(file);
		}
		return(true);
	}
}
