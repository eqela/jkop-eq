
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
	class AsyncQueue : Win32MainQueueHandler {
		HTTPClientTask task;
		Object event;
		public static AsyncQueue for_task(HTTPClientTask task, Object event) {
			var v = new AsyncQueue();
			v.task = task;
			v.event = event;
			return(v);
		}

		public void on_main_queue_event() {
			task.trigger_event(event);
		}
	}

	class HTTPClientTask : BackgroundTask
	{
		embed "c++" {{{
			#include <windows.h>
			#include <winhttp.h>
			#include <string.h>
		}}}

		Buffer post_buffer;
		Win32MainQueue background_task;
		HTTPClientRequest rq;
		EventReceiver listener;
		bool aborted;
		bool async;
		ptr hrequest = null;
		ptr hconnect = null;
		ptr hsession = null;

		~HTTPClientTask() {
			close_handles();
			rq = null;
		}

		public static HTTPClientTask start(HTTPClientRequest rq, EventReceiver listener, bool async = true) {
			var v = new HTTPClientTask();
			v.rq = rq;
			v.listener = listener;
			v.async = async;
			if(v.do_run() == false) {
				return(null);
			}
			return(v);
		}

		public void trigger_event(Object event) {
			if(event != null && event is Stringable) {
				Log.debug(String.as_string(event));
			}
			EventReceiver.event(listener, event);
			if(event is HTTPClientErrorEvent) {
				int err = 0;
				embed {{{
					err = GetLastError();
				}}}
				aborted = true;
				on_read_done(false);
				rq = null;
			}
			if(event is HTTPClientEndEvent) {
				if(async && hrequest != null) { //ensure that it was from an async request.
					close_handles();
					embed "c++" {{{
						unref_eq_api_Object(self);
					}}}
				}
			}
		}

		void queue_event(Object event) {
			if(async) {
				if(background_task == null) {
					background_task = Win32MainQueue.instance();
				}
				background_task.add_to_queue(AsyncQueue.for_task(this, event));
			}
			else {
				EventReceiver.event(listener, event);
			}
			if(aborted) {
				return;
			}
		}

		embed "c++" {{{
			LPWSTR to_lpwstr(char* cptr) {
				if(cptr) {
					int len = MultiByteToWideChar(CP_ACP, 0, cptr, strlen(cptr)+1, 0, 0);
					wchar_t* buf = new wchar_t[len];
					MultiByteToWideChar(CP_ACP, 0, cptr, strlen(cptr)+1, buf, len);
					return(buf);
				}
				return(NULL);
			}

			char* get_cstring_headers(HINTERNET hrequest) {
				char* v = 0;
				DWORD dwSize;
				WinHttpQueryHeaders(hrequest, WINHTTP_QUERY_RAW_HEADERS_CRLF,
					WINHTTP_HEADER_NAME_BY_INDEX, NULL,
					&dwSize, WINHTTP_NO_HEADER_INDEX);
				if(GetLastError() == ERROR_INSUFFICIENT_BUFFER)	{
					WCHAR* lpOutBuffer = new WCHAR[dwSize/sizeof(WCHAR)];
					BOOL bresults = WinHttpQueryHeaders(hrequest, WINHTTP_QUERY_RAW_HEADERS_CRLF,
						WINHTTP_HEADER_NAME_BY_INDEX,	lpOutBuffer,
						&dwSize,	WINHTTP_NO_HEADER_INDEX);
					if(bresults) {
						v = new char[wcslen(lpOutBuffer)+1];
						wcstombs(v, lpOutBuffer, wcslen(lpOutBuffer));
					}
					delete[] lpOutBuffer;
				}
				return(v);
			}

			void CALLBACK AsyncCallback(HINTERNET hInternet, DWORD* self, DWORD dwInternetStatus, void * lpvStatusInfo, DWORD dwStatusInfoLength) {
				switch(dwInternetStatus) {
					case WINHTTP_CALLBACK_STATUS_HEADERS_AVAILABLE: {
						char* headers = get_cstring_headers(hInternet);
						eq_net_http_HTTPClientOperation_HTTPClientTask_on_headers_set(self, headers);
						delete[] headers;
						if(!WinHttpQueryDataAvailable(hInternet, 0)) {
							eq_net_http_HTTPClientOperation_HTTPClientTask_on_failed(self, (char*)"(WINHTTP) Query available data failed.", -1);
						}
					}
					break;
					case WINHTTP_CALLBACK_STATUS_SENDREQUEST_COMPLETE: {
					}
					break;
					case WINHTTP_CALLBACK_STATUS_DATA_AVAILABLE: {
						DWORD size = (DWORD)*((DWORD*)lpvStatusInfo);
						BYTE* obuf = new BYTE[size+1];
						ZeroMemory(obuf, size+1);
						if(!WinHttpReadData(hInternet, (LPVOID)obuf, size, NULL)) {
							eq_net_http_HTTPClientOperation_HTTPClientTask_on_failed(self, (char*)"(WINHTTP) Reading data failed.", -1);
						}
					}
					break;
					case WINHTTP_CALLBACK_STATUS_WRITE_COMPLETE: {
					}
					case WINHTTP_CALLBACK_STATUS_READ_COMPLETE: {
						BYTE* obuf = (BYTE*)lpvStatusInfo;
						DWORD size = dwStatusInfoLength;
						if(size > 0) {
							eq_net_http_HTTPClientOperation_HTTPClientTask_on_read_completed(self, obuf, size);
							if(!WinHttpQueryDataAvailable(hInternet, 0)) {
								eq_net_http_HTTPClientOperation_HTTPClientTask_on_failed(self, (char*)"(WINHTTP) Query available data failed.", -1);
							}
						}
						else {
							eq_net_http_HTTPClientOperation_HTTPClientTask_on_read_done(self, TRUE);
						}
						delete[] obuf;
					}
					break;
					case WINHTTP_CALLBACK_STATUS_REQUEST_ERROR: {
						WINHTTP_ASYNC_RESULT* res = (WINHTTP_ASYNC_RESULT*)lpvStatusInfo;
						DWORD err = 0;
						if(res) {
							err = res->dwResult;
							if(err == 1) {
								eq_net_http_HTTPClientOperation_HTTPClientTask_on_failed(self, (char*)"RECEIVE RESPONSE", res->dwError);
							}
							else if(err == 2) {
								eq_net_http_HTTPClientOperation_HTTPClientTask_on_failed(self, (char*)"QUERY_DATA_AVAILABLE", res->dwError);
							}
							else if(err == 3) {
								eq_net_http_HTTPClientOperation_HTTPClientTask_on_failed(self, (char*)"READ_DATA", res->dwError);
							}
							else if(err == 4) {
								eq_net_http_HTTPClientOperation_HTTPClientTask_on_failed(self, (char*)"WRITE_DATA", res->dwError);
							}
							else if(err == 5) {
								eq_net_http_HTTPClientOperation_HTTPClientTask_on_failed(self, (char*)"SEND_DATA", res->dwError);
							}
						}
					}
					break;
					case WINHTTP_CALLBACK_STATUS_HANDLE_CLOSING: {
					}
					default: {
					}
					break;
				}
			}
		}}}

		private void receive_response() {
			strptr cstring;
			ptr hrequest = this.hrequest;
			embed "c++" {{{
				WinHttpReceiveResponse(hrequest, 0);
				BOOL bresults;
				DWORD dwSize;
				cstring = get_cstring_headers(hrequest);
			}}}
			if(cstring != null) {
				var hdr = parse_header(String.for_strptr(cstring));
				embed "c++" {{{
					delete[] cstring;
				}}}
				var re = new HTTPClientResponseEvent();
				re.set_headers(hdr);
				re.set_status(hdr.get_string("HTTP_STATUS"));
			}
			int dlen;
			embed "c++" {{{
				DWORD size = 0;
				if(bresults) {
					while(true) {
						if(!WinHttpQueryDataAvailable(hrequest, (DWORD*)&dlen) || dlen < 1) {
							break;
						}
						BYTE* obuf = new BYTE[dlen+1];
						if(!obuf) {
							eq_net_http_HTTPClientOperation_HTTPClientTask_on_failed(self, (char*)"Failed to allocate memory", -1);
							dlen = 0;
						}
						else {
							ZeroMemory(obuf, dlen+1);
							if(!WinHttpReadData(hrequest, (LPVOID)obuf, (DWORD)dlen, &size)) {
								eq_net_http_HTTPClientOperation_HTTPClientTask_on_failed(self, (char*)"Failed reading data", -1);
							}
							eq_net_http_HTTPClientOperation_HTTPClientTask_on_read_completed(self, obuf, size);
							delete[] (BYTE*)obuf;
						}
					}
				}
				eq_net_http_HTTPClientOperation_HTTPClientTask_on_read_done(self, bresults);
			}}}
		}

		void on_headers_set(strptr str) {
			var headers = parse_header(String.for_strptr(str));
			if(headers != null) {
				var re = new HTTPClientResponseEvent();
				re.set_status(headers.get_string("HTTP_STATUS"));
				re.set_headers(headers);
				queue_event(re);
			}
		}

		void on_read_completed(ptr data, int size) {
			var buffer = DynamicBuffer.create(size);
			if(buffer == null) {
				queue_event(new HTTPClientErrorEvent().set_message("Failed to allocate memory for the response."));
				return;
			}
			var pbuffer = buffer.get_pointer();
			pbuffer.cpyfrom(Pointer.create(data), 0, 0, size);
			var de = new HTTPClientDataEvent();
			de.set_buffer(buffer);
			queue_event(de);
		}

		void on_read_done(bool v) {
			queue_event(new HTTPClientEndEvent().set_complete(v));
		}

		void on_failed(strptr cstr, int err = -1) {
			String message = String.for_strptr(cstr);
			if(err > -1) {
				message = "%s: code `%d'".printf().add(message).add(err).to_string();
			}
			queue_event(new HTTPClientErrorEvent().set_message(message));
		}

		public bool do_run() {
			bool async = this.async;
			trigger_event(new HTTPClientStartEvent());
			if(rq == null) {
				trigger_event(new HTTPClientErrorEvent().set_message("No request"));
				return(false);
			}
			ptr hsession = null;
			ptr hrequest = null;
			ptr hconnect = null;
			var mm = rq.get_method();
			var urlo = rq.get_url();
			var hdrs = rq.get_headers();
			var version = "HTTP/1.1";
			if(urlo == null) {
				trigger_event(new HTTPClientErrorEvent().set_message("No URL"));
				return(false);
			}
			var cptr_host = urlo.get_host().to_strptr();
			String port = urlo.get_port();
			int iport;
			int flag = 0;
			if("https".equals(urlo.get_scheme())) {
				embed "c++" {{{
					iport = INTERNET_DEFAULT_HTTPS_PORT;
					flag = WINHTTP_FLAG_SECURE;
				}}}
			}
			else {
				embed "c++" {{{
					iport = INTERNET_DEFAULT_HTTP_PORT;
				}}}
			}
			if(port != null) {
				iport = port.to_integer();
			}
			String ua = null;
			if(hdrs != null) {
				ua = EqelaUserAgent.get_platform_user_agent(hdrs.get("User-Agent") as String);
			}
			strptr aua;
			if(ua != null) {
				aua = ua.to_strptr();
			}
			else {
				aua = "".to_strptr();
			}
			embed "c++" {{{
				DWORD aflag = WINHTTP_FLAG_ASYNC;
				if(async == false) {
					aflag = 0;
				}
				LPWSTR str = to_lpwstr(aua);
				hsession = WinHttpOpen(str,
					WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
					WINHTTP_NO_PROXY_NAME, 
					WINHTTP_NO_PROXY_BYPASS, aflag
				);
				delete[] (wchar_t*)str;
				}}} this.hsession = hsession;embed "c++" {{{
				if(hsession) {
					if(async) {
						WinHttpSetStatusCallback(hsession,
							(WINHTTP_STATUS_CALLBACK)AsyncCallback,
							WINHTTP_CALLBACK_FLAG_ALL_NOTIFICATIONS,
							0
						);
					}
					LPWSTR str = to_lpwstr(cptr_host);
					hconnect = WinHttpConnect(hsession, str, (DWORD)iport, 0);
					delete[] (wchar_t*)str;
					}}} this.hconnect = hconnect; embed "c++" {{{
				}
				else {
					}}} trigger_event(new HTTPClientErrorEvent().set_message("(WINHTTP) Failed to open a connection.")); embed "c++" {{{
				}
				if(!hconnect) {
					}}} trigger_event(new HTTPClientErrorEvent().set_message("(WINHTTP) Failed to connect."));
					return(false);
					embed "c++" {{{
				}
			}}}
			String str_nohost = urlo.to_string_nohost();
			var cptr_nohost = str_nohost.to_strptr();
			var cptr_method = mm.to_strptr();
			if(cptr_method == null) {
				trigger_event(new HTTPClientErrorEvent().set_message("Unsupported HTTP client method: `%s'".printf().add(mm).to_string()));
				return(false);
			}
			embed "c++" {{{
				if(hconnect) {
					LPWSTR lpwstr_host = to_lpwstr(cptr_nohost);
					LPWSTR lpwstr_method = to_lpwstr(cptr_method);
					hrequest = WinHttpOpenRequest(hconnect, lpwstr_method, lpwstr_host,
						NULL, WINHTTP_NO_REFERER, 
						WINHTTP_DEFAULT_ACCEPT_TYPES, 
						flag);
					delete[] (wchar_t*)lpwstr_host;
					delete[] (wchar_t*)lpwstr_method;
				}
			}}}
			this.hrequest = hrequest;
			String str_headers = null;
			if(hdrs != null && hdrs.count() != 0) {
				StringBuffer arequest = StringBuffer.create();
				foreach(String key in hdrs.iterate_keys()) {
					var val = hdrs.get_string(key);
					if(val != null) {
						arequest.append("%s: %s\r\n".printf().add(key).add(val).to_string());
					}
				}
				str_headers = arequest.to_string();
			}
			strptr ptr_headers = null;
			if(str_headers!=null) {
				ptr_headers = str_headers.to_strptr();
			}
			ptr np = null;
			int sz = 0;
			if("POST".equals(mm)) {
				var rr = InputStream.create(rq.get_body());
				if(rr != null) {
					post_buffer = rr.read_all_buffer();
					if(post_buffer != null) {
						var ptr = post_buffer.get_pointer();
						sz = post_buffer.get_size();
						if(ptr != null) {
							np = ptr.get_native_pointer();
						}
					}
				}
			}
			embed "c++" {{{
				if(hrequest) {
					LPWSTR str = to_lpwstr(ptr_headers);
					bool bResults = WinHttpSendRequest(
						hrequest, str, (str ? wcslen(str) : 0), 
						(np != NULL) ? np : WINHTTP_NO_REQUEST_DATA,
						(DWORD)sz, (DWORD)sz, (DWORD_PTR)self);
					delete[] (wchar_t*)str;
				}
				else {
					}}} Log.error("(WINHTTP) Failed to open a request"); embed "c++" {{{
				}
			}}}
			if(async) {
				embed "c++" {{{
					ref_eq_api_Object(self);
					WinHttpReceiveResponse(hrequest, NULL);
				}}}
			}
			else {
				receive_response();
			}
			return(true);
		}

		private HashTable parse_header(String str) {
			var v = HashTable.create();
			var chars = str.iterate();
			int c;
			bool first = true;
			while(true) {
				var sb = StringBuffer.create();
				while ((c = chars.next_char()) != 0) {
					if (c == '\r') {
					}
					else if (c == '\n') {
						break;
					}
					else {
						sb.append_c(c);
					}
				}
				var t = sb.dup_string();
				if(t == null || t.get_length() < 1) {
					break;
				}
				if(first) {
					var comps = t.split(' ', 3);
					String tmp = comps.next() as String;
					if(tmp != null) {
						v.set("HTTP_VERSION", tmp);
						tmp = comps.next() as String;
						if(tmp != null) {
							v.set("HTTP_STATUS", tmp);
							tmp = comps.next() as String;
							if(tmp != null) {
								v.set("HTTP_STATUS_DESC", tmp);
							}
						}
					}
				}
				else {
					var comps = t.split(':', 2);
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
			return(v);
		}

		private void close_handles() {
			ptr hsession = this.hsession;
			ptr hrequest = this.hrequest;
			ptr hconnect = this.hconnect;
			embed "c++" {{{
				if(hrequest) {
					WinHttpCloseHandle(hrequest);
				}
				if(hsession) {
					WinHttpCloseHandle(hsession);
				}
				if(hconnect) {
					WinHttpCloseHandle(hconnect);
				}
				WinHttpSetStatusCallback(hsession,
					NULL,
					WINHTTP_CALLBACK_FLAG_ALL_NOTIFICATIONS,
					0
				);
			}}}
			this.hsession = null;
			this.hrequest = null;
			this.hconnect = null;
		}

		public bool abort() {
			ptr hrequest = this.hrequest;
			if(hrequest != null) {
				queue_event(new HTTPClientErrorEvent().set_message("Aborted"));
			}
			return(true);
		}
	}

	public static BackgroundTask start(BackgroundTaskManager el, HTTPClientRequest rq, EventReceiver listener) {
		return(HTTPClientTask.start(rq, listener));
	}

	public static bool execute(HTTPClientRequest rq, EventReceiver listener) {
		HTTPClientTask.start(rq, listener, false);
		return(true);
	}
}

