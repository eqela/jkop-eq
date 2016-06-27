
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

public class ListSelectorDialogWidget : PopupDialogWidget, ListSelectorDialog, EventReceiver
{
	property bool is_filterable = true;
	String title;
	ListSelectorWidget list;
	Collection items;
	EventReceiver listener;
	LabelWidget titlewidget;

	public void set_title(String title) {
		this.title = title;
		if(titlewidget != null) {
			titlewidget.set_text(title);
		}
	}

	public void set_items(Collection items) {
		this.items = items;
		if(list != null) {
			list.set_items(items);
		}
	}

	public void set_listener(EventReceiver listener) {
		this.listener = listener;
	}

	public void initialize() {
		base.initialize();
		set_size_request_override(px("100mm"), px("80mm"));
		add(CanvasWidget.for_color(Color.black()));
		set_draw_color(Color.white());
		var box = BoxWidget.vertical();
		box.add(LayerWidget.for_widget(titlewidget = LabelWidget.for_string(title).set_font(Theme.font().modify("3mm bold")))
			.set_margin(px("2mm")));
		box.set_spacing(px("500um"));
		box.set_margin(px("500um"));
		box.add_box(1, LayerWidget.instance()
			.add(CanvasWidget.for_color(Color.instance("#444444")))
			.add(LayerWidget.for_widget(list = ListSelectorWidget.instance())
				.set_margin(px("1mm")))
			.set_draw_color(Color.white())
		);
		list.set_filterable(is_filterable);
		var button = ButtonWidget.for_string("Cancel");
		button.set_draw_frame(false);
		button.set_draw_outline(false);
		button.set_font(Theme.font().modify("color=lightred bold 3mm"));
		button.set_event("cancel");
		box.add(button);
		add(box);
		if(items != null) {
			list.set_items(items);
		}
	}

	public void cleanup() {
		base.cleanup();
		list = null;
		titlewidget = null;
	}

	public bool on_key_press(KeyEvent e) {
		if(e != null && (e.has_name("escape") || e.has_name("back"))) {
			close_frame();
			return(true);
		}
		return(base.on_key_press(e));
	}

	public void on_event(Object o) {
		if("cancel".equals(o)) {
			close_frame();
			return;
		}
		if(o != null) {
			if(listener != null) {
				listener.on_event(o);
			}
			close_frame();
			return;
		}
	}
}
