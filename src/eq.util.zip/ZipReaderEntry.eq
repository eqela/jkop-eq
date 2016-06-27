
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

public class ZipReaderEntry
{
	property String name;
	property int compressed_size;
	property int uncompressed_size;
	property bool is_directory;

	public virtual bool write_to_file(File file) {
		return(false);
	}

	public File write_to_dir(File dir, bool fullpath = true, bool overwrite = true, Error err = null) {
		if(dir == null || name == null) {
			Error.set(err, "invalid_arguments", "Null parameters");
			return(null);
		}
		File path;
		if(fullpath == false) {
			String nn;
			var r = name.rchr((int)'/');
			if(r < 1) {
				nn = name;
			}
			else {
				nn = name.substring(r+1);
			}
			if(String.is_empty(nn)) {
				Error.set(err, "no_name", "Unable to determine name for the entry");
				return(null);
			}
			path = dir.entry(nn);
		}
		else {
			path = dir;
			foreach(String x in name.split((int)'/')) {
				if(String.is_empty(x) == false) {
					path = path.entry(x);
				}
			}
			var dd = path.get_parent();
			if(dd.is_directory() == false) {
				dd.mkdir_recursive();
			}
			if(dd.is_directory() == false) {
				Error.set(err, "failed_to_create_directory", "Failed to create directory: `%s'".printf().add(dd).to_string());
				return(null);
			}
		}
		if(overwrite == false) {
			if(path.exists()) {
				Error.set(err, "already_exists", "Path `%s' already exists.".printf().add(path).to_string());
				return(null);
			}
		}
		if(write_to_file(path) == false) {
			Error.set(err, "write_failed", "Failed to write file: `%s'".printf().add(path).to_string());
			return(null);
		}
		return(path);
	}
}
