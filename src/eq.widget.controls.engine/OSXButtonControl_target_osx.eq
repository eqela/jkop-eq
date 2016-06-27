
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

public class OSXButtonControl : OSXNativeWidget, ButtonControl
{
	embed {{{
		#import <Cocoa/Cocoa.h>
	}}}

	embed {{{
		@interface MyClickHandler : NSObject
		{
			@public void* control;
		}
		- (void) onClick;
		@end
		@implementation MyClickHandler
		- (void) onClick
		{
			eq_widget_controls_engine_OSXButtonControl_on_click(control);
		}
		@end
		@interface MyButton : NSButton
		{
			@public void* control;
			@public BOOL focusable;
		}
		@end
		@implementation MyButton
		- (BOOL)acceptsFirstResponder
		{
			return(focusable);
		}
		- (void)keyDown:(NSEvent *)theEvent
		{
			if([theEvent keyCode] == 49) {
				return;
			}
			[super keyDown:theEvent];
		}
		- (void)keyUp:(NSEvent *)theEvent
		{
			if([theEvent keyCode] == 49) {
				eq_widget_controls_engine_OSXButtonControl_on_click(control);
				return;
			}
			[super keyUp:theEvent];
		}
		- (BOOL)becomeFirstResponder
		{
			BOOL v = [super becomeFirstResponder];
			eq_widget_controls_engine_OSXNativeWidget_on_became_first_responder(control);
			return(v);
		}
		@end
	}}}

	ActionItem item;
	ptr handler;
	bool focusable = true;

	public OSXButtonControl() {
		item = ActionItem.instance();
		ptr hh;
		var myself = this;
		embed {{{
			MyClickHandler* handler = [[MyClickHandler alloc] init];
			handler->control = myself;
			hh = (__bridge_retained void*)handler;
		}}}
		this.handler = hh;
	}

	~OSXButtonControl() {
		var hh = handler;
		embed {{{
			MyClickHandler* handler = (__bridge_transfer MyClickHandler*)hh;
		}}}
	}

	public ButtonControl set_focusable(bool v) {
		focusable = v;
		return(this);
	}

	public bool is_focusable() {
		return(focusable);
	}

	public void on_click() {
		ActionItemWidget.execute(item, this);
	}

	public void initialize_nsview() {
		base.initialize_nsview();
		update_button();
	}

	public ptr create_nsview() {
		ptr v = null;
		var hh = handler;
		embed {{{
			BOOL ff = NO;
		}}}
		if(is_focusable()) {
			embed {{{
				ff = YES;
			}}}
		}
		embed {{{
			MyButton* button = [[MyButton alloc] init];
			button->control = self;
			button->focusable = (BOOL)ff;
			[button setButtonType:NSMomentaryLightButton];
			[button setBezelStyle:NSRoundedBezelStyle];
			[button setTarget:(__bridge MyClickHandler*)hh];
			[button setAction:NSSelectorFromString(@"onClick")];
			v = (__bridge_retained void*)button;
		}}}
		return(v);
	}

	void update_button() {
		var view = get_nsview();
		if(view == null) {
			return;
		}
		var text = item.get_text();
		if(text == null) {
			text = "";
		}
		var tp = text.to_strptr();
		embed {{{
			[(__bridge NSButton*)view setTitle:[NSString stringWithUTF8String:tp]];
		}}}
		update_size_request();
	}

	public ButtonControl set_action_item(ActionItem item) {
		this.item = item;
		if(this.item == null) {
			this.item = ActionItem.instance();
		}
		update_button();
		return(this);
	}

	public ButtonControl set_text(String text) {
		item.set_text(text);
		update_button();
		return(this);
	}

	public ButtonControl set_event(Object object) {
		item.set_event(object);
		return(this);
	}

	public ButtonControl set_action(Executable action) {
		item.set_action(action);
		return(this);
	}

	public ButtonControl set_menu(Menu menu) {
		item.set_menu(menu);
		return(this);
	}
}
