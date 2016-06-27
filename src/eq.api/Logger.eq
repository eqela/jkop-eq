
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

public class Logger
{
	public static Logger for_default() {
		return(new LogImpl());
	}

	property int log_level = 3;
	public String string_error;
	public String string_warning;
	public String string_debug;

	public Logger() {
		string_error = "ERROR";
		string_warning = "WARNING";
		string_debug = "DEBUG";
	}

	public virtual void log(String prefix, String msg, String ident = null) {
	}

	public virtual void log_message(Object o, String ident = null) {
		if(log_level < 3) {
			return;
		}
		log(null, String.as_string(o), ident);
	}

	public virtual void log_error(Object o, String ident = null) {
		if(log_level < 1) {
			return;
		}
		log(string_error, String.as_string(o), ident);
	}

	public virtual void log_warning(Object o, String ident = null) {
		if(log_level < 2) {
			return;
		}
		log(string_warning, String.as_string(o), ident);
	}

	public virtual void log_debug(Object o, String ident = null) {
		if(log_level < 4) {
			return;
		}
		log(string_debug, String.as_string(o), ident);
	}
}
