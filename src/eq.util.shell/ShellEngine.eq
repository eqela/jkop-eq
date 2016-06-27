
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

public class ShellEngine
{
	File cwd;
	property HashTable env;
	Collection processes;
	property bool enable_builtin_cd = true;
	property BackgroundTaskManager background_task_manager;
	ShellOutput output;
	EventReceiver listener;
	StringBuffer output_buffer;
	Collection terminate_listeners;
	BackgroundTask terminate_timer;

	public ShellEngine() {
		processes = LinkedList.create();
		env = SystemEnvironment.get_env_vars();
		env.set("_EQELA_PLATFORM", VALUE("target_platformid"));
		var platform = VALUE("target_platformid");
		if(platform != null && (platform.has_suffix("86") || platform.has_suffix("32"))) {
			env.set("_EQELA_PLATFORM_BITS", "32");
		}
		else if(platform != null && (platform.has_suffix("64"))) {
			env.set("_EQELA_PLATFORM_BITS", "64");
		}
		cwd = SystemEnvironment.get_current_dir();
	}

	public ShellOutput get_output() {
		return(output);
	}

	public void set_environment_variable(String key, String val) {
		if(key == null) {
			return;
		}
		env.set(key, val);
	}

	public String get_environment_variable(String key) {
		if(env == null) {
			return(null);
		}
		return(env.get_string(key));
	}

	public ShellEngine set_output(ShellOutput output) {
		this.output = output;
		if(output != null && output_buffer != null) {
			output.print(output_buffer.to_string());
			output_buffer = null;
		}
		return(this);
	}

	public void kill_processes() {
		foreach(ShellProcess ps in processes) {
			ps.kill();
		}
		processes = LinkedList.create();
		on_all_processes_exited();
	}

	public void interrupt_processes() {
		foreach(ShellProcess ps in processes) {
			ps.interrupt();
		}
	}

	class MyTerminateTimeoutHandler : TimerHandler
	{
		property ShellEngine engine;
		public bool on_timer(Object arg) {
			engine.on_terminate_timeout();
			return(false);
		}
	}

	public void on_terminate_timeout() {
		terminate_timer = null;
		kill_processes();
	}

	public void terminate_processes(ShellEngineTerminateProcessesListener listener = null, int timeout = -1) {
		if(processes == null || processes.count() < 1) {
			if(listener != null) {
				listener.on_processes_terminated();
			}
			return;
		}
		if(listener != null) {
			if(terminate_listeners == null) {
				terminate_listeners = LinkedList.create();
			}
			terminate_listeners.append(listener);
		}
		if(terminate_timer != null) {
			terminate_timer.abort();
			terminate_timer = null;
		}
		if(background_task_manager != null) {
			interrupt_processes();
			var tt = timeout;
			if(tt < 0) {
				tt = 3000000;
			}
			terminate_timer = background_task_manager.start_timer(tt, new MyTerminateTimeoutHandler().set_engine(this));
		}
		else {
			kill_processes();
		}
	}

	public void set_listener(EventReceiver listener) {
		this.listener = listener;
		EventReceiver.event(listener, new ShellEngineCwdChangedEvent().set_cwd(cwd));
	}

	public File get_cwd() {
		return(cwd);
	}

	public bool set_cwd(File cwd) {
		if(cwd == null) {
			return(false);
		}
		if(cwd.is_directory() == false) {
			println("Not a directory: `%s'".printf().add(cwd));
			return(false);
		}
		this.cwd = cwd;
		EventReceiver.event(listener, new ShellEngineCwdChangedEvent().set_cwd(cwd));
		return(true);
	}

	public Collection get_processes() {
		return(processes);
	}

	public int count_processes() {
		if(processes == null) {
			return(0);
		}
		return(processes.count());
	}

	public void print(Object o) {
		var s = String.as_string(o);
		if(s == null) {
			return;
		}
		if(output == null) {
			if(output_buffer == null) {
				output_buffer = StringBuffer.create();
			}
			output_buffer.append(s);
			return;
		}
		output.print(s);
	}

	public void println(Object o) {
		var s = String.as_string(o);
		if(s == null) {
			print("\n");
			return;
		}
		print(s.append("\n"));
	}

	public virtual ShellExecutable get_internal_executable(String cmdname) {
		return(null);
	}

	class ChildProcessEventReceiver : EventReceiver
	{
		property ShellEngine spm;
		property ShellCommandListener listener;
		property ShellCommand command;
		public void on_event(Object o) {
			if(o is File) {
				if(spm != null) {
					spm.set_cwd((File)o);
				}
			}
			else if(o is Stringable) {
				if(command != null && command.get_ignore_output()) {
				}
				else {
					spm.print(o);
				}
			}
			else if(o is ShellProcessStartEvent) {
				if(spm != null) {
					spm.on_process_start((ShellProcessStartEvent)o);
				}
			}
			else if(o is ShellProcessExitEvent) {
				if(spm != null) {
					spm.on_process_exit((ShellProcessExitEvent)o);
				}
				if(listener != null) {
					int rv = -1;
					var pp = ((ShellProcessExitEvent)o).get_process();
					if(pp != null) {
						if(pp.get_terminated() == false) {
							rv = pp.get_exit_status();
						}
					}
					var rrv = rv;
					if(command != null) {
						rrv = command.as_return_value(rv);
					}
					listener.on_command_ended(rrv);
				}
			}
		}
	}

	public virtual ShellCommand translate_command(ShellCommand command) {
		return(command);
	}

	public virtual File find_command_file_for_name(String name) {
		return(null);
	}

	public virtual File find_command_file(ShellCommand command, HashTable myenv) {
		if(command == null) {
			return(null);
		}
		var cwd = command.get_cwd();
		if(cwd == null) {
			cwd = this.cwd;
		}
		var words = command.get_words(cwd, myenv, null);
		if(words == null) {
			return(null);
		}
		var cmd = String.as_string(words.get(0));
		if(cmd == null) {
			return(null);
		}
		var nn = find_command_file_for_name(cmd);
		if(nn != null) {
			return(nn);
		}
		var cc = cmd;
		if(Path.is_absolute_path(cc) == false && cwd != null) {
			cc = "%s/%s".printf().add(cwd.get_native_path()).add(cmd).to_string();
		}
		var ff = File.for_native_path(cc);
		if(ff != null && ff.is_file()) {
			return(ff);
		}
		if(cmd.chr((int)'/') >= 0 || cmd.chr((int)'\\') >= 0) {
			return(null);
		}
		return(SystemEnvironment.find_command(cmd));
	}

	public virtual int execute_internal(ShellCommand command, Collection words, HashTable env) {
		var cmd0 = String.as_string(words.get(0));
		if(enable_builtin_cd && "cd".equals(cmd0)) {
			var dir = String.as_string(words.get(1));
			if(String.is_empty(dir)) {
				set_cwd(SystemEnvironment.get_home_dir());
				return(0);
			}
			var ff = get_cwd();
			if(ff == null) {
				ff = SystemEnvironment.get_current_dir();
			}
			if(ff == null) {
				ff = File.for_eqela_path("/native/");
			}
			set_cwd(File.for_native_path(dir, ff));
			return(0);
		}
		if("clear".equals(cmd0)) {
			if(output != null) {
				output.clear();
			}
			return(0);
		}
		return(-1);
	}

	class MyExecuteWaiter : ShellEngineTerminateProcessesListener
	{
		property ShellEngine shell;
		property ShellCommand command;
		property ShellCommandListener listener;
		property HashTable custom_env;
		public void on_processes_terminated() {
			shell.execute(command, listener, custom_env);
		}
	}

	public void execute_exclusive(ShellCommand acommand, ShellCommandListener listener = null, HashTable custom_env = null) {
		int n = processes.count();
		if(n < 1) {
			execute(acommand, listener, custom_env);
			return;
		}
		var ss = "es";
		if(n == 1) {
			ss = "";
		}
		println("Terminating %d process%s ..".printf().add(n).add(ss).to_string());
		terminate_processes(new MyExecuteWaiter().set_shell(this).set_command(acommand)
			.set_listener(listener).set_custom_env(custom_env));
	}

	public bool execute(ShellCommand acommand, ShellCommandListener listener, HashTable custom_env = null) {
		var command = translate_command(acommand);
		if(command == null) {
			println("ShellEngine.execute: No command");
			if(listener != null) {
				listener.on_command_ended(-1);
			}
			return(false);
		}
		var msg = command.get_execute_message();
		if(String.is_empty(msg) == false) {
			println(msg);
		}
		var cwd = command.get_cwd();
		if(cwd == null) {
			cwd = this.cwd;
		}
		var ee = custom_env;
		if(ee == null) {
			ee = env;
		}
		var cc = HashTable.create();
		var words = command.get_words(cwd, ee, cc);
		if(words == null) {
			println("ShellEngine.execute: No command words");
			if(listener != null) {
				listener.on_command_ended(command.as_return_value(-1));
			}
			return(false);
		}
		if(words.count() < 1) {
			foreach(String kk in cc.iterate_keys()) {
				ee.set(kk, cc.get_string(kk));
			}
			if(listener != null) {
				listener.on_command_ended(command.as_return_value(0));
			}
			return(true);
		}
		ee = ee.dup();
		foreach(String kk in cc.iterate_keys()) {
			ee.set(kk, cc.get_string(kk));
		}
		var ir = execute_internal(command, words, ee);
		if(ir >= 0) {
			if(listener != null) {
				listener.on_command_ended(command.as_return_value(ir));
			}
			return(true);
		}
		var cmd0 = String.as_string(words.get(0));
		var cmd = get_internal_executable(cmd0);
		if(cmd == null) {
			var file = find_command_file(command, ee);
			if(file != null) {
				if(file.is_file() && file.has_extension("sequence")) {
					ee = ee.dup();
					int n = 0;
					foreach(String w in words) {
						ee.set(String.for_integer(n), w);
						n++;
					}
					return(execute_sequence_file(file, words, listener, ee));
				}
				cmd = ShellExternalExecutable.for_file(file);
			}
		}
		if(cmd == null) {
			println("%s: No such command".printf().add(cmd0));
			if(listener != null) {
				listener.on_command_ended(command.as_return_value(-1));
			}
			return(false);
		}
		var pr = new ShellProcess();
		pr.set_cwd(cwd);
		pr.set_env(ee);
		pr.set_executable(cmd);
		pr.set_command(command);
		var ll = new ChildProcessEventReceiver().set_spm(this).set_listener(listener).set_command(command);
		if(background_task_manager != null) {
			var bgt = background_task_manager.start_task(pr, ll);
			if(bgt != null) {
				return(true);
			}
		}
		pr.do_run(ll);
		return(true);
	}

	public bool execute_sequence_file(File file, Collection argv, ShellCommandListener listener, HashTable custom_env = null) {
		if(file == null) {
			return(false);
		}
		int n = 0;
		var ccs = LinkedList.create();
		var ifccs = LinkedList.create();
		StringBuffer sb;
		foreach(String line in file.lines()) {
			n ++;
			line = line.strip();
			if(String.is_empty(line) || line.has_prefix("#")) {
				continue;
			}
			if(line.has_prefix("IF ")) {
				if(ifccs.count() > 0) {
					Log.error("`%s':%d: Nested preprocessor IF".printf().add(file).add(n));
					return(false);
				}
				var ifcc = line.substring(3);
				if(ifcc.has_prefix("||") || ifcc.has_suffix("||")) {
					Log.error("`%s':%d: Invalid use of condition ||".printf().add(file).add(n));
					return(false);
				}
				while(true) {
					int idx = ifcc.str("||");
					if(idx > 0) {
						ifccs.append(ifcc.substring(0, idx-1).strip());
						ifcc = ifcc.substring(idx+2);
					}
					else {
						ifccs.append(ifcc.strip());
						break;
					}
				}
				continue;
			}
			if("ENDIF".equals(line)) {
				if(ifccs.count() < 1) {
					Log.error("`%s':%d: ENDIF without IF".printf().add(file).add(n));
					return(false);
				}
				ifccs.clear();
				continue;
			}
			if(ifccs.count() > 0) {
				String pfname;
				IFDEF("target_osx") {
					pfname = "osx";
				}
				ELSE IFDEF("target_windows") {
					pfname = "windows";
				}
				ELSE IFDEF("target_linux") {
					pfname = "linux";
				}
				ELSE {
					pfname = "unknown";
				}
				if(String.is_in_collection(pfname, ifccs) == false) {
					continue;
				}
			}
			if(line.has_suffix("\\")) {
				if(sb == null) {
					sb = StringBuffer.create();
				}
				sb.append(line.substring(0, line.get_length()-1));
				continue;
			}
			if(sb != null) {
				sb.append(line);
				line = sb.to_string();
			}
			ccs.add(ShellCommand.for_string(line));
		}
		if(ccs.count() < 1) {
			Log.error("No commands in sequence: `%s'".printf().add(file));
			return(false);
		}
		HashTable ee;
		if(custom_env != null) {
			ee = custom_env.dup();
		}
		else {
			ee = HashTable.create();
		}
		var fp = file.get_parent();
		if(fp != null) {
			var np = fp.get_native_path();
			ee.set("SEQUENCEDIR", np);
			ee.set("_SEQUENCE_DIR", np);
		}
		var fnp = file.get_native_path();
		ee.set("SEQUENCEFILE", fnp);
		ee.set("_SEQUENCE_FILE", fnp);
		var selff = SystemEnvironment.find_self();
		if(selff != null) {
			var snp = selff.get_native_path();
			ee.set("SELF", snp);
			ee.set("_SELF", snp);
			var sp = selff.get_parent();
			if(sp != null) {
				var spp = sp.get_native_path();
				ee.set("SELFDIR", spp);
				ee.set("_SELFDIR", spp);
			}
		}
		execute_sequence(ccs, listener, ee);
		return(true);
	}

	class SequenceListener : ShellCommandListener
	{
		property ShellEngine engine;
		property ShellCommand command;
		property Iterator commands;
		property ShellCommandListener listener;
		property HashTable custom_env;
		property File owd;
		public void on_command_ended(int astatus) {
			var status = astatus;
			if(command != null) {
				status = command.as_return_value(astatus);
			}
			Log.debug("Command ended with return value %d: `%s'".printf().add(status).add(command));
			if(status != 0) {
				Log.debug("FAILED status %d terminates the command sequence".printf().add(status));
				if(owd != null && owd.is_same(engine.get_cwd()) == false) {
					engine.set_cwd(owd);
				}
				if(listener != null) {
					listener.on_command_ended(status);
				}
				return;
			}
			if(commands == null) {
				return;
			}
			engine.execute_sequence_next(commands, listener, custom_env, owd);
		}
	}

	public void execute_sequence_next(Iterator it, ShellCommandListener listener, HashTable custom_env, File owd) {
		if(it == null) {
			return;
		}
		var cc = it.next() as ShellCommand;
		if(cc == null) {
			Log.debug("No more commands in sequence: Ending sequence");
			if(owd != null && owd.is_same(get_cwd()) == false) {
				set_cwd(owd);
			}
			if(listener != null) {
				listener.on_command_ended(0);
			}
			return;
		}
		Log.debug("Command sequence: Executing `%s'".printf().add(cc));
		execute_exclusive(cc, new SequenceListener().set_engine(this).set_command(cc)
			.set_commands(it).set_listener(listener).set_custom_env(custom_env)
			.set_owd(owd), custom_env);
	}

	public void execute_sequence(Collection commands, ShellCommandListener listener = null, HashTable custom_env = null) {
		if(commands == null || commands.count() < 1) {
			return;
		}
		execute_sequence_next(commands.iterate(), listener, custom_env, get_cwd());
	}

	public virtual void on_all_processes_exited() {
		if(terminate_timer != null) {
			terminate_timer.abort();
			terminate_timer = null;
		}
		var ls = terminate_listeners;
		terminate_listeners = null;
		foreach(ShellEngineTerminateProcessesListener ll in ls) {
			ll.on_processes_terminated();
		}
	}

	public virtual void on_process_start(ShellProcessStartEvent se) {
		processes.add(se.get_process());
		EventReceiver.event(listener, se);
	}

	public virtual void on_process_exit(ShellProcessExitEvent ee) {
		var oc = processes.count();
		processes.remove(ee.get_process());
		EventReceiver.event(listener, ee);
		if(processes.count() < 1 && processes.count() != oc) {
			on_all_processes_exited();
		}
	}
}
