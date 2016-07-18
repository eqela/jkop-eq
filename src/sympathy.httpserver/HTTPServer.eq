
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

public class HTTPServer : LoggerObject
{
	class PortInfo
	{
		property int port;
		property TCPSocket socket;
		property File ssl_certificate;
		property File ssl_private_key;
	}

	property HTTPServerDelegate delegate;
	LinkedList connections;
	BackgroundTask timer_timeout;
	property EventLoop eventloop;
	property int timeout = 30;
	property String server_name;
	property String server_url;
	property bool allow_cors = false;
	String str_options;
	property bool enable_caching = true;
	Collection listen_ports;
	Collection virtual_hosts;
	Collection listeners;
	ContentCache cache;

	public HTTPServer() {
		server_name = "Sympathy/%s".printf().add(VALUE("version")).to_string();
		server_url = "http://sympathy.ws";
		connections = LinkedList.create();
		str_options = "OPTIONS";
	}

	public void add_listener_port_http(int port) {
		if(port < 1) {
			return;
		}
		if(listen_ports == null) {
			listen_ports = LinkedList.create();
		}
		listen_ports.add(new PortInfo().set_port(port));
	}

	public void add_listener_port_https(int port, File ssl_certificate, File ssl_private_key) {
		if(port < 1) {
			return;
		}
		if(listen_ports == null) {
			listen_ports = LinkedList.create();
		}
		listen_ports.add(new PortInfo().set_port(port).set_ssl_certificate(ssl_certificate)
			.set_ssl_private_key(ssl_private_key));
	}

	public void add_listener_host_vhsd(String vhost) {
		if(vhost == null) {
			return;
		}
		if(virtual_hosts == null) {
			virtual_hosts = LinkedList.create();
		}
		virtual_hosts.add(vhost);
	}

	public bool open_listener_sockets() {
		foreach(PortInfo pi in listen_ports) {
			var socket = TCPSocket.for_listen_port(pi.get_port());
			if(socket == null) {
				log_error("FAILED to open listening port: %d".printf().add(pi.get_port()));
				return(false);
			}
			log_debug("Opened port %d for incoming TCP connections.".printf().add(pi.get_port()));
			pi.set_socket(socket);
		}
		return(true);
	}

	public virtual void refresh() {
	}

	public bool on_timeout_timer() {
		var now = SystemClock.seconds();
		Collection cfc;
		foreach(HTTPServerConnection wsc in connections) {
			if(wsc.get_responses() >= wsc.get_requests() && now - wsc.get_last_activity() >= timeout) {
				wsc.log_debug("Connection timed out.");
				if(cfc == null) {
					cfc = LinkedList.create();
				}
				cfc.add(wsc);
			}
		}
		foreach(HTTPServerConnection wsc in cfc) {
			wsc.close();
		}
		return(true);
	}

	class MyTimeoutTimer : TimerHandler
	{
		property HTTPServer server;
		public bool on_timer(Object arg) {
			if(server != null) {
				return(server.on_timeout_timer());
			}
			return(false);
		}
	}

	public BackgroundTask start_timer(int delay, TimerHandler handler) {
		if(eventloop == null) {
			return(null);
		}
		return(eventloop.start_timer(delay, handler));
	}

	public virtual void on_maintenance() {
		log_debug("HTTPServer: Running maintenance timer ..");
		if(cache != null) {
			cache.on_maintenance();
		}
	}

	public virtual Collection initialize_listeners() {
		var listeners = LinkedList.create();
		foreach(PortInfo pi in listen_ports) {
			var socket = pi.get_socket();
			HTTPServerSocketListener ll;
			if(socket == null) {
				ll = HTTPServerSocketListener.create(String.for_integer(pi.get_port()), this);
			}
			else {
				ll = HTTPServerSocketListener.for_socket(socket, this);
			}
			if(ll == null) {
				return(null);
			}
			ll.set_ssl_certificate(pi.get_ssl_certificate());
			ll.set_ssl_private_key(pi.get_ssl_private_key());
			listeners.add(ll);
		}
		foreach(String vhost in virtual_hosts) {
			var ll = HTTPServerVirtualHostListener.create(vhost, this);
			if(ll == null) {
				return(null);
			}
			listeners.add(ll);
		}
		return(listeners);
	}

	public virtual bool initialize() {
		var v = do_initialize();
		if(v == false) {
			undo_initialize();
		}
		return(v);
	}

	bool do_initialize() {
		listeners = initialize_listeners();
		if(listeners == null) {
			log_error("Failed to initialize listeners.");
			return(false);
		}
		if(this.timeout < 1) {
			log_debug("Timeout timer disabled");
		}
		else {
			log_debug("HTTPServer: Starting a timeout timer with a %d second delay.".printf().add(this.timeout));
			timer_timeout = start_timer(1000000 * this.timeout, new MyTimeoutTimer().set_server(this));
			if(timer_timeout == null) {
				log_error("HTTPServer: FAILED to start the timeout timer!");
			}
		}
		return(true);
	}

	void undo_initialize() {
		foreach(var ll in listeners) {
			if(ll is HTTPServerSocketListener) {
				((HTTPServerSocketListener)ll).close();
			}
			else if(ll is HTTPServerVirtualHostListener) {
				((HTTPServerVirtualHostListener)ll).close();
			}
		}
		listeners = null;
		if(timer_timeout != null) {
			timer_timeout.abort();
			timer_timeout = null;
		}
	}

	public virtual void cleanup() {
		undo_initialize();
	}

	public bool start(EventLoop el = null) {
		if(el != null) {
			this.eventloop = el;
		}
		if(this.eventloop == null) {
			return(false);
		}
		if(initialize() == false) {
			return(false);
		}
		return(true);
	}

	public void stop() {
		cleanup();
		this.eventloop = null;
	}

	public void on_new_client_socket(ConnectedSocket sc) {
		if(sc != null) {
			if(sc is TCPSocket) {
				((TCPSocket)sc).set_blocking(false);
			}
			var oo = new HTTPServerConnection().initialize(this, sc);
			if(oo != null) {
				var nn = LinkedListNode.create(oo);
				oo.set_mynode(nn);
				connections.add_node(nn);
			}
		}
	}

	public void on_connection_closed(HTTPServerConnection sc) {
		if(sc == null) {
			return;
		}
		int n = connections.count();
		var nn = sc.get_mynode();
		sc.set_mynode(null);
		if(nn == null) {
			connections.remove(sc);
		}
		else {
			connections.remove_node(nn);
		}
	}

	public void send_response(HTTPServerConnection conn, HTTPRequest req, HTTPResponse resp) {
		if(conn == null) {
			return;
		}
		if(allow_cors) {
			resp.enable_cors(req);
		}
		if(enable_caching && resp.get_cache_ttl() > 0) {
			var cid = req.get_cache_id();
			if(cid != null) {
				if(cache == null) {
					cache = new ContentCache();
				}
				cache.set(cid, resp, resp.get_cache_ttl());
			}
		}
		conn.send_response(req, resp);
	}

	public void handle_incoming_request(HTTPRequest req) {
		if(req == null) {
			return;
		}
		if(cache != null) {
			var cid = req.get_cache_id();
			if(cid != null) {
				var resp = cache.get(cid) as HTTPResponse;
				if(resp != null) {
					req.send_response(resp);
					return;
				}
			}
		}
		if(str_options.equals(req.get_method())) {
			var resp = create_options_response(req);
			if(resp != null) {
				req.send_response(resp);
				return;
			}
		}
		if(on_request(req) == false) {
			on_unhandled_request(req);
		}
	}

	public virtual HTTPResponse create_options_response(HTTPRequest req) {
		if(delegate != null) {
			var v = delegate.create_options_response(req);
			if(v != null) {
				return(v);
			}
		}
		return(new HTTPResponse().set_status("200").add_header("Content-Length", "0"));
	}

	public virtual HTTPRequestBodyHandler get_request_body_handler(HTTPRequest req) {
		if(delegate != null) {
			return(delegate.get_request_body_handler(req));
		}
		return(HTTPRequestMemoryBufferBodyHandler.for_maximum_size(32 * 1024));
	}

	public virtual void on_unhandled_request(HTTPRequest req) {
		if(delegate != null) {
			if(delegate.on_unhandled_request(req)) {
				return;
			}
		}
		req.send_response(HTTPResponse.for_http_not_found());
	}

	public virtual bool on_request(HTTPRequest req) {
		if(delegate != null) {
			return(delegate.on_http_request(req));
		}
		return(false);
	}

	public virtual void on_request_complete(HTTPRequest request, HTTPResponse resp, int bytes_sent, String remote_address) {
		if(delegate != null) {
			delegate.on_request_complete(request, resp, bytes_sent, remote_address);
		}
	}
}
