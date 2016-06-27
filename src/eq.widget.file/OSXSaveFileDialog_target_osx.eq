
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

public class OSXSaveFileDialog
{
	property String title;
	property File directory;
	property String filename;
	property int overwrite_action;

	embed {{{
		#import <AppKit/NSSavePanel.h>
		#import <AppKit/NSAlert.h>

		@interface SavePanelDelegate : NSObject  <NSOpenSavePanelDelegate>
		@property int oa;
		@property void* listener;
		@end
			
		@implementation SavePanelDelegate
		- (NSString *)panel:(id)sender userEnteredFilename:(NSString *)filename confirmed:(BOOL)okFlag
		{
			NSString *filepath = [[sender URL] path];
			const char* file = [filepath UTF8String];
			if(self.oa == eq_widget_file_SaveFileDialog_OVERWRITE_IGNORE) {
				void* fsp = eq_api_String_for_strptr(file);
				void* dsp = eq_api_String_dup(fsp);
				void* nativepath = eq_os_File_for_native_path(dsp, NULL);
				eq_widget_file_SaveFileDialogListener_on_save_file_dialog_ok(self.listener, nativepath);
				unref_eq_api_String(fsp); fsp = NULL;
				unref_eq_api_String(dsp); dsp = NULL;
				unref_eq_os_File(nativepath); nativepath = NULL;
				[sender cancel:sender];
				return(nil);
			}
			else if(self.oa == eq_widget_file_SaveFileDialog_OVERWRITE_DISALLOW) {
				BOOL file_exists = [[NSFileManager defaultManager] fileExistsAtPath:filepath];
				if(file_exists == YES) {
					NSString *message = [NSString stringWithFormat:@"%s%@%@","\"", filename, @"\" already exists."];
					NSAlert *alert = [[NSAlert alloc] init];
					[alert setMessageText:message];
					[alert setInformativeText:@"A file or folder with the same name already exists."];
					[alert setAlertStyle:NSWarningAlertStyle];
					[alert addButtonWithTitle:@"Ok"];
					[alert runModal];
					return(nil);
				}
			}
			return(filename);
		}
		@end
	}}}

	public bool execute(Frame frame, SaveFileDialogListener listener) {
		var str_path = directory.get_native_path().to_strptr();
		strptr sp_title = title.to_strptr();
		strptr sp_filename = filename.to_strptr();
		bool ok = false;
		int oa = overwrite_action;
		strptr sp_file;
		embed  {{{
			@autoreleasepool {
				NSSavePanel* save_panel = [NSSavePanel savePanel];
				SavePanelDelegate *savepanel_delegate = [[SavePanelDelegate alloc] init];
				savepanel_delegate.oa = oa;
				savepanel_delegate.listener = listener;
				[save_panel setTitle:[[NSString alloc] initWithUTF8String:sp_title]];
				[save_panel setNameFieldStringValue:[[NSString alloc] initWithUTF8String:sp_filename]];
				[save_panel setDirectoryURL:[NSURL fileURLWithPath:[[NSString alloc] initWithUTF8String:str_path]]];
				[save_panel setDelegate:savepanel_delegate];
				if([save_panel runModal] == NSOKButton) {
					ok = 1;
				}
				else {
					ok = 0;
				}
		}}}
		if(ok) {
			embed {{{
				NSString *filename = [[save_panel URL] path];
				if(filename != nil) {
					sp_file = [filename UTF8String];
				}
			}}}
		}
		else {
			return(true);
		}
		if(sp_file != null && listener != null) {
			listener.on_save_file_dialog_ok(File.for_native_path(String.for_strptr(sp_file).dup()));
		}
		embed {{{
			} // close the autoreleasepool
		}}}
		return(true);
	}
}
