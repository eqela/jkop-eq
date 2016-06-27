
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

public class BackgroundTaskDialogWidget : WaitDialogWidget
{
	class MyRunnableTask : RunnableTask
	{
		property BackgroundTaskDialogWidget widget;
		public void run(EventReceiver listener, BooleanValue abortflag) {
			widget.set_thread_listener(listener);
			var r = widget.run_in_background(abortflag);
			widget.set_thread_listener(null);
			EventReceiver.event(listener, Primitive.for_boolean(r));
		}
	}

	property Error error;
	property EventReceiver thread_listener;
	property RunnableTask runnable_task;

	public BackgroundTaskDialogWidget() {
		set_title("Processing");
		set_text("Please wait ..");
	}

	public BackgroundTaskDialogWidget execute(WidgetEngine engine) {
		Popup.widget(engine, this);
		return(this);
	}

	public virtual RunnableTask create_runnable_task() {
		if(runnable_task != null) {
			return(runnable_task);
		}
		return(new MyRunnableTask().set_widget(this));
	}

	public virtual BackgroundTask create_background_task() {
		var task = create_runnable_task();
		if(task == null) {
			return(null);
		}
		return(start_task(task, this));
	}

	class ChangeTextEvent
	{
		property String text;
	}

	public void change_dialog_text(String text) {
		if(thread_listener != null) {
			thread_listener.on_event(new ChangeTextEvent().set_text(text));
		}
	}

	public virtual bool run_in_background(BooleanValue abortflag) {
		return(false);
	}

	public virtual void on_task_success() {
	}

	public virtual void on_task_error() {
		var e = String.as_string(error);
		if(String.is_empty(e)) {
			e = "An unknown error occurred";
		}
		ErrorDialog.show(get_engine(), e);
	}

	public virtual void on_task_ended(bool result) {
		if(result) {
			on_task_success();
		}
		else {
			on_task_error();
		}
	}

	public void start() {
		base.start();
		if(get_op() != null) {
			return;
		}
		set_op(create_background_task());
	}

	public void stop() {
		base.stop();
		var op = get_op();
		if(op != null) {
			op.abort();
		}
		set_op(null);
	}

	public void on_event(Object o) {
		if(o != null && o is Boolean && o is String == false) {
			on_task_ended(((Boolean)o).to_boolean());
			Popup.close(this);
			return;
		}
		if(o != null && o is ChangeTextEvent) {
			set_text(((ChangeTextEvent)o).get_text());
			return;
		}
		base.on_event(o);
	}
}
