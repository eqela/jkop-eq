
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

IFNDEF("target_j2me") {
public class HTTPClientOperation
{
	class HTTPClientTask : RunnableTask, BackgroundTask
	{
		embed {{{
			java.net.HttpURLConnection conn;
		}}}
		property HTTPClientRequest request;

		public void error(EventReceiver listener, strptr msg) {
			var eqs = String.for_strptr(msg);
			embed {{{
				if(listener != null && eqs != null) {
					listener.on_event(new eq.net.http.HTTPClientErrorEvent().set_message(eqs));
				}
			}}}
		}

		public void run(EventReceiver listener, BooleanValue abortflag) {
			EventReceiver.event(listener, new HTTPClientStartEvent());
			bool v = do_run(listener, abortflag);
			EventReceiver.event(listener, new HTTPClientEndEvent().set_complete(v));
		}

		public bool do_run(EventReceiver listener, BooleanValue abort) {
			if(request == null) {
				error(listener, "No request".to_strptr());
				return(false);
			}
			var mm = request.get_method();
			var urlo = request.get_url();
			var hdrs = request.get_headers();
			var version = "HTTP/1.1";
			if(urlo == null) {
				error(listener, "No URL".to_strptr());
				return(false);
			}
			if(abort.get_value()) {
				error(listener, "Aborted".to_strptr());
				return(false);
			}
			var urls = urlo.to_string();
			embed {{{
				java.net.URL jurl = null;
				try {
					jurl = new java.net.URL(urls.to_strptr());
				}
				catch(java.net.MalformedURLException e) {
					error(listener, "Bad URL");
					return(false);
				}
				try {
					conn = (java.net.HttpURLConnection)jurl.openConnection();
				}
				catch(java.io.IOException e) {
					error(listener, "Failed to open a connection");
					return(false);
				}
				try {
					conn.setRequestMethod(mm.to_strptr());
				}
				catch(java.net.ProtocolException e) {
					error(listener, "Unsupported method");
					return(false);
				}
			}}}
			if(abort.get_value()) {
				error(listener, "Aborted".to_strptr());
				return(false);
			}
			if(hdrs != null && hdrs.count() > 0) {
				foreach(String key in hdrs.iterate()) {
					var val = hdrs.get_string(key);
					if(String.is_empty(val) == false) {
						embed {{{
							try {
								conn.setRequestProperty(key.to_strptr(), val.to_strptr());
							}
							catch(java.lang.Exception e) {
								e.printStackTrace();
							}
						}}}
					}
				}
			}
			if(abort.get_value()) {
				error(listener, "Aborted".to_strptr());
				return(false);
			}
			var bod = request.get_body();
			var ins = InputStream.for_reader(bod);
			Buffer buf = null;
			if(ins != null) {
				buf = ins.read_all_buffer();
			}
			if(buf != null) {
				var ptr = buf.get_pointer().get_native_pointer();
				int sz = buf.get_size();
				if(sz > 0) {
					embed {{{
						conn.setDoOutput(true);
						try {
							java.io.DataOutputStream dos = new java.io.DataOutputStream(conn.getOutputStream());
							dos.write(ptr, 0, sz);
							dos.flush();
							dos.close();
						}	
						catch(java.io.IOException e) {
							error(listener, "Failed to send request: " + e);
							return(false);
						}
					}}}
				}
			}
			if(abort.get_value()) {
				error(listener, "Aborted".to_strptr());
				return(false);
			}
			int response;
			embed {{{
				try {
					response = conn.getResponseCode();
				}
				catch(java.io.IOException e) {
					error(listener, "Failed to get response: " + e);
					return(false);
				}
			}}}
			var htr = HashTable.create();
			embed {{{
			java.util.Map<java.lang.String, java.util.List<java.lang.String>> map = conn.getHeaderFields();
				java.util.Set<java.util.Map.Entry<java.lang.String, java.util.List<java.lang.String>>> entries = map.entrySet();
				for(java.util.Map.Entry<java.lang.String, java.util.List<java.lang.String>> entry : entries) {
					if(entry.getKey() != null) {
						java.lang.String rk = entry.getKey().toLowerCase();
						java.lang.String rv = entry.getValue().get(0);
						htr.set(_S(rk), (eq.api.Object)_S(rv));
					}
				}
			}}}
			if(abort.get_value()) {
				error(listener, "Aborted".to_strptr());
				return(false);
			}
			var re = new HTTPClientResponseEvent();
			re.set_headers(htr);
			re.set_status(String.for_integer(response));
			EventReceiver.event(listener, re);
			embed {{{
				java.io.BufferedInputStream bis = null;
				try {
					bis = new java.io.BufferedInputStream(conn.getInputStream());
				}
				catch(java.lang.Exception e) {
					return(false);
				}
				int read = 0;
				do {
					byte[] data = new byte[1024 * 8];
					try {
						read = bis.read(data, 0, data.length);
					}
					catch(java.io.IOException e) {
					}
					if(read < 1) {
						break;
					}
					eq.net.http.HTTPClientDataEvent de = new eq.net.http.HTTPClientDataEvent();
					de.set_buffer(_buffer(_pointer(data), read));
					_event((eq.api.Object)listener, (eq.api.Object)de);
				}
				while(read > 0);
				conn.disconnect();
				
			}}}
			return(true);
		}

		public bool abort() {
			embed "java" {{{
				if(conn != null) {
					try {
						conn.disconnect();
					}
					catch(Exception e) {
					}
					conn = null;
				}
			}}}
			return(true);
		}
	}

	static void _event(Object listener, Object o) {
		EventReceiver.event(listener, o);
	}

	static Buffer _buffer(Pointer p, int sz) {
		return(Buffer.for_pointer(p, sz));
	}

	static Pointer _pointer(ptr p) {
		return(Pointer.create(p));
	}

	public static BackgroundTask start(BackgroundTaskManager el, HTTPClientRequest rq, EventReceiver listener) {
		if(el == null) {
			Log.error("HTTPClientOperation/Android: No background task manager. Cannot start.");
			return(null);
		}
		return(el.start_task(new HTTPClientTask().set_request(rq), listener));
	}

	public static bool execute(HTTPClientRequest rq, EventReceiver listener) {
		new HTTPClientTask().set_request(rq).run(listener, new BooleanValue().set_value(false));
		return(true);
	}
}
}
