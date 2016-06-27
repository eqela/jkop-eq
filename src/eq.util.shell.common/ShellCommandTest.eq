
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

public class ShellCommandTest : ShellInternalExecutable
{
	String op;
	String test;
	String fail_message;

	public bool on_command_line_argument(String arg) {
		if(op == null) {
			op = arg;
			return(true);
		}
		if(test == null) {
			test = arg;
			return(true);
		}
		if(fail_message == null) {
			fail_message = arg;
			return(true);
		}
		return(false);
	}

	int success() {
		return(0);
	}

	int fail() {
		if(String.is_empty(fail_message) == false) {
			log_error(fail_message);
		}
		return(1);
	}

	public int execute_main() {
		// check if a file exists
		if("-e".equals(op)) {
			var ff = File.for_native_path(test, get_cwd());
			if(ff.exists()) {
				return(success());
			}
			return(fail());
		}
		// check if a file does not exist
		if("-ne".equals(op)) {
			var ff = File.for_native_path(test, get_cwd());
			if(ff.exists() == false) {
				return(success());
			}
			return(fail());
		}
		// check if a file exists and is a file
		if("-f".equals(op)) {
			var ff = File.for_native_path(test, get_cwd());
			if(ff.is_file()) {
				return(success());
			}
			return(fail());
		}
		// check if a file is not a file
		if("-nf".equals(op)) {
			var ff = File.for_native_path(test, get_cwd());
			if(ff.is_file() == false) {
				return(success());
			}
			return(fail());
		}
		// check if a file exists and is a directory
		if("-d".equals(op)) {
			var ff = File.for_native_path(test, get_cwd());
			if(ff.is_directory()) {
				return(success());
			}
			return(fail());
		}
		// check if a file is not a directory
		if("-nd".equals(op)) {
			var ff = File.for_native_path(test, get_cwd());
			if(ff.is_directory() == false) {
				return(success());
			}
			return(fail());
		}
		// check if the parameter is empty
		if("-z".equals(op)) {
			if(String.is_empty(test)) {
				return(success());
			}
			return(fail());
		}
		// check if the parameter is non-empty
		if("-nz".equals(op)) {
			if(String.is_empty(test) == false) {
				return(success());
			}
			return(fail());
		}
		log_error("Unknown operation: `%s'".printf().add(op));
		return(1);
	}
}
