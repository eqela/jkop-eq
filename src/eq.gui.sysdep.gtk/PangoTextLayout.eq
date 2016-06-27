
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

public class PangoTextLayout : TextLayout, Size
{
	embed "c" {{{
		#include <pango/pangocairo.h>
	}}}
	TextProperties tprop;
	int dpi = 0;
	int width = 0;
	int height = 0;
	int text_width = 0;
	public ptr pangolayout;

	public static PangoTextLayout create(TextProperties tprop, int dpi) {
		var v = new PangoTextLayout();
		v.tprop = tprop;
		v.dpi = dpi;
		v.initialize();
		return(v);
	}

	public ~PangoTextLayout() {
		ptr pangolayout = this.pangolayout;
		if(pangolayout != null) {
			embed "c" {{{
				g_object_unref((PangoLayout*)pangolayout);
			}}}
			this.pangolayout = null;
		}
	}

	public void initialize() {
		ptr pangolayout;
		if(tprop == null) {
			return;
		}
		var proptext = tprop.get_text();
		if(proptext == null) {
			return;
		}
		var fontname = "Arial";
		var fontstyle = "";
		int fontsize = 12;
		var font = tprop.get_font();
		if(font != null) {
			fontname = font.get_name();
			fontsize = Length.to_pixels(font.get_size(), dpi);
			fontstyle = font.get_style();
		}
		String fontdesc = "%s %s %dpx".printf().add(fontname).add(fontstyle).add(Primitive.for_integer(fontsize)).to_string();
		var fontdescptr = fontdesc.to_strptr();
		var textptr = proptext.to_strptr();
		int wrapwidth = tprop.get_wrap_width();
		int alignment = tprop.get_alignment();
		int w, h, tw;
		embed "c" {{{
			PangoLayout *layout = NULL;
			PangoFontDescription *desc = NULL;
			PangoFontMap *fontmap = NULL;
			PangoContext *ctx = NULL;
			fontmap = pango_cairo_font_map_get_default();
			if(fontmap != NULL) {
				ctx = pango_font_map_create_context(fontmap);
			}
			layout = pango_layout_new(ctx);	
			pango_layout_set_text(layout, textptr, -1);
			desc = pango_font_description_from_string(fontdescptr);
			pango_layout_set_font_description(layout, desc);
			pango_font_description_free(desc);
			desc = NULL;
			if(alignment == 0) {
				pango_layout_set_alignment(layout, PANGO_ALIGN_LEFT);
			}
			else if(alignment == 1) {
				pango_layout_set_alignment(layout, PANGO_ALIGN_CENTER);
			}
			else if(alignment == 2) {
				pango_layout_set_alignment(layout, PANGO_ALIGN_RIGHT);
			}
			else if(alignment == 3) {
				pango_layout_set_alignment(layout, PANGO_ALIGN_LEFT);
				pango_layout_set_justify(layout, TRUE);
			}
			else {
				pango_layout_set_alignment(layout, PANGO_ALIGN_LEFT);
			}
			if(wrapwidth > 0) {
				pango_layout_set_wrap(layout, PANGO_WRAP_WORD_CHAR);
				pango_layout_set_width(layout, wrapwidth * PANGO_SCALE);
			}
			pango_layout_get_size(layout, &w, &h);
			pangolayout = layout;
			w /= PANGO_SCALE;
			h /= PANGO_SCALE;
			g_object_unref(ctx);
			ctx = NULL;
			if(wrapwidth > 0 && w < wrapwidth) {
				w = wrapwidth;
			}
		}}}
		this.width = w;
		this.height = h;
		this.pangolayout = pangolayout;
	}

	public double get_width() {
		return(width);
	}

	public double get_height() {
		return(height);
	}

	public ptr get_pango_layout() {
		return(pangolayout);
	}

	public int xy_to_index(double x, double y) {
		ptr pangolayout = this.pangolayout;
		int v = -1;
		if(pangolayout != null) {
			int tr = 0;
			embed "c" {{{
				if(pango_layout_xy_to_index(pangolayout, x * PANGO_SCALE, y * PANGO_SCALE, &v, &tr) == FALSE) {
					v = -1;
				}
			}}}
		}
		return(v);
	}

	public Rectangle get_cursor_position(int index) {
		ptr pangolayout = this.pangolayout;
		Rectangle v = null;
		int x, y, height;
		if(pangolayout != null) {
			embed "c" {{{
				PangoRectangle r;
				pango_layout_get_cursor_pos(pangolayout, index, &r, NULL);
				x = r.x / PANGO_SCALE;
				y = r.y / PANGO_SCALE;
				height = r.height / PANGO_SCALE;
			}}}
		}
		return(Rectangle.instance(x, y, 1, height));
	}

	public TextProperties get_text_properties() {
		return(tprop);
	}
}
