
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

public class ButtonWidget : ButtonFrameWidget
{
	public static ButtonWidget instance() {
		return(new ButtonWidget());
	}

	public static ButtonWidget for_text(String text) {
		return(new ButtonWidget().set_text(text));
	}

	public static ButtonWidget for_string(String text) {
		return(new ButtonWidget().set_text(text));
	}

	public static ButtonWidget for_image(Image img) {
		return(new ButtonWidget().set_icon(img));
	}

	public static ButtonWidget for_icon(Image img) {
		return(new ButtonWidget().set_icon(img));
	}

	public static ButtonWidget for_widget(Widget widget) {
		return(new ButtonWidget().set_custom_display_widget(widget));
	}

	public static ButtonWidget for_action_item(ActionItem ai) {
		return((ButtonWidget)new ButtonWidget().set_action_item(ai));
	}

	public static int LEFT = 0;
	public static int CENTER = 1;
	public static int RIGHT = 2;

	String text;
	Image icon;
	Image left_icon;
	Image right_icon;
	Font font;
	Font pressed_font;
	bool symmetric_icons = true;
	bool square_icons = true;
	int text_align = CENTER;
	property String icon_size;
	LabelWidget wtext;
	ImageWidget wlicon;
	ImageWidget wricon;
	AlignWidget wicontext;
	Widget custom_display_widget;

	static Font default_font;
	static Font default_pressed_font;

	public ButtonWidget() {
		if(default_font == null) {
			default_font = Font.instance("color=white shadow-color=black");
		}
		if(default_pressed_font == null) {
			default_pressed_font = Font.instance("color=white shadow-color=none outline-color=%s".printf().add(Theme.get_highlight_color()).to_string());
		}
		font = default_font;
		pressed_font = default_pressed_font;
		icon_size = Theme.get_icon_size();
	}

	public ButtonWidget set_custom_display_widget(Widget w) {
		if(custom_display_widget != null) {
			var pp = custom_display_widget.get_parent() as ContainerWidget;
			if(pp != null) {
				pp.remove(custom_display_widget);
			}
		}
		custom_display_widget = w;
		if(w != null) {
			var il = get_internal_layer();
			if(il != null) {
				il.add(w);
			}
		}
		return(this);
	}

	public ButtonWidget set_text_align(int n) {
		if(text_align != n) {
			text_align = n;
			update_icontext();
		}
		return(this);
	}

	public int get_text_align() {
		return(text_align);
	}

	public ButtonWidget set_action_item(ActionItem ai) {
		if(ai == null) {
			set_text(null);
			set_icon(null);
			set_event(null);
			set_popup(null);
			set_action(null);
			set_popup(null);
			set_context_popup(null);
		}
		else {
			set_text(ai.get_text());
			set_icon(ai.get_icon());
			set_event(ai.get_event());
			set_popup(ai.get_data() as Widget);
			set_action(ai.get_action());
			var menu = ai.get_menu();
			if(menu != null) {
				set_popup(MenuWidget.for_menu(menu));
			}
			set_context_popup(ai.get_context() as Widget);
		}
		return(this);
	}

	public ButtonWidget configure_theme(String id) {
		set_color(Theme.color("%s.color".printf().add(id).to_string()));
		set_font(Theme.font("%s.font".printf().add(id).to_string()));
		set_pressed_font(Theme.font("%s.pressed_font".printf().add(id).to_string()));
		var im = Theme.string("%s.internal_margin".printf().add(id).to_string());
		if(String.is_empty(im) == false) {
			set_internal_margin(im);
		}
		var oc = Theme.color("%s.outline_color".printf().add(id).to_string());
		if(oc != null) {
			set_outline_color(oc);
			set_draw_outline(true);
		}
		var ow = Theme.string("%s.outline_width".printf().add(id).to_string());
		if(ow != null) {
			set_outline_width(ow);
		}
		return(this);
	}

	public ButtonWidget set_symmetric_icons(bool v) {
		symmetric_icons = v;
		update_icons();
		return(this);
	}

	public bool get_symmetric_icons() {
		return(symmetric_icons);
	}

	public ButtonWidget set_square_icons(bool v) {
		square_icons = v;
		update_icons();
		return(this);
	}

	public bool get_square_icons() {
		return(square_icons);
	}

	public void initialize_button(LayerWidget lw) {
		var hb = HBoxWidget.instance();
		hb.set_spacing(px("1mm"));
		hb.add(wlicon = ImageWidget.for_image(left_icon).set_mode("fit"));
		hb.add_hbox(1, wicontext = AlignWidget.instance());
		update_icontext();
		hb.add(wricon = ImageWidget.for_image(right_icon).set_mode("fit"));
		lw.add(hb);
		if(custom_display_widget != null) {
			lw.add(custom_display_widget);
		}
	}

	public void initialize() {
		base.initialize();
		update_icons();
	}

	public void cleanup() {
		base.cleanup();
		wlicon = null;
		wtext = null;
		wricon = null;
		wicontext = null;
	}

	int iconwidthpx(int x) {
		if(square_icons) {
			return(x);
		}
		return(-1);
	}

	void update_icontext() {
		if(wicontext == null) {
			return;
		}
		wicontext.remove_children();
		var hb = HBoxWidget.instance();
		hb.set_spacing(px("1mm"));
		var fmm = px(icon_size);
		if(icon != null) {
			var wicon = ImageWidget.for_image(icon).set_mode("fit");
			wicon.set_image_size(iconwidthpx(fmm), fmm);
			hb.add(wicon);
		}
		if(String.is_empty(text) == false) {
			wtext = LabelWidget.for_string(text);
			wtext.set_font(font);
			wtext.set_minimum_height_request(fmm);
			hb.add(wtext);
		}
		if(text_align == ButtonWidget.LEFT) {
			wicontext.add_align(-1, 0, hb);
		}
		else if(text_align == ButtonWidget.RIGHT) {
			wicontext.add_align(1, 0, hb);
		}
		else {
			wicontext.add(hb);
		}
		on_changed();
	}

	public void on_changed() {
		base.on_changed();
		if(wtext != null) {
			if(get_pressed()) {
				wtext.set_font(pressed_font);
			}
			else {
				wtext.set_font(font);
			}
		}
	}

	public void update_icons() {
		if(wlicon == null || wricon == null) {
			return;
		}
		var fmm = px(icon_size);
		if(symmetric_icons == false) {
			if(right_icon != null) {
				wricon.set_size_request_override(iconwidthpx(fmm), fmm);
			}
			else {
				wricon.set_size_request_override(0, 0);
			}
			if(left_icon != null) {
				wlicon.set_size_request_override(iconwidthpx(fmm), fmm);
			}
			else {
				wlicon.set_size_request_override(0, 0);
			}
		}
		else {
			if(left_icon != null || right_icon != null) {
				wlicon.set_size_request_override(iconwidthpx(fmm), fmm);
				wricon.set_size_request_override(iconwidthpx(fmm), fmm);
			}
			else {
				wlicon.set_size_request_override(0, 0);
				wricon.set_size_request_override(0, 0);
			}
		}
	}

	public ButtonWidget set_font(Font font) {
		this.font = font;
		this.pressed_font = font;
		on_changed();
		return(this);
	}

	public Font get_font() {
		return(font);
	}

	public ButtonWidget set_pressed_font(Font font) {
		this.pressed_font = font;
		on_changed();
		return(this);
	}

	public Font get_pressed_font() {
		return(pressed_font);
	}

	public ButtonWidget set_left_icon(Image icon) {
		this.left_icon = icon;
		if(wlicon != null) {
			wlicon.set_image(icon);
			update_icons();
		}
		return(this);
	}

	public Image get_left_icon() {
		return(left_icon);
	}

	public ButtonWidget set_right_icon(Image icon) {
		this.right_icon = icon;
		if(wricon != null) {
			wricon.set_image(icon);
			update_icons();
		}
		return(this);
	}

	public Image get_right_icon() {
		return(right_icon);
	}

	public ButtonWidget set_icon(Image icon) {
		this.icon = icon;
		update_icontext();
		return(this);
	}

	public Image get_icon() {
		return(icon);
	}

	public ButtonWidget set_text(String text) {
		this.text = text;
		update_icontext();
		return(this);
	}

	public String get_text() {
		return(text);
	}
}
