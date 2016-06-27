
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

public class SingleActionCommandLineApplication : CommandLineApplication
{
	CommandLineApplicationAction action;

	public SingleActionCommandLineApplication set_action(CommandLineApplicationAction action) {
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

	public void on_usage(UsageInfo ui) {
		if(action != null) {
			action.on_usage(ui);
		}
	}

	public bool on_command_line_flag(String flag) {
		if(action != null) {
			if(action.on_command_line_flag(flag)) {
				return(true);
			}
		}
		return(base.on_command_line_flag(flag));
	}

	public bool on_command_line_option(String key, String value) {
		if(action != null) {
			return(action.on_command_line_option(key, value));
		}
		return(base.on_command_line_option(key, value));
	}

	public bool on_command_line_parameter(String param) {
		if(action != null) {
			return(action.on_command_line_parameter(param));
		}
		return(base.on_command_line_parameter(param));
	}

	public bool execute() {
		if(action != null) {
			return(action.execute());
		}
		return(base.execute());
	}

	public void cleanup() {
		action = null;
	}
}
