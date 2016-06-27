
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
		HTTPClientRequest request;
		EventReceiver listener;
		bool aborted;
		embed {{{
			Windows.Foundation.IAsyncInfo abortable;
			Windows.Web.Http.HttpClient client;
		}}}

		public static HTTPClientTask start_request(HTTPClientRequest rq, EventReceiver listener) {
			var v = new HTTPClientTask();
			if(v.request_async(rq, listener) == false) {
				return(null);
			}
			return(v);
		}

		void dispose() {
			embed {{{
				if(client != null) {
					client.Dispose();
					client = null;
				}
			}}}
		}

		void _event(Object o) {
			embed {{{
				Windows.ApplicationModel.Core.CoreApplication.MainView.CoreWindow.Dispatcher.RunAsync(
					Windows.UI.Core.CoreDispatcherPriority.Normal,
					() => {
						eq.api.CEventReceiver.@event((eq.api.Object)listener, o);
					}
				);
			}}}
			if(o is eq.net.http.HTTPClientErrorEvent) {
				_event(new eq.net.http.HTTPClientEndEvent().set_complete(false));
			}
		}

		embed {{{
			void retrieve_headers(eq.api.HashTable output, System.Collections.Generic.IDictionary<string, string> headers) {
				if(output != null && headers != null) {
					var rskeys = headers.Keys;
					foreach(string rsk in rskeys) {
						var rsv = headers[rsk];
						output.set(
							eq.api.CString.for_strptr(rsk).lowercase(),
							(eq.api.Object)eq.api.CString.for_strptr(rsv)
						);
					}	
				}
			}
			void request_complete(Windows.Foundation.IAsyncOperationWithProgress<Windows.Web.Http.HttpResponseMessage,Windows.Web.Http.HttpProgress> aowp, Windows.Foundation.AsyncStatus stat) {
				abortable = null;
				Windows.Web.Http.HttpResponseMessage res = null;
				try {
					res = aowp.GetResults();
				}
				catch(System.Exception e) {
					_event(new eq.net.http.HTTPClientErrorEvent().set_message(eq.api.CString.for_strptr("Web Exception: `" + e.Message + "'")));
					dispose();
					return;
				}
				var rscontent = res.Content;
				var sc = (int)res.StatusCode;
				var re = new eq.net.http.HTTPClientResponseEvent();
				re.set_status(eq.api.CString.for_integer(sc));
				{
					var hht = eq.api.CHashTable.create();
					retrieve_headers(hht, res.Headers);
					retrieve_headers(hht, rscontent.Headers);
					re.set_headers(hht);
				}
				_event(re);
				var ao = rscontent.ReadAsInputStreamAsync();
				ao.Completed = async (_aowp, _stat) => {
					var iis = System.IO.WindowsRuntimeStreamExtensions.AsStreamForRead(_aowp.GetResults());
					while(iis.CanRead) {
						var bytes = new byte[1024];
						int read = await iis.ReadAsync(bytes, 0, bytes.Length);
						if(read < 1) {
							break;
						}
						var de = new eq.net.http.HTTPClientDataEvent();
						de.set_buffer(eq.api.CBuffer.for_pointer(eq.api.CPointer.create(bytes), read));
						_event(de);
					}
					var ee = new eq.net.http.HTTPClientEndEvent().set_complete(true);
					_event(ee);
					abortable = null;
					dispose();
				};
				abortable = ao;
			}
		}}}

		bool request_async(HTTPClientRequest rq, EventReceiver listener) {
			this.request = rq;
			this.listener = listener;
			_event(new HTTPClientStartEvent());
			embed {{{
				Windows.Web.Http.HttpRequestMessage message = new Windows.Web.Http.HttpRequestMessage(); 
			}}}
			var urlo = request.get_url();
			if(request == null) {
				_event(new HTTPClientErrorEvent().set_message("No request"));
				return(false);
			}
			if(urlo == null) {
				_event(new HTTPClientErrorEvent().set_message("No URL"));
				return(false);
			}
			var mm = request.get_method();
			var urls = urlo.to_string();
			embed {{{
				try {
					message.RequestUri = new System.Uri(urls.to_strptr());
				}
				catch(System.UriFormatException e) {
					}}} _event(new eq.net.http.HTTPClientErrorEvent().set_message("Invalid URL format")); embed {{{
					return(false);
				}
			}}}
			if(aborted) {
				return(false);
			}
			var rd = request.get_body();
			var ins = InputStream.for_reader(rd);
			Buffer buf;
			if(ins != null) {
				buf = ins.read_all_buffer();
			}
			int sz = 0;
			ptr bytes = null;
			if(buf != null) {
				bytes = buf.get_pointer().get_native_pointer();
				sz = buf.get_size();
			}
			if("GET".equals(mm)) {
				embed {{{
					message.Method = Windows.Web.Http.HttpMethod.Get;
				}}}
			}
			else if("POST".equals(mm)) {
				embed {{{
					message.Method = Windows.Web.Http.HttpMethod.Post;
					if(bytes != null) {
						var iis = new Windows.Storage.Streams.InMemoryRandomAccessStream();
						var ous = iis.GetOutputStreamAt(0);
						using(var dw = new Windows.Storage.Streams.DataWriter(ous)) {
							dw.WriteBytes(bytes);
							var dwop = dw.StoreAsync();
							dwop.Completed = async (rsz, result) => {
								var aodw =  dw.FlushAsync();
								aodw.GetResults();
								dw.DetachStream();
							};
							dwop.GetResults();
						}
						message.Content = new Windows.Web.Http.HttpStreamContent(iis);
					}
				}}}
			}
			if(aborted) {
				return(false);
			}
			var rqheaders = request.get_headers();
			if(rqheaders != null) {
				embed {{{
					var msgheaders = message.Headers;
				}}}
				foreach(String key in rqheaders) {
					var val = rqheaders.get_string(key);
					if(String.is_empty(val) == false) {
						embed {{{
							try {
								msgheaders[key.to_strptr()] = val.to_strptr();
							}
							catch(System.Exception) {
							}
						}}}
					}
				}
			}
			if(aborted) {
				return(false);
			}
			embed {{{
				client = new Windows.Web.Http.HttpClient();
				var ao = client.SendRequestAsync(message);
				ao.Completed = new Windows.Foundation.AsyncOperationWithProgressCompletedHandler<Windows.Web.Http.HttpResponseMessage,Windows.Web.Http.HttpProgress>(request_complete);
				abortable = ao;
			}}}
			return(true);
		}

		public bool abort() {
			aborted = true;
			_event(new HTTPClientErrorEvent().set_message("Aborted"));
			embed {{{
				if(abortable != null) {
					abortable.Cancel();
				}
			}}}
			return(true);
		}
	}

	public static BackgroundTask start(BackgroundTaskManager el, HTTPClientRequest rq, EventReceiver listener) {
		if(el == null) {
			Log.error("No BackgroundTaskManager was set.");
			return(null);
		}
		return(HTTPClientTask.start_request(rq, listener));
	}

	public static bool execute(HTTPClientRequest rq, EventReceiver listener) {
		return(false);
	}
}
