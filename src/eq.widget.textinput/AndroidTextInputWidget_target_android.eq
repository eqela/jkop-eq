
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

public class AndroidTextInputWidget : AndroidNativeWidget, TextInputWidget, DataAwareObject
{
	public bool is_focusable() {
		return(true);
	}

	public void set_data(Object o) {
		set_text(String.as_string(o));
	}

	public Object get_data() {
		return(get_text());
	}

	int getpp() {
		return(px("5mm"));
	}

	public void select_all() {
		embed {{{
			MyEditText et = (MyEditText)androidview;
			if(et == null) {
				return;
			}
			et.selectAll();
		}}}
	}

	public void select_none() {
		embed {{{
			MyEditText et = (MyEditText)androidview;
			if(et == null) {
				return;
			}
			et.clearFocus();
		}}}
	}

	void hide_my_keyboard() {
		embed "java" {{{
			if(androidview != null && androidview.hasFocus()) {
				android.view.inputmethod.InputMethodManager imm =
					(android.view.inputmethod.InputMethodManager)androidview.getContext().getSystemService(android.content.Context.INPUT_METHOD_SERVICE);
				imm.hideSoftInputFromWindow(androidview.getWindowToken(), 0);
				androidview.clearFocus();
			}
		}}}
	}

	void show_my_keyboard() {
		embed "java" {{{
			if(androidview != null && androidview.hasFocus()) {
				android.view.inputmethod.InputMethodManager imm =
					(android.view.inputmethod.InputMethodManager)androidview.getContext().getSystemService(android.content.Context.INPUT_METHOD_SERVICE);
				imm.showSoftInput(androidview, 0);
			}
		}}}
	}

	public void on_gain_focus() {
		base.on_gain_focus();
		show_my_keyboard();
	}

	public void stop() {
		base.stop();
		hide_my_keyboard();
	}

	public void android_clear_focus() {
		hide_my_keyboard();
		base.android_clear_focus();
	}

	embed "java" {{{
		android.graphics.Typeface typeface;

		@Override
		protected android.view.View create_android_view(android.content.Context context) {
			if(font == null) {
				font = eq.widget.Theme.Static.font(null, null);
			}
			if(font == null) {
				font = new eq.gui.Font();
			}
			MyEditText et = new MyEditText(context, this);
			try {
				java.lang.reflect.Field f = android.widget.TextView.class.getDeclaredField("mCursorDrawableRes");
				f.setAccessible(true);
				f.set(et, 0);
			} catch (Exception e) {
			}
			et.setSingleLine();
			typeface = eq.gui.sysdep.android.AndroidTextLayout.font_to_typeface(font);
			et.setTypeface(typeface);
			float heightpx = (float)eq.gui.Length.Static.to_pixels(font.get_size(), get_dpi());
			et.setTextSize(android.util.TypedValue.COMPLEX_UNIT_PX, heightpx);
			int pp = getpp();
			int padding = (int)((pp - heightpx) / 2);
			et.setPadding(padding, padding, padding, padding);
			et.setBackgroundColor(0);
			return(et);
		}
	}}}

	embed "java" {{{
		class MyEditText extends android.widget.EditText implements java.lang.Runnable
		{
			AndroidTextInputWidget widget;

			public MyEditText(android.content.Context ctx, AndroidTextInputWidget widget) {
				super(ctx);
				this.widget = widget;
				setOnEditorActionListener(new android.widget.TextView.OnEditorActionListener() {
					public boolean onEditorAction(android.widget.TextView v, int actionId, android.view.KeyEvent event) {
						if(actionId == android.view.inputmethod.EditorInfo.IME_ACTION_DONE ||
							actionId == android.view.inputmethod.EditorInfo.IME_ACTION_NEXT ||
							actionId == android.view.inputmethod.EditorInfo.IME_ACTION_GO ||
							actionId == android.view.inputmethod.EditorInfo.IME_ACTION_SEARCH ||
							actionId == android.view.inputmethod.EditorInfo.IME_ACTION_SEND) {
							on_enter_pressed();
							return(true);
						}
						if(actionId == android.view.inputmethod.EditorInfo.IME_ACTION_PREVIOUS) {
							on_previous_pressed();
							return(true);
						}
						return(false);
					}
				});
			}

			protected void onAttachedToWindow() {
				super.onAttachedToWindow();
				android.os.Handler handler = new android.os.Handler();
				handler.postDelayed(this, 100);
			}

			public void run() {
				widget.show_my_keyboard();
			}

			protected void onFocusChanged (boolean gainFocus, int direction, android.graphics.Rect previouslyFocusedRect) {
				super.onFocusChanged(gainFocus, direction, previouslyFocusedRect);
				if(widget == null) {
					return;
				}
				if(gainFocus) {
					widget.grab_focus();
				}
				else {
					widget.release_focus();
				}
			}

			protected void on_enter_pressed() {
				if(widget != null) {
					widget.on_enter_pressed();
				}
			}

			protected void on_previous_pressed() {
				if(widget != null) {
					widget.on_previous_pressed();
				}
			}
			
			protected void onTextChanged (CharSequence text, int start, int lengthBefore, int lengthAfter) {
				super.onTextChanged(text, start, lengthBefore, lengthAfter);
				if(widget == null) {
					return;
				}
				eq.api.EventReceiver ll = widget.get_listener();
				if(ll == null) {
					return;
				}
				else {
					if(start >= 0) {
						ll.on_event(new TextInputWidgetEvent().set_widget(widget).set_changed(true).set_selected(false));
					}
				}
			}
		}
	}}}

	String text;
	Color text_color;
	String placeholder;
	EventReceiver listener;
	int text_align;
	int input_type;
	int lines = 1;
	int max_length = -1;
	Font font;

	public void initialize() {
		base.initialize();
		update_to_view();
	}

	public void on_surface_created(Surface surface) {
		base.on_surface_created(surface);
		update_to_view();
	}

	public void on_resize() {
		base.on_resize();
		// HACK: The EditText view refuses to redraw itself upon changing device orientation resizing.
		// This trickery here seems to prompt it to behave properly.
		embed {{{
			if(androidview != null) {
				MyEditText et = (MyEditText)androidview;
				et.setGravity(android.view.Gravity.LEFT);
				et.setGravity(android.view.Gravity.CENTER);
			}
		}}}
		update_align();
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

	public void on_previous_pressed() {
		var en = get_engine();
		if(en != null) {
			en.focus_previous();
		}
	}

	void update_align() {
		embed {{{
			MyEditText et = (MyEditText)androidview;
			if(et == null) {
				return;
			}
			et.setGravity(android.view.Gravity.LEFT);
			/*
			// FIXME: It just so happens that if CENTER or RIGHT is chosen, the
			// edited text is no longer visible (?)
			if(text_align == TextInputWidget.Static.LEFT) {
				et.setGravity(android.view.Gravity.LEFT);
			}
			else if(text_align == TextInputWidget.Static.CENTER) {
				et.setGravity(android.view.Gravity.CENTER);
			}
			else if(text_align == TextInputWidget.Static.RIGHT) {
				et.setGravity(android.view.Gravity.RIGHT);
			}
			*/
		}}}
	}

	void update_to_view() {
		embed {{{
			MyEditText et = (MyEditText)androidview;
			if(et == null) {
				return;
			}
			et.setText(text != null ? text.to_strptr() : "");
			et.setHint(placeholder != null ? placeholder.to_strptr() : "");
			if(text_color != null) {
				et.setTextColor(android.graphics.Color.argb(
					(int)(text_color.get_a() * 255.0),
					(int)(text_color.get_r() * 255.0),
					(int)(text_color.get_g() * 255.0),
					(int)(text_color.get_b() * 255.0)));
				et.setHintTextColor(android.graphics.Color.argb(
					(int)(text_color.get_a() * 255.0 / 2.0),
					(int)(text_color.get_r() * 255.0),
					(int)(text_color.get_g() * 255.0),
					(int)(text_color.get_b() * 255.0)));
			}
			if(max_length > -1) {
				android.text.InputFilter maxLengthFilter = new android.text.InputFilter.LengthFilter(max_length);
				et.setFilters(new android.text.InputFilter[]{maxLengthFilter});
			}
		}}}
		update_align();
		embed {{{
			if(input_type == TextInputWidget.Static.INPUT_TYPE_DEFAULT) {
				et.setInputType(android.text.InputType.TYPE_CLASS_TEXT);
			}
			else if(input_type == TextInputWidget.Static.INPUT_TYPE_NONASSISTED) {
				et.setInputType(android.text.InputType.TYPE_CLASS_TEXT | android.text.InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS
					| android.text.InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD);
			}
			else if(input_type == TextInputWidget.Static.INPUT_TYPE_NAME) {
				et.setInputType(android.text.InputType.TYPE_CLASS_TEXT | android.text.InputType.TYPE_TEXT_VARIATION_PERSON_NAME |
					android.text.InputType.TYPE_TEXT_FLAG_CAP_WORDS);
			}
			else if(input_type == TextInputWidget.Static.INPUT_TYPE_EMAIL) {
				et.setInputType(android.text.InputType.TYPE_CLASS_TEXT | android.text.InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS
					 | android.text.InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
			}
			else if(input_type == TextInputWidget.Static.INPUT_TYPE_URL) {
				et.setInputType(android.text.InputType.TYPE_CLASS_TEXT | android.text.InputType.TYPE_TEXT_VARIATION_URI);
			}
			else if(input_type == TextInputWidget.Static.INPUT_TYPE_PHONE_NUMBER) {
				et.setInputType(android.text.InputType.TYPE_CLASS_PHONE);
			}
			else if(input_type == TextInputWidget.Static.INPUT_TYPE_PASSWORD) {
				et.setInputType(android.text.InputType.TYPE_CLASS_TEXT | android.text.InputType.TYPE_TEXT_VARIATION_PASSWORD);
			}
			else if(input_type == TextInputWidget.Static.INPUT_TYPE_INTEGER) {
				et.setInputType(android.text.InputType.TYPE_CLASS_NUMBER);
			}
			else if(input_type == TextInputWidget.Static.INPUT_TYPE_FLOAT) {
				et.setInputType(android.text.InputType.TYPE_CLASS_NUMBER | android.text.InputType.TYPE_NUMBER_FLAG_DECIMAL);
			}
			if(lines > 1) {
				et.setInputType(et.getInputType() | android.text.InputType.TYPE_TEXT_FLAG_MULTI_LINE);
				et.setLines(lines);
			}
			if(typeface != null) {
				typeface = eq.gui.sysdep.android.AndroidTextLayout.font_to_typeface(font);
				et.setTypeface(typeface);
				float heightpx = (float)eq.gui.Length.Static.to_pixels(font.get_size(), get_dpi());
				et.setTextSize(android.util.TypedValue.COMPLEX_UNIT_PX, heightpx);
				int pp = getpp();
				int padding = (int)((pp - heightpx) / 2);
				et.setPadding(padding, padding, padding, padding);
			}
		}}}
	}

	void update_from_view() {
		strptr tt;
		embed {{{
			MyEditText et = (MyEditText)androidview;
			if(et == null) {
				return;
			}
			android.text.Editable ee = et.getText();
			if(ee != null) {
				tt = ee.toString();
			}
		}}}
		this.text = String.for_strptr(tt);
	}

	public TextInputWidget set_lines(int nlines) {
		lines = nlines;
		update_to_view();
		return(this);
	}

	public int get_lines() {
		return(lines);
	}

	public TextInputWidget set_input_type(int type) {
		this.input_type = type;
		update_to_view();
		return(this);
	}

	public int get_input_type() {
		return(input_type);
	}

	public TextInputWidget set_text_align(int align) {
		this.text_align = align;
		update_to_view();
		return(this);
	}

	public int get_text_align() {
		return(text_align);
	}

	// The icon is handled in the frame widget

	public TextInputWidget set_icon(Image icon) {
		return(this);
	}

	public Image get_icon() {
		return(null);
	}

	public TextInputWidget set_listener(EventReceiver listener) {
		this.listener = listener; // FIXME: Where do we use this?
		return(this);
	}

	public EventReceiver get_listener() {
		return(listener);
	}

	public TextInputWidget set_placeholder(String text) {
		this.placeholder = text;
		update_to_view();
		return(this);
	}

	public String get_placeholder() {
		return(placeholder);
	}

	public TextInputWidget set_text_color(Color c) {
		this.text_color = c;
		update_to_view();
		return(this);
	}

	public Color get_text_color() {
		return(text_color);
	}

	public TextInputWidget set_text(String text) {
		this.text = text;
		update_to_view();
		return(this);
	}

	public String get_text() {
		update_from_view();
		return(text);
	}

	public TextInputWidget set_max_length(int length) {
		this.max_length = length;
		update_to_view();
		return(this);
	}

	public TextInputWidget set_font(Font f) {
		font = f;
		update_to_view();
		return(this);
	}
}
