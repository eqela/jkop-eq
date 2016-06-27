
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

IFNDEF("target_nacl") {

class ProcessLauncherBackend
{
	class MyProcess : Process
	{
		embed "c" {{{
			#include <unistd.h>
			#include <signal.h>
			#include <sys/wait.h>
		}}}
		IFDEF("target_ios") {
			embed {{{
				#include <util.h>
			}}}
		}

		private int pid = -1;
		private bool running = false;
		private int exitstatus = -1;

		public static MyProcess create(int _pid) {
			var v = new MyProcess();
			v.pid = _pid;
			v.running = true;
			return(v);
		}

		public String get_id() {
			return("%d".printf().add(Primitive.for_integer(pid)).to_string());
		}

		private bool waitpid(bool hang) {
			if(running == false) {
				return(running);
			}
			int status = 0, p = 0;
			if(hang) {
				var pid = this.pid;
				embed "c" {{{
					p = waitpid(pid, &status, 0);
				}}}
			}
			else {
				var pid = this.pid;
				embed "c" {{{
					p = waitpid(pid, &status, WNOHANG);
				}}}
			}
			if(p > 0) {
				running = false;
				int es;
				embed "c" {{{
					es = WEXITSTATUS(status);
				}}}
				exitstatus = es;
			}
			return(running);
		}

		public bool is_running() {
			return(waitpid(false));
		}

		public int wait_for_exit() {
			waitpid(true);
			return(exitstatus);
		}

		public int get_exit_status() {
			return(exitstatus);
		}

		public void send_interrupt() {
			if(running) {
				var p = pid;
				embed "c" {{{
					kill(-p, SIGINT);
				}}}
			}
		}

		public void kill_request() {
			if(running) {
				var p = pid;
				embed "c" {{{
					kill(p, SIGTERM);
				}}}
			}
		}

		public void kill_force() {
			if(running) {
				var p = pid;
				embed "c" {{{
					kill(p, SIGKILL);
				}}}
			}
		}

		public void kill(int timeout) {
			int n = 0;
			kill_request();
			while(n == 0 || n < timeout) {
				if(waitpid(false) == false) {
					break;
				}
				if(n >= timeout) {
					break;
				}
				embed "c" {{{
					sleep(1);
				}}}
				n++;
			}
			if(is_running()) {
				kill_force();
			}
			waitpid(true);
		}
	}

	embed "c" {{{
		#include <signal.h>
		#include <errno.h>
		#include <string.h>
		#include <sys/stat.h>
	}}}

	public static Process start_process(ProcessLauncher launcher, bool wait, ProcessLauncherListener listener, Logger logger) {
		return(new ProcessLauncherBackend().do_start_process(launcher, wait, listener, logger));
	}

	ptr s_sigquit = null;
	ptr ss_restore = null;

	public ProcessLauncherBackend() {
		ptr ssr;
		embed "c" {{{
			ssr = (void*)malloc(sizeof(sigset_t));
		}}}
		ss_restore = ssr;
	}

	~ProcessLauncherBackend() {
		var ssr = ss_restore;
		embed "c" {{{
			free(ssr);
		}}}
	}

	void init_wait_signals() {
		ptr sq;
		ptr ss;
		embed "c" {{{
			sq = (void*)signal(SIGQUIT, SIG_IGN);
			ss = malloc(sizeof(sigset_t));
		}}}
		s_sigquit = sq;
		var ssr = ss_restore;
		embed "c" {{{
			sigemptyset((sigset_t*)ss);
			sigaddset((sigset_t*)ss, SIGCHLD);
			pthread_sigmask(SIG_BLOCK, (sigset_t*)ss, (sigset_t*)ssr);
			free(ss);
		}}}
	}

	void clear_wait_signals() {
		if(s_sigquit != null) {
			var sq = s_sigquit;
			embed "c" {{{
				signal(SIGQUIT, sq);
			}}}
		}
		s_sigquit = null;
		var ssr = ss_restore;
		embed "c" {{{
			sigset_t os;
			pthread_sigmask(SIG_SETMASK, ssr, &os);
		}}}
	}

	int do_execute_command(ProcessLauncher launcher, int pipefd, File exefile, Logger logger) {
		var exestr = exefile.get_native_path();
		if(exestr == null) {
			return(-1);
		}
		var exestrp = exestr.to_strptr();
		if(exestrp == null) {
			return(-1);
		}
		int pid;
		if(launcher.get_replace_self()) {
			pid = 0;
		}
		else {
			embed "c" {{{
				pid = fork();
			}}}
		}
		// failure
		if(pid < 0) {
			Log.error("Failed to fork a process!", logger);
			return(pid);
		}
		// success (parent)
		if(pid > 0) {
			return(pid);
		}
		if(launcher.get_start_group()) {
			embed "c" {{{
				setsid();
			}}}
		}
		// the rest is success (child)
		embed "c" {{{
			sigset_t ss;
			sigset_t os;
			sigemptyset(&ss);
			pthread_sigmask(SIG_SETMASK, &ss, &os);
		}}}
		if(pipefd >= 0) {
			embed "c" {{{
				close(1);
				close(2);
				dup2(pipefd, 1);
				dup2(pipefd, 2);
				close(pipefd);
			}}}
		}
		var uid = launcher.get_uid();
		if(uid >= 0) {
			embed "c" {{{
				setuid(uid);
			}}}
		}
		var gid = launcher.get_gid();
		if(gid >= 0) {
			embed "c" {{{
				setgid(gid);
			}}}
		}
		var cwd = launcher.get_cwd();
		if(cwd != null) {
			var cwdp = cwd.get_native_path();
			if(String.is_empty(cwdp) == false) {
				strptr err;
				var cp = cwdp.to_strptr();
				bool r = true;
				embed "c" {{{
					if(chdir(cp) != 0) {
						err = strerror(errno);
						r = 0;
					}
				}}}
				if(r == false) {
					Log.warning("Failed to chdir to `%s' when starting new process: %s".printf().add(cwdp).add(String.for_strptr(err)), logger);
				}
			}
		}
		var env = launcher.get_env();
		foreach(String key in env) {
			SystemEnvironment.set_env_var(key, env.get_string(key));
		}
		var params = launcher.get_params();
		int argc = 1 + params.count();
		int n = 1;
		embed "c" {{{
			char** argv = (char**)malloc((argc+1) * sizeof(char*));
			argv[0] = exestrp;
		}}}
		foreach(String arg in params) {
			var pp = arg.to_strptr();
			if(pp != null) {
				embed "c" {{{
					argv[n] = pp;
					n++;
				}}}
			}
		}
		embed "c" {{{
			argv[n] = NULL;
		}}}
		strptr err = null;
		embed "c" {{{
			execv(exestrp, argv);
			err = strerror(errno);
		}}}
		Log.error("When executing command `%s': %s".printf().add(exestr).add(String.for_strptr(err)), logger);
		embed "c" {{{
			exit(1);
		}}}
		return(0);
	}

	File verify_command_file(ProcessLauncher launcher, Logger logger) {
		var ff = launcher.get_file();
		if(ff != null) {
			if(ff.is_file() == false) {
				Log.error("%s: Not a file.".printf().add(ff), logger);
				return(null);
			}
			return(ff);
		}
		var cmd = launcher.get_command();
		if(String.is_empty(cmd)) {
			return(null);
		}
		if(cmd.chr('/') >= 0) {
			var f2 = File.for_native_path(cmd);
			if(f2.is_file()) {
				return(f2);
			}
		}
		var cmdf = SystemEnvironment.find_command(cmd);
		if(cmdf == null || cmdf.is_file() == false) {
			Log.error("`%s': Command not found.".printf().add(cmd), logger);
			return(null);
		}
		return(cmdf);
	}

	public Process do_start_process(ProcessLauncher launcher, bool wait, ProcessLauncherListener listener, Logger logger) {
		if(launcher == null) {
			return(null);
		}
		var exefile = verify_command_file(launcher, logger);
		if(exefile == null) {
			return(null);
		}
		MyProcess v = null;
		if(wait) {
			init_wait_signals();
		}
		String msg;
		if(wait) {
			msg = "and waiting";
		}
		else {
			msg = "in background";
		}
		// initialize pipes, if requested
		int pipe_read = -1;
		int pipe_write = -1;
		var pipe_str = launcher.get_string_pipe_handler();
		var pipe_buf = launcher.get_buffer_pipe_handler();
		if(pipe_str != null || pipe_buf != null) {
			if(wait == false) {
				Log.warning("Attempt to use a pipe handler in a child process that we do not wait for. Cannot do it.", logger);
				pipe_str = null;
				pipe_buf = null;
			}
		}
		if(pipe_str != null || pipe_buf != null) {
			if(launcher.get_pipe_pty()) {
				embed "c" {{{
					if(openpty(&pipe_read, &pipe_write, NULL, NULL, NULL) < 0) {
						pipe_read = -1;
						pipe_write = -1;
					}
				}}}
			}
			else {
				embed "c" {{{
					int pipes[2];
					if(pipe(pipes) == 0) {
						pipe_read = pipes[0];
						pipe_write = pipes[1];
					}
				}}}
			}
			if(pipe_read < 0 || pipe_write < 0) {
				Log.error("FAILED to initialize pipe file descriptors. Continuing execution without piping.", logger);
				embed "c" {{{
					if(pipe_read >= 0) {
						close(pipe_read);
						pipe_read = -1;
					}
					if(pipe_write >= 0) {
						close(pipe_write);
						pipe_write = -1;
					}
				}}}
			}
		}
		int pid = do_execute_command(launcher, pipe_write, exefile, logger);
		if(pid >= 0) {
			v = MyProcess.create(pid);
		}
		if(pipe_write >= 0) {
			embed "c" {{{
				close(pipe_write);
			}}}
			pipe_write = -1;
		}
		if(v != null && listener != null) {
			listener.on_process_launched(v);
		}
		if(v != null && wait) {
			embed "c" {{{
				void* h_sigint;
			}}}
			if(launcher.get_trap_sigint()) {
				embed "c" {{{
					h_sigint = (void*)signal(SIGINT, SIG_IGN);
				}}}
			}
			if(pipe_read >= 0) {
				var rd = FileDescriptorReader.create(pipe_read);
				if(pipe_str != null) {
					var ins = InputStream.create(rd);
					String line;
					while((line = ins.readline()) != null) {
						pipe_str.on_pipe_string(line);
					}
				}
				else if(pipe_buf != null) {
					var buf = DynamicBuffer.create(4096);
					int n;
					while((n = rd.read(buf)) > 0) {
						pipe_buf.on_pipe_buffer(SubBuffer.create(buf, 0, n));
					}
				}
			}
			v.wait_for_exit();
			if(launcher.get_trap_sigint()) {
				embed "c" {{{
					signal(SIGINT, h_sigint);
				}}}
			}
		}
		if(pipe_read >= 0) {
			embed "c" {{{
				close(pipe_read);
			}}}
			pipe_read = -1;
		}
		if(wait) {
			clear_wait_signals();
		}
		return(v);
	}
}

}
