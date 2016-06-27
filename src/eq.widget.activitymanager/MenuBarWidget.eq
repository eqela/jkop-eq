
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

public class MenuBarWidget : LayerWidget
{
	BoxWidget hboxleft;
	BoxWidget hboxright;
	Collection leftwidgets;
	Collection rightwidgets;

	public void initialize() {
		base.initialize();
		var c1 = Theme.color("eq.widget.activitymanager.MenuBarWidget.color1", "#FFFFFF80");
		var c2 = Theme.color("eq.widget.activitymanager.MenuBarWidget.color1", "#77777780");
		add(CanvasWidget.for_colors(c1, c2));
		var hbox = HBoxWidget.instance().set_spacing(0);
		hbox.add_hbox(1, hboxleft = HBoxWidget.instance().set_spacing(0));
		hbox.add_hbox(0, hboxright = HBoxWidget.instance().set_spacing(0));
		add(hbox);
		foreach(Widget widget in leftwidgets) {
			hboxleft.add(widget);
		}
		foreach(Widget widget in rightwidgets) {
			hboxright.add(widget);
		}
		leftwidgets = null;
		rightwidgets = null;
	}

	public void cleanup() {
		base.cleanup();
		hboxleft = null;
		hboxright = null;
	}

	public MenuBarWidget add_widget(Widget widget, bool right = false) {
		if(widget == null) {
			return(this);
		}
		if(right) {
			if(hboxright == null) {
				if(rightwidgets == null) {
					rightwidgets = LinkedList.create();
				}
				rightwidgets.add(widget);
			}
			else {
				hboxright.add(widget);
			}
		}
		else {
			if(hboxleft == null) {
				if(leftwidgets == null) {
					leftwidgets = LinkedList.create();
				}
				leftwidgets.add(widget);
			}
			else {
				hboxleft.add(widget);
			}
		}
		return(this);
	}
}
