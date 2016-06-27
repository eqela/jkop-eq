
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

public class ListItemWidget : ClickWidget
{
	property ActionItem item;
	property bool show_desc = true;
	property bool show_icon = true;
	property Font text_font;
	property Font title_font;
	property Font desc_font;
	property bool rounded = false;
	property String icon_size;
	property String icon_margin;
	property Color kb_hover_outline_color;
	property Color hover_background_color;
	property Color hover_outline_color;
	property Color pressed_color;
	property Color focus_color;
	CanvasWidget bg;
	bool kb_hover = false;

	public bool is_focusable() {
		return(false);
	}

	public virtual Widget create_view_widget() {
		var hb = HBoxWidget.instance();
		hb.set_margin(px("1mm"));
		hb.set_spacing(px("1mm"));
		Image icon;
		String text;
		String desc;
		if(item != null) {
			icon = item.get_icon();
			text = item.get_text();
			desc = item.get_desc();
		}
		var iconsize = Theme.get_icon_size();
		if(icon_size != null) {
			iconsize = icon_size;
		}
		if(iconsize == null) {
			iconsize = "5mm";
		}
		var iconmargin = icon_margin;
		if(iconmargin == null) {
			iconmargin = "1mm";
		}
		if(show_desc) {
			if(show_icon) {
				var sz = px(iconsize) + px(iconmargin) * 2;
				var px_str = "%spx".printf().add(sz).to_string();
				if(icon != null) {
					hb.add(AlignWidget.instance().add_align(0, -1, ImageWidget.for_image(icon).set_mode("fit").set_size_request_override(sz, sz)));
				}
			}
			hb.add_hbox(1, AlignWidget.instance().add_align(-1, 0, VBoxWidget.instance()
				.add(LabelWidget.for_string(text).set_text_align(LabelWidget.LEFT).set_font(title_font))
				.add(LabelWidget.for_string(desc).set_text_align(LabelWidget.LEFT).set_font(desc_font))
			));
		}
		else {
			if(show_icon) {
				var sz = px(iconsize);
				if(icon != null) {
					hb.add(ImageWidget.for_image(icon).set_mode("fit").set_size_request_override(sz, sz));
				}
			}
			hb.add_hbox(1, LabelWidget.for_string(text).set_text_align(LabelWidget.LEFT).set_font(text_font));
		}
		return(hb);
	}

	public void initialize() {
		base.initialize();
		add(bg = CanvasWidget.instance().set_rounded(rounded));
		var ww = create_view_widget();
		if(ww != null) {
			add(ww);
		}
		on_changed();
	}

	public void cleanup() {
		base.cleanup();
		bg = null;
	}

	public void on_changed() {
		if(bg == null) {
			return;
		}
		if(kb_hover) {
			bg.set_outline_color(kb_hover_outline_color);
		}
		else {
			bg.set_outline_color(null);
		}
		if(get_pressed() || (item != null && item.get_selected())) {
			bg.set_color_gradient(pressed_color);
		}
		else if(kb_hover) {
			bg.set_outline_color(kb_hover_outline_color);
			bg.set_color_gradient(hover_background_color);
		}
		else if(get_hover()) {
			bg.set_color_gradient(hover_background_color);
			bg.set_outline_color(hover_outline_color);
		}
		else if(get_focus()) {
			bg.set_color_gradient(focus_color);
		}
		else if(bg.get_surface() != null) {
			bg.set_color(Color.instance("#00000000"));
			bg.set_color2(Color.instance("#00000000"));
		}
		else {
			bg.set_color(null);
			bg.set_outline_color(null);
		}
	}

	public void set_kb_hover(bool v) {
		kb_hover = v;
		on_changed();
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

	public void on_clicked() {
		var lw = ListSelectorWidget.find_list_widget(this);
		if(lw != null) {
			lw.on_item_clicked(this);
		}
	}

	public bool on_context(int x, int y) {
		var lw = ListSelectorWidget.find_list_widget(this);
		if(lw != null) {
			lw.on_item_context(this);
		}
		return(true);
	}
}
