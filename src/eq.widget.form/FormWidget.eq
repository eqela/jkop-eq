
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

public class FormWidget : VBoxWidget
{
	public static FormWidget for_form(eq.gui.form.Form form) {
		if(form == null) {
			return(null);
		}
		var fw = new FormWidget();
		foreach(eq.gui.form.FormTab tab in form.get_tabs()) {
			foreach(eq.gui.form.FormField field in tab.get_fields()) {
				if(field is eq.gui.form.FormFieldHidden) {
					var fh = (eq.gui.form.FormFieldHidden)field;
					fw.add_hidden_field(fh.get_id(), fh.get_default_value());
				}
				else if(field is eq.gui.form.FormFieldText) {
					var ft = (eq.gui.form.FormFieldText)field;
					fw.add_text_field(field.get_id(), ft.get_label(), ft.get_description(),
						ft.get_default_value(), ft.get_placeholder());
				}
				else if(field is eq.gui.form.FormFieldTextArea) {
					// FIXME: We don't actually have this.
					var ft = (eq.gui.form.FormFieldTextArea)field;
					fw.add_text_field(field.get_id(), ft.get_label(), ft.get_description(),
						ft.get_default_value());
				}
				else if(field is eq.gui.form.FormFieldPassword) {
					// FIXME: We don't actually have this.
					var fp = (eq.gui.form.FormFieldPassword)field;
					fw.add_text_field(field.get_id(), fp.get_label(), fp.get_description(),
						fp.get_default_value(), fp.get_placeholder());
				}
				else if(field is eq.gui.form.FormFieldInteger) {
					var fi = (eq.gui.form.FormFieldInteger)field;
					fw.add_integer_field(fi.get_id(), fi.get_label(), fi.get_description(),
						fi.get_default_value());
				}
				else if(field is eq.gui.form.FormFieldList) {
					var fl = (eq.gui.form.FormFieldList)field;
					fw.add_list_field(fl.get_id(), fl.get_label(), fl.get_description(),
						fl.get_rows(), fl.get_entries());
				}
				else if(field is eq.gui.form.FormFieldSelect) {
					var fs = (eq.gui.form.FormFieldSelect)field;
					fw.add_select_field(fs.get_id(), fs.get_label(), fs.get_description(), fs.get_entries());
				}
				else {
					Log.error("Unknown form field encountered");
				}
			}
		}
		return(fw);
	}

	public static FormWidget instance() {
		return(new FormWidget());
	}

	interface FormField
	{
		public String get_id();
		public String get_label();
		public String get_description();
		public Object get_value_object();
		public void set_value_object(Object o);
		public Widget get_widget();
	}

	class HiddenFormField : FormField
	{
		property String id;
		property String value;

		public String get_label() {
			return(null);
		}

		public String get_description() {
			return(null);
		}

		public Object get_value_object() {
			return(value);
		}

		public void set_value_object(Object o) {
			value = String.as_string(o);
		}

		public Widget get_widget() {
			return(null);
		}
	}

	class RealFormField : FormField
	{
		property String id;
		property String label;
		property String description;
		property Widget widget;

		public Object get_value_object() {
			if(widget == null || id == null) {
				return(null);
			}
			if(widget is TextInputWidget) {
				return(((TextInputWidget)widget).get_text());
			}
			if(widget is ListSelectorWidget) {
				var ai = ((ListSelectorWidget)widget).get_selected_action_item();
				if(ai == null) {
					return(null);
				}
				return(ai.get_data());
			}
			if(widget is ComboButtonWidget) {
				var ai = ((ComboButtonWidget)widget).get_selected();
				if(ai == null) {
					return(null);
				}
				return(ai.get_data());
			}
			if(widget is FileAwareWidget) {
				return(((FileAwareWidget)widget).get_file());
			}
			return(null);
		}

		public void set_value_object(Object o) {
			if(widget == null) {
			}
			else if(widget is TextInputWidget) {
				((TextInputWidget)widget).set_text(String.as_string(o));
			}
			else if(widget is ComboButtonWidget) {
				((ComboButtonWidget)widget).select_item_by_string(String.as_string(o));
			}
		}
	}

	LinkedList fields;
	Widget default_widget;
	property String default_field_id;

	public FormWidget() {
		fields = LinkedList.create();
	}

	public void initialize() {
		base.initialize();
		set_minimum_width_request(px("50mm"));
		set_margin(px("2500um"));
		set_spacing(px("2500um"));
		foreach(FormField ff in fields) {
			add_widgets(ff);
		}
	}

	public void cleanup() {
		base.cleanup();
		default_widget = null;
	}

	public Widget get_default_focus_widget() {
		return(default_widget);
	}

	public FormWidget add_field(String id, String label, String description, Widget widget) {
		add_field_object(new RealFormField().set_id(id).set_label(label).set_description(description).set_widget(widget));
		return(this);
	}

	public FormWidget add_hidden_field(String id, String default_value = null) {
		add_field_object(new HiddenFormField().set_id(id).set_value(default_value));
		return(this);
	}

	public FormWidget add_text_field(String id, String label, String description = null, String default_value = null, String placeholder = null, int input_type = 0) {
		return(add_field(id, label, description, TextInputWidget.instance().set_text(default_value)
			.set_placeholder(placeholder).set_input_type(input_type)));
	}

	public FormWidget add_integer_field(String id, String label, String description = null, int default_value = 0) {
		return(add_field(id, label, description, TextInputWidget.instance().set_input_type(TextInputWidget.INPUT_TYPE_INTEGER)
			.set_text(String.for_integer(default_value))));
	}

	public FormWidget add_list_field(String id, String label, String description = null, int rows = 3, Collection items = null) {
		return(add_field(id, label, description, new ListSelectorWidget().set_select_mode(ListSelectorWidget.SELECT_SINGLE)
			.set_items(items).set_row_count_request(rows)));
	}

	public FormWidget add_select_field(String id, String label, String description = null, Collection items = null) {
		var cbw = new ComboButtonWidget().set_raise_selected_event(false).set_items(items);
		cbw.set_popup_force_same_width(true);
		if(cbw.get_selected() == null) {
			cbw.select_first_item();
		}
		return(add_field(id, label, description, cbw));
	}

	public FormWidget add_button(String title, String label, Object event) {
		return(add_field(null, null, null, new FormButtonWidget().set_title(title).set_label(label).set_event(event)));
	}

	FormField get_form_field(String id) {
		if(id == null) {
			return(null);
		}
		foreach(FormField field in fields) {
			if(id.equals(field.get_id())) {
				return(field);
			}
		}
		return(null);
	}

	public Object get_form_field_value(String id) {
		var ww = get_form_field(id);
		if(ww == null) {
			return(null);
		}
		return(ww.get_value_object());
	}

	public String get_form_field_value_string(String id) {
		var ww = get_form_field(id);
		if(ww == null) {
			return(null);
		}
		return(String.as_string(ww.get_value_object()));
	}

	public Widget get_form_field_widget(String id) {
		var ww = get_form_field(id);
		if(ww == null) {
			return(null);
		}
		return(ww.get_widget());
	}

	public HashTable data_to_hash_table() {
		var v = HashTable.create();
		foreach(FormField field in fields) {
			v.set(field.get_id(), field.get_value_object());
		}
		return(v);
	}

	public FormWidget data_from_hash_table(HashTable data) {
		if(data == null) {
			return(this);
		}
		foreach(String key in data) {
			var field = get_form_field(key);
			if(field != null) {
				field.set_value_object(data.get(key));
			}
		}
		return(this);
	}

	void add_field_object(FormField ff) {
		fields.add(ff);
		if(is_initialized()) {
			add_widgets(ff);
		}
	}

	void add_widgets(FormField ff) {
		if(ff == null) {
			return;
		}
		var widget = ff.get_widget();
		if(widget == null) {
			return;
		}
		var vb = VBoxWidget.instance();
		vb.set_spacing(px("1500um"));
		var vb2 = BoxWidget.vertical();
		vb2.set_spacing(px("500um"));
		var label = ff.get_label();
		if(String.is_empty(label) == false) {
			vb2.add(LabelWidget.for_string(label).set_font(Theme.font().modify("bold")).set_text_align(LabelWidget.LEFT).set_wrap(true));
		}
		var description = ff.get_description();
		if(String.is_empty(description) == false) {
			vb2.add(LabelWidget.for_string(description).set_font(Theme.font()).set_text_align(LabelWidget.LEFT).set_wrap(true));
		}
		vb.add(vb2);
		double myweight = 0;
		if(widget != null) {
			myweight = widget.get_weight();
			if(default_widget == null) {
				default_widget = widget;
			}
			else if(default_field_id != null && default_field_id.equals(ff.get_id())) {
				default_widget = widget;
			}
			if(widget is ListSelectorWidget) {
				var lw = LayerWidget.instance();
				lw.set_draw_color(Color.instance("black"));
				lw.add(CanvasWidget.for_color(Color.instance("#DDDDDD")).set_rounded(true));
				lw.add(LayerWidget.instance().set_margin(px("1mm")).add(widget));
				widget = lw;
				widget.set_weight(myweight);
			}
			if(widget is ComboButtonWidget) {
				((ComboButtonWidget)widget).set_icon_align(ButtonWidget.LEFT);
				((ComboButtonWidget)widget).set_text_align(ButtonWidget.LEFT);
				((ComboButtonWidget)widget).set_color(Color.instance("#DDDDDD"));
				((ComboButtonWidget)widget).set_font(Theme.font().modify("color=black"));
				((ComboButtonWidget)widget).set_pressed_font(Theme.font().modify("color=black"));
			}
			vb.add(widget);
		}
		add_box(myweight, vb);
	}
}
