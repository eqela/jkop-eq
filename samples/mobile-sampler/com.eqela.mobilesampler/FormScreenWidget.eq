
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

class FormScreenWidget : MobileApplicationScreenWidget
{
	FormWidget form;
	
	public void initialize() {
		base.initialize();
		form = FormWidget.instance();
		form.add_text_field("text", "Text Field", "Please type some text here", null, "Text input here");
		form.add_integer_field("integer", "Integer Field", "Please type integer numbers here");
		form.add_list_field("list", "List Field", "Please choose one of the following entries", 3,
			LinkedList.create().add("First entry").add("Second entry").add("Third entry"));
		form.add_select_field("select", "Select Field", "Please also choose from the following",
			LinkedList.create().add("First entry").add("Second entry").add("Third entry"));
		form.add_button("Button", "Click me to continue", "button");
		add(VScrollerWidget.for_widget(form));
	}

	public void cleanup() {
		base.cleanup();
		form = null;
	}

	public Object get_mobile_app_title() {
		return("Form Sample");
	}

	public void on_event(Object o) {
		if("button".equals(o)) {
			var data = form.data_to_hash_table();
			var json = JSONEncoder.encode(data);
			var screen = TextScreenWidget.for_text(json);
			screen.set_title("Your Input");
			push_screen(screen);
		}
	}
}
