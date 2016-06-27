
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

public class HTTPJSONRequest : LoggerObject, BackgroundTask
{
	class MyRequestListener : HTTPClientJSONReceiver
	{
		property EventReceiver jsonlistener;
		property bool debug = false;
		public void on_json_response(Object data, HTTPClientStringResponse resp) {
			if(debug) {
				Log.debug("*** HTTP JSON RESPONSE START ***");
				var hdrs = resp.get_headers();
				if(hdrs != null && hdrs.count() > 0) {
					Log.debug("--- Response headers start ---");
					foreach(String hdrkey in hdrs) {
						log_debug("- `%s' = `%s'".printf().add(hdrkey).add(hdrs.get_string(hdrkey)));
					}
					Log.debug("--- Response headers end ---");
				}
				Log.debug(resp.get_data());
				Log.debug("*** HTTP JSON RESPONSE END ***");
			}
			if(jsonlistener != null) {
				jsonlistener.on_event(data);
			}
		}
	}

	BackgroundTask task;
	property bool debug = false;

	public HTTPJSONRequest() {
		if("yes".equals(SystemEnvironment.get_env_var("EQ_DEBUG_HTTP_JSON"))) {
			debug = true;
		}
	}

	public HTTPJSONRequest start(BackgroundTaskManager btm, String method, URL url, HashTable headers, Object data, EventReceiver listener) {
		if(btm == null) {
			log_warning("HTTPJSONRequest: No background task manager!");
			if(listener != null) {
				listener.on_event(null);
			}
			return(null);
		}
		if(task != null) {
			abort();
		}
		var hcr = new HTTPClientRequest().set_method(method).set_url(url);
		var hdrs = headers;
		if(headers == null) {
			hdrs = HashTable.create();
		}
		hdrs.set("content-type", "application/json");
		hcr.set_headers(hdrs);
		if(debug) {
			log_debug("*** HTTP JSON REQUEST START ***");
			if(hdrs.count() > 0) {
				log_debug("--- Request headers start ---");
				foreach(String hdrkey in hdrs) {
					log_debug("- `%s' = `%s'".printf().add(hdrkey).add(hdrs.get_string(hdrkey)));
				}
				log_debug("--- Request headers end ---");
			}
		}
		if(data != null) {
			var o = JSONEncoder.encode(data);
			if(debug) {
				log_debug(o);
			}
			hcr.set_body(StringReader.for_string(o));
		}
		if(debug) {
			log_debug("*** HTTP JSON REQUEST END ***");
		}
		task = hcr.start(btm, new MyRequestListener().set_debug(debug).set_jsonlistener(listener));
		if(task == null) {
			if(listener != null) {
				listener.on_event(null);
			}
			return(null);
		}
		return(this);
	}

	public bool abort() {
		if(task != null) {
			if(task.abort()) {
				task = null;
				return(true);
			}
		}
		return(false);
	}
}
