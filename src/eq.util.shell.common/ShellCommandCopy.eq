
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

public class ShellCommandCopy : ShellInternalExecutable
{
	Collection files;

	public bool on_command_line_parameter(String param) {
		if(files == null) {
			files = LinkedList.create();
		}
		files.append(File.for_native_path(param, get_cwd()));
		return(true);
	}

	public int execute_main() {
		if(files == null || files.count() < 2) {
			println("Usage: %s [src] .. [dest]".printf().add(get_argv0()));
			return(1);
		}
		if(files.count() == 2) {
			var src = files.get(0) as File;
			var dst = files.get(1) as File;
			if(src == null || dst == null) {
				log_error("src or dest file not specified");
				return(1);
			}
			if(dst.is_directory()) {
				dst = dst.entry(src.basename());
			}
			if(src.copy_to(dst) == false) {
				log_error("Failed to copy: `%s' -> `%s'".printf().add(src).add(dst));
				return(1);
			}
			log_debug("COPIED: `%s' -> `%s'".printf().add(src).add(dst));
			return(0);
		}
		var srcs = files;
		var dst = files.get(files.count()-1) as File;
		files.remove(dst);
		if(dst.is_directory() == false) {
			dst.mkdir_recursive();
		}
		if(dst.is_directory() == false) {
			log_error("Failed to create directory: `%s'".printf().add(dst));
			return(1);
		}
		foreach(File src in srcs) {
			var dd = dst.entry(src.basename());
			if(src.copy_to(dd) == false) {
				log_error("Failed to copy: `%s' -> `%s'".printf().add(src).add(dd));
				return(1);
			}
			log_debug("COPIED: `%s' -> `%s'".printf().add(src).add(dd));
		}
		return(0);
	}
}
