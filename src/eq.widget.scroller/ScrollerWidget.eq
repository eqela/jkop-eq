
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

public class ScrollerWidget : LayerWidget, ScrollerControl
{
	public static ScrollerWidget find(Widget w) {
		var ww = w;
		while(ww != null) {
			if(ww is ScrollerWidget) {
				return((ScrollerWidget)ww);
			}
			ww = ww.get_parent() as Widget;
		}
		return(null);
	}

	public static ScrollerWidget instance() {
		return(new ScrollerWidget());
	}

	public static ScrollerWidget for_widget(Widget widget) {
		var v = new ScrollerWidget();
		v.add_scroller(widget);
		return(v);
	}

	public static ScrollerWidget vertical() {
		return(new ScrollerWidget().set_vertical(true).set_horizontal(false));
	}

	public static ScrollerWidget horizontal() {
		return(new ScrollerWidget().set_vertical(false).set_horizontal(true));
	}

	ScrollerContainerWidget container;
	ScrollBarWidget sb_vertical;
	ScrollBarWidget sb_horizontal;
	property bool scrollbar = true;

	public ScrollerWidget() {
		container = new ScrollerContainerWidget();
	}

	public ScrollerContainerWidget get_container() {
		return(container);
	}

	public ScrollerWidget set_enable_keyboard_control(bool v) {
		if(container != null) {
			container.set_enable_keyboard_control(v);
		}
		return(this);
	}

	public ScrollerWidget set_vertical(bool v) {
		if(container != null) {
			container.set_vertical(v);
		}
		return(this);
	}

	public ScrollerWidget set_horizontal(bool v) {
		if(container != null) {
			container.set_horizontal(v);
		}
		return(this);
	}

	public bool is_at_bottom() {
		if(container == null) {
			return(false);
		}
		return(container.is_at_bottom());
	}

	public void scroll_to_bottom() {
		if(container != null) {
			container.scroll_to_bottom();
		}
	}

	public void scroll_to_top() {
		if(container != null) {
			container.scroll_to_top();
		}
	}

	public void on_changed(int cx, int cy, int scrollerw, int scrollerh, int totalw, int totalh) {
		if(sb_vertical != null) {
			sb_vertical.update(cy, scrollerh, totalh);
		}
		if(sb_horizontal != null) {
			sb_horizontal.update(cx, scrollerw, totalw);
		}
	}

	public ContainerWidget add(Widget child) {
		return(add_scroller(child));
	}

	public void initialize() {
		base.initialize();
		if(container == null) {
			return;
		}
		// reference the container so that if it gets deleted while being added,
		// it still won't end up getting deleted (yes, this has happened).
		var cc = container;
		base.add(cc);
		if(scrollbar) {
			if(cc.get_vertical()) {
				base.add(AlignWidget.instance().set_margin(px("500um")).set_maximize_height(true).add_align(1, 0, sb_vertical = new ScrollBarWidget().set_horizontal(false)));
			}
			if(cc.get_horizontal()) {
				base.add(AlignWidget.instance().set_margin(px("500um")).set_maximize_width(true).add_align(0, 1, sb_horizontal = new ScrollBarWidget().set_horizontal(true)));
			}
		}
	}

	public void cleanup() {
		base.cleanup();
		var oc = container;
		container = new ScrollerContainerWidget();
		container.copy_settings_from(oc);
		sb_vertical = null;
		sb_horizontal = null;
	}

	public ScrollerWidget add_scroller(Widget w) {
		if(container != null) {
			container.add(w);
		}
		return(this);
	}
}
