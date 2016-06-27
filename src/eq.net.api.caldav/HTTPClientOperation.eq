
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

interface IOWatcher
{
	public void add_read(Object o);
	public void add_write(Object o);
	public bool wait(int timeout = -1);
	public Iterator get_read();
	public Iterator get_write();
	public void clear();
	public static IOWatcher create() {
		IFDEF("target_posix") {
			return(IOWatcherPosix.create());
		}
		ELSE {
			return(null);
		}
	}
}

IFDEF("target_posix") {
class IOWatcherPosix : IOWatcher
{
	class MyIterator : Iterator
	{
		embed "c" {{{
			#include <stdlib.h>
			#include <errno.h>
			#include <string.h>
			#include <sys/select.h>
		}}}

		private IOWatcherPosix select = null;
		private bool write = false;
		private Iterator it = null;

		public static MyIterator create(IOWatcherPosix s, bool w) {
			var v = new MyIterator();
			v.select = s;
			v.write = w;
			if(v.write) {
				v.it = v.select.writelist.iterate();
			}
			else {
				v.it = v.select.readlist.iterate();
			}
			return(v);
		}

		public Object next() {
			if(it == null) {
				return(null);
			}
			FileDescriptor v = null;
			while((v = it.next() as FileDescriptor) != null) {
				int fd = v.get_fd();
				if(fd < 0) {
					continue;
				}
				if(write) {
					var fdw = select.fdsetw;
					embed "c" {{{
						if(FD_ISSET(fd, (fd_set*)fdw) != 0) {
							break;
						}
					}}}
				}
				else {
					var fdr = select.fdsetr;
					embed "c" {{{
						if(FD_ISSET(fd, (fd_set*)fdr) != 0) {
							break;
						}
					}}}
				}
			}
			return(v);
		}
	}

	public Collection readlist = null;
	public Collection writelist = null;
	public ptr fdsetr;
	public ptr fdsetw;

	public static IOWatcher create() {
		return(new IOWatcherPosix());
	}

	public IOWatcherPosix() {
		ptr r;
		ptr w;
		embed "c" {{{
			r = (void*)malloc(sizeof(fd_set));
			w = (void*)malloc(sizeof(fd_set));
		}}}
		this.fdsetr = r;
		this.fdsetw = w;
		clear();
	}

	~IOWatcherPosix() {
		var r = fdsetr;
		var w = fdsetw;
		embed "c" {{{
			free(r);
			free(w);
		}}}
	}

	public void clear() {
		readlist = LinkedList.create();
		writelist = LinkedList.create();
	}

	public void add_read(Object o) {
		if(o is FileDescriptor == false) {
			Log.error("Tried to add a non-FileDescriptor object to Select. Ignoring it.");
			return;
		}
		readlist.add(o);
	}

	public void add_write(Object o) {
		if(o is FileDescriptor == false) {
			Log.error("Tried to add a non-FileDescriptor object to Select. Ignoring it.");
			return;
		}
		writelist.add(o);
	}

	public bool wait(int timeout = -1) {
		int n = 0, fd;
		var fdr = fdsetr;
		var fdw = fdsetw;
		embed "c" {{{
			FD_ZERO((fd_set*)fdr);
			FD_ZERO((fd_set*)fdw);
		}}}
		if(readlist.count() > 0) {
			var it = readlist.iterate();
			FileDescriptor o;
			while((o = it.next() as FileDescriptor) != null) {
				fd = o.get_fd();
				if(fd >= 0) {
					embed "c" {{{
						FD_SET(fd, (fd_set*)fdr);
					}}}
				}
				if(fd > n) {
					n = fd;
				}
			}
		}
		if(writelist.count() > 0) {
			var it = writelist.iterate();
			FileDescriptor o;
			while((o = it.next() as FileDescriptor) != null) {
				fd = o.get_fd();
				if(fd >= 0) {
					embed "c" {{{
						FD_SET(fd, (fd_set*)fdr);
					}}}
				}
				if(fd > n) {
					n = fd;
				}
			}
		}
		int nc = 0;
		if(n > 0) {
			nc = n + 1;
		}
		int r = -1;
		if(timeout < 0) {
			embed "c" {{{ r = select(nc, (fd_set*)fdr, (fd_set*)fdw, (void*)0, (void*)0); }}}
		}
		else {
			embed "c" {{{
				struct timeval tv;
				tv.tv_sec = (long)timeout / 1000000;
				tv.tv_usec = (long)timeout % 1000000;
				r = select(nc, (fd_set*)fdr, (fd_set*)fdw, (void*)0, &tv);
			}}}
		}
		bool v = false;
		if(r < 0) {
			strptr err = null;
			embed "c" {{{
				if(errno != EINTR) {
					err = strerror(errno);
				}
			}}}
			if(err != null) {
				Log.error("Call to 'select()' returned error status %d: '%s'".printf().add(Primitive.for_integer(r))
					.add(String.for_strptr(err)).to_string());
			}
		}
		else if(r > 0) {
			v = true;
		}
		return(v);
	}

	public Iterator get_read() {
		return(MyIterator.create(this, false));
	}

	public Iterator get_write() {
		return(MyIterator.create(this, true));
	}
}
}

class HTTPClientOperation
{
	class EqelaUserAgent
	{
		public static String get_platform_user_agent(String aua) {
			var ua = aua;
			if(ua == null) {
				String name = Application.get_display_name();
				String version = Application.get_version();
				if(String.is_empty(name) == false && String.is_empty(version) == false) {
					ua = "%s/%s (%s)".printf().add(name).add(version)
						.add(VALUE("target_platform")).to_string();
				}
			}
			if(ua == null) {
				ua = "eq.net.api.caldav/%s".printf().add(VALUE("version")).to_string();
			}
			else {
				ua = "%s eq.net.api.caldav/%s".printf().add(ua).add(VALUE("version")).to_string();
			}
			return(ua);
		}
	}

	class ResponseParser
	{
		private DynamicBuffer resp = null;
		private HashTable headers = null;

		public ResponseParser() {
			resp = DynamicBuffer.create(0);
		}

		private bool has_end_of_headers(Buffer buf, int size) {
			int n = 0;
			bool v = false;
			var ptr = buf.get_pointer();
			while (n <= size - 4) {
				if(ptr.get_byte(n) == '\r' && ptr.get_byte(n+1) == '\n' && ptr.get_byte(n+2) == '\r' && ptr.get_byte(n+3) == '\n') {
					v = true;
					break;
				}
				n++;
			}
			return(v);
		}

		private HashTable parse_headers(Buffer buf) {
			var ptr = buf.get_pointer();
			if(ptr == null) {
				return(null);
			}
			int i = 0;
			uint8 p = (uint8)'0';
			var v = HashTable.create();
			bool first = true;
			while(true) {
				var sb = StringBuffer.create();
				while ((p = ptr.get_byte(i)) != 0) {
					if (p == '\r') {
					}
					else if (p == '\n') {
						i++;
						break;
					}
					else {
						sb.append_c(p);
					}
					i++;
				}
				var t = sb.dup_string();
				if(t == null || t.get_length() < 1) {
					break;
				}
				if(first) {
					var comps = t.split((int)' ', 3);
					String tmp = comps.next() as String;
					if (tmp != null) {
						v.set("HTTP_VERSION", tmp);
						tmp = comps.next() as String;
						if (tmp != null) {
							v.set("HTTP_STATUS", tmp);
							tmp = comps.next() as String;
							if (tmp != null) {
								v.set("HTTP_STATUS_DESC", tmp);
							}
						}
					}
				}
				else {
					var comps = t.split((int)':', 2);
					if (comps != null) {
						var key = (comps.next() as String);
						if (key != null) {
							key = key.lowercase();
							var val = (comps.next() as String);
							if(val != null) {
								v.set(key, val.strip());
							}
							else {
								v.set(key, null);
							}
						}
					}
				}
				first = false;
			}
			int l = (int)(resp.get_size() - i);
			if(l > 0) {
				var bb = DynamicBuffer.create(l);
				var ptr_d = bb.get_pointer();
				ptr_d.cpyfrom(ptr, i, 0, l);
				resp = bb;
			}
			else {
				resp = DynamicBuffer.create(0);
			}
			return(v);
		}

		public void add(Buffer buf, int size) {
			var p = resp.append(size);
			if(p == true) {
				var ptr_d = resp.get_pointer();
				var ptr_s = buf.get_pointer();
				ptr_d.cpyfrom(ptr_s, 0, resp.get_size()-size, size);
			}
		}

		private bool is_chunked() {
			bool v = false;
			if(headers != null) {
				String te = headers.get("transfer-encoding") as String;
				if(te != null && "chunked".equals(te)) {
					v = true;
				}
			}
			return(v);
		}

		private Buffer get_chunk() {
			Buffer v = null;
			if(resp == null) {
				return(null);
			}
			var ptr = resp.get_pointer();
			if(ptr == null) {
				return(null);
			}
			int i = 0;
			var sb = StringBuffer.create();
			while(true) {
				int p = ptr.get_byte(i);
				if(p == '\r') {
				}
				else if(p == '\n') {
					i++;
					break;
				}
				else {
					sb.append_c(p);
				}
				i++;
				if(sb.count() >= 16) {
					Log.debug("garbage chunk encountered: `%s'".printf().add(sb.to_string()));
					return(null);
				}
			}
			int cl = -1;
			String t = sb.to_string().strip();
			if(t!=null && t.get_length()>0) {
				cl = t.to_integer_base(16);
			}
			if(cl < 0) {
				v = null;
			}
			else if(cl == 0) {
				v = null; //DynamicBuffer.create(0);
			}
			else if(resp.get_size() - i >= cl) {
				v = DynamicBuffer.create(cl);
				var ptr_d = v.get_pointer();
				var ptr_s = resp.get_pointer();
				ptr_d.cpyfrom(ptr_s, i, 0, cl);
				i += cl;
				while(ptr.get_byte(i) == '\r' || ptr.get_byte(i) == '\n') {
					i++;
				}
				int rem = (int)(resp.get_size() - i);
				if(rem > 0) {
					var tmp = resp;
					resp = DynamicBuffer.create(rem);
					ptr_s = tmp.get_pointer();
					ptr_d = resp.get_pointer();
					ptr_d.cpyfrom(ptr_s, i, 0, rem);
				}
				else {
					resp = DynamicBuffer.create(0);
				}
			}
			else {
				; // desired chunk is larger than what we have in buffer. must still wait for the rest to come?
			}
			return(v);
		}

		public Object process() {
			Object v = null;
			if(headers == null) {
				if(has_end_of_headers(resp, resp.get_size())) {
					headers = parse_headers(resp);
					if(headers != null) {
						v = headers;
					}
				}
			}
			else if(is_chunked()) {
				v = get_chunk();
			}
			else {
				if(resp.get_size() > 0) {
					v = resp;
					resp = DynamicBuffer.create(0);
				}
			}
			return(v);
		}
	}

	class HTTPClientTask : RunnableTask
	{
		property HTTPClientRequest rq;
		bool debug = false;
		Mutex mutex;

		public HTTPClientTask() {
			mutex = Mutex.create();
			//if("yes".equals(SystemEnvironment.get_env_var("EQ_HTTP_DEBUG"))) {
			//	debug = true;
			//}
		}

		private bool send_request(Writer socket, HTTPClientRequest rq) {
			var url = rq.get_url();
			var bod = rq.get_body();
			var request = StringBuffer.create();
			var headers = rq.get_headers();
			var version = "HTTP/1.1";
			var path = url.to_string_nohost();
			if(String.is_empty(path)) {
				path = "/";
			}
			request.append("%s %s %s\r\n".printf().add(rq.get_method()).add(path).add(version).to_string());
			// set some mandatory headers
			if(headers == null) {
				headers = HashTable.create();
			}
			var ua = EqelaUserAgent.get_platform_user_agent(headers.get("User-Agent") as String);
			headers.set("User-Agent", ua);
			String host = headers.get("Host") as String;
			if(host == null) {
				headers.set("Host", url.get_host());
			}
			if(bod != null) {
				headers.set_int("Content-Length", bod.get_size());
			}
			headers.set("Connection", "close"); // FIXME: For the time being
			// add headers
			foreach(String key in headers) {
				request.append("%s: %s\r\n".printf().add(key).add(headers.get(key)).to_string());
			}
			request.append("\r\n"); // blank line before content.
			var output = OutputStream.create(socket as Writer);
			output.write_string(request.to_string());
			if(bod != null) {
				var bf = DynamicBuffer.create(4096);
				while(true) {
					int r = bod.read(bf);
					Log.debug("Reading body request");
					if(r < 1) {
						break;
					}
					output.write(bf, r);
				}
			}
			return(true);
		}

		void event(EventReceiver listener, Object event) {
			if(debug && event != null && event is Stringable) {
				Log.debug(String.as_string(event));
			}
			EventReceiver.event(listener, event);
		}

		public void run(EventReceiver listener, BooleanValue abort) {
			event(listener, new HTTPClientStartEvent());
			mutex.lock();
			var v = do_run(listener, abort);
			mutex.unlock();
			event(listener, new HTTPClientEndEvent().set_complete(true));
		}

		public bool do_run(EventReceiver listener, BooleanValue abort) {
			if(rq == null) {
				event(listener, new HTTPClientErrorEvent().set_message("No request"));
				return(false);
			}
			var url = rq.get_url();
			if(url == null) {
				event(listener, new HTTPClientErrorEvent().set_message("No URL"));
				return(false);
			}
			if(abort.to_boolean()) {
				event(listener, new HTTPClientErrorEvent().set_message("Aborted"));
				return(false);
			}
			Log.debug("Executing HTTP %s request: `%s'".printf().add(rq.get_method()).add(url));
			ConnectedSocket socket = null;
			var myheaders = HashTable.create();
			if("http".equals(url.get_scheme()) || "https".equals(url.get_scheme())) {
				String address = url.get_host();
				int port = url.get_port_int();
				if(port < 1) {
					if("https".equals(url.get_scheme())) {
						port = 443;
					}
					else {
						port = 80;
					}
				}
				myheaders.set("Host", address);
				Log.debug("Resolving address: `%s'".printf().add(address).to_string());
				var ip = DNSCache.resolve(address);
				if(ip != null) {
					address = ip;
				}
				else {
					event(listener, new HTTPClientErrorEvent().set_message("Unable to resolve hostname: '%s'".printf().add(address).to_string()));
					address = null;
				}
				if(address != null) {
					Log.debug("Connecting to `%s:%d'".printf().add(address).add(Primitive.for_integer(port)).to_string());
					var tsocket = TCPSocket.create();
					if(tsocket != null) {
						if(tsocket.connect(address, port) == false) {
							event(listener, new HTTPClientErrorEvent().set_message(
								"Connection failed: `%s:%d'".printf().add(address).add(Primitive.for_integer(port)).to_string()));
							tsocket = null;
						}
					}
					socket = (ConnectedSocket)tsocket;
				}
				if("https".equals(url.get_scheme())) {
					socket = SSLSocket.for_client(socket);
					if(socket == null) {
						event(listener, new HTTPClientErrorEvent().set_message("FAILED to create SSL socket for HTTPS"));
					}
				}
			}
			else {
				event(listener, new HTTPClientErrorEvent().set_message("URL must start with either http:// or https://"));
			}
			if(socket == null) {
				return(false);
			}
			if(abort.to_boolean()) {
				event(listener, new HTTPClientErrorEvent().set_message("Aborted"));
				return(false);
			}
			// 2. write the request
			Log.debug("Sending request");
			if(send_request(socket, rq) == false) {
				event(listener, new HTTPClientErrorEvent().set_message("Failed to send HTTP request"));
				return(false);
			}
			if(abort.to_boolean()) {
				event(listener, new HTTPClientErrorEvent().set_message("Aborted"));
				return(false);
			}
			// 3. read the response
			var parser = new ResponseParser();
			var select = IOWatcher.create();
			if(select == null) {
				Log.debug("No IO watcher found. Reading the socket will block.");
			}
			else {
				select.add_read(socket);
			}
			Log.debug("Receiving headers");
			var buf = DynamicBuffer.create(1024 * 64);
			int tcounter = 0;
			int totalbytes = 0;
			while(true) {
				if(abort.to_boolean()) {
					event(listener, new HTTPClientErrorEvent().set_message("Aborted"));
					return(false);
				}
				if(tcounter > 30 * 1000000) {
					Log.debug("Timed out");
					event(listener, new HTTPClientErrorEvent().set_message(
						"ERROR: Timed out while waiting for server response"));
					return(false);
				}
				if(select != null && select.wait(100000) == false) {
					tcounter += 100000;
					continue;
				}
				tcounter = 0;
				int r = socket.read(buf);
				if(r < 1) {
					Log.debug("Closing socket");
					socket.close();
					break; // socket closed
				}
				Log.debug("Adding socket read to response parser");
				parser.add(buf, r);
				var b = parser.process();
				while(b != null) {
					if(b is Buffer) {
						if(listener != null) {
							var ee = new HTTPClientDataEvent();
							ee.set_buffer((Buffer)b);
							totalbytes += ((Buffer)b).get_size();
							event(listener, ee);
						}
					}
					else if(b is HashTable) {
						if(listener != null) {
							var ht = (HashTable)b;
							var ee = new HTTPClientResponseEvent();
							var stat = ht.get_string("HTTP_STATUS");
							ee.set_status(stat);
							ee.set_headers(ht);
							event(listener, ee);
						}
						Log.debug("Receiving response data");
					}
					b = parser.process();
				}
			}
			return(true);
		}
	}

	public static BackgroundTask start(BackgroundTaskManager el, HTTPClientRequest rq, EventReceiver listener) {
		if(el == null) {
			Log.error("HTTPClientOperation: No background task manager. Cannot start.");
			return(null);
		}
		return(el.start_task(new HTTPClientTask().set_rq(rq), listener));
	}

	public static bool execute(HTTPClientRequest rq, EventReceiver listener) {
		new HTTPClientTask().set_rq(rq).run(listener, new BooleanValue().set_value(false));
		return(true);
	}
}
