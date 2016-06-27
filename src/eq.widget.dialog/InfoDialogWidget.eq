
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

public class InfoDialogWidget : DialogWidget
{
	property Object event_ok;
	KeyValueList items;
	BoxWidget datawidget;

	public InfoDialogWidget() {
		set_title("Information");
		event_ok = "ok";
	}

	public InfoDialogWidget set_items(KeyValueList items) {
		this.items = items;
		update_content();
		return(this);
	}

	public KeyValueList get_items() {
		return(items);
	}

	void update_content() {
		if(datawidget != null) {
			datawidget.remove_children();
			foreach(KeyValuePair kvp in items) {
				var t1 = kvp.get_key();
				var t2 = String.as_string(kvp.get_value());
				if(String.is_empty(t1) == false) {
					datawidget.add(LabelWidget.for_string(t1).set_font(Theme.font().modify("bold")).set_text_align(LabelWidget.LEFT).set_wrap(true));
				}
				if(String.is_empty(t2) == false) {
					datawidget.add(LabelWidget.for_string(t2).set_text_align(LabelWidget.LEFT).set_wrap(true));
				}
			}
		}
	}

	public bool on_enter_pressed() {
		raise_event(event_ok);
		return(true);
	}

	public void initialize() {
		base.initialize();
		set_dialog_main_widget(VScrollerWidget.instance().add_scroller(datawidget = BoxWidget.vertical().set_margin(px("1mm")).set_spacing(px("1mm"))));
		if(event_ok != null) {
			set_dialog_footer_widget(ButtonSet.ok(event_ok));
			set_cancel_event(event_ok);
		}
		update_content();
	}

	public void cleanup() {
		base.cleanup();
		datawidget = null;
	}
}
