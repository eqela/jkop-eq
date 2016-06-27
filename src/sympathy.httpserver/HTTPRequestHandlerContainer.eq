
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

public class HTTPRequestHandlerContainer : HTTPRequestHandlerAdapter, HTTPRequestHandlerWithLifeCycle
{
	property HTTPRequestSessionHandler session_handler;
	HashTable static_handlers;
	Collection request_handlers;
	HTTPRequestHandler default_handler;
	bool initialized = false;

	Iterator iterate_life_cycle_handlers() {
		var v = LinkedList.create();
		if(static_handlers != null) {
			foreach(HTTPRequestHandlerWithLifeCycle handler in static_handlers.iterate_values()) {
				v.append(handler);
			}
		}
		if(request_handlers != null) {
			foreach(HTTPRequestHandlerWithLifeCycle handler in request_handlers) {
				v.append(handler);
			}
		}
		var ehlf = default_handler as HTTPRequestHandlerWithLifeCycle;
		if(ehlf != null) {
			v.append(ehlf);
		}
		return(v.iterate());
	}

	public void initialize() {
		initialized = true;
		foreach(HTTPRequestHandlerWithLifeCycle handler in iterate_life_cycle_handlers()) {
			handler.initialize();
		}
	}

	public void on_maintenance() {
		foreach(HTTPRequestHandlerWithLifeCycle handler in iterate_life_cycle_handlers()) {
			handler.on_maintenance();
		}
	}

	public void on_refresh() {
		foreach(HTTPRequestHandlerWithLifeCycle handler in iterate_life_cycle_handlers()) {
			handler.on_refresh();
		}
	}

	public void cleanup() {
		initialized = false;
		foreach(HTTPRequestHandlerWithLifeCycle handler in iterate_life_cycle_handlers()) {
			handler.cleanup();
		}
	}

	public virtual void on_handler_add(HTTPRequestHandler handler) {
		var lf = handler as HTTPRequestHandlerWithLifeCycle;
		if(lf == null) {
			return;
		}
		if(initialized) {
			lf.initialize();
		}
	}

	public virtual void on_handler_remove(HTTPRequestHandler handler) {
		var lf = handler as HTTPRequestHandlerWithLifeCycle;
		if(lf == null) {
			return;
		}
		lf.cleanup();
	}

	public HTTPRequestHandlerContainer set_default_handler(HTTPRequestHandler handler) {
		set_request_handler(null, handler);
		return(this);
	}

	public HTTPRequestHandlerContainer set_root_handler(HTTPRequestHandler handler) {
		set_request_handler("", handler);
		return(this);
	}

	public void remove_request_handler_for_path(String path) {
		set_request_handler(path, null);
	}

	public HTTPRequestHandlerContainer set_request_handler(String path, HTTPRequestHandler handler) {
		if(path == null) {
			if(default_handler != null) {
				on_handler_remove(default_handler);
			}
			default_handler = handler;
			if(default_handler != null) {
				on_handler_add(default_handler);
			}
			return(this);
		}
		if(path.chr((int)'/') >= 0) {
			log_warning("Request handler path `%s' contains a `/'. This should not be, and will not work.".printf().add(path));
		}
		if(static_handlers != null) {
			var cc = static_handlers.get(path) as HTTPRequestHandler;
			if(cc != null) {
				on_handler_remove(cc);
			}
		}
		if(handler == null) {
			if(static_handlers != null) {
				static_handlers.remove(path);
			}
			return(this);
		}
		if(static_handlers == null) {
			static_handlers = HashTable.create();
		}
		static_handlers.set(path, handler);
		on_handler_add(handler);
		return(this);
	}

	public HTTPRequestHandlerContainer add_request_handler(HTTPRequestHandler handler) {
		if(handler == null) {
			return(this);
		}
		if(request_handlers == null) {
			request_handlers = LinkedList.create();
		}
		request_handlers.append(handler);
		on_handler_add(handler);
		return(this);
	}

	public HTTPRequestBodyHandler get_request_body_handler(HTTPRequest req) {
		if(static_handlers != null) {
			var r1 = req.pop_resource();
			if(r1 == null) {
				r1 = "";
			}
			var rh = static_handlers.get(r1) as HTTPRequestHandler;
			if(rh != null) {
				var session = check_session(req);
				if(session != null) {
					var v = rh.get_authenticated_request_body_handler(req, session);
					req.unpop_resource();
					return(v);
				}
				var v = rh.get_request_body_handler(req);
				req.unpop_resource();
				return(v);
			}
			req.unpop_resource();
		}
		if(default_handler != null) {
			return(default_handler.get_request_body_handler(req));
		}
		if(request_handlers != null) {
			foreach(HTTPRequestHandler handler in request_handlers) {
				var v = handler.get_request_body_handler(req);
				if(v != null) {
					return(v);
				}
			}
		}
		return(null);
	}

	public bool on_http_request(HTTPRequest req) {
		if(static_handlers != null) {
			var r1 = req.pop_resource();
			if(r1 == null) {
				r1 = "";
			}
			var rh = static_handlers.get(r1) as HTTPRequestHandler;
			if(rh != null) {
				var session = check_session(req);
				if(session != null) {
					if(rh.on_authenticated_request(req, session) == false) {
						return(on_unhandled_request(req, rh));
					}
					return(true);
				}
				if(rh.on_http_request(req) == false) {
					return(on_unhandled_request(req, rh));
				}
				return(true);
			}
			req.unpop_resource();
		}
		if(default_handler != null) {
			if(default_handler.on_http_request(req) == true) {
				return(true);
			}
		}
		if(base.on_http_request(req)) {
			return(true);
		}
		if(request_handlers != null) {
			foreach(HTTPRequestHandler handler in request_handlers) {
				if(handler.on_http_request(req)) {
					return(true);
				}
			}
		}
		return(on_unhandled_request(req, null));
	}

	public override bool on_unhandled_request(HTTPRequest req, HTTPRequestHandler handler = null) {
		if(handler != null) {
			return(handler.on_unhandled_request(req));
		}
		return(false);
	}

	public virtual Object check_session(HTTPRequest req) {
		if(session_handler == null) {
			return(null);
		}
		return(session_handler.check_session(req));
	}
}
