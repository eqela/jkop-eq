
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

public class SMTPSender : LoggerObject
{
	public static SMTPSender for_server_address(String name, BackgroundTaskManager btm) {
		return(new SMTPSender().set_this_server_address(name).set_background_task_manager(btm));
	}

	public static SMTPSender for_configuration(HashTable config, BackgroundTaskManager btm) {
		return(new SMTPSender().set_background_task_manager(btm).configure(config));
	}

	property String this_server_address;
	property String server;
	String server_internal;
	property String my_name;
	property String my_address;
	property BackgroundTaskManager background_task_manager;
	property int max_sender_count = 0;
	int sender_count = 0;

	public SMTPSender() {
		this_server_address = "unknown.server.com";
	}

	public String get_description() {
		var sb = StringBuffer.for_initial_size(512);
		if(String.is_empty(my_name) == false) {
			sb.append_c((int)'"');
			sb.append(my_name);
			sb.append_c((int)'"');
		}
		if(String.is_empty(my_address) == false) {
			var hasname = false;
			if(sb.count() > 0) {
				hasname = true;
			}
			if(hasname) {
				sb.append_c((int)' ');
				sb.append_c((int)'<');
			}
			sb.append(my_address);
			if(hasname) {
				sb.append_c((int)'>');
			}
		}
		var s = server_internal;
		if(String.is_empty(s)) {
			s = server;
		}
		if(String.is_empty(s) == false) {
			sb.append_c((int)' ');
			sb.append_c((int)'(');
			sb.append(s);
			sb.append_c((int)')');
		}
		if(sb.count() < 1) {
			sb.append("(no configuration; raw passhtrough of messages)");
		}
		return(sb.to_string());
	}

	public SMTPSender configure(HashTable config) {
		if(config == null) {
			return(this);
		}
		var default_port = "25";
		var scheme = config.get_string("server_type", "smtp");
		if("smtp+ssl".equals(scheme)) {
			default_port = "465";
		}
		var url = new URL()
			.set_scheme(scheme)
			.set_username(URLEncoder.encode(config.get_string("server_username")))
			.set_password(URLEncoder.encode(config.get_string("server_password")))
			.set_host(config.get_string("server_address"))
			.set_port(config.get_string("server_port", default_port));
		set_server(url.to_string());
		url.set_password(null);
		server_internal = url.to_string();
		set_my_name(config.get_string("sender_name", "eq.net.smtpclient"));
		set_my_address(config.get_string("sender_address", "my@address.com"));
		set_this_server_address(config.get_string("this_server_address", this_server_address));
		return(this);
	}

	class MyEventReceiver : EventReceiver
	{
		property SMTPSenderListener listener;
		property SMTPSender sender;
		public void on_event(Object o) {
			var et = o as SMTPClientResult;
			if(et == null) {
				return;
			}
			if(sender != null) {
				sender.on_send_end();
			}
			if(listener == null) {
				return;
			}
			listener.on_smtp_send_complete(et.get_message(), et);
		}
	}

	public void on_send_start() {
		sender_count ++;
		log_debug("SMTP send start: Now %d senders".printf().add(sender_count));
	}

	public void on_send_end() {
		sender_count --;
		log_debug("SMTP send end: Now %d senders".printf().add(sender_count));
	}

	public void send(SMTPMessage msg, SMTPSenderListener listener) {
		if(msg == null) {
			if(listener != null) {
				listener.on_smtp_send_complete(msg, SMTPClientResult.for_error("No message to send"));
			}
			return;
		}
		if(Collection.is_empty(msg.get_all_rcpts())) {
			if(listener != null) {
				listener.on_smtp_send_complete(msg, SMTPClientResult.for_success());
			}
			return;
		}
		if(background_task_manager == null) {
			Log.error("SMTPSender.send: No background task manager!");
			if(listener != null) {
				listener.on_smtp_send_complete(msg, SMTPClientResult.for_error("SMTPSender has no background task manager"));
			}
			return;
		}
		if(max_sender_count > 0 && sender_count > max_sender_count) {
			log_warning("Reached maximum sender count %d".printf().add(max_sender_count));
			if(listener != null) {
				listener.on_smtp_send_complete(msg, SMTPClientResult.for_error("Maximum number of SMTP senders has been exceeded."));
			}
			return;
		}
		if(String.is_empty(my_name) == false) {
			msg.set_my_name(my_name);
		}
		if(String.is_empty(my_address) == false) {
			msg.set_my_address(my_address);
		}
		var sct = new SMTPClientTask();
		if(String.is_empty(server) == false) {
			sct.set_server(URL.for_string(server));
		}
		sct.set_server_address(this_server_address);
		sct.set_msg(msg);
		if(background_task_manager.start_task(sct, new MyEventReceiver().set_listener(listener).set_sender(this)) == null) {
			log_error("Failed to start SMTP sender background task");
			if(listener != null) {
				listener.on_smtp_send_complete(msg, SMTPClientResult.for_error("Failed to start SMTP sender background task"));
			}
			return;
		}
		on_send_start();
	}
}
