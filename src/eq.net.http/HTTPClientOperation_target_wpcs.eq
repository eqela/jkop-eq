
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
	class HTTPClientTask : BackgroundTask
	{
		property HTTPClientRequest rq;
		EventReceiver listener;
		bool async;

		embed "cs" {{{
			System.Net.HttpWebRequest hwr;
			System.Windows.Threading.Dispatcher ui_dispatcher;
			System.Threading.ManualResetEvent waiter = new System.Threading.ManualResetEvent(false);
		}}}

		public HTTPClientTask() {
			embed "cs" {{{
				ui_dispatcher = System.Windows.Application.Current.RootVisual.Dispatcher;
			}}}
		}

		public static BackgroundTask start_request(HTTPClientRequest rq, EventReceiver listener, bool async = true) {
			var v = new HTTPClientTask();
			v.rq = rq;
			v.listener = listener;
			v.async = async;
			if(v.do_run() == false) {
				v = null;
			}
			return(v);
		}

		void dispatch_event(eq.api.Object o) {
			embed "cs" {{{
				if(ui_dispatcher != null) {
					ui_dispatcher.BeginInvoke(new System.Action(() => {
						trigger_event(listener, o);
						if(o is eq.net.http.HTTPClientErrorEvent) {
							trigger_event(listener, new eq.net.http.HTTPClientEndEvent().set_complete(false));
						}
					}));
				}
				else {
					trigger_event(listener, o);
					if(o is eq.net.http.HTTPClientErrorEvent) {
						trigger_event(listener, new eq.net.http.HTTPClientEndEvent().set_complete(false));
					}
				}
			}}}
		}

		void trigger_event(EventReceiver listener, Object event) {
			if(event != null && event is Stringable) {
				Log.debug("(HTTPOperation) %s".printf().add(String.as_string(event)));
			}
			EventReceiver.event(listener, event);
			if(event is HTTPClientEndEvent && async == false) {
				embed "cs" {{{
					waiter.Set();
				}}}
			}
		}

		void set_headers() {
			String ua = null, content_type = null;
			var hdrs = rq.get_headers();
			if(hdrs != null) {
				foreach(String key in hdrs) {
					var val = hdrs.get_string(key);
					if(val != null) {
						embed "cs" {{{
							try {
								hwr.Headers[key.to_strptr()] = val.to_strptr();
							}
							catch(System.Exception) {
							}
						}}}
					}
				}
				ua = EqelaUserAgent.get_platform_user_agent(hdrs.get("User-Agent") as String);
				content_type = hdrs.get_string("Content-Type");
			}
			if(ua != null) {
				embed "cs" {{{
					hwr.UserAgent = ua.to_strptr();
				}}}
			}
			if(content_type != null) {
				embed "cs" {{{
					hwr.ContentType = content_type.to_strptr();
				}}}
			}
		}

		public bool do_run() {
			dispatch_event(new HTTPClientStartEvent());
			if(rq == null) {
				dispatch_event(new HTTPClientErrorEvent().set_message("No request"));
				return(false);
			}
			var urlo = rq.get_url();
			if(urlo == null) {
				dispatch_event(new HTTPClientErrorEvent().set_message("No URL"));
				return(false);
			}
			var mm = rq.get_method();
			var urls = urlo.to_string();
			embed "cs" {{{
				var uri = new System.Uri(urls.to_strptr());
			}}}
			if("GET".equals(mm)) {
				embed "cs" {{{
					hwr = (System.Net.HttpWebRequest)System.Net.WebRequest.Create(uri);
					set_headers();
					try {
						hwr.BeginGetResponse(new System.AsyncCallback(async_get_response_callback), null);
					}				
					catch(System.Net.WebException w) {
						if(w.Status == System.Net.WebExceptionStatus.RequestCanceled) {
							dispatch_event(new eq.net.http.HTTPClientErrorEvent().set_message(eq.api.StringStatic.eq_api_StringStatic_for_strptr("Aborted")));
						}
						else {
							dispatch_event(new eq.net.http.HTTPClientErrorEvent().set_message(eq.api.StringStatic.eq_api_StringStatic_for_strptr("WebException encountered.")));
						}
						return(false);
					}
				}}}
			}
			else if("POST".equals(mm)) {
				var rr = InputStream.create(rq.get_body());
				embed "cs" {{{
					hwr = (System.Net.HttpWebRequest)System.Net.WebRequest.Create(uri);
					hwr.Method = "POST";
					try {
						hwr.BeginGetRequestStream(new System.AsyncCallback(async_request_stream_callback), rr);
					}
					catch(System.Net.WebException w) {
						if(w.Status == System.Net.WebExceptionStatus.RequestCanceled) {
							dispatch_event(new eq.net.http.HTTPClientErrorEvent().set_message(eq.api.StringStatic.eq_api_StringStatic_for_strptr("Aborted")));
						}
						else {
							dispatch_event(new eq.net.http.HTTPClientErrorEvent().set_message(eq.api.StringStatic.eq_api_StringStatic_for_strptr("WebException encountered.")));
						}
						return(false);
					}
				}}}
			}
			else {
				dispatch_event(new HTTPClientErrorEvent().set_message("Unsupported HTTP method: `%s'".printf().add(mm).to_string()));
				return(false);
			}
			embed "cs" {{{
				if(async == false) {
					waiter.WaitOne();
					waiter.Reset();
				}
			}}}
			return(true);
		}

		public bool abort() {
			embed "cs" {{{
				if(hwr != null) {
					hwr.Abort();
				}
			}}}
			dispatch_event(new HTTPClientErrorEvent().set_message("Aborted"));
			return(true);
		}

		embed "cs" {{{
			void async_get_response_callback(System.IAsyncResult result) {
				if(result.IsCompleted == false) {
					return;
				}
				System.Net.HttpWebResponse hwr_response = null;
				try {
					hwr_response = (System.Net.HttpWebResponse)hwr.EndGetResponse(result);
				}
				catch(System.Net.WebException w) {
					if(w.Status == System.Net.WebExceptionStatus.RequestCanceled) {
						dispatch_event(new eq.net.http.HTTPClientErrorEvent().set_message(eq.api.StringStatic.eq_api_StringStatic_for_strptr("Aborted")));
					}
					else {
						dispatch_event(new eq.net.http.HTTPClientErrorEvent().set_message(eq.api.StringStatic.eq_api_StringStatic_for_strptr("WebException encountered.")));
					}
					return;
				}
				int sc;
				sc = (int)hwr_response.StatusCode;
				var re = new eq.net.http.HTTPClientResponseEvent();
				re.set_status(eq.api.StringStatic.eq_api_StringStatic_for_integer(sc));
				var hht = eq.api.HashTableStatic.eq_api_HashTableStatic_create();
				var hwr_resp_header = hwr_response.Headers;
				foreach(string hkey in hwr_resp_header.AllKeys) {
					hht.set(eq.api.StringStatic.eq_api_StringStatic_for_strptr(hkey).lowercase(), (eq.api.Object)eq.api.StringStatic.eq_api_StringStatic_for_strptr(hwr_resp_header[hkey]).lowercase());
				}
				re.set_headers(hht);
				dispatch_event((eq.api.Object)re);
				var resp_stream = hwr_response.GetResponseStream();
				var sreader = new System.IO.BinaryReader(resp_stream);
				bool v = true;
				int len = (int)hwr_response.ContentLength;
				byte[] buffer_resp = new byte[len];
				try {
						sreader.Read(buffer_resp, 0, len);
				}
				catch(System.Exception) {
					v = false;
				}
				sreader.Close();
				resp_stream.Close();
				var de = new eq.net.http.HTTPClientDataEvent();
				var pointer = eq.api.PointerStatic.eq_api_PointerStatic_create(
					buffer_resp
				);
				de.set_buffer(eq.api.BufferStatic.eq_api_BufferStatic_for_pointer(pointer, len));
				dispatch_event((eq.api.Object)de);
				dispatch_event((eq.api.Object)new eq.net.http.HTTPClientEndEvent().set_complete(v));
			}

			void async_request_stream_callback(System.IAsyncResult result) {
				if(result.IsCompleted == false) {
					return;
				}
				var rr = result.AsyncState as eq.io.InputStream;
				if(rr != null) {
					var bb = rr.read_all_buffer();
					if(bb != null) {
						var ptr = bb.get_pointer();
						if(ptr != null) {
							var np = ptr.get_native_pointer();
							if(np != null) {
								if(hwr != null) {
									var hwr_rqstream = hwr.EndGetRequestStream(result);
									hwr_rqstream.Write(np, 0, np.Length);
									hwr_rqstream.Close();
								}
							}
						}
					}
				}
				set_headers();
				try { //Check whether abort
					hwr.BeginGetResponse(new System.AsyncCallback(async_get_response_callback), null);
				}
				catch(System.Net.WebException w) {
					if(w.Status == System.Net.WebExceptionStatus.RequestCanceled) {
						dispatch_event(new eq.net.http.HTTPClientErrorEvent().set_message(eq.api.StringStatic.eq_api_StringStatic_for_strptr("Aborted")));
					}
					else {
						dispatch_event(new eq.net.http.HTTPClientErrorEvent().set_message(eq.api.StringStatic.eq_api_StringStatic_for_strptr("WebException encountered.")));
					}
					return;
				}
			}
		}}}
	}

	public static BackgroundTask start(BackgroundTaskManager el, HTTPClientRequest rq, EventReceiver listener) {
		if(el == null) {
			Log.error("No BackgroundTaskManager was set.");
			return(null);
		}
		return(HTTPClientTask.start_request(rq, listener));
	}

	public static bool execute(HTTPClientRequest rq, EventReceiver listener) {
		HTTPClientTask.start_request(rq, listener, false);
		return(true);
	}
}
