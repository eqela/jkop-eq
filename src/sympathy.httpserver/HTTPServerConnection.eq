
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

public class HTTPServerConnection : LoggerObject, EventLoopReadListener, EventLoopWriteListener
{
	static int idcounter = 0;
	property HTTPServer server = null;
	property ConnectedSocket socket = null;
	EventLoopEntry socket_ee;
	DynamicBuffer read_buffer = null;
	property int buffer_limit;
	property int read_buffer_size;
	property int write_buffer_size;
	property int last_activity;
	property int id;
	property LinkedListNode mynode;
	private Queue request_queue = null;
	private HTTPResponse send_response_ptr = null;
	private bool close_after_send = false;
	private Buffer send_buffer = null;
	private Reader send_body = null;
	private Buffer send_body_buffer = null;
	private int send_written = 0;
	private bool send_chunked = false;
	HTTPRequest current_request = null;
	HTTPRequestParser parser;
	property int requests = 0;
	property int responses = 0;
	String remote_address;

	public HTTPServerConnection() {
		id = idcounter++;
		buffer_limit = 8 * 1024 * 1024;
		read_buffer_size = 1024 * 32;
		write_buffer_size = 1024 * 512;
	}

	public HTTPServerConnection initialize(HTTPServer server, ConnectedSocket socket) {
		if(server != null) {
			set_logger(server.get_logger());
		}
		var v = do_initialize(server, socket);
		if(v == false) {
			close();
			return(null);
		}
		last_activity = SystemClock.seconds();
		return(this);
	}

	bool do_initialize(HTTPServer server, ConnectedSocket socket) {
		this.socket = socket;
		this.server = server;
		if(server == null || socket == null) {
			return(false);
		}
		var el = server.get_eventloop();
		if(el == null) {
			log_error("Incoming socket: No eventloop");
			return(false);
		}
		socket_ee = el.entry_for_object(socket);
		if(socket_ee == null) {
			log_error("Incoming socket: Unable to add to eventloop");
			return(false);
		}
		set_listen_mode(1);
		parser = new MyHTTPRequestParser().set_connection(this);
		return(true);
	}

	public void close() {
		current_request = null;
		parser = null;
		if(socket_ee != null) {
			set_listen_mode(0);
			socket_ee.remove();
			socket_ee = null;
		}
		if(socket != null) {
			socket.close();
			socket = null;
		}
		if(server != null) {
			var ss = server;
			server = null;
			ss.on_connection_closed(this);
		}
	}

	public String get_remote_address() {
		if(remote_address == null) {
			var ts = socket as TCPSocket;
			if(ts == null && socket is ConnectedSocketWrapper) {
				ts = ((ConnectedSocketWrapper)socket).get_original() as TCPSocket;
			}
			if(ts != null) {
				remote_address = "%s:%d".printf().add(ts.get_remote_address()).add(Primitive.for_integer(ts.get_remote_port())).to_string();
			}
			else {
				var ls = socket as LocalSocket;
				if(ls != null) {
					remote_address = "%d:%d:%d".printf()
						.add(Primitive.for_integer(ls.get_remote_pid()))
						.add(Primitive.for_integer(ls.get_remote_uid()))
						.add(Primitive.for_integer(ls.get_remote_gid())).to_string();
				}
			}
		}
		return(remote_address);
	}

	public void on_write_ready() {
		send_data();
	}

	public void on_read_ready() {
		on_data_available();
		last_activity = SystemClock.seconds();
	}

	public HTTPRequestBodyHandler get_request_body_handler(HTTPRequest req) {
		if(server == null) {
			return(null);
		}
		return(server.get_request_body_handler(req));
	}

	class MyHTTPRequestParser : HTTPRequestParser
	{
		property HTTPServerConnection connection;

		public HTTPRequestBodyHandler get_request_body_handler(HTTPRequest req) {
			return(connection.get_request_body_handler(req));
		}

		public void on_request(HTTPRequest req) {
			if(req == null) {
				on_request_error(req, HTTPResponse.for_http_invalid_request());
				return;
			}
			if(String.is_empty(req.get_method()) || String.is_empty(req.get_uri_string())) {
				on_request_error(req, HTTPResponse.for_http_invalid_request());
				return;
			}
			if("HTTP/0.9".equals(req.get_version()) && "GET".equals(req.get_method()) == false) {
				on_request_error(req, HTTPResponse.for_http_invalid_request());
				return;
			}
			connection.on_complete_request(req);
		}

		public void on_request_error(HTTPRequest areq, HTTPResponse aresp) {
			var req = areq;
			if(req == null) {
				req = new HTTPRequest();
			}
			var resp = aresp;
			if(resp == null) {
				resp = HTTPResponse.for_http_invalid_request();
			}
			req.set_error_response(resp);
			connection.on_complete_request(req);
		}
	}

	public void on_complete_request(HTTPRequest req) {
		if(req == null) {
			return;
		}
		requests ++;
		req.set_server(server);
		req.set_connection(this);
		if(current_request == null) {
			current_request = req;
			handle_current_request();
		}
		else {
			if(request_queue == null) {
				request_queue = Queue.create();
			}
			request_queue.push(req);
		}
	}

	void handle_next_request() {
		current_request = null;
		if(request_queue == null) {
			return;
		}
		var req = request_queue.pop() as HTTPRequest;
		if(req == null) {
			return;
		}
		current_request = req;
		handle_current_request();
	}

	void handle_current_request() {
		if(current_request == null) {
			return;
		}
		var er = current_request.get_error_response();
		if(er != null) {
			close_after_send = true;
			send_response(current_request, er);
			return;
		}
		if(server != null) {
			server.handle_incoming_request(current_request);
		}
	}

	private void on_data_available() {
		if(read_buffer == null) {
			read_buffer = DynamicBuffer.create(read_buffer_size);
		}
		int r = socket.read(read_buffer);
// Log.message("Connection reads data %d".printf().add(r));
		if (r < 0) {
			close();
			return;
		}
		else if(r == 0) {
		}
		if(parser != null) {
			var pp = parser;
			pp.on_data(read_buffer, 0, r);
		}
	}

	private String get_full_status(String status) {
		String v = null;
		if(status != null && status.str(" ") < 1) {
			if("200".equals(status)) {
				v = "200 OK";
			}
			else if("301".equals(status)) {
				v = "301 Moved Permanently";
			}
			else if("303".equals(status)) {
				v = "303 See Other";
			}
			else if("304".equals(status)) {
				v = "304 Not Modified";
			}
			else if("400".equals(status)) {
				v = "400 Bad Request";
			}
			else if("401".equals(status)) {
				v = "401 Unauthorized";
			}
			else if("403".equals(status)) {
				v = "403 Forbidden";
			}
			else if("404".equals(status)) {
				v = "404 Not found";
			}
			else if("405".equals(status)) {
				v = "405 Method not allowed";
			}
			else if("500".equals(status)) {
				v = "500 Internal server error";
			}
			else if("501".equals(status)) {
				v = "501 Not implemented";
			}
			else if("503".equals(status)) {
				v = "503 Service unavailable";
			}
			else {
				v = "%s Unknown".printf().add(status).to_string();
			}
		}
		else {
			v = status;
		}
		return(v);
	}

	private String get_status_code(String status) {
		if(status == null) {
			return(null);
		}
		var comps = status.split((int)' ') as Iterator;
		if(comps != null) {
			return(comps.next() as String);
		}
		return(null);
	}

	public void send_response(HTTPRequest req, HTTPResponse aresp) {
		if(socket == null) {
			// The socket has already been closed; nothing to send really
			return;
		}
		if(current_request == null) {
			log_error("Sending a response, but no current request!");
			close();
			return;
		}
		if(current_request != req) {
			log_error("Sending a response for an incorrect request");
			close();
			return;
		}
		responses ++;
		var resp = aresp;
		if(resp == null) {
			resp = HTTPResponse.for_text_string("");
		}
		var inm = req.get_etag();
		if(inm != null) {
			if(inm.equals(resp.get_etag())) {
				resp = new HTTPResponse();
				resp.set_status("304");
				resp.set_etag(aresp.get_etag());
			}
		}
		bool v = true;
		var status = resp.get_status();
		var bod = resp.get_body_reader();
		var headers = resp.get_headers();
		send_chunked = false;
		if("HTTP/0.9".equals(req.get_version())) {
			close_after_send = true;
		}
		else {
			if(status == null || status.get_length() < 1) {
				status = "200";
				resp.set_status(status);
			}
			if(req.get_connection_close()) {
				close_after_send = true;
			}
			var fs = get_full_status(status);
			// headers
			{
				var reply = StringBuffer.for_initial_size(4096);
				String ver = req.get_version();
				if(ver == null || ver.get_length() < 1) {
					reply.append("HTTP/1.1");
				}
				else {
					reply.append(ver);
				}
				reply.append_c((int)' ');
				reply.append(fs);
				reply.append_c((int)'\r');
				reply.append_c((int)'\n');
				if(fs.has_prefix("400 ")) {
					close_after_send = true;
				}
				if(headers != null) {
					foreach(KeyValuePair kvp in headers.iterate()) {
						reply.append(kvp.get_key());
						reply.append_c((int)':');
						reply.append_c((int)' ');
						reply.append(String.as_string(kvp.get_value()));
						reply.append_c((int)'\r');
						reply.append_c((int)'\n');
					}
				}
				if(close_after_send) {
					reply.append("Connection: close\r\n");
				}
				reply.append("Server: ");
				reply.append(server.get_server_name());
				reply.append_c((int)'\r');
				reply.append_c((int)'\n');
				reply.append("Date: ");
				reply.append(VerboseDateTimeString.for_now());
				reply.append_c((int)'\r');
				reply.append_c((int)'\n');
				reply.append_c((int)'\r');
				reply.append_c((int)'\n');
				send_buffer = reply.get_buffer();
			}
		}
		send_written = 0;
		if(bod != null) {
			if("HEAD".equals(req.get_method()) == false) {
				send_body = bod;
			}
		}
		send_response_ptr = resp;
		set_listen_mode(3);
	}

	int current_listen_mode = 0;

	void set_listen_mode(int n) {
		if(n == current_listen_mode) {
			return;
		}
		current_listen_mode = n;
		if(socket_ee == null) {
			return;
		}
		if(n == 0) {
			socket_ee.set_listeners(null, null);
		}
		else if(n == 1) {
			socket_ee.set_listeners(this, null);
		}
		else if(n == 2) {
			socket_ee.set_listeners(null, this);
		}
		else if(n == 3) {
			socket_ee.set_listeners(this, this);
		}
	}

	private void send_data() {
		while(true) {
			// get more data
			if(Buffer.is_empty(send_buffer)) {
				if(send_body != null) {
					if(send_body is BufferReader) {
						send_buffer = ((BufferReader)send_body).get_buffer();
						send_body = null;
					}
					else if(send_body is StringReader) {
						send_buffer = ((StringReader)send_body).get_buffer();
						send_body = null;
					}
					else {
						if(send_body_buffer == null) {
							send_body_buffer = DynamicBuffer.create(write_buffer_size);
						}
						int n = send_body.read(send_body_buffer);
						if(n < 1) {
							send_body = null; // all done
						}
						else if(n == write_buffer_size) {
							send_buffer = send_body_buffer;
						}
						else {
							send_buffer = SubBuffer.create(send_body_buffer, 0, n);
						}
					}
				}
			}
			// send the current buffer
			if(Buffer.is_empty(send_buffer) == false) {
				int r = socket.write(send_buffer);
				if(r < 0) {
					send_buffer = null;
					send_body = null;
					close();
					break;
				}
				else if(r == 0) {
				}
				else {
					send_written += r;
					var osz = send_buffer.get_size();
					if(r < osz) {
						// FIXME: There may be an unnecessary amount of recursion here for large in-memory buffers
						send_buffer = SubBuffer.create(send_buffer, r, osz - r);
					}
					else {
						send_buffer = null;
					}
				}
				if(Buffer.is_empty(send_buffer) == false) {
					break;
				}
			}
			// all done
			if(Buffer.is_empty(send_buffer) && send_body == null) {
				if(server != null) {
					server.on_request_complete(current_request, send_response_ptr, send_written, get_remote_address());
				}
				current_request = null;
				send_response_ptr = null;
				if(close_after_send) {
					close();
				}
				set_listen_mode(1);
				handle_next_request();
				break;
			}
		}
		last_activity = SystemClock.seconds();
	}
}
