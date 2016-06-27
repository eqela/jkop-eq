
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

public class GridSelectorItemWidget : ClickWidget
{
	property ActionItem item;
	property Color hover_background_color;
	property Color pressed_color;
	property Color focus_color;
	CanvasWidget bg;

	public void initialize() {
		base.initialize();
		var ww = create_view_widget();
		if(ww != null) {
			add(ww);
		}
		add(bg = CanvasWidget.instance().set_rounded(true));
		on_changed();
	}

	public virtual Widget create_view_widget() {
		var isz = px(Theme.get_icon_size());
		var mm1 = px("1mm");
		set_width_request_override(isz*6);
		if(item == null) {
			return(null);
		}
		var ww = BoxWidget.vertical();
		ww.set_margin(mm1);
		ww.set_spacing(mm1);
		ww.add_box(0, AlignWidget.instance().add(
			ImageWidget.for_image(item.get_icon()).set_image_size(isz*3, isz*3).set_size_request_override(isz*3, isz*3))
		);
		ww.add_box(0, LabelWidget.for_string(item.get_text()).set_wrap(true));
		return(ww);
	}

	public void on_changed() {
		if(bg == null) {
			return;
		}
		if(get_pressed() || (item != null && item.get_selected())) {
			bg.set_color_gradient(pressed_color);
		}
		else if(get_hover()) {
			bg.set_color(hover_background_color);
		}
		else if(get_focus()) {
			bg.set_color_gradient(focus_color);
		}
		else {
			bg.set_color(null);
		}
	}

	public bool get_selected() {
		if(item == null) {
			return(false);
		}
		return(item.get_selected());
	}

	public void set_selected(bool v) {
		if(item != null) {
			item.set_selected(v);
			on_changed();
		}
	}

	public void cleanup() {
		base.cleanup();
	}

	public void on_clicked() {
		var gs = GridSelectorWidget.find_grid_widget(this);
		if(gs != null) {
			gs.on_item_clicked(this);
		}
	}

}
