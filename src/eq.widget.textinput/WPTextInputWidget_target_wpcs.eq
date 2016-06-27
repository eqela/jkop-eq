
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

class WPTextInputWidget : LayerWidget, TextInputWidget, DataAwareObject
{
	class PlaceholderWidget : AlignWidget
	{
		LabelWidget label;
		property String text;
		public static PlaceholderWidget for_string(String t) {
			var v = new PlaceholderWidget();
			v.set_text(t);
			return(v);
		}
		public void  initialize() {
			base.initialize();
			label = LabelWidget.instance();
			add(label);
			set_margins(10, 10, 0, 0);
			update_text(text);
		}
		public void cleanup() {
			base.cleanup();
			label = null;
		}
		public void update_text(String atext) {
			var text = atext;
			if(text == null) {
				text = "";
			}
			if(text.equals(this.text) == false) {
				label.set_text(text);
			}
			this.text = text;
		}
		public void update_align(int align) {
			if(label != null) {
				if(align == TextInputWidget.CENTER) {
					label.set_align_x(0);
				}
				else if(align == TextInputWidget.RIGHT) {
					label.set_align_x(1);
				}
				else {
					label.set_align_x(-1);
				}
			}
		}
		public void update_color(Color a) {
			if(label != null && a != null) {
				label.set_color(a.dup().set_a(0.6));
			}
		}
		public void set_visible(bool v) {
			if(label != null) {
				label.set_enabled(v);
			}
		}
	}

	EventReceiver listener;
	Color text_color;
	String text;
	String placeholder;
	int text_align = -1;
	int text_input_type = -1;
	PlaceholderWidget phwidget;
	WPTextBox textbox;
	WPPasswordBox pwbox;

	public bool is_focusable() {
		return(true);
	}

	public void initialize() {
		base.initialize();
		if(text_input_type == TextInputWidget.INPUT_TYPE_PASSWORD) {
			add((pwbox = new WPPasswordBox().set_widget(this)));
		}
		else {
			add((textbox = new WPTextBox().set_widget(this)));
		}
		phwidget = PlaceholderWidget.for_string(text);
		add(phwidget);
		update_subcomponents();
	}

	public void update_subcomponents() {
		if(phwidget != null) {
			phwidget.update_color(text_color);
			phwidget.update_align(text_align);
			phwidget.update_text(placeholder);
		}
		String mytext = this.text;
		if(mytext == null) {
			mytext = "";
		}
		embed "cs" {{{
			System.Windows.Media.SolidColorBrush textbrush = null;
			if(text_color != null) {
				textbrush = new System.Windows.Media.SolidColorBrush(
					System.Windows.Media.Color.FromArgb(
						(byte)(text_color.get_a() * 255),
						(byte)(text_color.get_r() * 255),
						(byte)(text_color.get_g() * 255),
						(byte)(text_color.get_b() * 255)
					)
				);
			}
			if(textbox != null) {	
				var scope = new System.Windows.Input.InputScope();
				var name = new System.Windows.Input.InputScopeName();
				if(text_input_type == TextInputWidgetStatic.INPUT_TYPE_DEFAULT) {
					name.NameValue = System.Windows.Input.InputScopeNameValue.Text;
				}
				else if(text_input_type == TextInputWidgetStatic.INPUT_TYPE_NONASSISTED) {
					name.NameValue = System.Windows.Input.InputScopeNameValue.Default;
				}
				else if(text_input_type == TextInputWidgetStatic.INPUT_TYPE_NAME) {
					name.NameValue = System.Windows.Input.InputScopeNameValue.PersonalFullName;
				}
				else if(text_input_type == TextInputWidgetStatic.INPUT_TYPE_EMAIL) {
					name.NameValue = System.Windows.Input.InputScopeNameValue.EmailNameOrAddress;
				}
				else if(text_input_type == TextInputWidgetStatic.INPUT_TYPE_URL) {
					name.NameValue = System.Windows.Input.InputScopeNameValue.Url;
				}
				else if(text_input_type == TextInputWidgetStatic.INPUT_TYPE_PHONE_NUMBER) {
					name.NameValue = System.Windows.Input.InputScopeNameValue.TelephoneNumber;
				}
				else if(text_input_type == TextInputWidgetStatic.INPUT_TYPE_INTEGER) {
					name.NameValue = System.Windows.Input.InputScopeNameValue.CurrencyAmount;
				}
				else if(text_input_type == TextInputWidgetStatic.INPUT_TYPE_FLOAT) {
					name.NameValue = System.Windows.Input.InputScopeNameValue.CurrencyAmount;
				}
				scope.Names.Add(name);
				var tb = textbox.get_native_textbox();
				if(tb != null) {
					tb.Text = mytext.to_strptr();
					tb.Foreground = textbrush;
					if(text_align == TextInputWidgetStatic.LEFT) {
						tb.TextAlignment = System.Windows.TextAlignment.Left;
					}
					else if(text_align == TextInputWidgetStatic.CENTER) {
						tb.TextAlignment = System.Windows.TextAlignment.Center;
					}
					else if(text_align == TextInputWidgetStatic.RIGHT) {
						tb.TextAlignment = System.Windows.TextAlignment.Right;
					}
					tb.InputScope = scope;
				}
			}
			else if(pwbox != null) {
				var pb = pwbox.get_native_passwordbox();
				if(pb != null) {
					pb.Password = mytext.to_strptr();
					pb.Foreground = textbrush;
					if(text_align == TextInputWidgetStatic.LEFT) {
						pb.HorizontalAlignment = System.Windows.HorizontalAlignment.Left;
					}
					else if(text_align == TextInputWidgetStatic.CENTER) {
						pb.HorizontalAlignment = System.Windows.HorizontalAlignment.Center;
					}
					else if(text_align == TextInputWidgetStatic.RIGHT) {
						pb.HorizontalAlignment = System.Windows.HorizontalAlignment.Right;
					}
				}
			}
		}}}
		if(phwidget != null) {
			phwidget.set_visible(String.is_empty(text));
		}
	}

	public Object get_data() {
		//FIXME
		return(null);
	}

	public void set_data(Object data) {
		//FIXME
	}

	public TextInputWidget set_max_length(int max) {
		//FIXME
		return(this);
	}

	public TextInputWidget set_lines(int lines) {
		//FIXME
		return(this);
	}

	public int get_lines() {
		return(0);
	}

	public void select_all() {
		embed "cs" {{{
			if(textbox != null) {
				var tb = textbox.get_native_textbox();
				if(tb != null) {
					tb.SelectAll();
				}
			}
			if(pwbox != null) {
				var pb = pwbox.get_native_passwordbox();
				if(pb != null) {
					pb.SelectAll();
				}
			}
		}}}
	}

	public void select_none() {
		embed "cs" {{{
			if(textbox != null) {
				var tb = textbox.get_native_textbox();
				if(tb != null) {
					tb.Select(0, 0);
				}
			}
			// FIXME: PasswordBox has no method for select_none
		}}}
	}

	void update_from_subcomponents() {
		strptr cstr;
		embed "cs" {{{
			if(textbox != null) {
				var tb = textbox.get_native_textbox();
				if(tb != null) {
					cstr = tb.Text;
				}
			}
			if(pwbox != null) {
				var pb = pwbox.get_native_passwordbox();
				if(pb != null) {
					cstr = pb.Password;
				}
			}
		}}}
		if(cstr != null) {
			text = String.for_strptr(cstr);
		}
	}

	public void on_textbox_got_focus() {
		if(phwidget != null) {
			phwidget.set_visible(false);
		}
		grab_focus();
	}

	public void on_textbox_lost_focus() {
		if(phwidget != null) {
			if(String.is_empty(get_text())) {
				phwidget.set_visible(true);
			}
		}
		release_focus();
	}

	public void on_enter_pressed() {
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

	public void on_gain_focus() {
		base.on_gain_focus();
		if(textbox!=null) {
			textbox.set_native_focus(true);
		}
		else if(pwbox!=null) {
			pwbox.set_native_focus(true);
		}
	}

	public override void on_lose_focus() {
		base.on_lose_focus();
		if(textbox!=null) {
			textbox.set_native_focus(false);
		}
		else if(pwbox!=null) {
			pwbox.set_native_focus(false);
		}
	}

	public TextInputWidget set_input_type(int type) {
		text_input_type = type;
		if(type == TextInputWidget.INPUT_TYPE_PASSWORD) {
			if(pwbox == null) {
				textbox = null;
				reinitialize();
			}
		}
		else {
			if(textbox == null) {
				pwbox = null;
				reinitialize();
			}
		}
		return(this);
	}

	public int get_input_type() {
		return(text_input_type);
	}

	public TextInputWidget set_text_align(int align) {
		text_align = align;
		update_subcomponents();
		return(this);
	}

	public int get_text_align() {
		return(text_align);
	}

	public TextInputWidget set_icon(Image icon) {
		// Handled by frame
		return(this);
	}

	public Image get_icon() {
		return(null);
	}

	public TextInputWidget set_listener(EventReceiver listener) {
		this.listener = listener;
		return(this);
	}

	public EventReceiver get_listener() {
		return(listener);
	}

	public TextInputWidget set_placeholder(String text) {
		placeholder = text;
		update_subcomponents();
		return(this);
	}
	public String get_placeholder() {
		return(placeholder);
	}

	public TextInputWidget set_text_color(Color c) {
		text_color = c;
		update_subcomponents();
		return(this);
	}

	public Color get_text_color() {
		return(text_color);
	}

	public TextInputWidget set_text(String text) {
		this.text = text;
		update_subcomponents();
		return(this);
	}

	public String get_text() {
		update_from_subcomponents();
		return(text);
	}
}
