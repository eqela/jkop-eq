
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

public class TabbedViewControlWidget : LayerWidget, TabbedViewControl
{
	class MyTabViewWidget : TabViewWidget
	{
		Collection listeners;

		public MyTabViewWidget() {
			listeners = LinkedList.create();
		}

		public void on_current_changed() {
			base.on_current_changed();
			foreach(TabbedViewControlListener ll in listeners) {
				ll.on_tab_page_shown(get_selected_widget());
			}
		}

		public void on_tab_added(Widget widget) {
			base.on_tab_added(widget);
			foreach(TabbedViewControlListener ll in listeners) {
				ll.on_tab_page_added(widget);
			}
		}

		public void on_tab_removed(Widget widget) {
			base.on_tab_removed(widget);
			foreach(TabbedViewControlListener ll in listeners) {
				ll.on_tab_page_removed(widget);
			}
		}

		public void add_listener(TabbedViewControlListener listener) {
			if(listener != null) {
				listeners.add(listener);
			}
		}

		public void remove_listener(TabbedViewControlListener listener) {
			if(listener != null) {
				listeners.remove(listener);
			}
		}
	}

	MyTabViewWidget tabview;

	public TabbedViewControlWidget() {
		tabview = new MyTabViewWidget();
	}

	public void initialize() {
		base.initialize();
		add(tabview);
	}

	public void cleanup() {
		base.cleanup();
	}

	public Widget get_shown_page() {
		return(tabview.get_selected_widget());
	}

	public void add_page(Widget widget, String title, Image icon) {
		tabview.add_tab(widget, title, icon, false);
	}

	public void remove_page(Widget widget) {
		tabview.remove_tab(widget);
	}

	public Iterator iterate_pages() {
		return(tabview.iterate_tabs());
	}

	public Widget show_page_by_index(int index) {
		var it = iterate_pages();
		int n = 0;
		while(it != null) {
			var w = it.next() as Widget;
			if(w == null) {
				break;
			}
			if(n == index) {
				return(show_page(w));
			}
			n++;
		}
		return(null);
	}

	public Widget show_page(Widget widget) {
		tabview.select_tab(widget);
		return(widget);
	}

	public int get_page_count() {
		return(tabview.count_tabs());
	}

	public void add_listener(TabbedViewControlListener listener) {
		tabview.add_listener(listener);
	}

	public void remove_listener(TabbedViewControlListener listener) {
		tabview.remove_listener(listener);
	}
}
