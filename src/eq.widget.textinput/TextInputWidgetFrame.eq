
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

public class TextInputWidgetFrame : LayerWidget, TextInputWidget, FocusFrameWidget, DataAwareObject
{
	TextInputWidget widget;
	ImageWidget iconw;
	CanvasWidget framecanvas;
	property bool draw_frame = true;
	property bool rounded = true;
	property Color background_color;
	property Color frame_color = null;
	Color text_color;
	property String inner_margin;
	property String icon_size;
	int lines = 1;

	public TextInputWidgetFrame() {
		iconw = ImageWidget.instance().set_mode("fit");
		inner_margin = "1mm";
		icon_size = Theme.get_icon_size();
		set_text_color(Theme.color("eq.widget.textinput.TextInputWidget.text_color", "black"));
	}

	public void set_data(Object o) {
		var tiw = get_text_input_widget();
		if(tiw != null) {
			tiw.set_data(o);
		}
	}

	public Object get_data() {
		var tiw = get_text_input_widget();
		if(tiw == null) {
			return(null);
		}
		return(tiw.get_data());
	}

	public virtual TextInputWidget create_text_input_widget() {
		TextInputWidget v;
		IFDEF("target_android") {
			v = new AndroidTextInputWidget();
		}
		ELSE IFDEF("target_wpcs") {
			v = new WPTextInputWidget();
		}
		ELSE IFDEF("target_html") {
			v = new HTMLTextInputWidget();
		}
		ELSE IFDEF("target_ios") {
			if(lines > 1) {
				// FIXME: Create the special widget that can do multiple lines
			}
			v = new IOSTextInputWidget();
		}
		ELSE {
			v = new CustomTextInputWidget();
		}
		v.set_lines(lines);
		return(v);
	}

	public TextInputWidget get_text_input_widget() {
		if(widget == null) {
			widget = create_text_input_widget();
		}
		return(widget);
	}

	public void grab_focus() {
		var tiw = get_text_input_widget();
		if(tiw != null) {
			tiw.grab_focus();
		}
		else {
			base.grab_focus();
		}
	}

	public void on_gain_focus() {
		var tiw = get_text_input_widget();
		if(tiw != null) {
			tiw.grab_focus();
		}
		else {
			base.on_gain_focus();
		}
	}

	public void select_all() {
		var tiw = get_text_input_widget();
		if(tiw != null) {
			tiw.select_all();
		}
	}

	public void select_none() {
		var tiw = get_text_input_widget();
		if(tiw != null) {
			tiw.select_none();
		}
	}

	public void update_focus_state(bool focused) {
		if(framecanvas != null) {
			if(focused) {
				framecanvas.set_outline_color(Theme.get_highlight_color());
			}
			else {
				framecanvas.set_outline_color(frame_color);
			}
		}
		var tiw = get_text_input_widget();
		if(tiw != null) {
			var ll = tiw.get_listener();
			if(ll != null) {
				var ee = new TextInputWidgetEvent();
				if(focused) {
					ee.set_gained_focus(true);
				}
				else {
					ee.set_lost_focus(true);
				}
				ll.on_event(ee);
			}
		}
	}

	public virtual Widget create_right_widget() {
		return(null);
	}

	public void initialize() {
		base.initialize();
		var tiw = get_text_input_widget();
		var box = HBoxWidget.instance().set_spacing(px("1mm"));
		box.add_hbox(0, iconw);
		box.add_hbox(1, tiw);
		var rw = create_right_widget();
		if(rw != null) {
			box.add_hbox(0, rw);
		}
		if(draw_frame) {
			var bgc = background_color;
			if(bgc == null) {
				bgc = Color.instance("#DDDDDD");
			}
			add(framecanvas = CanvasWidget.instance().set_rounded(rounded).set_color(bgc));
			framecanvas.set_outline_color(frame_color);
			add(LayerWidget.instance().set_margin(px(inner_margin)).add(box).set_draw_color(Color.instance("#000000")));
			set_draw_color(Color.instance("black"));
		}
		else {
			add(box);
		}
		if(text_color == null) {
			tiw.set_text_color(get_draw_color());
		}
		update_icon_size_request();
	}

	public void cleanup() {
		base.cleanup();
		framecanvas = null;
	}

	public TextInputWidget set_lines(int n) {
		lines = n;
		var tiw = get_text_input_widget();
		if(tiw != null) {
			tiw.set_lines(n);
		}
		return(this);
	}

	public int get_lines() {
		var tiw = get_text_input_widget();
		if(tiw == null) {
			return(1);
		}
		return(tiw.get_lines());
	}

	public TextInputWidget set_input_type(int type) {
		var tiw = get_text_input_widget();
		if(tiw != null) {
			tiw.set_input_type(type);
		}
		return(this);
	}

	public int get_input_type() {
		var tiw = get_text_input_widget();
		if(tiw == null) {
			return(0);
		}
		return(tiw.get_input_type());
	}

	public TextInputWidget set_text_align(int align) {
		var tiw = get_text_input_widget();
		if(tiw != null) {
			tiw.set_text_align(align);
		}
		return(this);
	}

	public int get_text_align() {
		var tiw = get_text_input_widget();
		if(tiw == null) {
			return(0);
		}
		return(tiw.get_text_align());
	}

	void update_icon_size_request() {
		if(is_initialized() == false) {
			return;
		}
		var icon = iconw.get_image();
		if(icon != null) {
			var sz = px(icon_size);
			iconw.set_size_request_override(sz, sz);
		}
		else {
			iconw.set_size_request_override(0,0);
		}
	}

	public TextInputWidget set_icon(Image icon) {
		iconw.set_image(icon);
		update_icon_size_request();
		return(this);
	}

	public Image get_icon() {
		return(iconw.get_image());
	}

	public TextInputWidget set_listener(EventReceiver listener) {
		var tiw = get_text_input_widget();
		if(tiw != null) {
			tiw.set_listener(listener);
		}
		return(this);
	}

	public EventReceiver get_listener() {
		var tiw = get_text_input_widget();
		if(tiw == null) {
			return(null);
		}
		return(tiw.get_listener());
	}

	public TextInputWidget set_placeholder(String text) {
		var tiw = get_text_input_widget();
		if(tiw != null) {
			tiw.set_placeholder(text);
		}
		return(this);
	}

	public String get_placeholder() {
		var tiw = get_text_input_widget();
		if(tiw == null) {
			return(null);
		}
		return(tiw.get_placeholder());
	}

	public TextInputWidget set_text_color(Color c) {
		this.text_color = c;
		if(c != null) {
			var tiw = get_text_input_widget();
			if(tiw != null) {
				tiw.set_text_color(c);
			}
		}
		return(this);
	}

	public Color get_text_color() {
		return(text_color);
	}

	public TextInputWidget set_text(String text) {
		var tiw = get_text_input_widget();
		if(tiw != null) {
			tiw.set_text(text);
		}
		return(this);
	}

	public String get_text() {
		var tiw = get_text_input_widget();
		if(tiw == null) {
			return(null);
		}
		return(tiw.get_text());
	}

	public TextInputWidget set_max_length(int length) {
		var tiw = get_text_input_widget();
		if(tiw != null) {
			tiw.set_max_length(length);
		}
		return(this);
	}

	public TextInputWidget set_font(Font font) {
		var tiw = get_text_input_widget();
		if(tiw != null) {
			tiw.set_font(font);
		}
		return(this);
	}
}
