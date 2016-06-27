
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

public class CommandLineApplicationAction : LoggerObject
{
	property CommandLineApplication app;

	public MultiActionCommandLineApplication get_multi_action_application() {
		return(app as MultiActionCommandLineApplication);
	}

	public void usage() {
		if(app != null) {
			app.usage();
		}
	}

	public void set_exit_status(int s) {
		if(app != null) {
			app.set_exit_status(s);
		}
	}

	public void print(Object o, bool err = false) {
		if(app != null) {
			app.print(o, err);
		}
	}

	public void println(Object o = null, bool err = false) {
		if(app != null) {
			app.println(o, err);
		}
	}

	public String readline() {
		if(app != null) {
			return(app.readline());
		}
		return(null);
	}

	public void print_header() {
		if(app != null) {
			app.print_header();
		}
	}

	public virtual bool on_command_line_flag(String flag) {
		return(false);
	}

	public virtual bool on_command_line_option(String key, String value) {
		return(false);
	}

	public virtual bool on_command_line_parameter(String param) {
		return(false);
	}

	public virtual void on_usage(UsageInfo ui) {
	}

	public virtual bool execute() {
		return(true);
	}
}
