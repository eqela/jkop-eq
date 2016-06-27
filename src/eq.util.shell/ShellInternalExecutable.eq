
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

public class ShellInternalExecutable : LoggerObject, ShellExecutable
{
	property ShellOutput output;
	property String argv0;
	property Collection args;
	property BooleanValue abortflag;
	property File cwd;
	property HashTable env;

	public bool get_abort_flag() {
		if(abortflag == null) {
			return(false);
		}
		return(abortflag.to_boolean());
	}

	public virtual void print(Object ss) {
		ShellOutput.output(output, String.as_string(ss));
	}

	public void log_message(Object o, String ident = null) {
		println(o);
	}

	public void log_error(Object o, String ident = null) {
		println("[ERROR] %s".printf().add(o));
	}

	public void log_warning(Object o, String ident = null) {
		println("[WARNING] %s".printf().add(o));
	}

	public void log_debug(Object o, String ident = null) {
		println("[DEBUG] %s".printf().add(o));
	}

	public virtual void println(Object ss) {
		var str = String.as_string(ss);
		if(str == null) {
			ShellOutput.output(output, "\n");
		}
		else {
			ShellOutput.output(output, str.append("\n"));
		}
	}

	public virtual bool on_command_line_flag(String flag) {
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

	public virtual bool parse_args(String argv0, Collection args) {
		foreach(String arg in args) {
			var r = on_command_line_argument(arg);
			if(r == false) {
				log_error("%s: Unsupported command line argument: `%s'".printf().add(argv0).add(arg));
				return(false);
			}
		}
		return(true);
	}

	public virtual int execute_main() {
		return(1);
	}

	public virtual int main(String argv0, Collection args) {
		if(parse_args(argv0, args) == false) {
			return(1);
		}
		return(execute_main());
	}

	public int execute(ShellCommand command, File cwd, HashTable env, ShellOutput output) {
		if(command == null) {
			return(-1);
		}
		set_cwd(cwd);
		set_env(env);
		set_output(output);
		var params = command.get_words(cwd, env, null);
		argv0 = String.as_string(params.get(0));
		args = LinkedList.create();
		foreach(String a in params.iterate_from_index(1)) {
			args.append(a);
		}
		return(main(argv0, args));
	}
}
