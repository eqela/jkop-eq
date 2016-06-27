
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

class TaskListWidget : LayerWidget, EventReceiver
{
	class AddEvent
	{
	}

	TextInputWidget text;
	ListSelectorWidget list;
	Collection items;

	public void initialize() {
		base.initialize();
		set_draw_color(Color.instance("white"));
		add(ImageWidget.for_image(IconCache.get("background")).set_mode("fill"));
		var vbox = BoxWidget.vertical();

		var title = BoxWidget.horizontal();
		title.set_draw_color(Color.instance("black"));
		title.add_box(1, LayerWidget.instance().set_margin(px("1mm")).add(LabelWidget.for_string(VALUE("displayname"))
			.set_font(Theme.font().modify("Dearest.ttf bold 4mm"))
			.set_text_align(LabelWidget.LEFT)));
		title.add_box(0, FramelessButtonWidget.for_image(IconCache.get("menu")).set_internal_margin("1500um").set_event(new ToggleBackgroundEvent()));
		vbox.add(LayerWidget.instance()
			.add(CanvasWidget.for_color(Color.instance("#FFFFFF80")))
			.add(title)
		);

		list = ListSelectorWidget.instance();
		list.set_show_desc(false);
		list.set_show_icon(false);
		vbox.add_box(1, LayerWidget.instance().set_margin(px("1mm"))
			.add(CanvasWidget.for_color(Color.instance("#00000080")).set_rounded(true))
			.add(LayerWidget.instance().set_margin(px("1mm")).add(list))
		);

		var input = BoxWidget.horizontal();
		input.add_box(1, LayerWidget.instance().set_margin(px("1mm")).add(text = TextInputWidget.instance(false)));
		text.set_placeholder("Type to add task ..");
		text.set_listener(this);
		input.add_box(0, FramelessButtonWidget.for_image(IconCache.get("add")).set_internal_margin("1500um").set_event(new AddEvent()));
		vbox.add(LayerWidget.instance()
			.add(CanvasWidget.for_color(Color.instance("#FFFFFF80")))
			.add(input)
		);

		add(vbox);
		load_items();
	}

	public void cleanup() {
		base.cleanup();
		list = null;
		text = null;
	}

	public void start() {
		base.start();
	}

	void on_items_changed() {
		save_items();
		if(list != null) {
			list.set_items(items);
		}
	}

	void add_item(String item) {
		if(String.is_empty(item)) {
			return;
		}
		if(items == null) {
			items = LinkedList.create();
		}
		items.prepend(item);
		on_items_changed();
	}

	void on_add_event() {
		var txt = text.get_text();
		if(String.is_empty(txt) == false) {
			add_item(txt);
		}
		text.set_text("");
		text.grab_focus();
	}

	public void delete_item(String todelete) {
		items.remove(todelete);
		on_items_changed();
	}

	public void delete_all_items() {
		items = LinkedList.create();
		on_items_changed();
	}

	class DeleteConfirmDialog : YesNoDialogWidget
	{
		property TaskListWidget widget;
		property String todelete;

		public void initialize() {
			set_title("Confirmation");
			set_text("Are you sure to delete the task `%s'".printf().add(todelete).to_string());
			base.initialize();
		}

		public bool on_yes() {
			widget.delete_item(todelete);
			return(false);
		}
	}

	class ClearConfirmDialog : YesNoDialogWidget
	{
		property TaskListWidget widget;

		public void initialize() {
			set_title("Confirmation");
			set_text("This will delete all entries in your task list. Are you sure you wish to proceed?");
			base.initialize();
		}

		public bool on_yes() {
			widget.delete_all_items();
			return(false);
		}
	}

	public void on_clear_request() {
		Popup.widget(get_engine(), new ClearConfirmDialog().set_widget(this));
	}

	public void on_event(Object o) {
		if(o is AddEvent) {
			on_add_event();
			return;
		}
		if(o is TextInputWidgetEvent && ((TextInputWidgetEvent)o).get_selected()) {
			on_add_event();
			return;
		}
		if(o is String) {
			Popup.widget(get_engine(), new DeleteConfirmDialog().set_widget(this).set_todelete((String)o));
			return;
		}
		forward_event(o);
	}

	void save_items() {
		var ad = ApplicationData.for_this_application();
		if(ad == null) {
			return;
		}
		ad.mkdir_recursive();
		var sb = StringBuffer.create();
		foreach(String item in items) {
			sb.append(item);
			sb.append_c('\n');
		}
		ad.entry("items.txt").set_contents_string(sb.to_string());
	}

	void load_items() {
		var ad = ApplicationData.for_this_application();
		if(ad == null) {
			return;
		}
		var i = LinkedList.create();
		foreach(String line in ad.entry("items.txt").lines()) {
			i.add(line);
		}
		items = i;
		on_items_changed();
	}
}
