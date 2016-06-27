
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

public class CreateNewDirectoryDialogWidget : TextInputDialogWidget
{
	public static void execute(WidgetEngine engine, File basedir, String default_value = null, EventReceiver listener = null) {
		Popup.widget(engine, new CreateNewDirectoryDialogWidget().set_basedir(basedir).set_create_listener(listener).set_default_value(default_value));
	}

	property File basedir;
	property EventReceiver create_listener;
	property String default_value;
	property int max_length = 255;

	public void initialize() {
		set_title("Create a new directory");
		set_prompt("Please enter the name of the directory to create");
		set_placeholder("The name of the new directory");
		set_value(default_value);
		base.initialize();
	}

	bool is_valid_directory_name(String text, Error err) {
		if(String.is_empty(text)) {
			Error.set(err, "name_is_empty", "The directory name is empty");
			return(false);
		}
		if(text.get_length() > max_length) {
			Error.set(err, "name_is_too_long", "The directory name is too long");
			return(false);
		}
		if(text.chr((int)'/') >= 0 || text.chr((int)'\\') >= 0) {
			Error.set(err, "contains_slash", "The directory name cannot contain a slash or backslash");
			return(false);
		}
		return(true);
	}

	public void on_ok(String text) {
		if(String.is_empty(text) || basedir == null) {
			return;
		}
		var err = new Error();
		if(is_valid_directory_name(text, err) == false) {
			ErrorDialog.show(get_engine(), err.get_message());
			return;
		}
		var dd = basedir.entry(text);
		if(dd.exists()) {
			ErrorDialog.show(get_engine(), "The path already exists: %s".printf().add(dd).to_string());
			return;
		}
		if(dd.mkdir_recursive() == false) {
			ErrorDialog.show(get_engine(), "Failed to create directory: %s".printf().add(dd).to_string());
			return;
		}
		if(create_listener != null) {
			create_listener.on_event(dd);
		}
		close_popup();
	}
}
