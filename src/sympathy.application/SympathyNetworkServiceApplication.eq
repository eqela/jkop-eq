
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

public class SympathyNetworkServiceApplication : SympathyApplication
{
	class NetworkServiceEntry
	{
		property NetworkService service;
		property int port;
	}

	Collection services;

	public virtual void add_services() {
	}

	public void add_service(int port, NetworkService service) {
		if(service == null || port < 1) {
			return;
		}
		if(services == null) {
			services = LinkedList.create();
		}
		services.add(new NetworkServiceEntry()
			.set_service(service)
			.set_port(port));
	}

	TCPSocket open_listening_socket(int port) {
		if(port < 1 || port > 65535) {
			log_error("Invalid TCP port %d".printf().add(port));
			return(null);
		}
		var ss = TCPSocket.create();
		if(ss == null) {
			log_error("Failed to create a TCP socket for listening.");
			return(null);
		}
		if(ss.listen(port) == false) {
			log_error("FAILED to bind port %d for listening".printf().add(port));
			return(null);
		}
		log_debug("Listening on TCP port '%d'".printf().add(port).to_string());
		return(ss);
	}

	public bool early_initialize() {
		if(base.early_initialize() == false) {
			return(false);
		}
		add_services();
		foreach(NetworkServiceEntry nse in services) {
			var srv = nse.get_service();
			if(srv == null) {
				continue;
			}
			var ss = open_listening_socket(nse.get_port());
			if(ss == null) {
				return(false);
			}
			srv.set_socket(ss);
		}
		return(true);
	}

	public bool initialize() {
		if(base.initialize() == false) {
			return(false);
		}
		var eventloop = get_event_loop();
		foreach(NetworkServiceEntry service in services) {
			var srv = service.get_service();
			if(srv == null) {
				continue;
			}
			if(srv.start(eventloop) == false) {
				log_error("Failed to start a service.");
				return(false);
			}
		}
		return(true);
	}

	public void cleanup() {
		log_debug("Stopping network services ..");
		foreach(NetworkServiceEntry service in services) {
			var srv = service.get_service();
			if(srv == null) {
				continue;
			}
			srv.stop();
		}
		base.cleanup();
	}
}
