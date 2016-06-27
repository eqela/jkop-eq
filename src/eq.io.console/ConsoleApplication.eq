
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

public interface ConsoleApplication
{
	public void on_close();
	public void on_refresh();

	IFDEF("target_posix") {
		embed "c" {{{
			#include <stdlib.h>
			#include <signal.h>
			static void __on_signal(int sig) {
				void* __main = eq_api_Application_get_main();
				if(sig == SIGINT || sig == SIGTERM) {
					if(__main != (void*)0) {
						if(vtab_as_eq_api_Object(__main, type_eq_io_console_ConsoleApplication) != (void*)0) {
							eq_io_console_ConsoleApplication_on_close(__main);
							return;
						}
					}
					exit(1);
				}
				if(sig == SIGHUP) {
					if(__main != (void*)0) {
						if(vtab_as_eq_api_Object(__main, type_eq_io_console_ConsoleApplication) != (void*)0) {
							eq_io_console_ConsoleApplication_on_refresh(__main);
						}
					}
				}
				if(sig == SIGCHLD) {
				}
			}
		}}}
	}

	public static int execute(Object maino, String command, Collection args) {
		Application.set_main(maino);
		Application.set_instance_command(command);
		Application.set_instance_args(args);
		IFDEF("target_posix") {
			embed "c" {{{
				signal(SIGPIPE, SIG_IGN);
				signal(SIGINT, __on_signal);
				signal(SIGTERM, __on_signal);
				signal(SIGHUP, __on_signal);
				signal(SIGCHLD, __on_signal);
			}}}
		}
		SystemEnvironment.set_env_var("_EQ_ARGV0", command);
		if(maino == null) {
			Log.error("No Main object");
			return(-1);
		}
		int r = -1;
		IFDEF("target_apple") {
			embed {{{
				@autoreleasepool {
			}}}
		}
		if(maino is Command) {
			r = ((Command)maino).main(command, args);
		}
		else if(maino is Executable) {
			((Executable)maino).execute();
			r = 0;
		}
		else {
			Log.error("Main class is of unknown type");
		}
		IFDEF("target_apple") {
			embed {{{
				}
			}}}
		}
		return(r);
	}
}
