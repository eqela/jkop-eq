
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

public class ShellProcess : LoggerObject, RunnableTask
{
	int exitvalue = -1;
	BooleanValue abortflag;
	bool running = false;
	property ShellCommand command;
	property EventReceiver listener;
	property ShellExecutable executable;
	property File cwd;
	property HashTable env;
	property bool terminated = false;

	class MyShellOutputWrapper : ShellOutput, Stringable
	{
		StringBuffer sb;
		Mutex mutex;
		property EventReceiver listener;

		public MyShellOutputWrapper() {
			mutex = Mutex.create();
		}

		public void print(String text) {
			if(mutex != null) {
				mutex.lock();
			}
			bool firsttime = false;
			if(sb == null) {
				sb = StringBuffer.create();
				firsttime = true;
			}
			sb.append(text);
			if(mutex != null) {
				mutex.unlock();
			}
			if(firsttime) {
				EventReceiver.event(listener, this);
			}
		}

		public void clear() {
		}

		public String to_string() {
			String v;
			if(mutex != null) {
				mutex.lock();
			}
			if(sb != null) {
				v = sb.to_string();
				sb = null;
			}
			if(mutex != null) {
				mutex.unlock();
			}
			return(v);
		}
	}

	public void do_run(EventReceiver listener) {
		var ow = new MyShellOutputWrapper().set_listener(listener);
		var logger = new ShellOutputLogger().set_output(ow);
		var pl = Log.get_logger();
		if(pl != null) {
			logger.set_log_level(pl.get_log_level());
		}
		set_logger(logger);
		this.listener = listener;
		if(executable != null) {
			exitvalue = executable.execute(command, cwd, env, ow);
		}
		this.listener = null;
		set_logger(null);
	}

	public void run(EventReceiver listener, BooleanValue abortflag) {
		EventReceiver.event(listener, new ShellProcessStartEvent().set_process(this).set_command(command));
		running = true;
		this.abortflag = abortflag;
		do_run(listener);
		this.abortflag = null;
		running = false;
		EventReceiver.event(listener, new ShellProcessExitEvent().set_process(this));
	}

	public void interrupt() {
		terminated = true;
		if(executable is ShellExternalExecutable) {
			((ShellExternalExecutable)executable).interrupt();
		}
		if(abortflag != null) {
			abortflag.set_value(true);
		}
	}

	public void kill() {
		terminated = true;
		if(executable is ShellExternalExecutable) {
			((ShellExternalExecutable)executable).kill();
		}
		if(abortflag != null) {
			abortflag.set_value(true);
		}
	}

	public String get_process_id() {
		var ee = executable as ShellExternalExecutable;
		if(ee == null) {
			return(null);
		}
		var process = ee.get_process();
		if(process == null) {
			return(null);
		}
		return(process.get_id());
	}

	public bool is_running() {
		return(running);
	}

	public int get_exit_status() {
		return(exitvalue);
	}
}
