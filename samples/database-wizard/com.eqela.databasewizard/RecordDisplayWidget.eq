
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

class RecordDisplayWidget : MobileApplicationScreenWidget
{
	property Object data;

	public Object get_mobile_app_title() {
		return("Data Record");
	}

	public Collection get_mobile_app_menu_items() {
		var v = LinkedList.create();
		v.add(ActionItem.for_text("Back").set_event(new BackEvent()));
		return(v);
	}

	public Collection get_mobile_app_toolbar_items() {
		return(null);
	}

	public void initialize() {
		base.initialize();
		var tw = new TADisplayWidget();
		tw.set_background_color(Color.instance("black"));
		tw.set_text_color(Color.instance("#CCCCCC"));
		tw.set_text(JSONEncoder.encode(data));
		add(tw);
	}

	public void on_event(Object o) {
		if(o is BackEvent) {
			widget_stack_pop();
			return;
		}
	}
}
