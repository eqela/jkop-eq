
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

public class NetworkServiceConnection : LoggerObject
{
	TCPSocket socket;
	NetworkService service;

	public virtual void refresh() {
	}

	public virtual void on_maintenance_timer(long now) {
	}

	public String get_remote_address() {
		if(socket == null) {
			return(null);
		}
		return(socket.get_remote_address());
	}

	public NetworkService get_service() {
		return(service);
	}

	public TCPSocket get_socket() {
		return(socket);
	}

	public virtual bool initialize(NetworkService service, TCPSocket socket) {
		this.socket = socket;
		this.service = service;
		return(true);
	}

	public virtual void close() {
		log_debug("NetworkServiceConnection closing");
		if(socket != null) {
			socket.close();
			socket = null;
		}
		if(service != null) {
			var ss = service;
			service = null;
			ss.on_remove(this);
		}
	}
}
