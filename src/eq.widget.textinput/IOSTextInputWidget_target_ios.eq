
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

public class IOSTextInputWidget : TextInputWidgetAdapter
{
	embed "objc" {{{
		#import <UIKit/UIKit.h>
		@interface MyTextFieldDelegate : NSObject <UITextFieldDelegate>
		@property void* widget;
		@end
		@implementation MyTextFieldDelegate
		-(void)textFieldDidBeginEditing:(UITextField*)textField
		{
			eq_widget_textinput_IOSTextInputWidget_on_uiview_gain_focus(_widget);
		}
		-(void)textFieldDidEndEditing:(UITextField*)textField
		{
			eq_widget_textinput_IOSTextInputWidget_on_uiview_lose_focus(_widget);
		}
		-(BOOL)textFieldShouldReturn:(UITextField*)textField
		{
			eq_widget_textinput_IOSTextInputWidget_on_uiview_return(_widget);
			return(NO);
		}
		-(void)textFieldDidChange:(UITextField*)textField {
			eq_widget_textinput_IOSTextInputWidget_on_uiview_changed(_widget);
		}
		- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
			int max = eq_widget_textinput_TextInputWidgetAdapter_get_max_length(_widget);
			if(max <= 0) {
				return(YES);
			}
			if(range.length + range.location > textField.text.length) // This prevents the crashing undo bug of UITextField.
			{
				return(NO);
			}
			NSUInteger newLength = textField.text.length + [string length] - range.length;
			return(newLength <= max);
		}
		@end
	}}}

	String _text;
	ptr uiview;
	ptr delegate;
	double scale_factor = 1.0;

	public bool is_focusable() {
		return(true);
	}

	~IOSTextInputWidget() {
		free_objects();
	}

	public override bool get_always_has_surface() {
		return(true);
	}

	public override bool is_surface_container() {
		return(true);
	}

	void free_objects() {
		if(uiview != null) {
			var uv = uiview;
			embed {{{
				(__bridge_transfer UIView*)uv;
			}}}
			uiview = null;
		}
		if(delegate != null) {
			var dd = delegate;
			embed {{{
				(__bridge_transfer MyTextFieldDelegate*)dd;
			}}}
			delegate = null;
		}
	}

	void update_text_from_view() {
		if(uiview == null) {
			return;
		}
		var vw = uiview;
		strptr ctxt;
		embed {{{
			UITextField* uiv = (__bridge UITextField*)vw;
			NSString* txt = uiv.text;
			ctxt = (char*)[txt UTF8String];
		}}}
		_text = String.for_strptr(ctxt).dup();
	}

	void update_text_to_view() {
		if(uiview == null) {
			return;
		}
		var vw = uiview;
		var tt = _text;
		if(tt == null) {
			tt = "";
		}
		var ctt = tt.to_strptr();
		embed {{{
			UITextField* uiv = (__bridge UITextField*)vw;
			uiv.text = [[NSString alloc] initWithUTF8String:ctt];
		}}}
	}

	public TextInputWidget set_text(String t) {
		_text = t;
		update_text_to_view();
		return(this);
	}

	public String get_text() {
		update_text_from_view();
		return(_text);
	}

	public void initialize() {
		base.initialize();
		int hr;
		embed {{{
			UITextField* tf = [[UITextField alloc] init];
			tf.text = @"TXjgLKqp";
			[tf sizeToFit];
			hr = tf.frame.size.height;
		}}}
		if(hr < px("5mm")) {
			hr = px("5mm");
		}
		set_size_request(px("50mm"), hr);
	}

	public void on_gain_focus() {
		base.on_gain_focus();
		if(uiview == null) {
			return;
		}
		var vw = uiview;
		embed {{{
			UIView* uiv = (__bridge UIView*)vw;
			[uiv becomeFirstResponder];
		}}}
	}

	public void on_lose_focus() {
		base.on_lose_focus();
		if(uiview == null) {
			return;
		}
		var vw = uiview;
		embed {{{
			UIView* uiv = (__bridge UIView*)vw;
			[uiv resignFirstResponder];
		}}}
	}

	void resize_view() {
		if(uiview == null) {
			return;
		}
		var uv = uiview;
		var w = (int)(get_width() / scale_factor);
		var h = (int)(get_height() / scale_factor);
		embed {{{
			UIView* uu = (__bridge UIView*)uv;
			uu.frame = CGRectMake(uu.frame.origin.x, uu.frame.origin.y, w, h);
		}}}
	}

	void on_uiview_changed() {
		var listener = get_listener();
		if(listener != null) {
			EventReceiver.event(listener, new TextInputWidgetEvent().set_widget(this).set_changed(false).set_selected(true));
		}
	}

	void on_uiview_return() {
		var listener = get_listener();
		if(listener != null) {
			EventReceiver.event(listener, new TextInputWidgetEvent().set_widget(this).set_changed(false).set_selected(true));
		}
		var e = get_engine();
		if(e != null) {
			e.focus_next();
		}
	}

	void on_uiview_gain_focus() {
		grab_focus();
	}

	void on_uiview_lose_focus() {
		release_focus();
	}

	public void on_surface_created(Surface surface) {
		base.on_surface_created(surface);
		var ss = surface as UIViewSurface;
		if(ss == null) {
			Log.error("IOSTextInputWidget: Created surface is not a UIView surface!");
			return;
		}
		scale_factor = ss.get_scale_factor();
		var pview = ss.get_uiview();
		if(pview == null) {
			Log.error("IOSTextInputWidget: Parent surface does not have a view");
			return;
		}
		ptr tfp;
		ptr ddp;
		var thiswidget = this;
		embed {{{
			UITextField* tf = [[UITextField alloc] init];
			MyTextFieldDelegate* tfd = [[MyTextFieldDelegate alloc] init];
			tfd.widget = thiswidget;
			tf.delegate = tfd;
			[tf addTarget:tfd action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
			UIView* uipview = (__bridge UIView*)pview;
			[uipview addSubview:tf];
			tfp = (__bridge_retained void*)tf;
			ddp = (__bridge_retained void*)tfd;
		}}}
		uiview = tfp;
		delegate = ddp;
		resize_view();
		on_visual_change();
		update_text_to_view();
		if(has_focus()) {
			embed {{{
				[tf becomeFirstResponder];
			}}}
		}
	}

	public void on_resize() {
		base.on_resize();
		resize_view();
	}

	public void on_surface_removed() {
		update_text_from_view();
		free_objects();
	}

	public void on_visual_change() {
		if(uiview == null) {
			return;
		}
		var uw = uiview;
		var type = get_input_type();
		if(type == TextInputWidget.INPUT_TYPE_DEFAULT) {
			embed {{{
				[(__bridge UITextField*)uw setKeyboardType:UIKeyboardTypeDefault];
				[(__bridge UITextField*)uw setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
				[(__bridge UITextField*)uw setAutocorrectionType:UITextAutocorrectionTypeDefault];
				[(__bridge UITextField*)uw setSpellCheckingType:UITextSpellCheckingTypeDefault];
			}}}
		}
		else if(type == TextInputWidget.INPUT_TYPE_NONASSISTED) {
			embed {{{
				[(__bridge UITextField*)uw setKeyboardType:UIKeyboardTypeDefault];
				[(__bridge UITextField*)uw setAutocapitalizationType:UITextAutocapitalizationTypeNone];
				[(__bridge UITextField*)uw setAutocorrectionType:UITextAutocorrectionTypeNo];
				[(__bridge UITextField*)uw setSpellCheckingType:UITextSpellCheckingTypeNo];
			}}}
		}
		else if(type == TextInputWidget.INPUT_TYPE_NAME) {
			embed {{{
				[(__bridge UITextField*)uw setKeyboardType:UIKeyboardTypeDefault];
				[(__bridge UITextField*)uw setAutocapitalizationType:UITextAutocapitalizationTypeWords];
				[(__bridge UITextField*)uw setAutocorrectionType:UITextAutocorrectionTypeNo];
				[(__bridge UITextField*)uw setSpellCheckingType:UITextSpellCheckingTypeNo];
			}}}
		}
		else if(type == TextInputWidget.INPUT_TYPE_EMAIL) {
			embed {{{
				[(__bridge UITextField*)uw setKeyboardType:UIKeyboardTypeEmailAddress];
				[(__bridge UITextField*)uw setAutocapitalizationType:UITextAutocapitalizationTypeNone];
				[(__bridge UITextField*)uw setAutocorrectionType:UITextAutocorrectionTypeNo];
				[(__bridge UITextField*)uw setSpellCheckingType:UITextSpellCheckingTypeNo];
			}}}
		}
		else if(type == TextInputWidget.INPUT_TYPE_URL) {
			embed {{{
				[(__bridge UITextField*)uw setKeyboardType:UIKeyboardTypeURL];
				[(__bridge UITextField*)uw setAutocapitalizationType:UITextAutocapitalizationTypeNone];
				[(__bridge UITextField*)uw setAutocorrectionType:UITextAutocorrectionTypeNo];
				[(__bridge UITextField*)uw setSpellCheckingType:UITextSpellCheckingTypeNo];
			}}}
		}
		else if(type == TextInputWidget.INPUT_TYPE_PHONE_NUMBER) {
			embed {{{
				[(__bridge UITextField*)uw setKeyboardType:UIKeyboardTypePhonePad];
				[(__bridge UITextField*)uw setAutocapitalizationType:UITextAutocapitalizationTypeNone];
				[(__bridge UITextField*)uw setAutocorrectionType:UITextAutocorrectionTypeNo];
				[(__bridge UITextField*)uw setSpellCheckingType:UITextSpellCheckingTypeNo];
			}}}
		}
		else if(type == TextInputWidget.INPUT_TYPE_PASSWORD) {
			embed {{{
				[(__bridge UITextField*)uw setKeyboardType:UIKeyboardTypeDefault];
				[(__bridge UITextField*)uw setAutocapitalizationType:UITextAutocapitalizationTypeNone];
				[(__bridge UITextField*)uw setAutocorrectionType:UITextAutocorrectionTypeNo];
				[(__bridge UITextField*)uw setSpellCheckingType:UITextSpellCheckingTypeNo];
				[(__bridge UITextField*)uw setSecureTextEntry:YES];
			}}}
		}
		else if(type == TextInputWidget.INPUT_TYPE_INTEGER) {
			embed {{{
				[(__bridge UITextField*)uw setKeyboardType:UIKeyboardTypeNumberPad];
				[(__bridge UITextField*)uw setAutocapitalizationType:UITextAutocapitalizationTypeNone];
				[(__bridge UITextField*)uw setAutocorrectionType:UITextAutocorrectionTypeNo];
				[(__bridge UITextField*)uw setSpellCheckingType:UITextSpellCheckingTypeNo];
			}}}
		}
		else if(type == TextInputWidget.INPUT_TYPE_FLOAT) {
			embed {{{
				[(__bridge UITextField*)uw setKeyboardType:UIKeyboardTypeDecimalPad];
				[(__bridge UITextField*)uw setAutocapitalizationType:UITextAutocapitalizationTypeNone];
				[(__bridge UITextField*)uw setAutocorrectionType:UITextAutocorrectionTypeNo];
				[(__bridge UITextField*)uw setSpellCheckingType:UITextSpellCheckingTypeNo];
			}}}
		}
		var ph = get_placeholder();
		if(String.is_empty(ph)) {
			embed {{{
				[(__bridge UITextField*)uw setPlaceholder:nil];
			}}}
		}
		else {
			var php = ph.to_strptr();
			embed {{{
				[(__bridge UITextField*)uw setPlaceholder:[[NSString alloc] initWithUTF8String:php]];
			}}}
		}
		var al = get_text_align();
		if(al == TextInputWidget.LEFT) {
			embed {{{
				[(__bridge UITextField*)uw setTextAlignment:NSTextAlignmentLeft];
			}}}
		}
		else if(al == TextInputWidget.CENTER) {
			embed {{{
				[(__bridge UITextField*)uw setTextAlignment:NSTextAlignmentCenter];
			}}}
		}
		else if(al == TextInputWidget.RIGHT) {
			embed {{{
				[(__bridge UITextField*)uw setTextAlignment:NSTextAlignmentRight];
			}}}
		}
		var cc = get_text_color();
		if(cc == null) {
			embed {{{
				[(__bridge UITextField*)uw setTextColor:[UIColor blackColor]];
			}}}
		}
		else {
			var r = cc.get_r(), g = cc.get_g(), b = cc.get_b(), a = cc.get_a();
			embed {{{
				[(__bridge UITextField*)uw setTextColor:[[UIColor alloc] initWithRed:r green:g blue:b alpha:a]];
			}}}
		}
	}
}
