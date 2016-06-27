
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

class OpenFileDialogNative
{
	public static bool execute(Frame frame, File dir, String filter, bool choose_directory, OpenFileDialogListener listener) {
		var sf = frame as SwingFrame;
		embed {{{
			java.awt.Window window = null;
			if(sf != null) {
				window = sf.get_java_window();
			}
		}}}
		strptr path;
		if(dir != null) {
		 	path = dir.get_native_path().to_strptr();
		}
		String selected_path;
		embed {{{
			javax.swing.JFileChooser fc = new javax.swing.JFileChooser(path);
			if(choose_directory) {
				fc.setFileSelectionMode(javax.swing.JFileChooser.DIRECTORIES_ONLY);
			}
			int res = fc.showOpenDialog(window);
			if(res == javax.swing.JFileChooser.APPROVE_OPTION) {
				selected_path = new eq.api.Object()._S(fc.getSelectedFile().getPath());
			}
		}}}
		if(selected_path != null && listener != null) {
			listener.on_open_file_dialog_ok(File.for_native_path(selected_path));
		}
		return(true);
	}
}
