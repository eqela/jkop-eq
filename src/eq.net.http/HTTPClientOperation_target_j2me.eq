
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

public class HTTPClientOperation
{
	class HTTPClientTask : RunnableTask
	{
		property HTTPClientRequest rq;

		public void run(EventReceiver listener, BooleanValue abort) {
			EventReceiver.event(listener, new HTTPClientStartEvent());
			var v = do_run(listener, abort);
			EventReceiver.event(listener, new HTTPClientEndEvent().set_complete(v));
		}

		void _event(EventReceiver listener, Object o) {
			if(o is Stringable) {
				Log.message("[HTTPClientOperation] %s".printf().add(o));
			}
			EventReceiver.event(listener, o);
		}

		String _eqstr(strptr message) {
			if(message == null) {
				return(null);
			}
			return(String.for_strptr(message));
		}

		bool do_run(EventReceiver listener, BooleanValue abort) {
			var mm = rq.get_method();
			var urlo = rq.get_url();
			if(urlo == null) {
				_event(listener, new HTTPClientErrorEvent().set_message("NULL URL given to HTTP client"));
				return(false);
			}
			IFDEF("target_bbjava") {
				var urls = "%s;deviceside=true;interface=wifi".printf().add(urlo.to_string()).to_string();
			}
			ELSE {
				var urls = urlo.to_string();
			}
			embed "java" {{{
				javax.microedition.io.HttpConnection hc = null;
				try {
			}}}
			{
				embed "java" {{{
					hc = (javax.microedition.io.HttpConnection)javax.microedition.io.Connector.open(urls.to_strptr(), javax.microedition.io.Connector.READ_WRITE);
					try {
				}}}
				{
					var hdrs = rq.get_headers();
					foreach(String key in rq.get_headers()) {
						var val = hdrs.get_string(key);
						if(val != null) {
							embed "java" {{{
								hc.setRequestProperty(key.to_strptr(), val.to_strptr());
							}}}
						}
					}
					String ua = null;
					if(hdrs != null) {
						ua = EqelaUserAgent.get_platform_user_agent(hdrs.get("User-Agent") as String);
					}
					if(ua != null) {
						embed "java" {{{
							hc.setRequestProperty("User-Agent", ua.to_strptr());
						}}}
					}
				}
				embed "java" {{{
					}
					catch(Exception e) {
						_event(listener, new HTTPClientErrorEvent().set_message(_eqstr("Connector.open: `" + e + "'")));
					}
				}}}
				if("GET".equals(mm)) {
					embed "java" {{{
						hc.setRequestMethod(javax.microedition.io.HttpConnection.GET);
					}}}
				}
				else if("POST".equals(mm)) {
					embed "java" {{{
						hc.setRequestMethod(javax.microedition.io.HttpConnection.POST);
					}}}
					var rr = InputStream.create(rq.get_body());
					if(rr != null) {
						var bb = rr.read_all_buffer();
						if(bb != null) {
							var ptr = bb.get_pointer();
							if(ptr != null) {
								var np = ptr.get_native_pointer();
								if(np != null) {
									embed "java" {{{
										java.io.OutputStream ous = hc.openOutputStream();
										ous.write(np,0, np.length);
									}}}
								}
							}
						}
					}
				}
				else if("HEAD".equals(mm)) {
					embed "java" {{{
						hc.setRequestMethod(javax.microedition.io.HttpConnection.HEAD);
					}}}
				}
				else {
					_event(listener, new HTTPClientErrorEvent().set_message("Unsupported HTTP client method: `%s'".printf().add(mm).to_string()));
					embed "java" {{{
						try {
							hc.close();
						}
						catch(Throwable t) {
							hc = null;
							_event(listener, new HTTPClientErrorEvent().set_message(_eqstr("HttpConnection.close: `" + t + "'")));
							return(false);
						}
					}}}
					return(false);
				}
			}
			embed "java" {{{
				}
				catch(Exception e) {
					_event(listener, new HTTPClientErrorEvent().set_message(_eqstr("Unknown: `" + e + "'")));
					return(false);
				}
			}}}
			var re = new HTTPClientResponseEvent();
			int sc;
			embed "java" {{{
				try {
					sc = hc.getResponseCode();
				}
				catch(Exception e) {
					_event(listener, new HTTPClientErrorEvent().set_message(_eqstr("HttpConnection.getResponseCode: `" + e + "'")));
					return(false);
				}
			}}}
			re.set_status("%d".printf().add(Primitive.for_integer(sc)).to_string());
			ptr bytes;
			int ll;
			var hht = HashTable.create();
			embed "java" {{{
				int n = 0;
				String key = null;
				String val = null;
				try {
					while((key = hc.getHeaderFieldKey(n)) != null) {
						val = hc.getHeaderField(n);
						hht.set(eq.api.StringStatic.eq_api_StringStatic_for_strptr(key), (eq.api.Object)eq.api.StringStatic.eq_api_StringStatic_for_strptr(val));
						n++;
					}
				}
				catch(Exception e) {
					_event(listener, new HTTPClientErrorEvent().set_message(_eqstr("HttpConnection.getHeaderFieldKey: `" + e + "'")));
					return(false);
				}
			}}}
			re.set_headers(hht);
			_event(listener, re);
			embed "java" {{{
				java.io.InputStream ins = null;
				try {
					ins = hc.openDataInputStream();
				}
				catch(Exception e) {
					_event(listener, new HTTPClientErrorEvent().set_message(_eqstr("HttpConnection.openDataInputStream: `" + e + "'")));
				}
				if(ins != null) {
					java.io.ByteArrayOutputStream os = new java.io.ByteArrayOutputStream();
					try {
						int i;
						while((i = ins.read()) != -1) {
							os.write(i);
						}
					}
					catch(Exception e) {
						_event(listener, new HTTPClientErrorEvent().set_message(_eqstr("InputStream.read: `" + e + "'")));
						os = null;
					}
					if(os != null) {
						bytes = os.toByteArray();
						ll = 0;
						if(bytes != null) {
							ll = bytes.length;
						}
						}}}
						var bf = Buffer.for_pointer(Pointer.create(bytes), ll);
						var de = new HTTPClientDataEvent();
						de.set_buffer(bf);
						_event(listener, de);
						embed "java" {{{
							try {
								os.close();
							}
							catch(Throwable t) {
								_event(listener, new HTTPClientErrorEvent().set_message(_eqstr("ByteArrayOutputStream.close: `" + t + "'")));
								os = null;
							}
					}
				}
			}}}
			embed "java" {{{
				try {
					hc.close();
				}
				catch(Throwable t) {
					_event(listener, new HTTPClientErrorEvent().set_message(_eqstr("HttpConnection.close: `" + t + "'")));
					hc = null;
					return(false);
				}
			}}}
			return(true);
		}
	}

	public static BackgroundTask start(BackgroundTaskManager el, HTTPClientRequest rq, EventReceiver listener) {
		if(el == null) {
			Log.error("HTTPClientOperation/J2ME: No background task manager. Cannot start.");
			return(null);
		}
		return(el.start_task(new HTTPClientTask().set_rq(rq), listener));
	}

	public static bool execute(HTTPClientRequest rq, EventReceiver listener) {
		new HTTPClientTask().set_rq(rq).run(listener, new BooleanValue().set_value(false));
		return(true);
	}
}
