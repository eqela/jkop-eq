
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

public class DirectorySelectorButtonWidget : ButtonWidget, OpenFileDialogListener, FileAwareWidget
{
	public static DirectorySelectorButtonWidget instance() {
		return(new DirectorySelectorButtonWidget());
	}

	public static DirectorySelectorButtonWidget for_directory(File dir) {
		return(new DirectorySelectorButtonWidget().set_directory(dir));
	}

	property File directory;

	public DirectorySelectorButtonWidget() {
		set_color(Color.instance("#DDDDDD"));
		set_pressed_color(Color.instance("#AAAAAA"));
		set_font(Theme.font().modify("bold color=black"));
		set_pressed_font(Theme.font().modify("bold color=white"));
	}

	public File get_file() {
		return(directory);
	}

	public void initialize() {
		base.initialize();
		if(directory == null) {
			directory = File.for_home_directory();
		}
		var text = directory.basename();
		if(String.is_empty(text)) {
			text = "(unknown)";
		}
		set_text(text);
	}

	public void on_open_file_dialog_ok(File file) {
		if(file == null) {
			return;
		}
		if(file.is_directory() == false) {
			return;
		}
		directory = file;
		set_text(directory.basename());
	}

	public void on_clicked() {
		File dd;
		if(directory != null) {
			dd = directory; //.get_parent();
		}
		if(dd == null) {
			dd = File.for_home_directory();
		}
		FileDialog.open_directory(this, dd, get_frame());
	}
}
