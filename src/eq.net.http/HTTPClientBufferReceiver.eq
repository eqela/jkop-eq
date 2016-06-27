
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

public class HTTPClientBufferReceiver : HTTPClientListener
{
	property DynamicBuffer data;
	property EventReceiver listener;

	public void on_data(HTTPClientDataEvent event) {
		if(data == null) {
			data = DynamicBuffer.create();
		}
		DynamicBuffer.cat(data, event.get_buffer());
	}

	public void on_end(HTTPClientEndEvent event) {
		var resp = new HTTPClientBufferResponse();
		resp.copy_header_from(get_header());
		resp.set_data(data);
		// data = null;
		on_buffer_response(resp);
	}

	public virtual void on_buffer_response(HTTPClientBufferResponse resp) {
		EventReceiver.event(listener, resp);
	}
}
