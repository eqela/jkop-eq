
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

public class LoggerObject
{
	public static void set_logger_for_object(Object o, Logger lg) {
		if(o != null && o is LoggerObject) {
			((LoggerObject)o).set_logger(lg);
		}
	}

	property String logger_ident;
	Logger logger;

	public Logger get_logger() {
		if(logger == null) {
			return(Log.get_logger());
		}
		return(logger);
	}

	public LoggerObject set_logger(Logger logger) {
		this.logger = logger;
		on_logger_changed();
		return(this);
	}

	public virtual void on_logger_changed() {
	}

	public virtual bool is_log_debug() {
		return(get_log_level() >= Log.LOG_LEVEL_DEBUG);
	}

	public virtual void set_log_level(int level) {
		var lg = get_logger();
		if(lg != null) {
			lg.set_log_level(level);
		}
	}

	public virtual int get_log_level() {
		var lg = logger;
		if(lg == null) {
			lg = Log.get_logger();
		}
		if(lg == null) {
			return(Log.LOG_LEVEL_QUIET);
		}
		return(lg.get_log_level());
	}

	public virtual void log_message(Object o, String ident = null) {
		var ii = ident;
		if(ii == null) {
			ii = logger_ident;
		}
		Log.message(o, logger, ii);
	}

	public virtual void log_error(Object o, String ident = null) {
		var ii = ident;
		if(ii == null) {
			ii = logger_ident;
		}
		Log.error(o, logger, ii);
	}

	public virtual void log_warning(Object o, String ident = null) {
		var ii = ident;
		if(ii == null) {
			ii = logger_ident;
		}
		Log.warning(o, logger, ii);
	}

	public virtual void log_debug(Object o, String ident = null) {
		var ii = ident;
		if(ii == null) {
			ii = logger_ident;
		}
		Log.debug(o, logger, ii);
	}
}
