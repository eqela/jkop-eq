
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

IFDEF("target_winrtcs")
{
	// FIXME: Do what???
	// This is the dummy implementation "for the meantime"
	class ProcessLauncherBackend
	{
		public static Process start_process(ProcessLauncher launcher, bool wait, ProcessLauncherListener listener, Logger logger) {
			return(null);
		}
	}
}

ELSE {
	class ProcessLauncherBackend
	{
		public class MyProcess : Process
		{
			embed "cs" {{{
				public System.Diagnostics.Process process = null;
			}}}
			int exitCode = 0;

			~MyProcess() {
				close();
			}

			public void close() {
				embed "cs" {{{
					if(process != null) {
						exitCode = process.ExitCode;
						process.Close();
						process = null;
					}
				}}}
			}

			public String get_id() {
				int id = 0;
				embed "cs" {{{
					if(process != null) {
						id = process.Id;
					}
				}}}
				return(String.for_integer(id));
			}

			public bool is_running() {
				bool v = false;
				embed "cs" {{{
					if(process != null) {
						try {
							int x = process.ExitCode;
						}
						catch {
							v = true;
						}
					}
				}}}
				return(v);
			}

			public int get_exit_status() {
				if(is_running()) {
					return(-1);
				}
				int v = -1;
				embed "cs" {{{
					if(process != null) {
						try {
							v = process.ExitCode;
						}
						catch {
							v = -1;
						}
						exitCode = v;
					}
					else {
						v = exitCode;
					}
				}}}
				close();
				return(v);
			}

			public void send_interrupt() {
			}

			public void kill_request() {
				kill_force();
			}

			public void kill_force() {
				embed "cs" {{{
					if(process != null) {
						try {
							process.Kill();
						}
						catch {
						}
					}
				}}}
			}

			public void kill(int timeout2) {
				kill_force();
				embed "cs" {{{
					if(process != null) {
						process.WaitForExit(timeout2);
					}
				}}}
			}

			public int wait_for_exit() {
				embed "cs" {{{
					if(process != null) {
						process.WaitForExit();
					}
				}}}
				return(get_exit_status());
			}
		}

		public static Process start_process(ProcessLauncher launcher, bool wait, ProcessLauncherListener listener, Logger logger) {
			var ff = launcher.get_file();
			if(ff == null) {
				var cmd = launcher.get_command();
				if(cmd != null) {
					ff = SystemEnvironment.find_command(cmd);
					if(ff == null) {
						Log.error("Failed to find command: `%s'".printf().add(cmd), logger);
						return(null);
					}
				}
			}
			if(ff == null) {
				Log.error("No command or file specified for ProcessLauncher", logger);
				return(null);
			}
			var fn = ff.get_native_path();
			if(fn == null) {
				return(null);
			}
			var fnp = fn.to_strptr();
			if(fnp == null) {
				return(null);
			}
			var sb = StringBuffer.create();
			foreach(String param in launcher.get_params()) {
				if(sb.count() > 0) {
					sb.append_c((int)' ');
				}
				sb.append_c((int)'"');
				sb.append(param);
				sb.append_c((int)'"');
			}
			var sbs = sb.to_string();
			if(sbs == null) {
				sbs = "";
			}
			var sbp = sbs.to_strptr();
			var np = new MyProcess();
			strptr cwdp = null;
			var cwd = launcher.get_cwd();
			if(cwd != null) {
				var cwds = cwd.get_native_path();
				if(cwds != null) {
					cwdp = cwds.to_strptr();
				}
			}
			embed "cs" {{{
				System.Diagnostics.ProcessStartInfo pi = new System.Diagnostics.ProcessStartInfo();
				pi.CreateNoWindow = true;
				pi.UseShellExecute = false;
				pi.FileName = fnp;
				pi.RedirectStandardOutput = true;
				pi.RedirectStandardError = true;
				pi.WindowStyle = System.Diagnostics.ProcessWindowStyle.Hidden;
				pi.Arguments = sbp;
				pi.WorkingDirectory = cwdp;
			}}}
			var env = launcher.get_env();
			if(env != null && env.count() > 0) {
				foreach(String key in env) {
					var kp = key.to_strptr();
					var val = env.get_string(key);
					if(val == null) {
						val = "";
					}
					var vp = val.to_strptr();
					embed "cs" {{{
						pi.EnvironmentVariables[kp] = vp;
					}}}
				}
			}
			embed "cs" {{{
				try {
					np.process = System.Diagnostics.Process.Start(pi);
				}
				catch {
					np = null;
				}
			}}}
			if(np == null) {
				Log.error("Failed to start process: `%s'".printf().add(fn), logger);
				return(null);
			}
			if(wait) {
				strptr output = null;
				embed "cs" {{{
					try {
						System.IO.StreamReader sro = np.process.StandardOutput;
						output = sro.ReadToEnd();
						System.IO.StreamReader sre = np.process.StandardError;
						output += sre.ReadToEnd();
					}
					catch {
					}
				}}}
				np.wait_for_exit();
				if(output == null) {
					Log.warning("No output from child process (?)", logger);
				}
				else {
					var sph = launcher.get_string_pipe_handler();
					var bph = launcher.get_buffer_pipe_handler();
					if(sph != null) {
						sph.on_pipe_string(String.for_strptr(output));
					}
					else {
						if(bph != null) {
							Log.warning("Buffer pipe handlers are not supported", logger);
						}
						embed "cs" {{{
							System.Console.WriteLine(output);
						}}}
					}
				}
				np.close();
			}
			return(np);
		}
	}
}
