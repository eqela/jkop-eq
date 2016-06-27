
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
	embed {{{
		static void on_result(Windows.UI.Core.CoreDispatcher dispatch, Windows.Storage.IStorageItem item, eq.widget.file.OpenFileDialogListener listener) {
			if(item == null) {
				return;
			}
			var strp = eq.api.CString.for_strptr(item.Path);
			eq.os.File f = null;
			if(strp != null) {
				f = eq.os.CFile.for_native_path(strp, null);
			}
			if(f != null) {
				dispatch.RunAsync(Windows.UI.Core.CoreDispatcherPriority.Normal, () => {
					if(f.exists()) {
						listener.on_open_file_dialog_ok(f);
					}
					else {
						var md = new Windows.UI.Popups.MessageDialog("Failed to open the file.");
						md.Title = "Unauthorized Access";
						md.ShowAsync();
					}
				});
			}
		}
	}}}

	public static bool execute(Frame frame, File dir, String filter, bool choose_directory, OpenFileDialogListener listener) {
		if(dir != null) {
			Log.debug("Custom starting location is unsupported: `%s'".printf().add(dir));
		}
		embed {{{
			var dispatcher =  Windows.UI.Core.CoreWindow.GetForCurrentThread().Dispatcher;
			var filter_type = eq.api.CString.as_strptr((eq.api.Object)filter);
			if(filter_type == null) {
				filter_type = "*";
			}
			if(choose_directory) {
				var picker = new Windows.Storage.Pickers.FolderPicker();
				var ado = picker.PickSingleFolderAsync();
				picker.FileTypeFilter.Add(filter_type);
				ado.Completed = (src, res) => {
					on_result(dispatcher, ado.GetResults(), listener);
				};
			}
			else {
				var picker = new Windows.Storage.Pickers.FileOpenPicker();
				picker.FileTypeFilter.Add(filter_type);
				var afo = picker.PickSingleFileAsync();
				afo.Completed = (src, res) => {
					on_result(dispatcher, afo.GetResults(), listener);
				};
			}
		}}}
		return(true);
	}
}
