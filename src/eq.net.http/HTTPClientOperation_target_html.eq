
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

class HTTPClientOperation
{
	ptr create_request() {
		ptr v = null;
		embed "js" {{{
			if(v === null) {
				if(typeof XDomainRequest !== "undefined") {
					try { v = new XDomainRequest(); } catch(e) {console.log("xdomain failed");}
				}
			}
			if(v === null) {
				try { v = new XMLHttpRequest(); } catch(e) {console.log("XMLHTTPRequest failed")}
			}
			if(v === null) {
				try { v = new ActiveXObject("Msxml2.XMLHTTP.6.0"); } catch(e) {console.log("msxml2 6.0 failed")}
			}
			if(v === null) {
				try { v = new ActiveXObject("Msxml2.XMLHTTP.3.0"); } catch(e) {console.log("msxml2 3.0 failed")}
			}
			if(v === null) {
				try { v = new ActiveXObject("Microsoft.XMLHTTP"); } catch(e) {console.log("ms xmlhttp failed")}
			}
			if(v === null) {
				try { v = window.createRequest(); } catch(e) {}
			}
		}}}
		return(v);
	}

	bool is_binary_request(HTTPClientRequest rq) {
		if(rq == null) {
			return(false);
		}
		var url = rq.get_url();
		if(url == null) {
			return(false);
		}
		var path = url.get_path();
		if(path == null) {
			return(false);
		}
		// FIXME: This is a hack just to enable image retrieval.
		if(path.has_suffix(".png") || path.has_suffix(".jpg") || path.has_suffix(".mp3") || path.has_suffix(".m4a") ||
			path.has_suffix(".ogg") || path.has_suffix(".mp4")) {
			return(true);
		}
		return(false);
	}

	ptr init_request(HTTPClientRequest rq, bool async, EventReceiver listener) {
		trigger_event(listener, new HTTPClientStartEvent());
		ptr v = create_request();
		if(v == null) {
			trigger_event(listener, new HTTPClientErrorEvent().set_message("Failed to create an HTTPClientRequest"));
			return(null);
		}
		var meth = rq.get_method();
		if(meth == null) {
			trigger_event(listener, new HTTPClientErrorEvent().set_message("No method"));
			return(null);
		}
		var url = rq.get_url();
		if(url == null) {
			trigger_event(listener, new HTTPClientErrorEvent().set_message("No URL"));
			return(null);
		}
		var urls = url.to_string();
		if(urls == null) {
			return(null);
		}
		if("https".equals(url.get_scheme()) || "http".equals(url.get_scheme())) {
			embed "js" {{{
				v.open(meth.to_strptr(), urls.to_strptr(), async);
			}}}
		}
		else {
			v = null;
			return(null);
		}
		if(is_binary_request(rq)) {
			embed "js" {{{
				v.responseType = 'arraybuffer';
			}}}
		}
		var hdr = rq.get_headers();
		if(hdr != null) {
			var it = hdr.iterate_keys();
			while(it != null) {
				var k = it.next() as String;
				if(k == null) {
					break;
				}
				var val = hdr.get_string(k);
				if(val == null) {
					val = "";
				}
				var keyp = k.to_strptr();
				var valp = val.to_strptr();
				embed "js" {{{
					v.setRequestHeader(keyp, valp);
				}}}
			}
		}
		String ua = null;
		if(hdr != null) {
			ua = EqelaUserAgent.get_platform_user_agent(hdr.get("User-Agent") as String);
		}
		if(ua != null) {
			embed "js" {{{
				v.setRequestHeader("User-Agent", ua.to_strptr());
			}}}
		}
		if(async) {
			embed "js" {{{
				var self = this;
				v.onreadystatechange = function() {
					if(v.readyState == 4) {
						if(listener !== null) {
							self.on_js_http_response(rq, v, listener);
						}
					}
				};
			}}}
		}
		return(v);
	}

	bool send_request(HTTPClientRequest rq, ptr xrq) {
		bool v = true;
		embed "js" {{{
			try {
		}}}
		if("POST".equals(rq.get_method())) {
			String str;
			var bd = rq.get_body();
			if(bd == null) {
			}
			else if(bd is String) {
				str = (String)bd;
			}
			else if(bd is Stringable) {
				str = ((Stringable)bd).to_string();
			}
			else if(bd is Reader) {
				var iss = InputStream.create((Reader)bd);
				if(iss != null) {
					str = iss.read_all_string();
				}
			}
			if(str == null) {
				Log.error("Unable to convert the POST body to a string");
				v = false;
			}
			else {
				embed "js" {{{
					xrq.send(str.to_strptr());
				}}}
			}
		}
		else {
			embed "js" {{{
				xrq.send(null);
			}}}
		}
		embed "js" {{{
			}
			catch(e) {
				v = false;
			}
		}}}
		return(v);
	}

	BackgroundTaskManager btm;

	class TriggerTimer : TimerHandler {
		property EventReceiver listener;
		public bool on_timer(Object event) {
			EventReceiver.event(listener, event);
			return(false);
		}
	}

	void trigger_event(EventReceiver listener, Object event) {
		if(btm == null) {
			btm = GUI.engine.get_background_task_manager();
		}
		var trigger = new TriggerTimer().set_listener(listener);
		btm.start_timer(0, trigger, event);
	}

	void trigger_response_events(HTTPClientRequest rq, ptr xr, EventReceiver listener) {
		if(xr == null) {
			return;
		}
		int status;
		strptr headers;
		strptr bodytext;
		ptr bodybuffer;
		embed "js" {{{
			if(xr.readyState != 4) {
				return(null);
			}
			status = xr.status;
			headers = xr.getAllResponseHeaders();
		}}}
		if(is_binary_request(rq)) {
			embed "js" {{{
				bodybuffer = xr.response;
			}}}
		}
		else {
			embed "js" {{{
				bodytext = xr.responseText;
			}}}
		}
		var re = new HTTPClientResponseEvent();
		re.set_status(String.for_integer(status));
		var hdrs = String.for_strptr(headers);
		var splt = StringSplitter.split(hdrs, '\n');
		var hht = HashTable.create();
		while(splt != null) {
			var line = splt.next() as String;
			if(line == null) {
				break;
			}
			var kvs = StringSplitter.split(line, ':', 2);
			if(kvs != null) {
				var key = kvs.next() as String;
				var val = kvs.next() as String;
				if(val != null) {
					val = val.strip();
				}
				if(String.is_empty(key) == false) {
					hht.set(key.lowercase(), val);
				}
			}
		}
		re.set_headers(hht);
		trigger_event(listener, re);
		var de = new HTTPClientDataEvent();
		Buffer v = null;
		if(bodytext != null) {
			var t = String.for_strptr(bodytext).dup();
			v = t.to_utf8_buffer();
		}
		if(bodybuffer != null) {
			int l;
			ptr ppp;
			embed "js" {{{
				l = bodybuffer.byteLength;
				ppp = new Uint8Array(bodybuffer);
			}}}
			v = Buffer.for_pointer(Pointer.create(ppp), l);
		}
		de.set_buffer(v);
		trigger_event(listener, de);
		trigger_event(listener, new HTTPClientEndEvent().set_complete(true));
	}

	void on_js_http_response(HTTPClientRequest rq, ptr xr, EventReceiver listener) {
		trigger_response_events(rq, xr, listener);
	}

	class MyAsyncOperation : BackgroundTask
	{
		property ptr xr;
		property EventReceiver listener;
		public bool abort() {
			if(xr != null) {
				var xxr = xr;
				embed "js" {{{
					xxr.abort();
				}}}
				xr = null;
				EventReceiver.event(listener, new HTTPClientErrorEvent().set_message("Aborted"));
				return(true);
			}
			return(false);
		}
	}

	public static BackgroundTask start(BackgroundTaskManager el, HTTPClientRequest rq, EventReceiver listener) {
		var v = new HTTPClientOperation();
		var xr = v.init_request(rq, true, listener);
		if(xr == null) {
			Log.error("FAILED to initialize an XMLHTTPClientRequest for `%s'".printf().add(rq.get_url()));
			v.trigger_event(listener, new HTTPClientEndEvent().set_complete(false));
		}
		if(xr != null) {
			if(v.send_request(rq, xr) == false) {
				v.trigger_event(listener, new HTTPClientErrorEvent().set_message("Sending request failed."));
				v.trigger_event(listener, new HTTPClientEndEvent().set_complete(false));
			}
		}
		return(new MyAsyncOperation().set_xr(xr).set_listener(listener));
	}

	public static bool execute(HTTPClientRequest rq, EventReceiver listener) {
		var v = new HTTPClientOperation();
		var xr = v.init_request(rq, false, listener);
		if(xr == null) {
			Log.error("FAILED to initialize an XMLHTTPClientRequest for `%s'".printf().add(rq.get_url()));
			v.trigger_event(listener, new HTTPClientEndEvent().set_complete(false));
			return(false);
		}
		if(v.send_request(rq, xr) == false) {
			v.trigger_event(listener, new HTTPClientErrorEvent().set_message("Sending request failed."));
			return(false);
		}
		v.trigger_response_events(rq, xr, listener);
		return(true);
	}
}

