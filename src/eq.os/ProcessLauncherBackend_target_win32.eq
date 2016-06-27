
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

class ProcessLauncherBackend
{
	class MyProcess : Process
	{
		int phndl = -1;
		int thndl = -1;
		bool running;
		int exit_status;

		embed "c" {{{
			#include <windows.h>
		}}}

		public static MyProcess create(int phndl, int thndl) {
			var v = new MyProcess();
			Log.debug("A new win32 process was created. phndl=%d, thndl=%d".printf().add(phndl).add(thndl));
			v.phndl = phndl;
			v.thndl = thndl;
			v.running = true;
			v.exit_status = 1;
			return(v);
		}

		public ~MyProcess() {
			close();
		}

		void close() {
			if(phndl >= 0 && thndl >= 0) {
				var pphndl = phndl, pthndl = thndl;
				embed "c" {{{
					if(pphndl >= 0) {
						CloseHandle((HANDLE)pphndl);
					}
					if(pthndl >= 0) {
						CloseHandle((HANDLE)pthndl);
					}
				}}}
				phndl = -1;
				thndl = -1;
			}
		}

		public String get_id() {
			return("%d".printf().add(Primitive.for_integer(phndl)).to_string());
		}

		public bool is_running() {
			return(running);
		}

		public int get_exit_status() {
			return(exit_status);
		}

		public void send_interrupt() {
			kill(0);
		}

		public void kill_request() {
			// FIXME
			Log.warning("kill_request: Not implemented.");
		}

		public void kill_force() {
			kill(0);
		}

		public void kill(int timeout = 2) {
			int rr = -1;
			int phndl = this.phndl;
			int err = 0;
			embed "c" {{{
				HANDLE hphndl = (HANDLE)phndl;
				DWORD exitcode = 0;
				if(GetExitCodeProcess(hphndl, &exitcode) != 0) {
					rr = exitcode;
				}
				if(TerminateProcess(hphndl, rr) == FALSE) {
					err = (int)GetLastError();
				}
				if(timeout > 0) {
					WaitForSingleObject(hphndl, timeout*1000);
				}
			}}}
			if(err != 0) {
				Log.error("Failed to TerminateProcess: %d".printf().add(err));
			}
			Log.debug("Process Terminated. GetExitCodeProcess returns a value of %d".printf().add(rr));
		}

		public int wait_for_exit() {
			int rr = -1;
			int phndl = this.phndl;
			embed "c" {{{
				HANDLE hphndl = (HANDLE)phndl;
				DWORD exitcode = 0;
				WaitForSingleObject(hphndl, INFINITE);
				if(GetExitCodeProcess(hphndl, &exitcode) != 0) {
					rr = (int)exitcode;
				}
			}}}
			if(rr < 0) {
				int err;
				embed "c" {{{
					err = (int)GetLastError();
				}}}
				Log.error("Failed to get exit code of child process %d: %d".printf().add(phndl).add(err));
			}
			Log.debug("According to GetExitCodeProcess, return value is %d".printf().add(rr));
			close();
			running = false;
			this.exit_status = rr;
			return(rr);
		}
	}

	public static Process start_process(ProcessLauncher launcher, bool wait, ProcessLauncherListener listener, Logger logger) {
		if(launcher == null) {
			return(null);
		}
		var cmd = launcher.to_string_noenv();
		var executable = launcher.get_file();
		var cwd = launcher.get_cwd();
		var env = SystemEnvironment.get_env_vars();
		var lenv = launcher.get_env();
		foreach(String key in lenv) {
			env.set(key, lenv.get(key));
		}
		var trap = launcher.get_trap_sigint();
		String epath;
		if(executable != null) {
			epath = executable.get_native_path();
			if(epath == null) {
				Log.error("Executable `%s' does not have a native path! Cannot execute it.".printf().add(executable));
				return(null);
			}
		}
		var cmdptr = cmd.to_strptr();
		strptr epathptr;
		if(epath != null) {
			epathptr = epath.to_strptr();
		}
		int id;
		strptr cwdsp;
		String cwdpath;
		if(cwd == null) {
			cwd = SystemEnvironment.get_current_dir();
		}
		Log.debug("Executing: module=`%s', commandline=`%s', cwd=`%s'".printf().add(epath).add(cmd).add(cwd));
		if(cwd !=  null) {
			cwdpath = cwd.get_native_path();
			cwdsp = cwdpath.to_strptr();
		}
		embed "c" {{{
			char* envp = NULL;
			char envblock[32767];
		}}}
		if(env != null) {
			embed "c" {{{
				char* p = envblock;
			}}}
			foreach(String key in env) {
				var val = env.get_string(key);
				if(val == null) {
					val = "";
				}
				var kptr = key.to_strptr();
				var vptr = val.to_strptr();
				if(kptr == null || vptr == null) {
					continue;
				}
				embed "c" {{{
					int ll = strlen(kptr) + 1 + strlen(vptr) + 1;
					if((int)(p - envblock) + ll >= 32766) {
						break;
					}
					strcpy(p, kptr);
					strcat(p, "=");
					strcat(p, vptr);
					p += ll;
				}}}
			}
			embed "c" {{{
				*p = 0;
				envp = envblock;
			}}}
		}
		var pipe_str = launcher.get_string_pipe_handler();
		var pipe_buf = launcher.get_buffer_pipe_handler();
		if(pipe_str != null || pipe_buf != null) {
			if(wait == false) {
				Log.warning("Attempt to use a pipe handler in a child process that we do not wait for. Cannot do it.", logger);
				pipe_str = null;
				pipe_buf = null;
			}
		}
		embed "c" {{{
			HANDLE stdin_rd = -1, stdin_wr = -1, stdout_rd = -1, stdout_wr = -1;
		}}}
		bool pipe = launcher.get_no_cmd_window();
		if(pipe_str != null || pipe_buf != null) {
			int err = -1;
			Log.debug("Opening pipe handles ..");
			embed "c" {{{
				SECURITY_ATTRIBUTES saattr;
				ZeroMemory(&saattr, sizeof(SECURITY_ATTRIBUTES));
				saattr.nLength = sizeof(SECURITY_ATTRIBUTES);
				saattr.bInheritHandle = TRUE;
				saattr.lpSecurityDescriptor = NULL;
				if(CreatePipe(&stdout_rd, &stdout_wr, &saattr, 0) == 0) {
					err = GetLastError();
				}
				if(CreatePipe(&stdin_rd, &stdin_wr, &saattr, 0) == 0) {
					err = GetLastError();
				}
				SetHandleInformation(stdout_rd, HANDLE_FLAG_INHERIT, 0);
				SetHandleInformation(stdin_wr, HANDLE_FLAG_INHERIT, 0);
			}}}
			if(err >= 0) {
				Log.error("Error %d when opening output pipes.".printf().add(err));
			}
			pipe = true;
		}
		embed "c" {{{
			STARTUPINFO si;
			PROCESS_INFORMATION pi;
			ZeroMemory(&pi, sizeof(PROCESS_INFORMATION));
			ZeroMemory(&si, sizeof(STARTUPINFO));
			si.cb = sizeof(STARTUPINFO);
			if(pipe) {
				si.hStdError = stdout_wr;
				si.hStdOutput = stdout_wr;
				si.hStdInput = stdin_rd;
				si.dwFlags |= STARTF_USESTDHANDLES;
			}
			if(pipe) {
				id = CreateProcess((LPCTSTR)epathptr, (LPTSTR)cmdptr, NULL, NULL, TRUE, CREATE_NO_WINDOW, (LPVOID)envp, cwdsp, &si, &pi);
			}
			else {
				id = CreateProcess((LPCTSTR)epathptr, (LPTSTR)cmdptr, NULL, NULL, TRUE, 0, (LPVOID)envp, cwdsp, &si, &pi);
			}
			if(pipe) {
				if(stdout_wr >= 0) {
					CloseHandle(stdout_wr);
					stdout_wr = -1;
				}
				if(stdin_rd >= 0) {
					CloseHandle(stdin_rd);
					stdin_rd = -1;
				}
			}
		}}}
		if(id == 0) {
			int err;
			embed "c" {{{
				err = (int)GetLastError();
				if(pipe) {
					if(stdout_rd >= 0) {
						CloseHandle(stdout_rd);
						stdout_rd = -1;
					}
					if(stdin_wr >= 0) {
						CloseHandle(stdin_wr);
						stdin_wr = -1;
					}
				}
			}}}
			Log.error("Failed to execute: `%s' (err=0x%x)".printf().add(cmd).add(err));
			return(null);
		}
		int phndl, thndl;
		embed "c" {{{
			phndl = (int)pi.hProcess;
			thndl = (int)pi.hThread;
		}}}
		var v = MyProcess.create(phndl, thndl);
		if(listener != null) {
			listener.on_process_launched(v);
		}
		if(wait == true) {
			if(trap) {
				embed "c" {{{
					SetConsoleCtrlHandler(NULL, TRUE);
				}}}
			}
			if(pipe) {
				int hh;
				embed "c" {{{
					hh = (int)stdout_rd;
				}}}
				var rd = HandleReader.create(hh);
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
			Log.debug("Waiting for process %d to end ..".printf().add(phndl));
			v.wait_for_exit();
			if(trap) {
				embed "c" {{{
					SetConsoleCtrlHandler(NULL, FALSE);
				}}}
			}
			if(pipe) {
				embed "c" {{{
					if(stdout_wr >= 0) {
						CloseHandle(stdout_wr);
						stdout_wr = -1;
					}
					if(stdin_rd >= 0) {
						CloseHandle(stdin_rd);
						stdin_rd = -1;
					}
				}}}
			}
			Log.debug("Process %d ended. exit_status=%d".printf().add(phndl).add(v.get_exit_status()));
		}
		return(v);
	}
}
