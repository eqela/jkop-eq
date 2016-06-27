
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

public class SympathyWebServerComponent : LoggerObject, SympathyComponent, HTTPServerDelegate
{
	public static SympathyWebServerComponent for_event_loop(EventLoop eventloop) {
		return(new SympathyWebServerComponent().set_event_loop(eventloop));
	}

	HTTPServer server;
	Collection ports;
	Collection vhosts;
	HTTPRequestHandler request_handler;
	property HTTPRequestLogger request_logger;
	property EventLoop event_loop;
	property bool allow_cors = false;
	property bool debug = false;
	HTTPRequestLogger debug_request_logger;
	bool initialized = false;

	public void add_port(int port) {
		if(ports == null) {
			ports = LinkedList.create();
		}
		ports.append(port);
	}

	public void add_vhost(String vhost) {
		if(vhost == null) {
			return;
		}
		if(vhosts == null) {
			vhosts = LinkedList.create();
		}
		vhosts.append(vhost);
	}

	public Collection get_ports() {
		return(ports);
	}

	public Collection get_vhosts() {
		return(vhosts);
	}

	public void on_refresh() {
		var lf = request_handler as HTTPRequestHandlerWithLifeCycle;
		if(lf != null) {
			lf.on_refresh();
		}
	}

	public void on_maintenance() {
		if(server != null) {
			server.on_maintenance();
		}
		var lf = request_handler as HTTPRequestHandlerWithLifeCycle;
		if(lf != null) {
			lf.on_maintenance();
		}
	}

	public HTTPResponse create_options_response(HTTPRequest req) {
		return(null);
	}

	public HTTPRequestBodyHandler get_request_body_handler(HTTPRequest req) {
		if(request_handler != null) {
			return(request_handler.get_request_body_handler(req));
		}
		return(null);
	}

	public bool on_unhandled_request(HTTPRequest req) {
		return(false);
	}

	public bool on_http_request(HTTPRequest req) {
		if(request_handler != null) {
			return(request_handler.on_http_request(req));
		}
		return(false);
	}

	public void on_request_complete(HTTPRequest request, HTTPResponse resp, int bytes_sent, String remote_address) {
		if(debug) {
			if(debug_request_logger == null) {
				debug_request_logger = new HTTPRequestLoggerCommon();
			}
			debug_request_logger.log_http_transaction(request, resp, bytes_sent, remote_address);
		}
		if(request_logger != null) {
			request_logger.log_http_transaction(request, resp, bytes_sent, remote_address);
		}
	}

	public virtual HTTPServer create_http_server() {
		return(new HTTPServer());
	}

	public bool early_initialize() {
		server = create_http_server();
		if(server == null) {
			return(false);
		}
		server.set_allow_cors(allow_cors);
		server.set_delegate(this);
		configure_http_server(server);
		if(server.open_listener_sockets() == false) {
			return(false);
		}
		return(true);
	}

	public virtual void configure_http_server(HTTPServer server) {
		foreach(Integer i in ports) {
			server.add_listener_port_http(i.to_integer());
		}
		foreach(String s in vhosts) {
			server.add_listener_host_vhsd(s);
		}
	}

	public SympathyWebServerComponent set_request_handler(HTTPRequestHandler h) {
		if(initialized) {
			var rf = request_handler as HTTPRequestHandlerWithLifeCycle;
			if(rf != null) {
				rf.cleanup();
			}
		}
		request_handler = h;
		if(initialized) {
			var rf = request_handler as HTTPRequestHandlerWithLifeCycle;
			if(rf != null) {
				rf.initialize();
			}
		}
		return(this);
	}

	public HTTPRequestHandler get_request_handler() {
		return(request_handler);
	}

	public bool initialize() {
		if(server == null) {
			log_error("No HTTP server (?!)");
			return(false);
		}
		if(server.start(get_event_loop()) == false) {
			return(false);
		}
		var lf = request_handler as HTTPRequestHandlerWithLifeCycle;
		if(lf != null) {
			lf.initialize();
		}
		log_message("Web server component successfully initialized.");
		if(Collection.is_empty(ports)) {
			log_message("NOT listening on any TCP port.");
		}
		else {
			foreach(Integer port in ports) {
				log_message("Listening on HTTP port: %d".printf().add(port));
			}
		}
		if(Collection.is_empty(vhosts)) {
			log_message("NOT listening on any virtual host.");
		}
		else {
			foreach(String vhost in vhosts) {
				log_message("Listening for virtual host connections: `%s'".printf().add(vhost));
			}
		}
		initialized = true;
		return(true);
	}

	public void cleanup() {
		var lf = request_handler as HTTPRequestHandlerWithLifeCycle;
		if(lf != null) {
			lf.cleanup();
		}
		if(server != null) {
			log_debug("Shutting down the HTTP server ..");
			server.stop();
			server.set_delegate(null);
			server = null;
		}
		initialized = false;
	}
}
