
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

class ModalDialogEngineOSX : ModalDialogEngine
{
	embed {{{
		#import <AppKit/AppKit.h>
	}}}

	public void message(Frame frame, String text, String title, ModalDialogListener alistener) {
		var listener = alistener;
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
			NSAlert* alert = [[NSAlert alloc] init];
			[alert setMessageText:[[NSString alloc] initWithUTF8String:titlep]];
			[alert setInformativeText:[[NSString alloc] initWithUTF8String:textp]];
			[alert runModal];
		}}}
		if(listener != null) {
			listener.on_dialog_closed();
		}
	}

	public void error(Frame frame, String text, String title, ModalDialogListener alistener) {
		var listener = alistener;
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
			NSAlert* alert = [[NSAlert alloc] init];
			[alert setMessageText:[[NSString alloc] initWithUTF8String:titlep]];
			[alert setInformativeText:[[NSString alloc] initWithUTF8String:textp]];
			[alert setAlertStyle:NSCriticalAlertStyle];
			[alert runModal];
		}}}
		if(listener != null) {
			listener.on_dialog_closed();
		}
	}

	public void yesno(Frame frame, String text, String title, ModalDialogBooleanListener alistener) {
		var listener = alistener;
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
			NSAlert* alert = [[NSAlert alloc] init];
			[alert addButtonWithTitle:@"Yes"];
			[alert addButtonWithTitle:@"No"];
			[alert setMessageText:[[NSString alloc] initWithUTF8String:titlep]];
			[alert setInformativeText:[[NSString alloc] initWithUTF8String:textp]];
			if([alert runModal] == NSAlertFirstButtonReturn) {
				ok = 1;
			}
		}}}
		if(listener != null) {
			listener.on_dialog_boolean_result(ok);
		}
	}

	public void okcancel(Frame frame, String text, String title, ModalDialogBooleanListener alistener) {
		var listener = alistener;
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
			NSAlert* alert = [[NSAlert alloc] init];
			[alert addButtonWithTitle:@"OK"];
			[alert addButtonWithTitle:@"Cancel"];
			[alert setMessageText:[[NSString alloc] initWithUTF8String:titlep]];
			[alert setInformativeText:[[NSString alloc] initWithUTF8String:textp]];
			if([alert runModal] == NSAlertFirstButtonReturn) {
				ok = 1;
			}
		}}}
		if(listener != null) {
			listener.on_dialog_boolean_result(ok);
		}
	}

	public void textinput(Frame frame, String text, String title, String initial_value, ModalDialogStringListener alistener) {
		var listener = alistener;
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
		strptr ivp;
		var iv = initial_value;
		if(iv != null) {
			ivp = iv.to_strptr();
		}
		strptr value = null;
		embed {{{
			NSString* resp;
			NSAlert* alert = [[NSAlert alloc] init];
			[alert addButtonWithTitle:@"OK"];
			[alert addButtonWithTitle:@"Cancel"];
			[alert setMessageText:[[NSString alloc] initWithUTF8String:titlep]];
			[alert setInformativeText:[[NSString alloc] initWithUTF8String:textp]];
			NSTextField* input = [[NSTextField alloc] initWithFrame:NSMakeRect(0,0,200,24)];
			if(ivp != NULL) {
				[input setStringValue:[[NSString alloc] initWithUTF8String:ivp]];
				[alert setAccessoryView:input];
			}
			if([alert runModal] == NSAlertFirstButtonReturn) {
				resp = [input stringValue];
				if(resp != nil) {
					value = [resp UTF8String];
				}
			}
		}}}
		if(listener != null) {
			if(value != null) {
				listener.on_dialog_string_result(String.for_strptr(value).dup());
			}
			else {
				listener.on_dialog_string_result(null);
			}
		}
	}
}
