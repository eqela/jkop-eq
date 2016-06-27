
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

public class HTTPClientStringReceiver : HTTPClientListener, Stringable
{
	property StringBuffer data;
	property EventReceiver listener;
	String response_string;

	public void on_data(HTTPClientDataEvent event) {
		if(data == null) {
			data = StringBuffer.create();
		}
		data.append(String.for_utf8_buffer(event.get_buffer(), false));
	}

	public void on_end(HTTPClientEndEvent event) {
		var resp = new HTTPClientStringResponse();
		resp.copy_header_from(get_header());
		if(data != null) {
			response_string = data.to_string();
			resp.set_data(response_string);
			data = null;
		}
		on_string_response(resp);
	}

	public virtual void on_string_response(HTTPClientStringResponse resp) {
		EventReceiver.event(listener, resp);
	}

	public String to_string() {
		return(response_string);
	}
}
