
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

public class ChooseFileAndExtract
{
	class MyConfirmOverwriteDialogWidget : YesNoDialogWidget
	{
		property File file;
		property File destdir;
		String name;
		public MyConfirmOverwriteDialogWidget set_name(String nn) {
			name = nn;
			set_text("%s is already installed. Do you want to overwrite it?".printf().add(name).to_string());
			return(this);
		}
		public bool on_yes() {
			Popup.widget(get_engine(), new ExtractFileDialogWidget().set_file(file).set_destpath(destdir).set_overwrite(true)
				.set_text("Installing %s ..".printf().add(name).to_string()));
			return(false);
		}
	}

	class MyOpenFileHandler : OpenFileDialogListener
	{
		property WidgetEngine engine;
		property File destdir;
		property String name;
		public void on_open_file_dialog_ok(File file) {
			if(file == null || destdir == null) {
				return;
			}
			if(destdir.exists()) {
				Popup.widget(engine, new MyConfirmOverwriteDialogWidget().set_file(file).set_destdir(destdir).set_name(name));
			}
			else {
				Popup.widget(get_engine(), new ExtractFileDialogWidget().set_file(file).set_destpath(destdir)
					.set_text("Installing %s ..".printf().add(name).to_string()));
			}
		}
	}

	public static void to_directory(WidgetEngine engine, String name, File destdir) {
		var dlg = new OpenFileDialog();
		dlg.set_directory(SystemEnvironment.get_home_dir());
		dlg.set_parent_frame(engine.get_frame());
		dlg.show(new MyOpenFileHandler().set_name(name).set_destdir(destdir).set_engine(engine));
	}
}
