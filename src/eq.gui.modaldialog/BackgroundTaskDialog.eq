
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

public class BackgroundTaskDialog
{
	class MyBackgroundTaskDialogWidget : BackgroundTaskDialogWidget
	{
		property BackgroundTaskDialog dlg;

		public bool run_in_background(BooleanValue abortflag) {
			dlg.set_abortflag(abortflag);
			var r = dlg.run_in_background();
			dlg.set_abortflag(null);
			return(r);
		}

		public void on_task_ended(bool result) {
			dlg.on_task_ended(result);
			dlg.clear();
		}
	}

	property BooleanValue abortflag;
	property bool modal = true;
	property Frame frame;
	MyBackgroundTaskDialogWidget dlgwidget;

	public void clear() {
		dlgwidget = null;
	}

	public virtual void on_task_ended(bool result) {
	}

	public bool should_abort() {
		if(abortflag == null) {
			return(false);
		}
		return(abortflag.to_boolean());
	}

	public void change_status(String text) {
		if(dlgwidget != null) {
			dlgwidget.change_dialog_text(text);
		}
	}

	public virtual bool run_in_background() {
		return(true);
	}

	public BackgroundTaskDialog execute(Frame frame) {
		this.frame = frame;
		var dlg = new MyBackgroundTaskDialogWidget().set_dlg(this);
		dlgwidget = dlg;
		var ff = frame;
		if(modal == false) {
			ff = null;
		}
		Frame.open_as_popup(WidgetEngine.for_widget(dlg), ff);
		return(this);
	}
}
