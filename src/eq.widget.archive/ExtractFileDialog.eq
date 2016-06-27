
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

public class ExtractFileDialog : BackgroundTaskDialog
{
	property File file;
	property File destpath;
	property bool overwrite = false;
	property ExtractFileDialogListener listener;
	property Error error;

	public void on_task_ended(bool result) {
		if(result) {
			if(listener != null) {
				listener.on_file_extracted(file, destpath);
			}
		}
		else {
			ModalDialog.error(String.as_string(error));
		}
	}

	public bool run_in_background() {
		if(file == null) {
			set_error(Error.instance("no_file", "No file to extract"));
			return(false);
		}
		if(destpath == null) {
			set_error(Error.instance("no_destpath", "No destination path given"));
			return(false);
		}
		if(destpath.exists()) {
			if(overwrite) {
				destpath.delete_recursive();
			}
			else {
				set_error(Error.instance("already_exists", "Destination path `%s' already exists".printf().add(destpath).to_string()));
				return(false);
			}
		}
		var ae = ArchiveExtractor.for_file(file);
		if(ae == null) {
			set_error(Error.instance("unknown_archive", "Unknown archive type: `%s'".printf().add(file).to_string()));
			return(false);
		}
		if(ae.extract_as_dir(destpath, true) == false) {
			set_error(Error.instance("failed_to_extract", "Failed to extract archive: `%s'".printf().add(file).to_string()));
			return(false);
		}
		return(true);
	}
}
