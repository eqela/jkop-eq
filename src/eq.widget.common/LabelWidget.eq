
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

public class LabelWidget : Widget
{
	public static int LEFT = 0;
	public static int CENTER = 1;
	public static int RIGHT = 2;
	public static int JUSTIFY = 3;

	public static LabelWidget instance() {
		return(new LabelWidget());
	}

	public static LabelWidget for_text(String str) {
		return(new LabelWidget().set_text(str));
	}

	public static LabelWidget for_string(String str) {
		return(new LabelWidget().set_text(str));
	}

	String text;
	int text_align = 1;
	Font font;
	bool font_auto_size = false;
	bool font_auto_shrink = false;
	bool wrap = false;
	Color color;
	Color outline_color;
	Color shadow_color;

	public LabelWidget scale_font(double f) {
		if(font == null) {
			font = Theme.font();
		}
		if(font != null) {
			font.set_scale_factor(f);
		}
		return(this);
	}

	public LabelWidget modify_font(String fd) {
		if(font == null) {
			font = Theme.font();
		}
		if(font != null) {
			font = font.modify(fd);
		}
		return(this);
	}

	public LabelWidget set_text(String text) {
		if(text == null) {
			this.text = null;
		}
		else {
			this.text = text.strip();
		}
		ltext = null;
		lshadow = null;
		if(is_initialized()) {
			do_update_layouts();
			update_view();
		}
		return(this);
	}

	public String get_text() {
		return(text);
	}

	public LabelWidget set_text_align(int n) {
		this.text_align = n;
		ltext = null;
		lshadow = null;
		if(is_initialized()) {
			do_update_layouts();
			update_view();
		}
		return(this);
	}

	public int get_text_align() {
		return(text_align);
	}

	public LabelWidget set_font(Font f) {
		font = f;
		ltext = null;
		lshadow = null;
		if(is_initialized()) {
			do_update_layouts();
			update_view();
		}
		return(this);
	}

	public Font get_font() {
		return(font);
	}

	public LabelWidget set_color(Color color) {
		this.color = color;
		ltext = null;
		lshadow = null;
		if(is_initialized()) {
			do_update_layouts();
			update_view();
		}
		return(this);
	}

	public Color get_color() {
		return(color);
	}

	public LabelWidget set_outline_color(Color color) {
		this.outline_color = color;
		ltext = null;
		lshadow = null;
		if(is_initialized()) {
			do_update_layouts();
			update_view();
		}
		return(this);
	}

	public Color get_outline_color() {
		return(outline_color);
	}

	public LabelWidget set_shadow_color(Color color) {
		this.shadow_color = color;
		ltext = null;
		lshadow = null;
		if(is_initialized()) {
			do_update_layouts();
			update_view();
		}
		return(this);
	}

	public Color get_shadow_color() {
		return(shadow_color);
	}

	public LabelWidget set_font_auto_size(bool asz) {
		font_auto_size = asz;
		ltext = null;
		lshadow = null;
		if(is_initialized()) {
			do_update_layouts();
			update_view();
		}
		return(this);
	}

	public bool get_font_auto_size() {
		return(font_auto_size);
	}

	public LabelWidget set_font_auto_shrink(bool asz) {
		font_auto_shrink = asz;
		ltext = null;
		lshadow = null;
		if(is_initialized()) {
			do_update_layouts();
			update_view();
		}
		return(this);
	}

	public bool get_font_auto_shrink() {
		return(font_auto_shrink);
	}

	public LabelWidget set_wrap(bool v) {
		wrap = v;
		ltext = null;
		lshadow = null;
		if(is_initialized()) {
			do_update_layouts();
			update_view();
		}
		return(this);
	}

	public bool get_wrap() {
		return(wrap);
	}

	TextLayout ltext;
	TextLayout lshadow;

	int available_width = -1;
	int available_height = -1;

	public void do_update_layouts(Font force_font = null) {
		if(String.is_empty(text)) {
			ltext = null;
			lshadow = null;
			set_size_request(0, 0);
			return;
		}
		var font = force_font;
		if(font == null) {
			font = this.font;
		}
		if(font == null) {
			font = Theme.font();
		}
		var color = this.color;
		if(color == null) {
			color = font.get_color();
		}
		if(color == null) {
			color = get_draw_color();
		}
		var outline_color = this.outline_color;
		if(outline_color == null) {
			outline_color = font.get_outline_color();
		}
		var shadow_color = this.shadow_color;
		if(shadow_color == null) {
			shadow_color = font.get_shadow_color();
		}
		if(font_auto_size) {
			font.set_size("%dpx".printf().add(Primitive.for_integer(get_height())).to_string());
		}
		int shadow_x = 1;
		int shadow_y = 1;
		if(shadow_color == null) {
			shadow_x = 0;
			shadow_y = 0;
		}
		int width_request = 0;
		int height_request = 0;
		var this_width = get_width();
		if(available_width > 0) {
			this_width = available_width;
			available_width = -1;
		}
		if(String.is_empty(text) == false) {
			var tp = TextProperties.for_string(text)
				.set_color(color).set_font(font)
				.set_outline_color(outline_color);
			tp.set_alignment(text_align);
			if(wrap && this_width > 0) {
				tp.set_wrap_width(this_width-shadow_x-shadow_x);
			}
			ltext = TextLayout.for_properties(tp, get_frame(), get_dpi());
			if(ltext != null) {
				width_request = Math.ceil(ltext.get_width()) + shadow_x + shadow_x;
			}
			var sc = shadow_color;
			if(wrap == false && this_width > 0) {
				ltext = TextLayout.for_properties_with_limit(tp, get_frame(), this_width, get_dpi());
				if(sc != null) {
					lshadow = TextLayout.for_properties_with_limit(TextProperties.for_string(text)
						.set_font(font).set_color(sc).set_alignment(text_align),
							get_frame(), this_width, get_dpi());
				}
			}
			else {
				if(sc != null) {
					var stp = TextProperties.for_string(text)
						.set_color(sc).set_font(font)
						.set_alignment(text_align);
					if(wrap && this_width > 0) {
						stp.set_wrap_width(this_width-shadow_x-shadow_x);
					}
					lshadow = TextLayout.for_properties(stp, get_frame(), get_dpi());
				}
			}
		}
		if(ltext != null) {
			height_request = Math.ceil(ltext.get_height()) + shadow_y + shadow_y;
		}
		else {
			width_request = 0;
			height_request = 0;
		}
		if(font_auto_shrink) {
			var width = get_width();
			var height = get_height();
			if((width > 0 && width_request > width) || (height > 0 && height_request > height)) {
				var cpx = px(font.get_size());
				if(cpx > 1) {
					var ff = font.dup();
					ff.set_size("%dpx".printf().add(cpx-1).to_string());
					if(px(ff.get_size()) < cpx) {
						do_update_layouts(ff);
						return;
					}
				}
			}
		}
		set_size_request(width_request, height_request);
	}

	public void initialize() {
		base.initialize();
		do_update_layouts();
	}

	public void on_resize() {
		ltext = null;
		lshadow = null;
		base.on_resize();
	}

	public void on_available_size(int w, int h) {
		if(w < 0) {
			return;
		}
		if(w != get_width()) {
			available_width = w;
			available_height = h;
			ltext = null;
			lshadow = null;
			do_update_layouts();
		}
	}

	public Collection render() {
		if(ltext == null) {
			do_update_layouts();
		}
		if(ltext == null) {
			return(null);
		}
		// FIXME: This actually has an imperfection. Since the layout
		// is prepared when preparing the size request, the layout will
		// only be accurate if the widget actually gets its request. If
		// the actual size is different from the request, then the layout
		// will be messed up (it may not fit and/or it may overflow)
		int x;
		if(text_align == 0) {
			x = 0;
		}
		else if(text_align == 1) {
			x = get_width() / 2;
		}
		else if(text_align == 2) {
			x = get_width();
			if(ltext != null) {
				x -= Math.ceil(ltext.get_width());
			}
		}
		int y = (get_height() - Math.ceil(ltext.get_height())) / 2;
		var v = LinkedList.create();
		if(lshadow != null) {
			int shadow_x = 1;
			int shadow_y = 1;
			v.add(new DrawObjectOperation().set_x(x+shadow_x).set_y(y+shadow_y).set_object(lshadow));
		}
		v.add(new DrawObjectOperation().set_x(x).set_y(y).set_object(ltext));
		return(v);
	}
}

