
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

public class WebImageProvider : DynamicImageProvider
{
	class MyImageBufferReceiver : EventReceiver
	{
		property EventReceiver dynamic_image_listener;
		property HTTPClientRequest req;

		public void on_event(Object o) {
			var br = o as HTTPClientBufferResponse;
			if(br == null) {
				return;
			}
			var img = Image.create_image_for_buffer(new ImageBuffer().set_buffer(br.get_data()).set_type(br.get_mime_type()));
			EventReceiver.event(dynamic_image_listener, new DynamicImageResult().set_image(img));
		}
	}

	public static WebImageProvider for_url(URL url) {
		return(new WebImageProvider().set_request(HTTPClientRequest.get(url)));
	}

	public static WebImageProvider for_url_string(String url_string) {
		return(new WebImageProvider().set_request(HTTPClientRequest.get(URL.for_string(url_string))));
	}

	public static WebImageProvider for_request(HTTPClientRequest req) {
		return(new WebImageProvider().set_request(req));
	}

	property HTTPClientRequest request;

	public BackgroundTask get(BackgroundTaskManager btm, EventReceiver listener) {
		if(request == null) {
			return(null);
		}
		return(request.start_get_buffer(btm,
			new MyImageBufferReceiver().set_req(request).set_dynamic_image_listener(listener)));
	}
}
