
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

#import "MyWindowDelegate.h"
#import "NSWindowFrame.h"

@implementation MyWindowDelegate

- (void)windowDidBecomeKey:(NSNotification *)notification
{
	eq_gui_sysdep_osx_NSWindowFrame_on_window_became_key(self.windowframe);
}

- (void)windowDidResignKey:(NSNotification *)notification
{
	eq_gui_sysdep_osx_NSWindowFrame_on_window_resign_key(self.windowframe);
}

- (void)windowDidChangeBackingProperties:(NSNotification *)notification
{
  eq_gui_sysdep_osx_NSWindowFrame_on_backing_properties_changed(self.windowframe);
}

- (void)windowDidResize:(NSNotification *)notification
{
  eq_gui_sysdep_osx_NSWindowFrame_on_resize(self.windowframe);
}

- (BOOL)windowShouldClose:(id)sender
{
  return(eq_gui_sysdep_osx_NSWindowFrame_on_close_request(self.windowframe) ? YES : NO);
}

- (void)windowWillClose:(NSNotification *)notification
{
  eq_gui_sysdep_osx_NSWindowFrame_on_window_will_close(self.windowframe);
}

- (NSRect) window:(NSWindow*)window willPositionSheet:(NSWindow*)sheet usingRect:(NSRect)rect
{
	rect.origin.x = window.frame.size.width / 2 - rect.size.width / 2;
	rect.origin.y = window.frame.size.height/2 + sheet.frame.size.height/2;
	return(rect);
}

@end
