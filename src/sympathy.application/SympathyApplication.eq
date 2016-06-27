
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

public class SympathyApplication : CommandLineApplication, ConsoleApplication
{
	class UidInfo
	{
		public int uid = 0;
		public int gid = 0;
	}

	class MyMaintenanceTimer : TimerHandler
	{
		property SympathyApplication app;
		public bool on_timer(Object arg) {
			app.on_maintenance();
			return(true);
		}
	}

	UidInfo uidinfo;
	EventLoop eventloop;
	property bool debug;
	property String logmode;
	PosixEnvironment posix;
	File datadir;
	property bool require_datadir = false;
	property int maintenance_timer_delay = 30 * 60;
	BackgroundTask maintenance_timer;
	Collection components;
	bool initialized = false;

	public SympathyApplication() {
		posix = PosixEnvironment.instance();
		debug = false;
		logmode = "console";
	}

	public void add_component(SympathyComponent comp) {
		if(comp == null) {
			return;
		}
		if(components == null) {
			components = LinkedList.create();
		}
		bool v = true;
		if(initialized) {
			v = comp.initialize();
		}
		if(v) {
			components.append(comp);
		}
	}

	public File get_datadir() {
		return(datadir);
	}

	public File get_datadir_file(String file) {
		if(datadir == null) {
			return(null);
		}
		if(String.is_empty(file)) {
			return(datadir);
		}
		return(datadir.entry(file));
	}

	public EventLoop get_event_loop() {
		return(eventloop);
	}

	public virtual void on_maintenance() {
		log_debug("Running maintenance timer ..");
		foreach(SympathyComponent comp in components) {
			comp.on_maintenance();
		}
	}

	public void on_refresh() {
		foreach(SympathyComponent comp in components) {
			comp.on_refresh();
		}
	}

	public BackgroundTask start_timer(int delay, TimerHandler handler) {
		var eventloop = get_event_loop();
		if(eventloop == null) {
			return(null);
		}
		return(eventloop.start_timer(delay, handler));
	}

	public void set_run_as_uid_gid(int uid, int gid) {
		uidinfo = new UidInfo();
		uidinfo.uid = uid;
		uidinfo.gid = gid;
	}

	public bool set_run_as_nobody() {
		return(set_run_as_user("nobody"));
	}

	public bool set_run_as_user(String username) {
		if(posix == null) {
			log_error("set_run_as_user: No posix environment.");
			return(false);
		}
		var us = posix.getpwnam(username);
		if(us == null) {
			log_error("User not found: %s".printf().add(username));
			return(false);
		}
		set_run_as_uid_gid(us.get_pw_uid(), us.get_pw_gid());
		return(true);
	}

	public void on_close() {
		log_debug("CLOSE request: Closing the application");
		if(eventloop != null) {
			eventloop.stop();
		}
		else {
			SystemEnvironment.terminate(1);
		}
	}

	public void on_usage(UsageInfo ui) {
		base.on_usage(ui);
		ui.add_option("debug", "true|false", "Toggle debug output / logging");
		ui.add_option("logmode", "console|none|file:..", "Select logging mode for application messages");
		ui.add_option("maintenance", "seconds", "Set the delay of the maintenance driver (0 to disable, default %d)".printf().add(maintenance_timer_delay).to_string());
		if(posix != null) {
			ui.add_option("user", "username", "Specify a username to run the program as");
		}
	}

	public bool on_command_line_flag(String flag) {
		if("debug".equals(flag)) {
			debug = true;
			return(true);
		}
		return(base.on_command_line_flag(flag));
	}

	public bool on_command_line_option(String key, String value) {
		if("maintenance".equals(key)) {
			if(value != null) {
				maintenance_timer_delay = value.to_integer();
			}
			return(true);
		}
		if("debug".equals(key)) {
			debug = Boolean.as_boolean(value);
			return(true);
		}
		if("logmode".equals(key)) {
			logmode = value;
			return(true);
		}
		if(posix != null) {
			if("user".equals(key)) {
				if(set_run_as_user(value) == false) {
					log_error("Failed to configure as user id: `%s'".printf().add(value));
					return(false);
				}
				return(true);
			}
		}
		return(base.on_command_line_option(key, value));
	}

	public bool on_command_line_parameter(String param) {
		if(datadir == null) {
			datadir = File.for_native_path(param);
			if(datadir.is_directory() == false) {
				datadir = null;
			}
			return(true);
		}
		return(base.on_command_line_parameter(param));
	}

	public virtual bool early_initialize() {
		foreach(SympathyComponent comp in components) {
			if(comp.early_initialize() == false) {
				return(false);
			}
		}
		return(true);
	}

	public KeyValueList read_datadir_config_file(String id) {
		if(String.is_empty(id)) {
			return(null);
		}
		var ff = get_datadir_file(id.append(".config"));
		if(ff == null) {
			return(null);
		}
		if(ff.is_file() == false) {
			log_debug("Configuration file does not exist: `%s' ..".printf().add(ff));
			return(null);
		}
		log_debug("Reading configuration file `%s' ..".printf().add(ff));
		var cf = ConfigFile.for_file(ff);
		if(cf == null) {
			return(null);
		}
		return(cf.get_data());
	}

	public virtual EventLoop create_eventloop() {
		IFDEF("target_linux") {
			return(EventLoopEpoll.instance(get_logger()));
		}
		ELSE {
			return(EventLoop.for_network(get_logger()));
		}
	}

	public virtual void initialize_components() {
	}

	public bool initialize() {
		if(base.initialize() == false) {
			return(false);
		}
		if(debug) {
			Log.set_log_level(Log.LOG_LEVEL_DEBUG);
		}
		if("none".equals(logmode)) {
			Log.set_logger(new NullLogger());
		}
		print_header();
		if(require_datadir) {
			if(datadir == null) {
				log_error("A data directory must be supplied as a command line parameter.");
				return(false);
			}
		}
		if(datadir != null) {
			log_debug("%s: Data directory is `%s'".printf().add(Application.get_display_name()).add(datadir));
			datadir.mkdir_recursive();
			if(datadir.is_directory() == false) {
				log_error("Failed to create data directory: `%s'".printf().add(datadir));
				return(false);
			}
		}
		eventloop = create_eventloop();
		if(eventloop == null) {
			log_error("Failed to create an event loop");
			return(false);
		}
		initialize_components();
		if(early_initialize() == false) {
			log_debug("Early initialization failed.");
			return(false);
		}
		if(uidinfo != null) {
			if(posix == null) {
				log_error("No posix environment. Unable to set uid/gid.");
				return(false);
			}
			log_debug("Setting process GID to %d".printf().add(uidinfo.gid));
			if(posix.setgid(uidinfo.gid) == false) {
				log_error("Failed to set process gid to %d".printf().add(uidinfo.gid));
				return(false);
			}
			log_debug("Setting process UID to %d".printf().add(uidinfo.gid));
			if(posix.setuid(uidinfo.uid) == false) {
				log_error("Failed to set process uid to %d".printf().add(uidinfo.uid));
				return(false);
			}
		}
		if("console".equals(logmode)) {
			; // default
		}
		else if(logmode.has_prefix("file:")) {
			var logdirname = logmode.substring(5);
			if(String.is_empty(logdirname)) {
				log_error("No logdir supplied as part of logmode");
				return(false);
			}
			// we only do this here after setting the uid/gid so that the file ownership
			// of our logfiles will be under the actual user. we may miss a few lines from
			// early_initialize though, but what can you do ...
			var logdir = File.for_native_path(logdirname);
			var logger = DirectoryLogger.for_directory(logdir);
			logger.set_log_level(Log.get_log_level());
			Log.set_logger(logger);
		}
		else if("none".equals(logmode)) {
			; // already handled above
		}
		else {
			log_error("Unknown logging mode: `%s'".printf().add(logmode));
		}
		if(maintenance_timer_delay > 0) {
			log_debug("Starting maintenance timer, delay=%d".printf().add(maintenance_timer_delay));
			maintenance_timer = start_timer(1000000 * maintenance_timer_delay, new MyMaintenanceTimer().set_app(this));
			if(maintenance_timer == null) {
				log_error("FAILED to start maintenance timer!");
			}
		}
		else {
			log_debug("Not starting maintenance timer");
		}
		foreach(SympathyComponent comp in components) {
			if(comp.initialize() == false) {
				return(false);
			}
		}
		initialized = true;
		return(true);
	}

	public bool execute() {
		log_message("Application successfully initialized. Entering event loop.");
		eventloop.execute();
		log_message("Event loop exited.");
		return(true);
	}

	public void cleanup() {
		log_debug("SympathyApplication: Cleaning up.");
		if(maintenance_timer != null) {
			maintenance_timer.abort();
			maintenance_timer = null;
		}
		this.eventloop = null;
		foreach(SympathyComponent comp in components) {
			comp.cleanup();
		}
		initialized = false;
		base.cleanup();
	}
}
