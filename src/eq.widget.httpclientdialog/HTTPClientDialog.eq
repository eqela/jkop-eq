
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

public class HTTPClientDialog : EventReceiver
{
	public HTTPClientDialog for_request(HTTPClientRequest req) {
		return(new HTTPClientDialog().set_request(req));
	}

	property HTTPClientRequest request;
	property String url;
	property String message;
	property bool modal = true;
	WaitDialogWidget wdw;

	public virtual HTTPClientRequest get_http_request() {
		if(request != null) {
			return(request);
		}
		if(url != null) {
			return(HTTPClientRequest.get(URL.for_string(url)));
		}
		return(null);
	}

	public BackgroundTask start_background_task() {
		var rq = get_http_request();
		if(rq == null) {
			return(null);
		}
		return(rq.start(GUI.engine.get_background_task_manager(),
			new HTTPClientBufferReceiver().set_listener(this)));
	}

	public virtual void on_response(HTTPClientBufferResponse b) {
	}

	public void on_event(Object o) {
		if(o is HTTPClientBufferResponse) {
			if(wdw != null) {
				Frame.close(wdw.get_frame());
				wdw = null;
			}
			on_response((HTTPClientBufferResponse)o);
			return;
		}
	}

	public HTTPClientDialog execute(Frame frame) {
		var op = start_background_task();
		if(op == null) {
			return(null);
		}
		wdw = new WaitDialogWidget();
		wdw.set_title("Communicating ..");
		var msg = message;
		if(String.is_empty(msg)) {
			msg = "Please wait ..";
		}
		wdw.set_text(msg);
		wdw.set_op(op);
		var ff = frame;
		if(modal == false) {
			ff = null;
		}
		Frame.open_as_popup(WidgetEngine.for_widget(wdw), ff);
		return(this);
	}
}
