
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

public class ListSelectorSearchBarWidget : LayerWidget, EventReceiver
{
	class MyTextInputWidget : CustomTextInputWidget
	{
		property ListSelectorWidget list;
		public bool on_key_press(KeyEvent e) {
			if(e == null) {
				return(false);
			}
			if("escape".equals(e.get_name())) {
				if(String.is_empty(get_text())) {
					return(false);
				}
				set_text("");
				list.filter(null);
				return(true);
			}
			if("up".equals(e.get_name()) || "down".equals(e.get_name()) || "return".equals(e.get_name()) ||
				"enter".equals(e.get_name())) {
				if(list != null) {
					list.grab_focus();
					if(list.on_key_press(e)) {
						return(true);
					}
				}
			}
			return(base.on_key_press(e));
		}
	}

	class MyTextInputWidgetFrame : TextInputWidgetFrame
	{
		public TextInputWidget create_text_input_widget() {
			var bb = base.create_text_input_widget();
			if(bb != null && bb is CustomTextInputWidget == false) {
				return(bb);
			}
			return(new MyTextInputWidget());
		}
		public MyTextInputWidgetFrame set_list(ListSelectorWidget list) {
			var tiw = get_text_input_widget() as MyTextInputWidget;
			if(tiw != null) {
				tiw.set_list(list);
			}
			return(this);
		}
	}

	TextInputWidget input;
	property ListSelectorWidget list;
	property Widget widget;

	public void initialize() {
		base.initialize();
		var box = BoxWidget.horizontal().set_spacing(px("1mm"));
		if(widget != null) {
			box.add(widget);
		}
		box.add_box(1, input = new MyTextInputWidgetFrame().set_list(list).set_icon(IconCache.get("selector_widget_search")));
		box.add(FramelessButtonWidget.for_image(IconCache.get("close")).set_event("clear"));
		add(box);
		input.set_placeholder("Search ..");
		input.set_listener(this);
	}

	public void cleanup() {
		base.cleanup();
		if(input != null) {
			input.set_listener(null);
		}
		input = null;
		list = null;
	}

	public void clear() {
		if(input != null) {
			input.set_text("");
			if(list != null) {
				list.filter(null);
			}
		}
	}

	public void grab_focus() {
		if(input != null) {
			input.grab_focus();
		}
	}

	public void on_event(Object o) {
		if("clear".equals(o)) {
			clear();
			return;
		}
		if(o is TextInputWidgetEvent) {
			if(((TextInputWidgetEvent)o).get_changed() && list != null && input != null) {
				list.filter(input.get_text());
			}
			return;
		}
		forward_event(o);
	}
}
