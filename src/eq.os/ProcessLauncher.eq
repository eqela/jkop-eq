
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

public class ProcessLauncher : Stringable
{
	public static ProcessLauncher for_command(String cmd) {
		return(new ProcessLauncher().set_command(cmd));
	}

	public static ProcessLauncher for_file(File file) {
		return(new ProcessLauncher().set_file(file));
	}

	public static ProcessLauncher for_string(String str) {
		return(new ProcessLauncher().parse(str));
	}

	property String command;
	property File file;
	property Collection params;
	property HashTable env;
	property File cwd;
	property int uid = -1;
	property int gid = -1;
	property StringPipeHandler string_pipe_handler;
	property BufferPipeHandler buffer_pipe_handler;
	property File executable;
	property bool trap_sigint = true;
	property bool replace_self = false;
	property bool pipe_pty = false;
	property bool start_group = false;
	property bool no_cmd_window = false;

	public ProcessLauncher() {
		params = LinkedList.create();
		env = HashTable.create();
	}

	void append_proper_param(StringBuffer sb, String p) {
		bool no_quotes = false;
		IFDEF("target_win32") {
			int rc = p.rchr((int)' ');
			if(rc < 0) {
				no_quotes = true;
			}
		}
		sb.append_c((int)' ');
		if(no_quotes) {
			sb.append(p);
		}
		else {
			sb.append_c((int)'"');
			sb.append(p);
			sb.append_c((int)'"');
		}
	}

	public String to_string() {
		var sb = StringBuffer.create();
		foreach(String key in env) {
			sb.append("%s=%s ".printf().add(key).add(env.get_string(key)).to_string());
		}
		if(file != null) {
			sb.append("\"%s\"".printf().add(file.get_native_path()).to_string());
		}
		else {
			sb.append("\"%s\"".printf().add(command).to_string());
		}
		foreach(String p in params) {
			append_proper_param(sb, p);
		}
		return(sb.to_string());
	}

	public String to_string_noenv() {
		var sb = StringBuffer.create();
		if(file != null) {
			sb.append("\"%s\"".printf().add(file.get_native_path()).to_string());
		}
		else {
			sb.append("\"%s\"".printf().add(command).to_string());
		}
		foreach(String p in params) {
			append_proper_param(sb, p);
		}
		return(sb.to_string());
	}

	public ProcessLauncher parse(String str) {
		var arr = SplitQuoted.split(str, (int)' ');
		if(arr == null) {
			return(null);
		}
		command = String.as_string(arr.get(0));
		if(command != null) {
			arr.remove(command);
		}
		params = arr;
		return(this);
	}

	public ProcessLauncher add_param(String arg) {
		if(arg != null) {
			if(params == null) {
				params = LinkedList.create();
			}
			params.add(arg);
		}
		return(this);
	}

	public ProcessLauncher add_param_file(File file) {
		if(file == null) {
			return(this);
		}
		var np = file.get_native_path();
		if(np == null) {
			np = "(eq)".append(file.get_eqela_path());
		}
		return(add_param(np));
	}

	public ProcessLauncher add_params(Collection params) {
		foreach(String s in params) {
			add_param(s);
		}
		return(this);
	}

	public ProcessLauncher set_env_variable(String key, String val) {
		if(env == null) {
			env = HashTable.create();
		}
		env.set(key, val);
		return(this);
	}

	public Process start(Logger logger = null) {
		return(ProcessLauncherBackend.start_process(this, false, null, logger));
	}

	public int execute(Logger logger = null) {
		var cp = ProcessLauncherBackend.start_process(this, true, null, logger);
		if(cp == null) {
			return(-1);
		}
		return(cp.get_exit_status());
	}

	public int execute_with_listener(ProcessLauncherListener listener, Logger logger = null) {
		var cp = ProcessLauncherBackend.start_process(this, true, listener, logger);
		if(cp == null) {
			return(-1);
		}
		return(cp.get_exit_status());
	}

	class MyStringPipeHandler : StringPipeHandler {
		property StringBuffer sb;
		public void on_pipe_string(String s) {
			if(sb != null) {
				sb.append(s);
				sb.append_c((int)'\n');
			}
		}
	}

	public int execute_to_string_buffer(StringBuffer output, Logger logger = null) {
		var msp = new MyStringPipeHandler().set_sb(output);
		var bph = get_buffer_pipe_handler();
		var sph = get_string_pipe_handler();
		set_buffer_pipe_handler(null);
		set_string_pipe_handler(msp);
		var cp = ProcessLauncherBackend.start_process(this, true, null, logger);
		set_string_pipe_handler(sph);
		set_buffer_pipe_handler(bph);
		if(cp == null) {
			return(-1);
		}
		return(cp.get_exit_status());
	}

	class MyBufferPipeHandler : BufferPipeHandler {
		property DynamicBuffer dest;
		public void on_pipe_buffer(Buffer buf) {
			if(dest != null) {
				DynamicBuffer.cat(dest, buf);
			}
		}
	}

	public int execute_to_buffer(DynamicBuffer output, Logger logger = null) {
		var msp = new MyBufferPipeHandler().set_dest(output);
		var bph = get_buffer_pipe_handler();
		var sph = get_string_pipe_handler();
		set_buffer_pipe_handler(msp);
		set_string_pipe_handler(null);
		var cp = ProcessLauncherBackend.start_process(this, true, null, logger);
		set_buffer_pipe_handler(bph);
		set_string_pipe_handler(sph);
		if(cp == null) {
			return(-1);
		}
		return(cp.get_exit_status());
	}

	public String execute_pipe_string(Logger logger = null) {
		var sb = StringBuffer.create();
		var r = execute_to_string_buffer(sb, logger);
		return(sb.to_string());
	}

	public Buffer execute_pipe_buffer(Logger logger = null) {
		var buf = DynamicBuffer.create();
		var r = execute_to_buffer(buf, logger);
		return(buf);
	}
}
