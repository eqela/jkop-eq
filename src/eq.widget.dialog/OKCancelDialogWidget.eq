
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

public class OKCancelDialogWidget : TextDialogWidget
{
	public static OKCancelDialogWidget for_question(String question) {
		return((OKCancelDialogWidget)new OKCancelDialogWidget().set_text(question));
	}

	property Object event_ok;
	property Object event_cancel;

	public OKCancelDialogWidget() {
		set_title("Question");
		event_ok = "ok";
		event_cancel = "cancel";
	}

	public void initialize() {
		base.initialize();
		set_dialog_footer_widget(ButtonSet.okcancel(event_ok, event_cancel));
		set_cancel_event(event_cancel);
	}

	public virtual bool on_ok() {
		return(false);
	}

	public virtual bool on_cancel() {
		return(false);
	}

	public bool on_dialog_widget_event(Object o) {
		if(event_ok != null && event_ok is String && ((String)event_ok).equals(o)) {
			return(on_ok());
		}
		if(event_cancel != null && event_cancel is String && ((String)event_cancel).equals(o)) {
			return(on_cancel());
		}
		return(false);
	}
}
