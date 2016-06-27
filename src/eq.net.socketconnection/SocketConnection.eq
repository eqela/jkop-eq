
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

public class SocketConnection : LoggerObject
{
	SocketConnectionSessionBase session;
	BackgroundTaskManager btm;
	String address;
	int port;
	bool persistent_connection;
	long last_connection_start;
	property int reconnect_delay = 60;
	BackgroundTask reconnect_timer;

	public void start_connection(String aaddress, int aport, bool persistent, BackgroundTaskManager background_task_manager) {
		stop_connection();
		if(background_task_manager == null) {
			on_connection_error("no_background_task_manager");
			on_connection_ended();
			return;
		}
		btm = background_task_manager;
		session = new SocketConnectionSession();
		session.set_logger(get_logger());
		session.set_socket(this);
		session.set_btmgr(background_task_manager);
		port = aport;
		address = aaddress;
		persistent_connection = persistent;
		if(address != null && address.chr((int)':') >= 0) {
			var sp = StringSplitter.split(address, (int)':', 2);
			address = sp.next() as String;
			var pp = sp.next() as String;
			if(pp != null) {
				port = pp.to_integer();
			}
		}
		session.connect(address, port);
		on_connection_started();
	}

	public void stop_connection() {
		persistent_connection = false;
		close_connection();
		if(reconnect_timer != null) {
			reconnect_timer.abort();
			reconnect_timer = null;
		}
		btm = null;
		address = null;
		port = -1;
	}

	public void close_connection() {
		if(session != null) {
			session.close();
		}
	}

	public void restart_connection() {
		start_connection(address, port, persistent_connection, btm);
	}

	public String get_address() {
		return(address);
	}

	public int get_port() {
		return(port);
	}

	public BackgroundTaskManager get_background_task_manager() {
		return(btm);
	}

	public bool send(Buffer data) {
		if(session == null) {
			return(false);
		}
		return(session.send(data));
	}

	public virtual void on_data_received(Buffer data) {
	}

	public virtual void on_connection_started() {
		last_connection_start = SystemClock.seconds();
	}

	public virtual void on_connection_opened() {
	}

	public virtual void on_connection_error(String err) {
	}

	public virtual void on_connection_reconnect(int delay) {
	}

	class ReconnectTimerHandler : TimerHandler
	{
		property SocketConnection connection;
		public bool on_timer(Object arg) {
			connection.restart_connection();
			return(false);
		}
	}

	public virtual void on_connection_ended() {
		if(session != null) {
			session.set_socket(null);
			session = null;
		}
		if(reconnect_timer != null) {
			reconnect_timer.abort();
			reconnect_timer = null;
		}
		if(persistent_connection) {
			var diff = SystemClock.seconds() - last_connection_start;
			if(diff < reconnect_delay) {
				Log.debug("Reconnection diff is less than %d. Waiting for %d seconds to reconnect ..".printf().add(reconnect_delay).add(reconnect_delay));
				if(btm != null) {
					reconnect_timer = btm.start_timer(reconnect_delay * 1000000, new ReconnectTimerHandler().set_connection(this));
				}
				on_connection_reconnect(reconnect_delay);
			}
			else {
				on_connection_reconnect(0);
				restart_connection();
			}
		}
	}
}
