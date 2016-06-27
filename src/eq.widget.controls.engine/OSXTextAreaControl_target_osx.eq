
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

public class OSXTextAreaControl : OSXNativeWidget, TextAreaControl, DataAwareObject
{
	embed {{{
		#import <Cocoa/Cocoa.h>
	}}}

	bool has_frame = true;
	TextAreaControlListener listener;
	String placeholder;
	Color text_color;
	String text;
	ptr textview = null;

	ptr get_textview() {
		return(textview);
	}

	embed {{{
		@interface MyTextAreaDelegate : NSObject <NSTextViewDelegate>
		{
			@public void* control;
		}
		@end
		@implementation MyTextAreaDelegate
		- (void)textDidChange:(NSNotification *)notification
		{
			eq_widget_controls_engine_OSXTextAreaControl_on_text_changed(control);
		}
		@end
		@interface MyTextView : NSTextView
		{
			@public void* control;
		}
		@end
		@implementation MyTextView
		- (BOOL)becomeFirstResponder
		{
			BOOL v = [super becomeFirstResponder];
			eq_widget_controls_engine_OSXNativeWidget_on_became_first_responder(control);
			return(v);
		}
		@end
	}}}

	ptr delegate;

	public OSXTextAreaControl() {
		ptr hh;
		var myself = this;
		embed {{{
			MyTextAreaDelegate* dg = [[MyTextAreaDelegate alloc] init];
			dg->control = myself;
			hh = (__bridge_retained void*)dg;
		}}}
		this.delegate = hh;
	}

	~OSXTextAreaControl() {
		var hh = delegate;
		embed {{{
			MyTextAreaDelegate* dg = (__bridge_transfer MyTextAreaDelegate*)hh;
		}}}
	}

	public bool is_focusable() {
		return(true);
	}

	public void update_size_request() {
		set_size_request(px("60mm"), px("40mm"));
	}

	public void on_text_changed() {
		if(listener != null) {
			listener.on_text_area_control_change();
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
		update_textview();
	}

	public void cleanup_nsview() {
		update_text_from_textview();
		base.cleanup_nsview();
		if(textview != null) {
			var p = textview;
			embed {{{
				NSView* ov = (__bridge_transfer NSView*)p;
			}}}
			textview = null;
		}
	}

	public ptr create_nsview() {
		ptr v = null;
		ptr tfv = null;
		var dg = delegate;
		embed {{{
			MyTextView* tf = [[MyTextView alloc] init];
			tf->control = self;
			[tf setRichText:NO];
			[tf setAutomaticQuoteSubstitutionEnabled:NO];
			[tf setAllowsImageEditing:NO];
			[tf setImportsGraphics:NO];
			[tf setAutomaticLinkDetectionEnabled:NO];
			[tf setDisplaysLinkToolTips:NO];
			[tf setContinuousSpellCheckingEnabled:NO];
			[tf setGrammarCheckingEnabled:NO];
			[tf setAutomaticDashSubstitutionEnabled:NO];
			[tf setAutomaticDataDetectionEnabled:NO];
			[tf setAutomaticSpellingCorrectionEnabled:NO];
			[tf setAutomaticTextReplacementEnabled:NO];
			[tf setFont:[NSFont systemFontOfSize:[NSFont systemFontSize]]];
			[tf setDelegate:(__bridge MyTextAreaDelegate*)dg];
			[tf setEditable:YES];
			[tf setSelectable:YES];
			[tf setWantsLayer:YES];
			[tf setVerticallyResizable:YES];
			[tf setHorizontallyResizable:YES];
			[[tf textContainer] setWidthTracksTextView:YES];
			tfv = (__bridge_retained void*)tf;
			NSScrollView* sv = [[NSScrollView alloc] init];
			[sv setBorderType:NSBezelBorder];
			[sv setHasVerticalScroller:YES];
			[sv setHasHorizontalScroller:NO];
			[sv setDocumentView:tf];
			v = (__bridge_retained void*)sv;
		}}}
		textview = tfv;
		return(v);
	}

	void update_text_from_textview() {
		var nsview = get_textview();
		if(nsview == null) {
			return;
		}
		strptr str = null;
		embed {{{
			NSTextView* tf = (__bridge NSTextView*)nsview;
			NSString* value = [tf string];
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

	void update_textview() {
		var view = get_textview();
		if(view == null) {
			return;
		}
		var text = this.text;
		if(text == null) {
			text = "";
		}
		var tp = text.to_strptr();
		embed {{{
			NSTextView* tf = (__bridge NSTextView*)view;
			[tf setString:[NSString stringWithUTF8String:tp]];
		}}}
		if(has_frame) {
			embed {{{
				[tf setDrawsBackground:YES];
			}}}
		}
		else {
			embed {{{
				[tf setDrawsBackground:NO];
			}}}
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
				// FIXME
			}}}
		}
		update_size_request();
	}

	public TextAreaControl set_has_frame(bool v) {
		has_frame = v;
		update_text_from_textview();
		update_textview();
		return(this);
	}

	public bool get_has_frame() {
		return(has_frame);
	}

	public TextAreaControl set_listener(TextAreaControlListener listener) {
		this.listener = listener;
		return(this);
	}

	public TextAreaControlListener get_listener() {
		return(listener);
	}

	public TextAreaControl set_placeholder(String text) {
		this.placeholder = text;
		update_text_from_textview();
		update_textview();
		return(this);
	}

	public String get_placeholder() {
		return(placeholder);
	}

	public TextAreaControl set_text_color(Color c) {
		this.text_color = c;
		update_text_from_textview();
		update_textview();
		return(this);
	}

	public Color get_text_color() {
		return(text_color);
	}

	public TextAreaControl set_text(String text) {
		this.text = text;
		update_textview();
		return(this);
	}

	public String get_text() {
		update_text_from_textview();
		return(text);
	}
}
