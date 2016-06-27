
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

public class NetworkService : LoggerObject, TimerHandler, EventLoopReadListener
{
	Collection connections;
	property TCPSocket socket;
	BackgroundTask timer;
	EventLoopEntry ee;
	property EventLoop eventloop;
	property int maintenance_timer_delay = 60;
	property NetworkServiceConnectionProvider connection_provider;

	public NetworkService() {
		connections = LinkedList.create();
	}

	public Iterator iterate_connections() {
		return(connections.iterate());
	}

	public void refresh() {
		foreach(NetworkServiceConnection c in connections) {
			c.refresh();
		}
	}

	public void close_all_connections() {
		foreach(NetworkServiceConnection c in connections) {
			c.close();
		}
	}

	public bool on_timer(Object arg) {
		var now = SystemClock.seconds();
		foreach(NetworkServiceConnection c in connections) {
			c.on_maintenance_timer(now);
		}
		return(true);
	}

	public virtual NetworkServiceConnection create_connection() {
		if(connection_provider != null) {
			return(connection_provider.create_connection());
		}
		return(null);
	}

	public void on_read_ready() {
		if(socket == null) {
			return;
		}
		var ns = socket.accept();
		if(ns != null) {
			var cc = create_connection();
			if(cc == null) {
				log_error("NetworkService: Received a connection but failed to create connection object! Connection lost");
				return;
			}
			if(cc.initialize(this, ns) == false) {
				log_error("NetworkService: Failed to initialize the connection object for incoming connection. Connection lost");
				ns.close();
			}
			else {
				connections.add(cc);
				log_debug("Received a connection: Now %d connections".printf().add(connections.count()));
			}
		}
	}

	public void on_remove(NetworkServiceConnection conn) {
		if(conn != null) {
			connections.remove(conn);
			log_debug("Removed a connection: Now %d connections".printf().add(connections.count()));
		}
	}

	public bool start(EventLoop eventloop) {
		if(eventloop == null) {
			log_error("NetworkService: No eventloop");
			return(false);
		}
		if(socket == null) {
			log_error("NetworkService: No socket");
			return(false);
		}
		this.eventloop = eventloop;
		ee = eventloop.entry_for_object(socket);
		if(ee == null) {
			log_error("NetworkService: Unable to register listening socket to event loop.");
			return(false);
		}
		ee.set_read_listener(this);
		if(maintenance_timer_delay > 0) {
			timer = eventloop.start_timer(maintenance_timer_delay * 1000000, this);
			if(timer == null) {
				log_warning("NetworkService: FAILED to start maintenance timer. Will not be able to automatically cut idle connections or do other timed actions.");
			}
		}
		log_message("NetworkService: Server initialized");
		return(true);
	}

	public void stop() {
		if(timer != null) {
			timer.abort();
			timer = null;
		}
		close_all_connections();
		if(ee != null) {
			ee.remove();
			ee = null;
		}
		if(socket != null) {
			socket.close();
			socket = null;
		}
		this.eventloop = null;
		log_message("NetworkService: Server ended");
	}
}
