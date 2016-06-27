
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

#import "MyApplicationDelegate.h"
#import <eq.api/eq.api.h>
#import <eq.gui.sysdep.osx/eq.gui.sysdep.osx.h>
#import <eq.os/eq.os.h>

@implementation MyApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.frame = eq_gui_sysdep_osx_NSWindowFrame_create(self.controller, nil);
	[NSApp activateIgnoringOtherApps:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return(YES);
}

- (BOOL)application:(NSApplication*)theApplication openFile:(NSString*) filename
{
	void* _eqela_application_main = eq_api_Application_get_main();
	if(_eqela_application_main == NULL) {
		return(NO);
	}
	if(vtab_as_eq_os_FileOpener(_eqela_application_main, type_eq_os_FileOpener) == NULL) {
		return(NO);
	}
	const char* fns = [filename UTF8String];
	void* es = eq_api_String_for_strptr(fns);
	void* ff = eq_os_File_for_native_path(es, NULL);
	void* cc = eq_api_LinkedList_create();
	eq_api_LinkedList_add(cc, ff);
	eq_os_FileOpener_open_files(_eqela_application_main, cc);
	unref_eq_os_File(ff); ff = NULL;
	unref_eq_api_String(es); es = NULL;
	unref_eq_api_LinkedList(cc); cc = NULL;
	return(YES);
}

- (BOOL)application:(NSApplication*)theApplication openFiles:(NSArray*) filenames
{
	void* _eqela_application_main = eq_api_Application_get_main();
	if(_eqela_application_main == NULL) {
		return(NO);
	}
	if(vtab_as_eq_os_FileOpener(_eqela_application_main, type_eq_os_FileOpener) == NULL) {
		return(NO);
	}
	void* cc = eq_api_LinkedList_create();
	int n;
	for(n=0; n<[filenames count]; n++) {
		NSString* filename = (NSString*)[filenames objectAtIndex:n];
		const char* fns = [filename UTF8String];
		void* es = eq_api_String_for_strptr(fns);
		void* ff = eq_os_File_for_native_path(es, NULL);
		eq_api_LinkedList_add(cc, ff);
		unref_eq_api_String(es); es = NULL;
		unref_eq_os_File(ff); ff = NULL;
	}
	eq_os_FileOpener_open_files(_eqela_application_main, cc);
	unref_eq_api_LinkedList(cc); cc = NULL;
	return(YES);
}

@end
