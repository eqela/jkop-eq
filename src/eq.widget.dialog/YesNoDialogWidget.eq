
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

public class YesNoDialogWidget : TextDialogWidget
{
	public static YesNoDialogWidget for_question(String question) {
		return((YesNoDialogWidget)new YesNoDialogWidget().set_text(question));
	}

	property Object event_yes;
	property Object event_no;

	public YesNoDialogWidget() {
		set_title("Question");
		event_yes = "yes";
		event_no = "no";
	}

	public void initialize() {
		base.initialize();
		set_dialog_footer_widget(ButtonSet.yesno(event_yes, event_no));
		set_cancel_event(event_no);
	}

	public virtual bool on_yes() {
		return(false);
	}

	public virtual bool on_no() {
		return(false);
	}

	public bool on_dialog_widget_event(Object o) {
		if(event_yes != null && event_yes is String && ((String)event_yes).equals(o)) {
			return(on_yes());
		}
		if(event_no != null && event_no is String && ((String)event_no).equals(o)) {
			return(on_no());
		}
		return(false);
	}
}
