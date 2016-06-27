
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

public class ExpanderWidget : VBoxWidget, EventReceiver
{
	property Widget widget;
	property String label;
	property bool is_expander_focusable = true;
	Widget content;
	ButtonWidget button;
	bool shown = true;

	public ExpanderWidget() {
		label = "Widget";
	}

	public virtual Widget get_content_widget() {
		return(widget);
	}

	public void initialize() {
		base.initialize();
		set_spacing(px("1mm"));
		var bb = FramelessButtonWidget.for_widget(SmallArrowIcon.down());
		bb.set_focusable(is_expander_focusable);
		bb.set_internal_margin("150um");
		bb.set_icon_size("2500um");
		bb.set_event("toggle");
		button = bb;
		add(BoxWidget.horizontal()
			.set_spacing(px("1mm"))
			.add_box(0, bb)
			.add_box(1, LabelWidget.for_string(label).set_text_align(LabelWidget.LEFT).set_color(Color.black()))
		);
		var cc = get_content_widget();
		if(cc != null) {
			add_box(1, cc);
			content = cc;
		}
		if(shown) {
			show();
		}
		else {
			hide();
		}
	}

	public void cleanup() {
		base.cleanup();
		content = null;
		button = null;
	}

	public void show() {
		if(content != null) {
			content.set_enabled(true);
		}
		if(button != null) {
			button.set_custom_display_widget(SmallArrowIcon.down());
		}
		shown = true;
	}

	public void hide() {
		if(content != null) {
			content.set_enabled(false);
		}
		if(button != null) {
			button.set_custom_display_widget(SmallArrowIcon.right());
		}
		shown = false;
	}

	public void toggle() {
		if(content != null) {
			if(content.is_enabled()) {
				hide();
			}
			else {
				show();
			}
		}
	}

	public void on_event(Object o) {
		if("toggle".equals(o)) {
			toggle();
			return;
		}
		forward_event(o);
	}
}
