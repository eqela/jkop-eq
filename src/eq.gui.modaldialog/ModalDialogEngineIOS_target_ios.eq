
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

class ModalDialogEngineIOS : ModalDialogEngine
{
	embed {{{
		#import <UIKit/UIKit.h>
	}}}

	embed {{{
		@interface MyModalDialogDelegate : NSObject <UIAlertViewDelegate>
		{
			@public void* modal_dialog_listener;
			@public void* modal_dialog_boolean_listener;
			@public void* modal_dialog_string_listener;
		}
		@end
		@implementation MyModalDialogDelegate
		- (id) init
		{
			self = [super init];
			if(self) {
				self->modal_dialog_listener = nil;
				self->modal_dialog_boolean_listener = nil;
				self->modal_dialog_string_listener = nil;
			}
			return(self);
		}
		- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
		{
			if(modal_dialog_listener != nil) {
				eq_gui_modaldialog_ModalDialogListener_on_dialog_closed(modal_dialog_listener);
				modal_dialog_listener = unref_eq_api_Object(modal_dialog_listener);
			}
			if(modal_dialog_boolean_listener != nil) {
				int x = 0;
				if(buttonIndex == 0) {
					x = 1;
				}
				eq_gui_modaldialog_ModalDialogBooleanListener_on_dialog_boolean_result(modal_dialog_boolean_listener, x);
				modal_dialog_boolean_listener = unref_eq_api_Object(modal_dialog_boolean_listener);
			}
			if(modal_dialog_string_listener != nil) {
				void* estr = nil;
				if(buttonIndex == 0) {
					UITextField* tf = [alertView textFieldAtIndex:0];
					if(tf != nil) {
						NSString* str = [tf text];
						if(str != nil) {
							const char* strptr = [str UTF8String];
							if(strptr != nil) {
								void* s1 = eq_api_String_for_strptr(strptr);
								estr = eq_api_String_dup(s1);
								s1 = unref_eq_api_String(s1);
							}
						}
					}
				}
				eq_gui_modaldialog_ModalDialogStringListener_on_dialog_string_result(modal_dialog_string_listener, estr);
				estr = unref_eq_api_String(estr);
			}
			void* p = (__bridge void*)self;
			(__bridge_transfer MyModalDialogDelegate*)p;
		}
		@end
	}}}

	public void message(Frame frame, String text, String title, ModalDialogListener listener) {
		var textp = String.as_strptr(text);
		if(textp == null) {
			embed {{{
				textp = "";
			}}}
		}
		var titlep = String.as_strptr(title);
		if(titlep == null) {
			embed {{{
				textp = "";
			}}}
		}
		bool ok = false;
		embed {{{
			MyModalDialogDelegate* dlg = [[MyModalDialogDelegate alloc] init];
			dlg->modal_dialog_listener = ref_eq_api_Object(listener);
			(__bridge_retained void*)dlg;
			UIAlertView* alert = [[UIAlertView alloc]
				initWithTitle:[[NSString alloc] initWithUTF8String:titlep]
				message:[[NSString alloc] initWithUTF8String:textp]
				delegate:dlg
				cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
			[alert show];
		}}}
	}

	public void error(Frame frame, String text, String title, ModalDialogListener listener) {
		message(frame, text, title, listener);
	}

	public void yesno(Frame frame, String text, String title, ModalDialogBooleanListener listener) {
		var textp = String.as_strptr(text);
		if(textp == null) {
			embed {{{
				textp = "";
			}}}
		}
		var titlep = String.as_strptr(title);
		if(titlep == null) {
			embed {{{
				textp = "";
			}}}
		}
		bool ok = false;
		embed {{{
			MyModalDialogDelegate* dlg = [[MyModalDialogDelegate alloc] init];
			dlg->modal_dialog_boolean_listener = ref_eq_api_Object(listener);
			(__bridge_retained void*)dlg;
			UIAlertView* alert = [[UIAlertView alloc]
				initWithTitle:[[NSString alloc] initWithUTF8String:titlep]
				message:[[NSString alloc] initWithUTF8String:textp]
				delegate:dlg
				cancelButtonTitle:nil otherButtonTitles:@"Yes",@"No",nil];
			[alert show];
		}}}
	}

	public void okcancel(Frame frame, String text, String title, ModalDialogBooleanListener listener) {
		var textp = String.as_strptr(text);
		if(textp == null) {
			embed {{{
				textp = "";
			}}}
		}
		var titlep = String.as_strptr(title);
		if(titlep == null) {
			embed {{{
				textp = "";
			}}}
		}
		bool ok = false;
		embed {{{
			MyModalDialogDelegate* dlg = [[MyModalDialogDelegate alloc] init];
			dlg->modal_dialog_boolean_listener = ref_eq_api_Object(listener);
			(__bridge_retained void*)dlg;
			UIAlertView* alert = [[UIAlertView alloc]
				initWithTitle:[[NSString alloc] initWithUTF8String:titlep]
				message:[[NSString alloc] initWithUTF8String:textp]
				delegate:dlg
				cancelButtonTitle:nil otherButtonTitles:@"OK",@"Cancel",nil];
			[alert show];
		}}}
	}

	public void textinput(Frame frame, String text, String title, String initial_value, ModalDialogStringListener listener) {
		var textp = String.as_strptr(text);
		if(textp == null) {
			embed {{{
				textp = "";
			}}}
		}
		var titlep = String.as_strptr(title);
		if(titlep == null) {
			embed {{{
				textp = "";
			}}}
		}
		bool ok = false;
		embed {{{
			MyModalDialogDelegate* dlg = [[MyModalDialogDelegate alloc] init];
			dlg->modal_dialog_string_listener = ref_eq_api_Object(listener);
			(__bridge_retained void*)dlg;
			UIAlertView* alert = [[UIAlertView alloc]
				initWithTitle:[[NSString alloc] initWithUTF8String:titlep]
				message:[[NSString alloc] initWithUTF8String:textp]
				delegate:dlg
				cancelButtonTitle:nil otherButtonTitles:@"OK",@"Cancel",nil];
			alert.alertViewStyle = UIAlertViewStylePlainTextInput;
		}}}
		if(initial_value != null) {
			var initp = String.as_strptr(initial_value);
			if(initp != null) {
				embed {{{
					UITextField* tf = [alert textFieldAtIndex:0];
					[tf setText:[[NSString alloc] initWithUTF8String:initp]];
				}}}
			}
		}
		embed {{{
			[alert show];
		}}}
	}
}
