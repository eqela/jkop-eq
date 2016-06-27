
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

public class MultiActionCommandLineApplication : CommandLineApplication
{
	int myloglevel = Log.LOG_LEVEL_MESSAGE;
	CommandLineApplicationAction action;

	public int get_my_log_level() {
		return(myloglevel);
	}

	public bool get_is_debug() {
		if(myloglevel == Log.LOG_LEVEL_DEBUG) {
			return(true);
		}
		return(false);
	}

	public MultiActionCommandLineApplication set_action(CommandLineApplicationAction action) {
		if(this.action != null) {
			this.action.set_app(null);
		}
		this.action = action;
		if(action != null) {
			action.set_app(this);
		}
		return(this);
	}

	public CommandLineApplicationAction get_action() {
		return(action);
	}

	public MultiActionCommandLineApplication() {
		var ll = SystemEnvironment.get_env_var("EQ_LOGLEVEL");
		if(String.is_empty(ll) == false) {
			myloglevel = ll.to_integer();
		}
	}

	public virtual CommandLineApplicationAction create_action(String name) {
		return(null);
	}

	public bool on_command_line_flag(String flag) {
		if(action != null) {
			if(action.on_command_line_flag(flag)) {
				return(true);
			}
		}
		if("v".equals(flag) || "verbose".equals(flag)) {
			myloglevel = Log.LOG_LEVEL_DEBUG;
			return(true);
		}
		if("q".equals(flag) || "quiet".equals(flag)) {
			myloglevel = Log.LOG_LEVEL_QUIET;
			return(true);
		}
		if("h".equals(flag) || "help".equals(flag)) {
			usage();
			set_exit_status(0);
			return(true);
		}
		return(base.on_command_line_flag(flag));
	}

	public bool on_command_line_option(String key, String value) {
		if(action != null) {
			if(action.on_command_line_option(key, value)) {
				return(true);
			}
		}
		return(base.on_command_line_option(key, value));
	}

	public bool on_command_line_parameter(String param) {
		if(action == null) {
			set_action(create_action(param));
			if(action == null) {
				return(false);
			}
			if(action is LoggerObject) {
				var lg = get_logger();
				if(lg != null) {
					((LoggerObject)action).set_logger(lg);
				}
			}
			on_action_created();
			return(true);
		}
		if(action.on_command_line_parameter(param)) {
			return(true);
		}
		return(base.on_command_line_parameter(param));
	}

	public virtual void on_action_created() {
	}

	public virtual void insert_usage_parameters(UsageInfo ui) {
	}

	public virtual void insert_general_usage_parameters(UsageInfo ui) {
		ui.add_parameter("-v | -verbose", "Verbose output");
		ui.add_parameter("-q | -quiet", "Suppress output completely (silent mode)");
		ui.add_parameter("-help | -h", "Help / usage information");
	}

	public void on_usage(UsageInfo ui) {
		ui.set_param_desc("<action> [parameters]");
		ui.add_section("General parameters");
		insert_general_usage_parameters(ui);
		insert_usage_parameters(ui);
		if(action == null) {
			ui.add_section("Available actions");
			add_usage_actions(ui);
		}
		else {
			action.on_usage(ui);
		}
	}

	public virtual void add_usage_actions(UsageInfo ui) {
	}

	public bool execute() {
		var lg = Log.get_logger();
		lg.set_log_level(myloglevel);
		var lg2 = get_logger();
		if(lg2 != null) {
			lg2.set_log_level(myloglevel);
		}
		if(action != null) {
			var alg = action.get_logger();
			if(alg != null) {
				alg.set_log_level(myloglevel);
			}
		}
		SystemEnvironment.set_env_var("EQ_LOGLEVEL", String.for_integer(myloglevel));
		if(action == null) {
			usage();
			return(false);
		}
		return(action.execute());
	}

	public void cleanup() {
		action = null;
	}
}
