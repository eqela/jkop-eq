
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

public class ShellExternalExecutable : ProcessLauncherListener, ShellExecutable
{
	public static ShellExternalExecutable for_file(File file) {
		if(file == null) {
			return(null);
		}
		return(new ShellExternalExecutable().set_executable(file));
	}

	property File executable;

	class PipeHandler : StringPipeHandler
	{
		property ShellOutput output;
		public void on_pipe_string(String o) {
			if(output != null) {
				output.print(o);
				output.print("\n");
			}
		}
	}

	Process process;

	public Process get_process() {
		return(process);
	}

	public void on_process_launched(Process process) {
		this.process = process;
	}

	public void interrupt() {
		if(process != null) {
			process.send_interrupt();
		}
	}

	public void kill() {
		if(process != null) {
			process.kill_force();
		}
	}

	public bool is_running() {
		if(process == null) {
			return(false);
		}
		return(process.is_running());
	}

	public int get_exit_status() {
		if(process == null) {
			return(-1);
		}
		return(process.get_exit_status());
	}

	public int execute(ShellCommand command, File cwd, HashTable env, ShellOutput output) {
		if(command == null) {
			ShellOutput.output(output, "No command given");
			return(-1);
		}
		var params = command.get_words(cwd, env, null);
		if(params == null) {
			params = LinkedList.create();
		}
		var pp = LinkedList.create();
		foreach(var o in params.iterate_from_index(1)) {
			pp.add(o);
		}
		var ff = executable;
		if(ff == null) {
			ShellOutput.output(output, "No executable file given to execute\n");
			return(-1);
		}
		var pl = ProcessLauncher.for_file(ff);
		pl.add_params(pp);
		foreach(String key in env) {
			pl.set_env_variable(key, env.get_string(key));
		}
		pl.set_cwd(cwd);
		pl.set_string_pipe_handler(new PipeHandler().set_output(output));
		pl.set_pipe_pty(true);
		pl.set_trap_sigint(false);
		pl.set_start_group(true);
		var r = pl.execute_with_listener(this);
		this.process = null;
		return(r);
	}
}
