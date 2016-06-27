
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

public class DirectoryLogger : Logger
{
	public static DirectoryLogger for_directory(File dir) {
		return(new DirectoryLogger().set_logdir(dir));
	}

	property File logdir;
	property String filename_prefix;
	String logfile_name;
	OutputStream output;
	Mutex mutex;

	public DirectoryLogger() {
		mutex = Mutex.create();
		filename_prefix = "messages_";
		var lg = Log.get_logger();
		if(lg != null) {
			set_log_level(lg.get_log_level());
		}
	}

	String get_logfile_name(DateTime atime = null) {
		var time = atime;
		if(time == null) {
			time = DateTime.for_now();
		}
		if(time == null) {
			return(null);
		}
		return("%s%s.log".printf().add(filename_prefix).add(time.to_string_date_compressed()).to_string());
	}

	public void reopen() {
		open_logfile(get_logfile_name());
	}

	void open_logfile(String name) {
		if(logdir == null || name == null) {
			return;
		}
		if(logdir.is_directory() == false) {
			if(logdir.mkdir_recursive() == false) {
				return;
			}
		}
		var ff = logdir.entry(name);
		output = OutputStream.create(ff.append());
	}

	public void log(String prefix, String msg, String ident) {
		mutex.lock();
		var now = DateTime.for_now();
		var lfn = get_logfile_name(now);
		if(lfn == null) {
			mutex.unlock();
			return;
		}
		if(output == null || lfn.equals(logfile_name) == false) {
			open_logfile(lfn);
		}
		if(output != null) {
			var pp = prefix;
			if(String.is_empty(pp)) {
				pp = "INFO";
			}
			var id = ident;
			if(String.is_empty(id)) {
				id = "generic";
			}
			output.println("[%s %s %s %s] %s".printf().add(now.to_string_date()).add(now.to_string_time(true,true,true))
				.add(pp).add(id).add(msg).to_string());
		}
		mutex.unlock();
	}
}
