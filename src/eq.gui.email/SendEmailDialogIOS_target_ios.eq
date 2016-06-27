
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

class SendEmailDialogIOS : SendEmailDialog
{
	embed {{{
		#import <MessageUI/MFMailComposeViewController.h>
		@interface MyDelegate : NSObject<MFMailComposeViewControllerDelegate>
		{
			@public void* ptr;
			@public void* listener;
			@public void* vc;
		}
		@end
		@implementation MyDelegate
		- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
		{
			switch (result)
			{
				case MFMailComposeResultSaved:
				case MFMailComposeResultSent:
				case MFMailComposeResultCancelled:
					if(listener != NULL) {
						eq_gui_email_SendEmailDialogListener_on_send_email_complete(listener, 1);
					}
					break;
				case MFMailComposeResultFailed:
				default:
					if(listener != NULL) {
						eq_gui_email_SendEmailDialogListener_on_send_email_complete(listener, 0);
					}
					break;
			}
			[(__bridge UIViewController*)vc dismissViewControllerAnimated:YES completion:nil];
			if(listener != NULL) {
				unref_eq_api_Object(listener);
				listener = NULL;
			}
			(__bridge_transfer MyDelegate*)ptr;
			ptr = nil;
		}
		@end
	}}}

	String recipient;
	String subject;
	String text;

	public void set_recipient(String rcpt) {
		this.recipient = rcpt;
	}

	public void set_subject(String subject) {
		this.subject = subject;
	}

	public void set_text(String text) {
		this.text = text;
	}

	public void execute(Frame frame, SendEmailDialogListener listener) {
		ptr vc;
		if(frame != null && frame is UIKitFrame) {
			vc = ((UIKitFrame)frame).get_view_controller();
		}
		if(vc == null) {
			if(listener != null) {
				listener.on_send_email_complete(false);
			}
			return;
		}
		var rcpt = this.recipient;
		var subject = this.subject;
		var text = this.text;
		if(rcpt == null) {
			rcpt = "";
		}
		if(subject == null) {
			subject = "";
		}
		if(text == null) {
			text = "";
		}
		var rp = rcpt.to_strptr();
		var sp = subject.to_strptr();
		var tp = text.to_strptr();
		embed {{{
			MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
			MyDelegate *dg = [[MyDelegate alloc] init];
			void* ptr = (__bridge_retained void*)dg;
			dg->vc = vc;
			dg->ptr = ptr;
			if(listener != NULL) {
				ref_eq_api_Object(listener);
				dg->listener = listener;
			}
			controller.mailComposeDelegate = dg;
			[controller setSubject:[[NSString alloc] initWithUTF8String:sp]];
			[controller setMessageBody:[[NSString alloc] initWithUTF8String:tp] isHTML:NO];
			NSArray* array = [NSArray arrayWithObject:[[NSString alloc] initWithUTF8String:rp]];
			[controller setToRecipients:array];
			[(__bridge UIViewController*)vc presentViewController:controller animated:YES completion:nil];
		}}}
	}
}
