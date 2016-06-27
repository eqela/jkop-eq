
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

class SortedDirectoryDataProvider : RunnableTask
{
	IFDEF("target_win32") {
		embed "c" {{{
			#include <windows.h>
		}}}
	}
	property File directory;
	property bool show_directories = true;
	property bool show_hidden_files = true;
	property FileIconProvider icon_provider;
	property bool show_parent_directory = false;
	property bool choose_directories_only = false;

	class FileComparer : Comparer
	{
		public int compare(Object a, Object b) {
			var fai = a as ActionItem;
			var fbi = b as ActionItem;
			if(fai == null) {
				return(1);
			}
			if(fbi == null) {
				return(-1);
			}
			var fa = fai.get_data() as File;
			var fb = fbi.get_data() as File;
			if(fa == null) {
				return(1);
			}
			if(fb == null) {
				return(-1);
			}
			var fas = fa.stat();
			var fbs = fb.stat();
			if(fas.is_directory() && fbs.is_file()) {
				return(-1);
			}
			if(fbs.is_directory() && fas.is_file()) {
				return(1);
			}
			var fan = fa.basename();
			var fbn = fb.basename();
			if(fan == null) {
				return(1);
			}
			return(fan.compare_ignore_case(fbn));
		}
	}

	Image get_icon_for_file(File file) {
		if(icon_provider == null) {
			return(null);
		}
		return(icon_provider.get_icon_for_file(file));
	}

	bool is_hidden(File file) {
		if(file == null) {
			return(false);
		}
		IFDEF("target_win32") {
			var fn = file.get_native_path();
			var str = fn.to_strptr();
			bool v = false;
			embed "c" {{{
				v = (GetFileAttributesA(str) & FILE_ATTRIBUTE_HIDDEN);
			}}}
			return(v);
		}
		ELSE {
			var filename = file.basename();
			return(filename.chr((int)'.') == 0);
		}
	}

	Collection do_read_directory(File directory, BooleanValue abortflag) {
		var v = Array.create();
		if(directory == null) {
			return(v);
		}
		foreach(File f in directory.entries()) {
			if((f.is_directory() && show_directories == false)
				|| (f.is_file() && choose_directories_only)
				|| (is_hidden(f) && show_hidden_files == false)
			) {
				continue;
			}
			var fn = f.basename();
			if(fn != null) {
				v.add(ActionItem.instance(get_icon_for_file(f), fn, null, f, f));
			}
		}
		MergeSort.sort_array(v, new FileComparer());
		if(show_parent_directory) {
			var pp = directory.get_parent();
			if(pp != null) {
				v.insert(ActionItem.instance(IconCache.get("parent_directory"), "..", null, pp, pp), 0);
			}
		}
		return(v);
	}

	public void run(EventReceiver listener, BooleanValue abortflag) {
		var r = do_read_directory(directory, abortflag);
		if(abortflag == null || abortflag.to_boolean() == false) {
			EventReceiver.event(listener, r);
		}
	}
}

