
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

public class OSXTextInputControl : OSXNativeWidget, TextInputControl, DataAwareObject
{
	embed {{{
		#import <Cocoa/Cocoa.h>
	}}}

	bool has_frame = true;
	int input_type = 0;
	int text_align = Alignment.LEFT;
	TextInputControlListener listener;
	String placeholder;
	Color text_color;
	String text;
	int max_length = -1;

	embed {{{
		@interface MyDelegate : NSObject <NSTextFieldDelegate>
		{
			@public void* control;
		}
		@end
		@implementation MyDelegate
		- (void)controlTextDidChange:(NSNotification *)aNotification
		{
			eq_widget_controls_engine_OSXTextInputControl_on_text_changed(control);
		}
		- (BOOL)control:(NSControl *)cc textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector
		{
			BOOL retval = NO;
			if(commandSelector == @selector(insertNewline:)) {
				eq_widget_controls_engine_OSXTextInputControl_on_text_accept(control);
				retval = YES;
			}
			return retval;
		}
		@end
		@interface MyTextField : NSTextField
		{
			@public void* control;
		}
		@end
		@implementation MyTextField
		- (BOOL)becomeFirstResponder
		{
			BOOL v = [super becomeFirstResponder];
			eq_widget_controls_engine_OSXNativeWidget_on_became_first_responder(control);
			return(v);
		}
		@end
	}}}

	ActionItem item;
	ptr delegate;

	public OSXTextInputControl() {
		ptr hh;
		var myself = this;
		embed {{{
			MyDelegate* dg = [[MyDelegate alloc] init];
			dg->control = myself;
			hh = (__bridge_retained void*)dg;
		}}}
		this.delegate = hh;
	}

	~OSXTextInputControl() {
		var hh = delegate;
		embed {{{
			MyDelegate* dg = (__bridge_transfer MyDelegate*)hh;
		}}}
	}

	public bool is_focusable() {
		return(true);
	}

	public void on_text_accept() {
		if(listener != null) {
			listener.on_text_input_control_accept();
		}
	}

	public void on_text_changed() {
		if(listener != null) {
			listener.on_text_input_control_change();
		}
	}

	public void set_data(Object o) {
		set_text(String.as_string(o));
	}

	public Object get_data() {
		return(get_text());
	}

	public void initialize_nsview() {
		base.initialize_nsview();
		update_field();
	}

	public void cleanup_nsview() {
		base.cleanup_nsview();
		update_text_from_field();
	}

	public ptr create_nsview() {
		ptr v = null;
		var dg = delegate;
		embed {{{
			MyTextField* tf = [[MyTextField alloc] init];
			tf->control = self;
			[tf.cell setWraps:NO];
			[tf.cell setScrollable:YES];
			[tf setFont:[NSFont systemFontOfSize:[NSFont systemFontSize]]];
			[tf setDelegate:(__bridge MyDelegate*)dg];
			[tf setEditable:YES];
			[tf setSelectable:YES];
			[tf setWantsLayer:YES];
			v = (__bridge_retained void*)tf;
		}}}
		return(v);
	}

	void update_text_from_field() {
		var nsview = get_nsview();
		if(nsview == null) {
			return;
		}
		strptr str = null;
		embed {{{
			NSTextField* tf = (__bridge NSTextField*)nsview;
			NSString* value = [tf stringValue];
			if(value != nil) {
				str = (char*)value.UTF8String;
			}
		}}}
		if(str != null) {
			text = String.for_strptr(str).dup();
		}
		else {
			text = "";
		}
	}

	void update_field() {
		var view = get_nsview();
		if(view == null) {
			return;
		}
		var text = this.text;
		if(text == null) {
			text = "";
		}
		var tp = text.to_strptr();
		embed {{{
			NSTextField* tf = (__bridge NSTextField*)view;
			[tf setStringValue:[NSString stringWithUTF8String:tp]];
		}}}
		if(has_frame) {
			embed {{{
				[tf setDrawsBackground:YES];
				[tf setBezeled:YES];
				[tf setBezelStyle:NSTextFieldRoundedBezel];
			}}}
		}
		else {
			embed {{{
				[tf setDrawsBackground:NO];
				[tf setBezeled:NO];
			}}}
		}
		if(text_align == Alignment.RIGHT) {
			embed {{{ [tf setAlignment:NSRightTextAlignment]; }}}
		}
		else if(text_align == Alignment.CENTER) {
			embed {{{ [tf setAlignment:NSCenterTextAlignment]; }}}
		}
		else {
			embed {{{ [tf setAlignment:NSNaturalTextAlignment]; }}}
		}
		var cc = text_color;
		if(cc == null && has_frame == false) {
			cc = get_draw_color();
		}
		if(cc != null) {
			var r = cc.get_r(), g = cc.get_g(), b = cc.get_b(), a = cc.get_a();
			embed {{{
				[tf setTextColor:[NSColor colorWithCalibratedRed:r green:g blue:b alpha:a]];
			}}}
		}
		if(placeholder != null) {
			var pt = placeholder.to_strptr();
			embed {{{
				[[tf cell] setPlaceholderString:[NSString stringWithUTF8String:pt]];
			}}}
		}
		// FIXME: input_type
		// FIXME: listener
		// FIXME: max_length
		update_size_request();
	}

	public TextInputControl set_has_frame(bool v) {
		has_frame = v;
		update_text_from_field();
		update_field();
		return(this);
	}

	public bool get_has_frame() {
		return(has_frame);
	}

	public TextInputControl set_input_type(int type) {
		input_type = type;
		update_text_from_field();
		update_field();
		return(this);
	}

	public int get_input_type() {
		return(input_type);
	}

	public TextInputControl set_text_align(int align) {
		this.text_align = align;
		update_text_from_field();
		update_field();
		return(this);
	}

	public int get_text_align() {
		return(text_align);
	}

	public TextInputControl set_listener(TextInputControlListener listener) {
		this.listener = listener;
		return(this);
	}

	public TextInputControlListener get_listener() {
		return(listener);
	}

	public TextInputControl set_placeholder(String text) {
		this.placeholder = text;
		update_text_from_field();
		update_field();
		return(this);
	}

	public String get_placeholder() {
		return(placeholder);
	}

	public TextInputControl set_text_color(Color c) {
		this.text_color = c;
		update_text_from_field();
		update_field();
		return(this);
	}

	public Color get_text_color() {
		return(text_color);
	}

	public TextInputControl set_text(String text) {
		this.text = text;
		update_field();
		return(this);
	}

	public String get_text() {
		update_text_from_field();
		return(text);
	}

	public TextInputControl set_max_length(int length) {
		this.max_length = length;
		update_field();
		return(this);
	}

	public int get_max_length() {
		return(max_length);
	}
}
