
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

public class WindowFrameWidget : LayerWidget, TitledFrame
{
	public static WindowFrameWidget find(Widget w) {
		var c = w;
		while(c != null) {
			if(c is WindowFrameWidget) {
				return((WindowFrameWidget)c);
			}
			c = c.get_parent() as Widget;
		}
		return(null);
	}

	Image icon;
	String title;
	LabelWidget title_label;
	ImageWidget iconwidget;
	CanvasWidget bgcanvas;
	Widget main_widget;
	Widget header_widget;
	LayerWidget title_layer;
	LayerWidget main_layer;
	ShadowContainerWidget shadow;
	CanvasWidget main_canvas;
	LayerWidget content_layer;
	property bool visible_frame = true;
	ButtonWidget close_button;
	bool closable = true;

	property bool enable_titlebar = true;
	property String shadow_thickness;
	String minimum_content_height;
	property String box_spacing;
	property Color title_background_color;
	property String title_margin;
	property Font title_font;
	property String title_align;
	property Color text_color;
	property String content_margin;
	property String content_margin_maximized;
	property Color outline_color;
	property String outline_width;
	property bool background_gradient;
	property Color background_color;
	property bool rounded = false;
	property bool rounded_maximized = false;
	property bool background_enabled_maximized = true;
	property String main_margin;
	property Color main_background_color;

	public WindowFrameWidget() {
		title_font = Theme.font("eq.widget.windowframe.WindowFrameWidget.title_font", "bold 133%% color=white outline-color=%s"
			.printf().add(Theme.get_highlight_color()).to_string());
		shadow_thickness = Theme.string("eq.widget.windowframe.WindowFrameWidget.shadow_thickness", "0mm");
		box_spacing = Theme.string("eq.widget.windowframe.WindowFrameWidget.box_spacing", "1mm");
		title_background_color = Theme.color("eq.widget.windowframe.WindowFrameWidget.title_background_color", "none");
		title_margin = Theme.string("eq.widget.windowframe.WindowFrameWidget.title_margin", "0mm");
		title_align = Theme.string("eq.widget.windowframe.WindowFrameWidget.title_align", "left");
		text_color = Theme.color("eq.widget.windowframe.WindowFrameWidget.text_color", "black");
		content_margin = Theme.string("eq.widget.windowframe.WindowFrameWidget.content_margin", "1mm");
		content_margin_maximized = Theme.string("eq.widget.windowframe.WindowFrameWidget.content_margin_maximized", "0mm");
		outline_color = Theme.color("eq.widget.windowframe.WindowFrameWidget.outline_color", "none");
		outline_width = Theme.string("eq.widget.windowframe.WindowFrameWidget.outline_width", "0px");
		background_gradient = Theme.boolean("eq.widget.windowframe.WindowFrameWidget.background_gradient", "false");
		background_color = Theme.color("eq.widget.windowframe.WindowFrameWidget.background_color", "#000000");
		rounded = Theme.boolean("eq.widget.windowframe.WindowFrameWidget.rounded", "false");
		rounded_maximized = Theme.boolean("eq.widget.windowframe.WindowFrameWidget.rounded_maximized", "false");
		background_enabled_maximized = Theme.boolean("eq.widget.windowframe.WindowFrameWidget.background_enabled_maximized", "false");
		main_margin = Theme.string("eq.widget.windowframe.WindowFrameWidget.main_margin", "1mm");
		main_background_color = Theme.color("eq.widget.windowframe.WindowFrameWidget.main_background_color", "#CCCCCC");
	}

	public WindowFrameWidget set_closable(bool v) {
		closable = v;
		update_close_button();
		return(this);
	}

	public bool get_closable() {
		return(closable);
	}

	public void set_minimum_content_height(String ch) {
		minimum_content_height = ch;
		update_minimum_content_height();
	}

	public String get_minimum_content_height() {
		return(minimum_content_height);
	}

	void update_minimum_content_height() {
		var main_layer = get_main_layer();
		if(main_layer != null) {
			if(minimum_content_height == null) {
				main_layer.set_minimum_height_request(-1);
			}
			else {
				main_layer.set_minimum_height_request(px(minimum_content_height));
			}
		}
	}

	public Widget get_main_widget() {
		return(main_widget);
	}

	public WindowFrameWidget set_main_widget(Widget widget) {
		main_widget = widget;
		if(main_layer != null) {
			main_layer.remove_children();
			if(widget != null) {
				main_layer.add(widget);
			}
		}
		return(this);
	}

	public LayerWidget get_main_layer() {
		return(main_layer);
	}

	public Image get_icon() {
		return(icon);
	}

	public String get_title() {
		return(title);
	}

	public virtual void on_icon_changed() {
		if(iconwidget != null) {
			iconwidget.set_image(icon);
		}
	}

	public void set_icon(Image icon) {
		this.icon = icon;
		on_icon_changed();
	}

	void update_title_layer() {
		if(title_layer == null || main_layer == null) {
		}
		else if(enable_titlebar && visible_frame && maximized_mode == false) {
			title_layer.set_enabled(true);
		}
		else {
			title_layer.set_enabled(false);
		}
	}

	public virtual void on_title_changed() {
		if(title_label != null) {
			title_label.set_text(title);
		}
	}

	public void set_title(String name) {
		this.title = name;
		on_title_changed();
	}

	void update_close_button() {
		if(close_button == null) {
			return;
		}
		close_button.set_enabled(closable);
	}

	public void initialize() {
		base.initialize();

		var box = BoxWidget.vertical();
		box.set_spacing(px(box_spacing));

		var cic = IconCache.get("close_window");
		String ctx;
		if(cic == null) {
			ctx = "Close";
		}
		var fmm = px("5mm");
		title_layer = LayerWidget.instance();
		title_layer.add(CanvasWidget.for_color(title_background_color).set_rounded(rounded));
		var hdr = HBoxWidget.instance().set_spacing(px("1mm")).set_margin(px(title_margin));
		hdr.add_hbox(0, iconwidget = ImageWidget.for_image(icon).set_mode("fit").set_image_size(fmm, fmm));
		hdr.add_hbox(1, title_label = LabelWidget.for_string(title).set_font(title_font)
			.set_wrap(false).set_text_align(LabelWidget.LEFT));
		hdr.add_hbox(0, HBoxWidget.instance()
			.add(close_button = (ButtonWidget)ButtonWidget.for_string(ctx).set_icon(cic).set_draw_frame(false).set_draw_outline(false)
				.set_rounded(false).set_color(Theme.get_base_color().set_a(0.75)).set_internal_margin("500um")
				.set_event(new WindowFrameCloseEvent().set_widget(this)))
		);
		update_close_button();
		title_layer.add(header_widget = hdr);
		if("left".equals(title_align)) {
			title_label.set_text_align(LabelWidget.LEFT);
		}
		else if("right".equals(title_align)) {
			title_label.set_text_align(LabelWidget.RIGHT);
		}
		else {
			title_label.set_text_align(LabelWidget.CENTER);
		}
		box.add(title_layer);
		update_title_layer();
		on_icon_changed();
		on_title_changed();

		main_layer = LayerWidget.instance();
		main_layer.set_margin(px(main_margin));
		box.add_box(1, LayerWidget.instance()
			.add(main_canvas = CanvasWidget.for_color(main_background_color).set_rounded(rounded))
			.add(main_layer));
		if(main_widget != null) {
			main_layer.add(main_widget);
		}
		update_minimum_content_height();

		set_draw_color(text_color);
		var layer = LayerWidget.instance();
		if(background_gradient) {
			bgcanvas = CanvasWidget.for_color_gradient(background_color);
		}
		else {
			bgcanvas = CanvasWidget.for_color(background_color);
		}
		bgcanvas.set_rounded(rounded);
		bgcanvas.set_outline_color(outline_color);
		bgcanvas.set_outline_width(outline_width);
		layer.add(bgcanvas);
		layer.add(content_layer = (LayerWidget)new LayerWidget()
			.set_margin(px(content_margin))
			.add(box)
		);
		add(shadow = ShadowContainerWidget.for_widget(layer).set_shadow_thickness(shadow_thickness));
		if(visible_frame == false) {
			remove_visible_frame();
		}
	}

	public void remove_visible_frame() {
		set_background_color(null);
		set_main_background_color(null);
		set_text_color(null);
		set_outline_color(null);
		set_outline_width("0px");
		set_main_margin("0px");
		set_content_margin("0px");
		set_content_margin_maximized("0px");
		if(title_layer != null) {
			title_layer.set_enabled(false);
		}
		set_shadow_thickness("0px");
		on_properties_changed();
	}

	public void on_properties_changed() {
		set_draw_color(text_color);
		if(bgcanvas != null) {
			bgcanvas.set_color(background_color);
			bgcanvas.set_rounded(rounded);
			bgcanvas.set_outline_color(outline_color);
			bgcanvas.set_outline_width(outline_width);
		}
		if(main_canvas != null) {
			main_canvas.set_color(main_background_color);
		}
		if(shadow != null) {
			shadow.set_shadow_thickness(shadow_thickness);
		}
		if(content_layer != null) {
			if(maximized_mode) {
				content_layer.set_margin(px(content_margin_maximized));
			}
			else {
				content_layer.set_margin(px(content_margin));
			}
		}
		if(main_layer != null) {
			main_layer.set_margin(px(main_margin));
		}
	}

	public void cleanup() {
		base.cleanup();
		bgcanvas = null;
		header_widget = null;
		iconwidget = null;
		title_label = null;
		title_layer = null;
		shadow = null;
		main_layer = null;
		main_canvas = null;
		content_layer = null;
		close_button = null;
	}

	bool maximized_mode = false;

	public bool get_maximized_mode() {
		return(maximized_mode);
	}

	public void on_maximized_mode_changed() {
		if(maximized_mode) {
			var wr = get_width_request();
			var hr = get_height_request();
			set_size_request_override(wr, hr);
			if(content_layer != null) {
				content_layer.set_margin(px(content_margin_maximized));
			}
			if(main_canvas != null) {
				main_canvas.set_rounded(rounded_maximized);
			}
			if(bgcanvas != null) {
				bgcanvas.set_rounded(false);
				bgcanvas.set_outline_color(null);
				bgcanvas.set_outline_width("0mm");
				bgcanvas.set_enabled(background_enabled_maximized);
			}
			if(shadow != null) {
				shadow.set_shadow_thickness("0mm");
			}
		}
		else {
			set_size_request_override(-1, -1);
			if(content_layer != null) {
				content_layer.set_margin(px(content_margin));
			}
			if(main_canvas != null) {
				main_canvas.set_rounded(rounded);
			}
			if(bgcanvas != null) {
				bgcanvas.set_rounded(rounded);
				bgcanvas.set_outline_color(outline_color);
				bgcanvas.set_outline_width(outline_width);
				bgcanvas.set_enabled(true);
			}
			if(shadow != null) {
				shadow.set_shadow_thickness(shadow_thickness);
			}
		}
		update_title_layer();
	}

	public void set_maximized_mode(bool v) {
		if(v == maximized_mode) {
			return;
		}
		maximized_mode = v;
		on_maximized_mode_changed();
	}
}
