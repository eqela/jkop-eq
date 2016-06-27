
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

public class ShellCommandDir : ShellInternalExecutable
{
	Collection paths;
	bool long_format = false;
	bool show_type = false;

	public bool on_command_line_flag(String flag) {
		if("l".equals(flag)) {
			long_format = true;
			return(true);
		}
		if("F".equals(flag)) {
			show_type = true;
			return(true);
		}
		return(false);
	}

	public bool on_command_line_parameter(String param) {
		if(paths == null) {
			paths = LinkedList.create();
		}
		paths.append(param);
		return(true);
	}

	IFDEF("target_posix") {
		embed "c" {{{
			#include <sys/stat.h>
		}}}
	}

	String interpret_mode(int mode) {
		String v;
		IFDEF("target_posix") {
			int f_lead = '-',
				f_irusr = '-', f_iwusr = '-', f_ixusr = '-',
				f_irgrp = '-', f_iwgrp = '-', f_ixgrp = '-',
				f_iroth = '-', f_iwoth = '-', f_ixoth = '-';
			var md = mode;
			embed "c" {{{
				if(md & S_IFDIR) { f_lead = 'd'; }
				if(md & S_IRUSR) { f_irusr = 'r'; }
				if(md & S_IWUSR) { f_iwusr = 'w'; }
				if(md & S_IXUSR) { f_ixusr = 'x'; }
				if(md & S_IRGRP) { f_irgrp = 'r'; }
				if(md & S_IWGRP) { f_iwgrp = 'w'; }
				if(md & S_IXGRP) { f_ixgrp = 'x'; }
				if(md & S_IROTH) { f_iroth = 'r'; }
				if(md & S_IWOTH) { f_iwoth = 'w'; }
				if(md & S_IXOTH) { f_ixoth = 'x'; }
			}}}
			var sb = StringBuffer.create();
			sb.append_c(f_lead);
			sb.append_c(f_irusr);
			sb.append_c(f_iwusr);
			sb.append_c(f_ixusr);
			sb.append_c(f_irgrp);
			sb.append_c(f_iwgrp);
			sb.append_c(f_ixgrp);
			sb.append_c(f_iroth);
			sb.append_c(f_iwoth);
			sb.append_c(f_ixoth);
			v = sb.to_string();
		}
		ELSE {
			v = "----------";
		}
		return(v);
	}

	bool do_ls_entry(File f) {
		var display = f.basename();
		FileInfo fi;
		if(show_type) {
			fi = f.stat();
			if(fi.is_directory()) {
				display = display.append("/");
			}
			else if(fi.is_link()) {
				display = display.append("@");
			}
			else if(fi.get_executable()) {
				display = display.append("*");
			}
		}
		if(long_format) {
			if(fi == null) {
				fi = f.stat();
			}
			println("%s %03d %03d %d %11d %s".printf().add(interpret_mode(fi.get_mode())).add(fi.get_owner_user()).add(fi.get_owner_group()).add(fi.get_modify_time())
				.add(fi.get_size()).add(display));
		}
		else {
			println(display);
		}
		return(true);
	}

	bool do_ls_directory(File f) {
		bool v = true;
		foreach(File e in f.entries()) {
			if(do_ls_entry(e) == false) {
				v = false;
			}
		}
		return(v);
	}

	bool do_ls(File f) {
		if(f == null) {
			log_error("Null file object given to ls");
			return(false);
		}
		if(f.is_file()) {
			return(do_ls_entry(f));
		}
		if(f.is_directory()) {
			return(do_ls_directory(f));
		}
		log_error("%s: No such file or directory".printf().add(f));
		return(false);
	}

	public int execute_main() {
		if("dir".equals(get_argv0())) {
			long_format = true;
			show_type = true;
		}
		var files = LinkedList.create();
		foreach(String x in paths) {
			files.append(File.for_native_path(x, get_cwd()));
		}
		if(Collection.is_empty(files)) {
			files.append(get_cwd());
		}
		int v = 0;
		foreach(File f in files) {
			if(do_ls(f) == false) {
				v = 1;
			}
		}
		return(v);
	}
}
