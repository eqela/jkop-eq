
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

public class CommandLineApplication : LoggerObject, Command
{
	property String displayname;
	property String version;
	property String copyright;
	property String license;
	property String description;
	property OutputStream stdout;
	property OutputStream stderr;
	property InputStream stdin;
	property bool force_header = false;
	property int exit_status = -1;

	public CommandLineApplication() {
		displayname = Application.get_display_name();
		version = Application.get_version();
		if(String.is_empty(displayname)) {
			displayname = Application.get_name();
		}
		if(String.is_empty(displayname)) {
			displayname = "Command Line Application";
		}
		copyright = Application.get_copyright();
		license = Application.get_license();
		description = Application.get_description();
		stdout = OutputStream.create(Stdout.instance());
		stderr = OutputStream.create(Stderr.instance());
		stdin = InputStream.create(Stdin.instance());
	}

	public void print(Object o, bool err = false) {
		String str = o as String;
		if(str == null) {
			var st = o as Stringable;
			if(st != null) {
				str = st.to_string();
			}
		}
		var oo = stdout;
		if(err) {
			oo = stderr;
		}
		if(str != null && oo != null) {
			oo.print(str);
		}
	}

	public void println(Object o = null, bool err = false) {
		String str = o as String;
		if(str == null) {
			var st = o as Stringable;
			if(st != null) {
				str = st.to_string();
			}
		}
		var oo = stdout;
		if(err) {
			oo = stderr;
		}
		if(oo != null) {
			if(str == null) {
				str = "";
			}
			oo.println(str);
		}
	}

	public String readline() {
		if(stdin == null) {
			return(null);
		}
		return(stdin.readline());
	}

	public virtual void usage() {
		if(force_header == false) {
			print_header();
		}
		if(String.is_empty(description) == false) {
			println(description);
			println("", true);
		}
		var usg = get_usage();
		if(usg != null) {
			print(usg);
		}
	}

	public virtual void on_usage(UsageInfo ui) {
	}

	public virtual Stringable get_usage() {
		var ui = new UsageInfo();
		on_usage(ui);
		return(ui);
	}

	public virtual String get_full_version() {
		String beg;
		if(String.is_empty(version)) {
			beg = displayname;
		}
		else {
			beg = "%s / %s".printf().add(displayname).add(version).to_string();
		}
		return("%s @ %s".printf().add(beg).add(VALUE("target_platform")).to_string());
	}

	public virtual void print_header() {
		println(get_full_version(), true);
		if(String.is_empty(copyright) == false) {
			println(copyright, true);
		}
		if(String.is_empty(license) == false) {
			println(license, true);
		}
		println("", true);
	}

	public virtual bool initialize_with_args(Collection args) {
		return(initialize());
	}

	public virtual bool initialize() {
		return(true);
	}

	public int main(String command, Collection args) {
		if(force_header) {
			print_header();
		}
		if(parse_args(args) == false) {
			exit_status = 1;
		}
		if(exit_status >= 0) {
			return(exit_status);
		}
		if(initialize_with_args(args) == false) {
			exit_status = 1;
		}
		if(exit_status >= 0) {
			return(exit_status);
		}
		var v = execute_args(args);
		cleanup();
		if(exit_status < 0) {
			if(v == false) {
				exit_status = 1;
			}
			else {
				exit_status = 0;
			}
		}
		Log.debug("Application exiting with exit status %d".printf().add(exit_status));
		return(exit_status);
	}

	public virtual bool on_command_line_flag(String flag) {
		if("help".equals(flag) || "h".equals(flag)) {
			usage();
			set_exit_status(0);
			return(true);
		}
		return(false);
	}

	public virtual bool on_command_line_option(String key, String value) {
		return(false);
	}

	public virtual bool on_command_line_parameter(String param) {
		return(false);
	}

	public virtual bool on_command_line_argument_key_value(String key, String value) {
		if(key != null && value != null) {
			return(on_command_line_option(key, value));
		}
		else if(key != null && value == null) {
			return(on_command_line_flag(key));
		}
		else if(key == null && value != null) {
			return(on_command_line_parameter(value));
		}
		return(false);
	}

	public virtual bool on_command_line_argument(String arg) {
		if(arg == null) {
			return(false);
		}
		bool r;
		if(arg.has_prefix("-")) {
			String aa;
			if(arg.has_prefix("--")) {
				aa = arg.substring(2);
			}
			else {
				aa = arg.substring(1);
			}
			if(aa.chr((int)'=') >= 0) {
				var ssp = StringSplitter.split(aa, (int)'=', 2);
				var key = ssp.next() as String;
				var val = ssp.next() as String;
				if(val == null) {
					val = "";
				}
				r = on_command_line_argument_key_value(key, val);
			}
			else {
				r = on_command_line_argument_key_value(aa, null);
			}
		}
		else {
			r = on_command_line_argument_key_value(null, arg);
		}
		return(r);
	}

	public virtual bool parse_args(Collection args) {
		foreach(String arg in args) {
			var r = on_command_line_argument(arg);
			if(r == false) {
				Log.error("Unsupported command line argument: `%s'".printf().add(arg));
				return(false);
			}
			if(exit_status >= 0) {
				break;
			}
		}
		return(true);
	}

	public virtual bool execute_args(Collection args) {
		return(execute());
	}

	public virtual bool execute() {
		Log.error("No execute() method defined for CommandLineApplication.");
		return(false);
	}

	public virtual void cleanup() {
	}
}
