
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

public class TextInputControlWidget : LayerWidget, TextInputControl, DataAwareObject
{
	TextInputWidget widget;
	bool has_frame = true;
	int type;
	int align;
	TextInputControlListener listener;
	String placeholder;
	Color text_color;
	String text;
	int max_length;

	public void set_data(Object data) {
		set_text(String.as_string(data));
	}

	public Object get_data() {
		return(get_text());
	}

	void recreate_widget() {
		if(widget != null) {
			text = widget.get_text();
		}
		remove_children();
		widget = TextInputWidget.instance(has_frame);
		update_input_type();
		widget.set_text_align(align);
		update_listener();
		widget.set_placeholder(placeholder);
		widget.set_text_color(text_color);
		widget.set_text(text);
		widget.set_max_length(max_length);
		add(widget);
	}

	public void initialize() {
		base.initialize();
		recreate_widget();
	}

	public void cleanup() {
		base.cleanup();
		if(widget != null) {
			text = widget.get_text();
			widget = null;
		}
	}

	public TextInputControl set_has_frame(bool v) {
		if(has_frame != v) {
			has_frame = v;
			if(is_initialized()) {
				recreate_widget();
			}
		}
		return(this);
	}

	public bool get_has_frame() {
		return(has_frame);
	}

	void update_input_type() {
		if(widget == null) {
			return;
		}
		if(type == TextInputControl.INPUT_TYPE_DEFAULT) {
			widget.set_input_type(TextInputWidget.INPUT_TYPE_DEFAULT);
		}
		else if(type == TextInputControl.INPUT_TYPE_NONASSISTED) {
			widget.set_input_type(TextInputWidget.INPUT_TYPE_NONASSISTED);
		}
		else if(type == TextInputControl.INPUT_TYPE_NAME) {
			widget.set_input_type(TextInputWidget.INPUT_TYPE_NAME);
		}
		else if(type == TextInputControl.INPUT_TYPE_EMAIL) {
			widget.set_input_type(TextInputWidget.INPUT_TYPE_EMAIL);
		}
		else if(type == TextInputControl.INPUT_TYPE_URL) {
			widget.set_input_type(TextInputWidget.INPUT_TYPE_URL);
		}
		else if(type == TextInputControl.INPUT_TYPE_PHONE_NUMBER) {
			widget.set_input_type(TextInputWidget.INPUT_TYPE_PHONE_NUMBER);
		}
		else if(type == TextInputControl.INPUT_TYPE_PASSWORD) {
			widget.set_input_type(TextInputWidget.INPUT_TYPE_PASSWORD);
		}
		else if(type == TextInputControl.INPUT_TYPE_INTEGER) {
			widget.set_input_type(TextInputWidget.INPUT_TYPE_INTEGER);
		}
		else if(type == TextInputControl.INPUT_TYPE_FLOAT) {
			widget.set_input_type(TextInputWidget.INPUT_TYPE_FLOAT);
		}
	}

	public TextInputControl set_input_type(int type) {
		this.type = type;
		update_input_type();
		return(this);
	}

	public int get_input_type() {
		return(type);
	}

	public TextInputControl set_text_align(int align) {
		this.align = align;
		if(widget != null) {
			widget.set_text_align(align);
		}
		return(this);
	}

	public int get_text_align() {
		return(align);
	}

	class TextInputControlListenerWrapper : EventReceiver
	{
		property TextInputControlListener listener;
		public void on_event(Object o) {
			var e = o as TextInputWidgetEvent;
			if(e == null || listener == null) {
				return;
			}
			if(e.get_changed()) {
				listener.on_text_input_control_change();
			}
			if(e.get_selected()) {
				listener.on_text_input_control_accept();
			}
		}
	}

	void update_listener() {
		if(widget == null) {
			return;
		}
		widget.set_listener(new TextInputControlListenerWrapper().set_listener(listener));
	}

	public TextInputControl set_listener(TextInputControlListener listener) {
		this.listener = listener;
		update_listener();
		return(this);
	}

	public TextInputControlListener get_listener() {
		return(listener);
	}

	public TextInputControl set_placeholder(String text) {
		this.placeholder = text;
		if(widget != null) {
			widget.set_placeholder(text);
		}
		return(this);
	}

	public String get_placeholder() {
		return(placeholder);
	}

	public TextInputControl set_text_color(Color c) {
		this.text_color = c;
		if(widget != null) {
			widget.set_text_color(c);
		}
		return(this);
	}

	public Color get_text_color() {
		return(text_color);
	}

	public TextInputControl set_text(String text) {
		this.text = text;
		if(widget != null) {
			widget.set_text(text);
		}
		return(this);
	}

	public String get_text() {
		if(widget != null) {
			return(widget.get_text());
		}
		return(text);
	}

	public TextInputControl set_max_length(int length) {
		this.max_length = length;
		if(widget != null) {
			widget.set_max_length(length);
		}
		return(this);
	}

	public int get_max_length() {
		return(max_length);
	}
}
