
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

public class Log
{
	public static int LOG_LEVEL_QUIET = 0;
	public static int LOG_LEVEL_ERROR = 1;
	public static int LOG_LEVEL_WARNING = 2;
	public static int LOG_LEVEL_MESSAGE = 3;
	public static int LOG_LEVEL_DEBUG = 4;
	static Logger logger;

	public static void set_logger(Logger lg) {
		logger = lg;
	}

	public static Logger get_logger() {
		if(logger == null) {
			logger = new LogImpl();
		}
		return(logger);
	}

	public static void set_log_level(int n) {
		var lg = get_logger();
		if(lg != null) {
			lg.set_log_level(n);
		}
	}

	public static int get_log_level(Logger lg = null) {
		if(lg != null) {
			return(lg.get_log_level());
		}
		return(get_logger().get_log_level());
	}

	public static void message(Object o, Logger lg = null, String ident = null) {
		if(lg != null) {
			lg.log_message(o, ident);
		}
		else {
			get_logger().log_message(o, ident);
		}
	}

	public static void error(Object o, Logger lg = null, String ident = null) {
		if(lg != null) {
			lg.log_error(o, ident);
		}
		else {
			get_logger().log_error(o, ident);
		}
	}

	public static void warning(Object o, Logger lg = null, String ident = null) {
		if(lg != null) {
			lg.log_warning(o, ident);
		}
		else {
			get_logger().log_warning(o, ident);
		}
	}

	public static void debug(Object o, Logger lg = null, String ident = null) {
		if(lg != null) {
			lg.log_debug(o, ident);
		}
		else {
			get_logger().log_debug(o, ident);
		}
	}
}
