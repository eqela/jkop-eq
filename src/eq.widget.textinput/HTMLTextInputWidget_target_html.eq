
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

public class HTMLTextInputWidget : TextInputWidgetAdapter
{
	HTMLElement input;
	String _text;

	public bool is_focusable() {
		return(true);
	}

	public override bool get_always_has_surface() {
		return(true);
	}

	public bool is_surface_container() {
		return(true);
	}

	void update_text_from_element() {
		if(input == null) {
			return;
		}
		var ee = input.get_element();
		if(ee == null) {
			return;
		}
		strptr vv;
		embed {{{
			vv = ee.value;
		}}}
		_text = String.for_strptr(vv);
	}

	void update_text_to_element() {
		if(input == null) {
			return;
		}
		var ee = input.get_element();
		if(ee == null) {
			return;
		}
		strptr vv;
		if(_text != null) {
			vv = _text.to_strptr();
		}
		embed {{{
			ee.value = vv;
		}}}
	}

	public TextInputWidget set_text(String t) {
		_text = t;
		update_text_to_element();
		return(this);
	}

	public String get_text() {
		update_text_from_element();
		return(_text);
	}

	void on_forward_event(ptr e) {
		var fr = get_frame() as HTML5Frame;
		if(fr != null) {
			release_focus();
			fr.on_key_down(e);
		}
	}

	void on_normal_key_pressed() {
		var listener = get_listener();
		if(listener != null) {
			EventReceiver.event(listener, new TextInputWidgetEvent()
				.set_widget(this).set_changed(true).set_selected(false));
		}
	}

	void on_enter_pressed() {
		var listener = get_listener();
		if(listener != null) {
			EventReceiver.event(listener, new TextInputWidgetEvent()
				.set_widget(this).set_changed(false).set_selected(true));
		}
		else {
			var en = get_engine();
			if(en != null) {
				en.focus_next();
			}
		}
	}

	public HTMLElement create_input_element() {
		HTMLElement input;
		int lines = get_lines();
		if(lines > 1) {
			input = HTMLElement.create("textarea");
			input.set_attribute("rows", String.as_string(lines));
			input.set_style("overflow", "hidden");
		}
		else {
			input = HTMLElement.create("input");
			input.set_attribute("type", "text");
		}
		return(input);
	}

	public void initialize() {
		base.initialize();
		var input = create_input_element();
		input.set_style("background-color", "transparent");
		input.set_style("backgroundColor", "transparent");
		input.set_style("border", "0px");
		input.set_style("outline", "none");
		var doc = new HTMLDocument();
		doc.append_to_body(input);
		var hh = input.get_height();
		if(hh < px("5mm")) {
			hh = px("5mm");
		}
		set_size_request(px("50mm"), hh);
		input.remove_from_dom();
	}

	public void on_gain_focus() {
		base.on_gain_focus();
		if(input != null) {
			var ee = input.get_element();
			if(ee != null) {
				embed {{{
					ee.focus();
				}}}
			}
		}
	}

	public void on_lose_focus() {
		base.on_lose_focus();
		if(input != null) {
			var ee = input.get_element();
			if(ee != null) {
				embed {{{
					ee.blur();
				}}}
			}
		}
	}

	void on_html_gain_focus() {
		grab_focus();
		var hf = get_frame() as HTML5Frame;
		if(hf != null) {
			hf.set_disable_key_capture(true);
		}
	}

	void on_html_lose_focus() {
		release_focus();
		var hf = get_frame() as HTML5Frame;
		if(hf != null) {
			hf.set_disable_key_capture(false);
		}
	}

	public void on_surface_created(Surface surface) {
		base.on_surface_created(surface);
		var ss = surface as HTML5ElementSurface;
		if(ss == null) {
			Log.error("HTMLTextInputWidget: Created surface is not an HTML5 element surface!");
			return;
		}
		var element = ss.get_element();
		if(element == null) {
			Log.warning("HTMLTextInputWidget: The surface element does not exist!");
			return;
		}
		input = create_input_element();
		var el = input.get_element();
		if(el != null) {
			var myself = this;
			int num_of_lines = get_lines();
			embed {{{
				el.onkeydown = function(e) {
					var key = e.keyCode || e.which;
					if(key == 27) {
						myself.on_forward_event(e);
						if(e.preventDefault) {
							e.preventDefault();
						}
						return(false);
					}
					if(key == 13) {
						myself.on_enter_pressed();
						if(e.preventDefault && (num_of_lines <= 1)) {
							e.preventDefault();
							return(false);
						}
						return(true);
					}
					myself.on_normal_key_pressed();
					return(true);
				};
				el.onkeyup = function(e) {
					var key = e.keyCode || e.which;
					if(key == 27) {
						myself.on_forward_event(e);
						if(e.preventDefault) {
							e.preventDefault();
						}
						return(false);
					}
					return(true);
				};
				el.onkeypress = function(e) {
					var key = e.keyCode || e.which;
					if(key == 27) {
						myself.on_forward_event(e);
						if(e.preventDefault) {
							e.preventDefault();
						}
						return(false);
					}
					return(true);
				};
			}}}
		}
		input.set_style("background-color", "transparent");
		input.set_style("backgroundColor", "transparent");
		input.set_style("border", "0px");
		input.set_style("outline", "none");
		input.set_style("width", "100%");
		input.set_style("height", "100%");
		element.append_child(input);
		var ee = input.get_element();
		var tw = this;
		embed {{{
			ee.onfocus = function() {
				tw.on_html_gain_focus();
			};
			ee.onblur = function() {
				tw.on_html_lose_focus();
			};
		}}}
		if(has_focus()) {
			embed {{{
				ee.focus();
			}}}
		}
		on_visual_change();
		update_text_to_element();
	}

	public void on_surface_removed() {
		update_text_from_element();
		input = null;
	}

	public void on_visual_change() {
		if(input == null) {
			return;
		}
		var type = get_input_type();
		if(type == TextInputWidget.INPUT_TYPE_DEFAULT) {
			input.set_attribute("type", "text");
		}
		else if(type == TextInputWidget.INPUT_TYPE_NONASSISTED) {
			input.set_attribute("type", "text");
		}
		else if(type == TextInputWidget.INPUT_TYPE_NAME) {
			input.set_attribute("type", "text");
		}
		else if(type == TextInputWidget.INPUT_TYPE_EMAIL) {
			input.set_attribute("type", "email");
		}
		else if(type == TextInputWidget.INPUT_TYPE_URL) {
			input.set_attribute("type", "url");
		}
		else if(type == TextInputWidget.INPUT_TYPE_PHONE_NUMBER) {
			input.set_attribute("type", "tel");
		}
		else if(type == TextInputWidget.INPUT_TYPE_PASSWORD) {
			input.set_attribute("type", "password");
		}
		else if(type == TextInputWidget.INPUT_TYPE_INTEGER) {
			input.set_attribute("type", "number");
		}
		else if(type == TextInputWidget.INPUT_TYPE_FLOAT) {
			input.set_attribute("type", "text");
		}
		var ph = get_placeholder();
		if(String.is_empty(ph)) {
			input.set_attribute("placeholder", "");
		}
		else {
			input.set_attribute("placeholder", ph);
		}
		var al = get_text_align();
		if(al == TextInputWidget.LEFT) {
			input.set_style("text-align", "left");
			input.set_style("textAlign", "left");
		}
		else if(al == TextInputWidget.CENTER) {
			input.set_style("text-align", "center");
			input.set_style("textAlign", "center");
		}
		else if(al == TextInputWidget.RIGHT) {
			input.set_style("text-align", "right");
			input.set_style("textAlign", "right");
		}
		var cc = get_text_color();
		if(cc == null) {
			input.set_style("color", "black");
		}
		else {
			input.set_style("color", cc.to_rgb_string());
		}
	}
}
