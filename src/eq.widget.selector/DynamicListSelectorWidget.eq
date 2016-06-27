
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

public class DynamicListSelectorWidget : ListSelectorWidget
{
	class ResultReceiver : EventReceiver
	{
		property DynamicListSelectorWidget widget;
		public void on_event(Object o) {
			widget.on_task_complete(o);
		}
	}

	ProgressOverlayWidget progress;

	public virtual RunnableTask create_update_task() {
		return(null);
	}

	public virtual BackgroundTask execute_update_task(EventReceiver listener) {
		var task = create_update_task();
		if(task == null) {
			return(null);
		}
		return(start_task(task, listener));
	}

	public virtual void on_task_result(Object o) {
	}

	public void first_start() {
		base.first_start();
		refresh();
	}

	public void refresh() {
		if(progress != null) {
			return;
		}
		// FIXME: The return value could be used to implement a `cancel' feature
		if(execute_update_task(new ResultReceiver().set_widget(this)) != null) {
			progress = ProgressOverlayWidget.show(this, "Updating list ..");
		}
	}

	public void on_task_complete(Object o) {
		progress = ProgressOverlayWidget.hide(progress);
		set_items(null);
		on_task_result(o);
	}
}
