
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

public class HTTPClientGetUrlTask : StartableTask, BackgroundTask
{
	property URL url;
	property bool as_buffer = false;
	BackgroundTask httpop;
	bool aborted = false;
	property BackgroundTaskManager background_task_manager;

	public BackgroundTask start(EventReceiver listener) {
		aborted = false;
		if(as_buffer) {
			httpop = HTTPClientRequest.get(url).start(background_task_manager, new MyBufferReceiver().set_task(this).set_er(listener));
		}
		else {
			httpop = HTTPClientRequest.get(url).start(background_task_manager, new MyStringReceiver().set_task(this).set_er(listener));
		}
		if(httpop == null) {
			return(null);
		}
		return(this);
	}

	class MyStringReceiver : HTTPClientStringReceiver {
		property HTTPClientGetUrlTask task;
		property EventReceiver er;
		public void on_string_response(HTTPClientStringResponse resp) {
			if(task != null) {
				task.on_string_response(resp, er);
			}
		}
	}

	class MyBufferReceiver : HTTPClientBufferReceiver {
		property HTTPClientGetUrlTask task;
		property EventReceiver er;
		public void on_buffer_response(HTTPClientBufferResponse resp) {
			if(task != null) {
				task.on_buffer_response(resp, er);
			}
		}
	}

	public virtual void on_string_response(HTTPClientStringResponse resp, EventReceiver er) {
		if(aborted) {
			return;
		}
		EventReceiver.event(er, resp);
	}

	public virtual void on_buffer_response(HTTPClientBufferResponse resp, EventReceiver er) {
		if(aborted) {
			return;
		}
		EventReceiver.event(er, resp);
	}

	public bool abort() {
		aborted = true;
		if(httpop != null) {
			return(httpop.abort());
		}
		return(false);
	}
}
