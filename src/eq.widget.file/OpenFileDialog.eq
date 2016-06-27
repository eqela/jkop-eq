
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

public class OpenFileDialog
{
	public static OpenFileDialog create() {
		return(new OpenFileDialog());
	}

	public static OpenFileDialog for_directory(File dir) {
		return(new OpenFileDialog().set_directory(dir));
	}

	property File directory;
	property FileIconProvider icon_provider;
	property bool allow_native = true;
	property String filter = null;
	property bool cancellable = true;
	property bool choose_directories = false;
	property Frame parent_frame;

	public OpenFileDialog() {
		if("no".equals(SystemEnvironment.get_env_var("EQ_OPENFILEDIALOG_ALLOW_NATIVE"))) {
			allow_native = false;
		}
	}

	public void show(OpenFileDialogListener listener) {
		if(directory == null) {
			directory = SystemEnvironment.get_current_dir();
		}
		if(directory == null) {
			directory = File.for_home_directory();
		}
		if(allow_native) {
			// FIXME: How to handle cancellable = false?
			if(OpenFileDialogNative.execute(parent_frame, directory, filter, choose_directories, listener) == true) {
				return;
			}
		}
		var ofdw = new OpenFileDialogWidget();
		ofdw.set_directory(directory);
		ofdw.set_choose_directories(choose_directories);
		ofdw.set_icon_provider(icon_provider);
		ofdw.set_open_listener(listener);
		ofdw.set_filter(filter);
		ofdw.set_cancellable(cancellable);
		Frame.open_as_popup(WidgetEngine.for_widget(ofdw), parent_frame);
	}
}
