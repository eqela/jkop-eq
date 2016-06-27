
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

public class CreateNewFileDialogWidget : TextInputDialogWidget
{
	public static void execute(WidgetEngine engine, File basedir, String default_value = null, EventReceiver listener = null) {
		Popup.widget(engine, new CreateNewFileDialogWidget().set_basedir(basedir).set_create_listener(listener).set_default_value(default_value));
	}

	property File basedir;
	property EventReceiver create_listener;
	property int max_length = 255;
	property String default_value;

	public virtual void pre_initialize() {
		set_title("Create a new file");
		set_prompt("Please enter the name of the file to create");
		set_placeholder("The name of the new file");
		set_value(default_value);
	}

	public void initialize() {
		pre_initialize();
		base.initialize();
	}

	public virtual String validate_input(String text, Error err) {
		if(String.is_empty(text)) {
			Error.set(err, "name_is_empty", "The file name is empty");
			return(null);
		}
		if(text.get_length() > max_length) {
			Error.set(err, "name_is_too_long", "The file name is too long");
			return(null);
		}
		if(text.chr((int)'/') >= 0 || text.chr((int)'\\') >= 0) {
			Error.set(err, "contains_slash", "The file name cannot contain a slash or backslash");
			return(null);
		}
		return(text);
	}

	public virtual bool create_file(File file) {
		if(file == null) {
			return(false);
		}
		return(file.touch());
	}

	public void on_ok(String text) {
		if(String.is_empty(text) || basedir == null) {
			return;
		}
		var err = new Error();
		var vtext = validate_input(text, err);
		if(vtext == null) {
			ErrorDialog.show(get_engine(), err.get_message());
			return;
		}
		var dd = basedir.entry(vtext);
		if(dd.exists()) {
			ErrorDialog.show(get_engine(), "The path already exists: %s".printf().add(dd).to_string());
			return;
		}
		if(create_file(dd) == false) {
			ErrorDialog.show(get_engine(), "Failed to create file: %s".printf().add(dd).to_string());
			return;
		}
		if(create_listener != null) {
			create_listener.on_event(dd);
		}
		close_popup();
	}
}
