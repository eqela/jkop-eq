
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

public class HTTPClientListener : LoggerObject, EventReceiver
{
	property HTTPClientResponseHeader header;

	public String get_status() {
		if(header == null) {
			return(null);
		}
		return(header.get_status());
	}

	public bool is_ok() {
		if(header == null) {
			return(false);
		}
		if("200".equals(header.get_status()) == false) {
			return(false);
		}
		return(true);
	}

	public void on_event(Object o) {
		if(o == null) {
		}
		else if(o is HTTPClientStartEvent) {
			on_start((HTTPClientStartEvent)o);
		}
		else if(o is HTTPClientResponseEvent) {
			on_response((HTTPClientResponseEvent)o);
		}
		else if(o is HTTPClientDataEvent) {
			on_data((HTTPClientDataEvent)o);
		}
		else if(o is HTTPClientEndEvent) {
			on_end((HTTPClientEndEvent)o);
		}
		else if(o is HTTPClientErrorEvent) {
			on_error((HTTPClientErrorEvent)o);
		}
	}

	public virtual void on_start(HTTPClientStartEvent event) {
	}

	public virtual void on_response(HTTPClientResponseEvent event) {
		if(header == null) {
			header = new HTTPClientResponseHeader();
		}
		header.set_status(event.get_status());
		header.set_headers(event.get_headers());
	}

	public virtual void on_data(HTTPClientDataEvent event) {
	}

	public virtual void on_end(HTTPClientEndEvent event) {
	}

	public virtual void on_error(HTTPClientErrorEvent event) {
		log_error(event.get_message());
	}
}
