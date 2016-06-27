
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

public class BufferedNetworkServiceConnection : NetworkServiceConnection, EventLoopReadListener, EventLoopWriteListener
{
	long last_activity_time;
	EventLoopEntry ee;
	property DynamicBuffer receive_buffer;
	Queue send_queue;
	property bool full_duplex = true;
	property int send_buffer_backlog_limit = -1;
	property int idle_timeout = -1;

	public BufferedNetworkServiceConnection() {
		send_queue = Queue.create();
		allocate_receive_buffer(4096);
	}

	public virtual void on_connected() {
	}

	public virtual void on_disconnecting() {
	}

	public virtual void on_disconnected() {
	}

	public virtual void on_buffer_received(Buffer data) {
	}

	public long get_last_activity_time() {
		return(last_activity_time);
	}

	public void on_maintenance_timer(long now) {
		base.on_maintenance_timer(now);
		if(idle_timeout > 0 && last_activity_time < now - idle_timeout) {
			log_debug("Idle timeout %d has been reached. Closing connection.".printf().add(idle_timeout));
			close();
		}
	}

	public void allocate_receive_buffer(int sz) {
		receive_buffer = DynamicBuffer.create(sz);
	}

	public bool initialize(NetworkService service, TCPSocket socket) {
		if(base.initialize(service, socket) == false) {
			return(false);
		}
		if(service == null) {
			log_error("BufferedNetworkServiceConnection: No service supplied.");
			return(false);
		}
		last_activity_time = SystemClock.seconds();
		var el = service.get_eventloop();
		if(el == null) {
			log_error("BufferedNetworkServiceConnection: No event loop");
			return(false);
		}
		ee = el.entry_for_object(socket);
		if(ee == null) {
			log_error("BufferedNetworkServiceConnection: Unable to add new socket to event loop");
			return(false);
		}
		ee.set_listeners(this, null);
		on_connected();
		return(true);
	}

	public void close() {
		on_disconnecting();
		if(ee != null) {
			ee.remove();
			ee = null;
		}
		base.close();
		on_disconnected();
	}

	public void send_buffer(Buffer data) {
		if(data == null || ee == null) {
			return;
		}
		send_queue.push(data);
		if(send_buffer_backlog_limit > 0 && send_queue.count() > send_buffer_backlog_limit) {
			log_debug("Connection has reached maximum send buffer backlog %d. Closing connection".printf().add(send_buffer_backlog_limit));
			close();
			return;
		}
		if(full_duplex) {
			ee.set_listeners(this, this);
		}
		else {
			ee.set_listeners(null, this);
		}
	}

	public void on_read_ready() {
		last_activity_time = SystemClock.seconds();
		var socket = get_socket();
		int r = socket.read(receive_buffer);
		if (r <= 0) {
			close();
			return;
		}
		if(r == receive_buffer.get_size()) {
			on_buffer_received(receive_buffer);
		}
		else {
			on_buffer_received(SubBuffer.create(receive_buffer, 0, r));
		}
	}

	public void on_write_ready() {
		write_to_socket();
		last_activity_time = SystemClock.seconds();
	}

	void write_to_socket() {
		var socket = get_socket();
		var send_buffer = send_queue.pop() as Buffer;
		if(send_buffer != null) {
			int r = socket.write(send_buffer);
			if(r < 0) {
				close();
			}
			else {
				if(r < send_buffer.get_size()) {
					int osz = send_buffer.get_size();
					send_queue.push_first(SubBuffer.create(send_buffer, r, osz - r));
				}
			}
		}
		if(send_queue.count() < 1) {
			ee.set_listeners(this, null);
		}
	}
}
