
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

public class HTTPServerSocketListener : LoggerObject, EventLoopReadListener
{
	public static HTTPServerSocketListener create(String listen, HTTPServer server) {
		if(server == null || listen == null) {
			return(null);
		}
		var v = new HTTPServerSocketListener();
		v.set_logger(server.get_logger());
		if(v.initialize(listen, server) == false) {
			v = null;
		}
		return(v);
	}

	public static HTTPServerSocketListener for_socket(ConnectedSocket socket, HTTPServer server) {
		if(server == null || socket == null) {
			return(null);
		}
		var v = new HTTPServerSocketListener();
		v.set_logger(server.get_logger());
		if(v.initialize_for_socket(socket, server) == false) {
			v = null;
		}
		return(v);
	}

	HTTPServer server;
	ConnectedSocket socket;
	EventLoopEntry socket_ee;
	property File ssl_certificate;
	property File ssl_private_key;

	bool initialize_for_socket(ConnectedSocket socket, HTTPServer server) {
		var eventloop = server.get_eventloop();
		if(eventloop == null) {
			log_error("HTTPServerSocketListener: HTTPServer has no eventloop");
			return(false);
		}
		log_debug("HTTPServerSocketListener: Socket listener initialized (pre-allocated socket)");
		socket_ee = eventloop.entry_for_object(socket);
		if(socket_ee == null) {
			log_error("HTTPServerSocketListener: Unable to register the listening socket in event loop!");
			return(false);
		}
		socket_ee.set_read_listener(this);
		this.socket = socket;
		this.server = server;
		return(true);
	}

	bool initialize(String listen, HTTPServer server) {
		var eventloop = server.get_eventloop();
		if(eventloop == null) {
			log_error("HTTPServerSocketListener: HTTPServer has no eventloop");
			return(false);
		}
		var s = open_server_socket(listen);
		if(s == null) {
			log_error("HTTPServerSocketListener: Failed to open server socket '%s'!".printf().add(listen).to_string());
			return(false);
		}
		log_debug("HTTPServerSocketListener: Listening on socket '%s'".printf().add(listen).to_string());
		socket_ee = eventloop.entry_for_object(s);
		if(socket_ee == null) {
			log_error("HTTPServerSocketListener: Unable to register the listening socket in event loop!");
			return(false);
		}
		socket_ee.set_read_listener(this);
		this.socket = s;
		this.server = server;
		return(true);
	}

	public void close() {
		if(socket_ee != null) {
			socket_ee.remove();
			socket_ee = null;
		}
		if(socket != null) {
			socket.close();
			socket = null;
		}
	}

	void on_connection_received() {
		ConnectedSocket ns = null;
		if(socket == null) {
		}
		else if(socket is TCPSocket) {
			ns = ((TCPSocket)socket).accept();
		}
		else if(socket is LocalSocket) {
			ns = ((LocalSocket)socket).accept();
		}
		if(ssl_certificate != null && ssl_private_key != null) {
			if(ssl_certificate.is_file() == false) {
				log_error("SSL certificate file does not exist: `%s'".printf().add(ssl_certificate));
			}
			if(ssl_private_key.is_file() == false) {
				log_error("SSL private key file does not exist: `%s'".printf().add(ssl_private_key));
			}
			ns = SSLSocket.for_server(ns, ssl_certificate, ssl_private_key, get_logger());
			if(ns == null) {
				log_error("Failed to initialize SSL socket for HTTPS!");
			}
		}
		if(ns != null && server != null) {
			server.on_new_client_socket(ns);
		}
	}

	public void on_read_ready() {
		on_connection_received();
	}

	ConnectedSocket open_server_socket(String socket) {
		if(socket == null) {
			return(null);
		}
		ConnectedSocket v = null;
		int n = socket.to_integer();
		if(n > 0) {
			var tv = TCPSocket.create();
			if(tv != null) {
				if(tv.listen(n) == false) {
					tv = null;
				}
			}
			v = tv;
		}
		else {
			var lv = LocalSocket.create();
			if(lv != null) {
				if(lv.listen(socket) == false) {
					lv = null;
				}
			}
			v = lv;
		}
		return(v);
	}
}
