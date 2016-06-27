
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

public class DefaultNavigationBarWidget : LayerWidget, NavigationBarWidget
{
	LabelWidget label;
	ButtonWidget back;
	ButtonWidget forward;
	property Color background_color;
	property Font title_font;
	int backwidth;

	public DefaultNavigationBarWidget() {
		background_color = Theme.color("eq.widget.navigation.DefaultNavigationBarWidget.background_color", "#00000040");
		title_font = Theme.font("eq.widget.navigation.DefaultNavigationBarWidget.title_font", "3mm bold color=white");
	}

	class MyButtonWidget : ButtonWidget
	{
		public MyButtonWidget() {
			set_icon_size("4mm");
			set_font(Theme.font().modify("2350um color=white"));
			set_pressed_font(Theme.font().modify("2350um color=white"));
			set_pressed_color(Color.instance("#00000080"));
			set_draw_outline(false);
			set_color(Color.instance("#00000040"));
			set_internal_margin("1mm");
		}
	}

	public void initialize() {
		base.initialize();
		if(background_color != null) {
			add(CanvasWidget.for_color(background_color));
		}
		add(BoxWidget.horizontal().set_spacing(px("1mm")).set_margin(px("500um"))
			.add_box(0, back = (ButtonWidget)new MyButtonWidget().set_text("Back")
				.set_icon(IconCache.get("navigation_back"))
				.set_event("back"))
			.add_box(1, new Widget())
			.add_box(0, forward = (ButtonWidget)new MyButtonWidget())
		);
		backwidth = back.get_width_request();
		forward.set_width_request_override(backwidth);
		forward.set_enabled(false);
		back.set_enabled(false);
		add(LayerWidget.instance().set_margin(px("1mm")).add(label = LabelWidget.instance().set_font(title_font)).set_height_request_override(px("7mm")));
	}

	public void cleanup() {
		base.cleanup();
		label = null;
		back = null;
		forward = null;
	}

	public void set_right_button(ActionItem actionitem) {
		if(forward == null) {
			return;
		}
		forward.set_action_item(actionitem);
		if(actionitem == null) {
			forward.set_enabled(false);
		}
		else {
			forward.set_enabled(true);
		}
	}

	public void on_resize() {
		base.on_resize();
		if(label != null) {
			var labelwidth = get_width() - backwidth*2 - px("1mm")*4;
			if(labelwidth < px("10mm")) {
				label.set_enabled(false);
			}
			else {
				label.set_width_request_override(labelwidth);
				label.set_enabled(true);
			}
		}
	}

	public void set_back_button_label(String label) {
		if(back == null) {
			return;
		}
		if(label == null) {
			back.set_text("Back");
		}
		else {
			back.set_text(label);
		}
	}

	public void set_title(String text) {
		if(label != null) {
			label.set_text(text);
		}
	}

	public void set_title_align(int align) {
		if(label != null) {
			label.set_text_align(align);
		}
	}

	public void set_navigation_bar_enabled(bool v) {
		set_enabled(v);
	}

	public void set_back_button_enabled(bool v) {
		if(back != null) {
			back.set_enabled(v);
		}
	}
}
