
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

public class OSXTabbedViewControl : TabbedViewControl, OSXNativeWidget
{
	class PageInfo
	{
		property Widget widget;
		property String title;
		property Image icon;
		property Widget wrapper;
		property NSViewFrame frame;
	}

	embed {{{
		#import <AppKit/NSTabView.h>
		#import <AppKit/NSTabViewItem.h>
	}}}

	Collection pages;

	public ptr create_nsview() {
		ptr p;
		embed {{{
			NSTabView* tabview = [[NSTabView alloc] init];
			p = (__bridge_retained void*)tabview;
		}}}
		return(p);
	}

	public void cleanup() {
		base.cleanup();
		foreach(PageInfo pageinfo in pages) {
			var ww = pageinfo.get_widget();
			if(ww != null) {
				ww.set_event_handler(null);
			}
			var ff = pageinfo.get_frame();
			if(ff != null) {
				ff.destroy();
				pageinfo.set_frame(null);
			}
		}
	}

	public void initialize_nsview() {
		foreach(PageInfo pageinfo in pages) {
			add_page_view(pageinfo);
		}
	}

	public Widget get_shown_page() {
		// FIXME
		return(null);
	}

	public void add_page(Widget widget, String title = null, Image icon = null) {
		var pageinfo = new PageInfo();
		pageinfo.set_widget(widget);
		pageinfo.set_title(title);
		pageinfo.set_icon(icon);
		if(pages == null) {
			pages = LinkedList.create();
		}
		pages.add(pageinfo);
		add_page_view(pageinfo);
	}

	void add_page_view(PageInfo pageinfo) {
		var nsview = get_nsview();
		if(nsview == null || pageinfo == null) {
			return;
		}
		var title = pageinfo.get_title();
		if(title == null) {
			title = "Tab";
		}
		var ff = pageinfo.get_frame();
		if(ff == null) {
			var ww = pageinfo.get_widget();
			if(ww != null) {
				ww.set_event_handler(this);
			}
			var we = WidgetEngine.for_widget(ww);
			ff = NSViewFrame.create(we, get_frame());
			ff.set_destroy_when_removed(false);
		}
		var nsv = ff.get_nsview();
		var tptr = title.to_strptr();
		embed {{{
			NSTabViewItem* item = [[NSTabViewItem alloc] initWithIdentifier:@"xxx"];
			[item setLabel:[NSString stringWithUTF8String:tptr]];
			[item setView:(__bridge NSView*)nsv];
			[(__bridge NSTabView*)nsview addTabViewItem:item];
		}}}
	}

	public void remove_page(Widget widget) {
		// FIXME
	}

	public Iterator iterate_pages() {
		// FIXME
		return(null);
	}

	public Widget show_page_by_index(int n) {
		// FIXME
		return(null);
	}

	public Widget show_page(Widget widget) {
		// FIXME
		return(null);
	}

	public int get_page_count() {
		// FIXME
		return(0);
	}

	public void add_listener(TabbedViewControlListener listener) {
		// FIXME
	}

	public void remove_listener(TabbedViewControlListener listener) {
		// FIXME
	}
}
