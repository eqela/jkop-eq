
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

class OSXToolBar : ToolBarControl
{
	embed {{{
		#import <AppKit/AppKit.h>
		#import <AppKit/NSToolbar.h>
		@interface MyToolBarDelegate : NSObject <NSToolbarDelegate>
		{
			@public void* osxtoolbar;
		}
		@end
		@implementation MyToolBarDelegate
		- (void) onAction:(NSToolbarItem*)item
		{
			eq_widget_desktopapplication_OSXToolBar_on_item_clicked(osxtoolbar, [item.itemIdentifier UTF8String]);
		}
		- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
		{
			NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
			[toolbarItem setTarget:self];
			[toolbarItem setAction:@selector(onAction:)];
			eq_widget_desktopapplication_OSXToolBar_fill_item(osxtoolbar, [itemIdentifier UTF8String], (__bridge void*)toolbarItem);
			return(toolbarItem);
		}
		- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
		{
			return([self toolbarDefaultItemIdentifiers:toolbar]);
		}
		- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
		{
			NSMutableArray* a = [[NSMutableArray alloc] init];
			eq_widget_desktopapplication_OSXToolBar_get_item_identifiers(osxtoolbar, (__bridge void*)a);
			return(a);
		}
		- (void)toolbarDidRemoveItem:(NSNotification *)notification
		{
		}
		- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
		{
			return(nil);
		}
		- (void)toolbarWillAddItem:(NSNotification *)notification
		{
		}
		@end
	}}}

	public static OSXToolBar for_frame(Frame frame) {
		return(new OSXToolBar().set_frame(frame));
	}

	property Frame frame;
	ptr nstoolbar = null;
	ToolBar toolbar;
	HashTable toolbarentries;
	ptr mydelegate = null;
	ToolBarControlListener listener;

	public void fill_item(strptr key, ptr itemp) {
		var str = String.for_strptr(key);
		if(str == null) {
			return;
		}
		var entry = toolbarentries.get(str) as ActionItem;
		if(entry == null) {
			return;
		}
		strptr ttp = null, ddp = null;
		var tt = entry.get_text();
		var dd = entry.get_desc();
		if(tt != null) {
			ttp = tt.to_strptr();
		}
		if(dd != null) {
			ddp = dd.to_strptr();
		}
		ptr nsimage = null;
		var img = entry.get_icon() as QuartzBitmapImage;
		if(img != null) {
			nsimage = img.as_nsimage();
		}
		embed {{{
			NSToolbarItem* item = (__bridge NSToolbarItem*)itemp;
			if(ttp != nil) {
				[item setLabel:[[NSString alloc] initWithUTF8String:ttp]];
			}
			if(ddp != nil) {
				[item setToolTip:[[NSString alloc] initWithUTF8String:ddp]];
			}
			if(nsimage != nil) {
				[item setImage:(__bridge_transfer NSImage*)nsimage];
			}
		}}}
	}

	public void on_item_clicked(strptr sp) {
		var str = String.for_strptr(sp);
		if(toolbarentries == null) {
			return;
		}
		var entry = toolbarentries.get(str) as ActionItem;
		if(entry == null) {
			return;
		}
		if(listener != null) {
			listener.on_toolbar_entry_selected(entry);
		}
	}

	public void get_item_identifiers(ptr nsarray) {
		embed {{{
			NSMutableArray* a = (__bridge NSMutableArray*)nsarray;
		}}}
		if(toolbarentries != null) {
			int n;
			var c = toolbarentries.count();
			for(n=0; n<c; n++) {
				var key = "%d".printf().add(n).to_string();
				var kp = key.to_strptr();
				var si = toolbarentries.get(key) as SeparatorItem;
				if(si != null) {
					if(si.get_weight() > 0) {
						embed {{{
							[a addObject:NSToolbarFlexibleSpaceItemIdentifier];
						}}}
					}
				}
				else {
					embed {{{
						[a addObject:[[NSString alloc] initWithUTF8String:kp]];
					}}}
				}
			}
		}
	}

	ptr get_nswindow() {
		var ff = frame as NSWindowFrame;
		if(ff == null) {
			return(null);
		}
		return(ff.get_nswindow());
	}

	public void initialize_toolbar(ToolBar tb, ToolBarControlListener listener) {
		do_finalize(false);
		toolbar = tb;
		toolbarentries = HashTable.create();
		this.listener = listener;
		if(tb == null) {
			return;
		}
		int n = 0;
		var tbi = tb.get_items();
		if(tbi == null || tbi.count() < 1) {
			return;
		}
		foreach(Object tbe in tbi) {
			toolbarentries.set("%d".printf().add(n).to_string(), tbe);
			n++;
		}
		var nswindow = get_nswindow();
		if(nswindow == null) {
			return;
		}
		ptr nstp = null;
		String tid;
		if(tb == null) {
			tid = "0";
		}
		else {
			tid = "%d".printf().add((int)tb).to_string();
		}
		var tidp = tid.to_strptr();
		ptr ddg = null;
		embed {{{
			NSToolbar* nst = [[NSToolbar alloc] initWithIdentifier:[[NSString alloc] initWithUTF8String:tidp]];
			MyToolBarDelegate* dlg = [[MyToolBarDelegate alloc] init];
			dlg->osxtoolbar = self;
			ddg = (__bridge_retained void*)dlg;
			[nst setDelegate:dlg];
			nstp = (__bridge_retained void*)nst;
			[(__bridge NSWindow*)nswindow setToolbar:nst];
		}}}
		mydelegate = ddg;
		nstoolbar = nstp;
	}

	public void finalize() {
		do_finalize(true);
	}

	void do_finalize(bool clearout) {
		var nswindow = get_nswindow();
		if(nswindow != null) {
			if(clearout) {
				embed {{{
					[(__bridge NSWindow*)nswindow setToolbar:nil];
				}}}
			}
		}
		var nstp = nstoolbar;
		embed {{{
			NSToolbar* nst = (__bridge_transfer NSToolbar*)nstp;
		}}}
		var ddg = mydelegate;
		embed {{{
			MyToolBarDelegate* dlg = (__bridge_transfer MyToolBarDelegate*)ddg;
		}}}
		mydelegate = null;
		nstoolbar = null;
		toolbar = null;
		toolbarentries = null;
		listener = null;
	}
}
