
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

class GtkVgContext : VgContext
{
	embed "c" {{{
		#include <gtk/gtk.h>
		#include <cairo.h>
		#include <math.h>
		#include <pango/pangocairo.h>
		#include <ft2build.h>
		#include FT_FREETYPE_H
	}}}

	property ptr cr = null;
	bool saved = false;

	public ~GtkVgContext() {
		var cr = this.cr;
		if(cr != null) {
			embed "c" {{{
				cairo_surface_t* ss = cairo_get_target((cairo_t*)cr);
				if(ss != NULL) {
					cairo_surface_flush(ss);
				}
			}}}
		}
	}

	private void play_custom_path(int x, int y, VgPathCustom path) {
		ptr cr = this.cr;
		int cx = x + path.get_start_x(), cy = y + path.get_start_y();
		embed "c" {{{
			cairo_new_path(cr);
			cairo_move_to(cr, cx, cy);
		}}}
		var it = path.iterate();
		while(it != null) {
			var e = it.next() as VgPathElement;
			if(e == null) {
				break;
			}
			int op = e.get_operation();
			switch(op) {
				case VgPathElement.OP_LINE: {
					int lx = x + e.get_x1(), ly = y + e.get_y1();
					embed "c" {{{
						cairo_line_to(cr, lx, ly);
					}}}
				}
				case VgPathElement.OP_CURVE: {
					int cx1 = x + e.get_x1(), cy1 = y + e.get_y1(), cx2 = x + e.get_x2(), cy2 = y + e.get_y2(), cx3 = x + e.get_x3(), cy3 = y + e.get_y3();
					embed "c" {{{
					 	cairo_curve_to(cr, cx1, cy1, cx2, cy2, cx3, cy3);
					 }}}
				}
				case VgPathElement.OP_ARC: {
					int ax = x + e.get_x1(), ay = y + e.get_y1(), arad = e.get_radius();
					double angle1 = e.get_angle1(), angle2 = e.get_angle2();
					embed "c" {{{
						cairo_arc(cr, ax, ay, arad, angle1, angle2);
					}}}
				}
			}
		}
	}

	private bool apply_path(int x, int y, VgPath vp, VgTransform vt, double adjust = 0.0) {
		bool v = true;
		ptr cr = this.cr;
		if(vt != null) {
			int tx = x+vp.get_x() + (vp.get_w()/2);
			int ty = y+vp.get_y() + (vp.get_h()/2);
			double tra = vt.get_rotate_angle();
			double tsx = vt.get_scale_x(), tsy = vt.get_scale_y();
			embed "c" {{{
				cairo_save(cr);
				cairo_translate(cr, tx, ty);
				cairo_rotate(cr, tra * M_PI/180); 
				cairo_scale(cr, tsx, tsy);
				cairo_translate(cr, -tx, -ty);
			}}}
		}
		if(vp == null) {
			v = false;
		}
		else if(vp is VgPathRectangle) {
			int rx = x + vp.get_x() + adjust, ry = y + vp.get_y() + adjust,
				rw = vp.get_w() - adjust * 2, rh = vp.get_h() - adjust * 2;
			embed "c" {{{
				cairo_new_path(cr);
				cairo_rectangle(cr, rx, ry, rw, rh);
			}}}
		}
		else if(vp is VgPathRoundedRectangle) {
			int aa = 0, ab = 0;
			if(adjust != 0.0) {
				aa = (int)Math.rint(adjust);
				ab = (int)Math.rint(adjust*2);
				if(adjust > 0.0 && aa < 1) {
					aa = 1;
					ab = 2;
				}
			}
			var rrec = (VgPathRoundedRectangle)vp;
			int rrx = x + rrec.get_x() + aa, rry = y + rrec.get_y() + aa,
				rrw = rrec.get_w() - ab, rrh = rrec.get_h() - ab;
			int radius = rrec.get_radius();
			radius = radius * 2;
			if(radius > rrw/2) {
				radius = rrw/2;
			}
			if(radius > rrh/2) {
				radius = rrh/2;
			}
			embed "c" {{{
				cairo_new_path(cr);
				cairo_move_to(cr, rrx+radius,rry);
				cairo_line_to(cr, rrx+rrw-radius,rry);
				cairo_curve_to(cr, rrx+rrw, rry, rrx+rrw, rry, rrx+rrw, rry+radius);
				cairo_line_to(cr, rrx+rrw, rry+rrh-radius);
				cairo_curve_to(cr, rrx+rrw,rry+rrh,rrx+rrw,rry+rrh,rrx+rrw-radius,rry+rrh);
				cairo_line_to(cr, rrx+radius,rry+rrh);
				cairo_curve_to(cr, rrx,rry+rrh,rrx,rry+rrh,rrx,rry+rrh-radius);
				cairo_line_to(cr, rrx,rry+radius);
				cairo_curve_to(cr, rrx,rry,rrx,rry,rrx+radius,rry);
				cairo_move_to(cr, rrx+radius,rry);
			}}}
		}
		else if(vp is VgPathCircle) {
			var circ = (VgPathCircle)vp;
			int cx = x + circ.get_xc(), cy = y + circ.get_yc(), crad = circ.get_radius() - adjust*2;
			embed "c" {{{
				cairo_new_path(cr);
				cairo_arc(cr, cx, cy, crad, 0, 2 * M_PI);
			}}}
		}
		else if(vp is VgPathCustom) {
			play_custom_path(x, y, (VgPathCustom)vp);
		}
		else {
			Log.warning("ERROR: VgPath(Other)"); //FIXME
			v = false;
		}
		return(v);
	}

	public bool stroke(int x, int y, VgPath vp, VgTransform vt, Color c, int linewidth, int style) {
		ptr cr = this.cr;
		if(apply_path(x, y, vp, vt, (double)linewidth / 2.0) == false) {
			return(false);
		}
		double va = 1.0;
		if(vt != null) {
			va = vt.get_alpha();
		}
		if(style == 1) {
			embed "c" {{{
				double dash1[] = {4.0, 1.0};
				int len  = sizeof(dash1) / sizeof(dash1[0]);
				cairo_set_dash(cr, dash1, len, 0);
			}}}
		}
		else if(style == 2) {
			embed "c" {{{
				double dash2[] = {4.0, 1.0, 4.0};
				int len2  = sizeof(dash2) / sizeof(dash2[0]);
				cairo_set_dash(cr, dash2, len2, 1);
			}}}
		}
		else if(style == 3) {
			embed "c" {{{
				double dash3[] = {1.0};
				int len3  = 1;
				cairo_set_dash(cr, dash3, len3, 0);
			}}}
		}
		else {
			embed "c" {{{
				double dash4[] = {1.0};
				int len4  = 0;
				cairo_set_dash(cr, dash4, len4, 0);
			}}}
		}
		double rc = c.get_r(), gc = c.get_g(), bc = c.get_b(), alpha = c.get_a() * va;
		embed "c" {{{
			cairo_set_line_width (cr, linewidth);
			cairo_set_source_rgba(cr, rc, gc, bc, alpha);
			cairo_set_line_join(cr, CAIRO_LINE_JOIN_ROUND);
			cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND);
			cairo_stroke(cr);
		}}}
		if(vt != null) {
			embed "c" {{{
				cairo_restore(cr);
			}}}
		}
		return(true);
	}

	public bool clear(int x, int y, VgPath vp, VgTransform vt) {
		ptr cr = this.cr;
		if(apply_path(x, y, vp, vt) == false) {
			return(false);
		}
		if(vt == null) {
			embed "c" {{{
				cairo_save(cr);
			}}}
		}
		embed "c" {{{
			cairo_set_source_rgba(cr, 0.0, 0.0, 0.0, 0.0);
			cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);
			cairo_fill(cr);
		}}}
		embed "c" {{{
			cairo_restore(cr);
		}}}
		return(true);
	}

	public bool fill_color(int x, int y, VgPath vp, VgTransform vt, Color c) {
		ptr cr = this.cr;
		if(apply_path(x, y, vp, vt) == false) {
			return(false);
		}
		double va = 1.0;
		if(vt != null) {
			va = vt.get_alpha();
		}
		double rc = c.get_r(), gc = c.get_g(), bc = c.get_b(), alpha = c.get_a() * va;
		embed "c" {{{
			cairo_set_source_rgba(cr, rc, gc, bc, alpha);
			cairo_fill(cr);
		}}}
		if(vt != null) {
			embed "c" {{{
				cairo_restore(cr);
			}}}
		}
		return(true);
	}

	public bool fill_vertical_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b) {
		ptr cr = this.cr;
		if(apply_path(x, y, vp, vt) == false) {
			return(false);
		}
		double alpha = 1.0;
		if(vt != null) {
			alpha = vt.get_alpha();
		}
		double ar = a.get_r(), ag = a.get_g(), ab = a.get_b(), aa = a.get_a() * alpha,
		    br = b.get_r(), bg = b.get_g(), bb = b.get_b(), ba = b.get_a() * alpha;
		int vx = x + vp.get_x(), vy1 = y + vp.get_y(), vy2 = vy1 + vp.get_h();
		embed "c" {{{
			cairo_pattern_t *pat = cairo_pattern_create_linear(vx, vy1, vx, vy2);
			cairo_pattern_add_color_stop_rgba(pat, 0, ar, ag, ab, aa);
			cairo_pattern_add_color_stop_rgba(pat, 1, br, bg, bb, ba);
			cairo_set_source (cr, pat);
			cairo_fill(cr);
			cairo_pattern_destroy(pat);
		}}}
		if(vt != null) {
			embed "c" {{{
				cairo_restore(cr);
			}}}
		}
		return(true);
	}

	public bool fill_horizontal_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b) {
		ptr cr = this.cr;
		if(apply_path(x, y, vp, vt) == false) {
			return(false);
		}
		double alpha = 1.0;
		if(vt != null) {
			alpha = vt.get_alpha();
		}
		double ar = a.get_r(), ag = a.get_g(), ab = a.get_b(), aa = a.get_a() * alpha,
		    br = b.get_r(), bg = b.get_g(), bb = b.get_b(), ba = b.get_a() * alpha;
		int hx1 = x + vp.get_x(), hy = y + vp.get_y(), hx2 = hx1 + vp.get_w();
		embed "c" {{{
			cairo_pattern_t *pat = cairo_pattern_create_linear(hx1, hy, hx2, hy);
			cairo_pattern_add_color_stop_rgba(pat, 0, ar, ag, ab, aa);
			cairo_pattern_add_color_stop_rgba(pat, 1, br, bg, bb, ba);
			cairo_set_source (cr, pat);
			cairo_fill(cr);
			cairo_pattern_destroy(pat);
		}}}
		if(vt != null) {
			embed "c" {{{
				cairo_restore(cr);
			}}}
		}
		return(true);
	}

	public bool fill_radial_gradient(int x, int y, VgPath vp, VgTransform vt, int radius, Color a, Color b) {
		ptr cr = this.cr;
		if(apply_path(x, y, vp, vt) == false) {
			return(false);
		}
		double alpha = 1.0;
		if(vt != null) {
			alpha = vt.get_alpha();
		}
		double ar = a.get_r(), ag = a.get_g(), ab = a.get_b(), aa = a.get_a() * alpha,
		    br = b.get_r(), bg = b.get_g(), bb = b.get_b(), ba = b.get_a() * alpha;
		int rx1 = x + vp.get_x() + (vp.get_w()/2), ry1 = y + vp.get_y() + (vp.get_h()/2),
			rx2 = x + vp.get_y() + (vp.get_w()/2), ry2 = y + vp.get_y() + (vp.get_h()/2);
		embed "c" {{{
			cairo_pattern_t *pat = cairo_pattern_create_radial(rx1, ry1, 0, rx2, ry2, radius);
			cairo_pattern_add_color_stop_rgba(pat, 0, ar, ag, ab, aa);
			cairo_pattern_add_color_stop_rgba(pat, 1, br, bg, bb, ba);
			cairo_set_source (cr, pat);
			cairo_fill(cr);
			cairo_pattern_destroy(pat);
		}}}
		if(vt != null) {
			embed "c" {{{
				cairo_restore(cr);
			}}}
		}
		return(true);
	}

	public bool fill_diagonal_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b, int direction) {
		ptr cr = this.cr;
		if(apply_path(x, y, vp, vt) == false) {
			return(false);
		}
		double alpha = 1.0;
		if(vt != null) {
			alpha = vt.get_alpha();
		}
		double ar = a.get_r(), ag = a.get_g(), ab = a.get_b(), aa = a.get_a() * alpha,
		    br = b.get_r(), bg = b.get_g(), bb = b.get_b(), ba = b.get_a() * alpha;
		int dx1, dy1, dx2, dy2;
		if(direction == 0) {
			dx1 = x+vp.get_x();
			dy1 = y+vp.get_y();
			dx2 = x+vp.get_x()+vp.get_w();
			dy2 = y+vp.get_y()+vp.get_h();
		}
		else if(direction == 1) {
			dx1 = x+vp.get_x();
			dy1 = y+vp.get_y()+vp.get_h();
			dx2 = x+vp.get_x()+vp.get_w();
			dy2 = y+vp.get_y();
		}
		else if(direction == 2) {
			dx1 = x+vp.get_x()+vp.get_w();
			dy1 = y+vp.get_y();
			dx2 = x+vp.get_x()+vp.get_w();
			dy2 = y+vp.get_y();
		}
		else if(direction == 3) {
			dx1 = x+vp.get_x()+vp.get_w();
			dy1 = y+vp.get_y()+vp.get_h();
			dx2 = x+vp.get_x();
			dy2 = y+vp.get_y();
		}
		embed "c" {{{
			cairo_pattern_t *pat = cairo_pattern_create_linear(dx1, dy1, dx2, dy2);
			cairo_pattern_add_color_stop_rgba(pat, 0, ar, ag, ab, aa);
			cairo_pattern_add_color_stop_rgba(pat, 1, br, bg, bb, ba);
			cairo_set_source (cr, pat);
			cairo_fill(cr);
			cairo_pattern_destroy(pat);
		}}}
		if(vt != null) {
			embed "c" {{{
				cairo_restore(cr);
			}}}
		}
		return(true);
	}

	bool draw_freetype_text(int x, int y, VgTransform vt, FreeTypeTextLayout freetype_text) {
		if(freetype_text == null) {
			return(false);
		}
		var tprop = freetype_text.get_text_properties();
		if(tprop == null) {
			return(false);
		}
		Color textcolor = tprop.get_color();
		Color outlinecolor = tprop.get_outline_color();
		int outwidth = 3;
		double tr, tg, tb, ta;
		if(textcolor != null) {
			tr = textcolor.get_r();
			tg = textcolor.get_g();
			tb = textcolor.get_b();
			ta = textcolor.get_a();
		}
		double or, og, ob, oa;
		if(outlinecolor != null) {
			or = outlinecolor.get_r();
			og = outlinecolor.get_g();
			ob = outlinecolor.get_b();
			oa = outlinecolor.get_a();
		}
		var font_face = freetype_text.get_font_face();
		if(font_face != null) {
			var cr = this.cr;
			if(cr == null) {
				return(false);
			}
			var font = tprop.get_font();
			int dpi = freetype_text.get_dpi();
			int fontsize = Length.to_pixels(font.get_size(), dpi);
			int alignment = tprop.get_alignment();
			int wrap_width = tprop.get_wrap_width();
			embed "c" {{{
				cairo_font_face_t* cairo_face = cairo_ft_font_face_create_for_ft_face((FT_Face)font_face, 0);
				cairo_set_font_face(cr, cairo_face);
				cairo_set_font_size(cr, fontsize);
			}}}
			double width = freetype_text.get_width();
			double height = freetype_text.get_height() - freetype_text.get_offset_y();
			double x_pos = x;
			double alpha = 1.0;
			if(alignment == 1) {
				x_pos = x - (width / 2);
			}
			if(vt != null) {
				double tlx = x_pos + (width / 2);
				double tly = y + (height / 2);
				double tlra = vt.get_rotate_angle();
				double tlsx = vt.get_scale_x();
				double tlsy = vt.get_scale_y();
				alpha = vt.get_alpha();
				embed "c" {{{
					cairo_save(cr);
					cairo_translate(cr, tlx, tly);
					cairo_rotate(cr, tlra * M_PI / 180);
					cairo_scale(cr, tlsx, tlsy);
					cairo_translate(cr, -tlx, -tly);
				}}}
			}
			if(width > wrap_width && wrap_width > 0) {
				double y_pos = y;
				var wrapped_texts = freetype_text.get_wrapped_texts();
				if(wrapped_texts != null) {
					foreach(FreeTypeText ftt in wrapped_texts) {
						double w = ftt.get_width();
						var textptr = ftt.get_text().to_strptr();
						if(alignment == 1) {
							x_pos = x - (w * 0.5);
						}
						else if(alignment == 2) {
							x_pos = wrap_width - w;
						}
						embed "c" {{{
							cairo_move_to(cr, x_pos, y_pos);
							cairo_text_path(cr, textptr);
							if(outlinecolor != NULL && outwidth > 0) {
								cairo_set_source_rgba(cr, or, og, ob, oa * alpha);
								cairo_set_line_width(cr, outwidth);
								cairo_stroke_preserve(cr);
							}
							cairo_set_source_rgba(cr, tr, tg, tb, ta * alpha);
							cairo_fill(cr);
						}}}
						y_pos += ftt.get_height();
					}
					wrapped_texts.clear();
				}
			}
			else {
				var textptr = tprop.get_text().to_strptr();
				embed "c" {{{
					cairo_move_to(cr, x_pos, y + height);
					cairo_text_path(cr, textptr);
					if(outlinecolor != NULL && outwidth > 0) {
						cairo_set_source_rgba(cr, or, og, ob, oa * alpha);
						cairo_set_line_width(cr, outwidth);
						cairo_stroke_preserve(cr);
					}
					cairo_set_source_rgba(cr, tr, tg, tb, ta * alpha);
					cairo_fill(cr);
				}}}
			}
			embed "c" {{{
				if(cairo_face != NULL) {
					cairo_font_face_destroy(cairo_face);
				}
			}}}
		}
		return(true);
	}

	public bool draw_pango_text(int x, int y, VgTransform vt, PangoTextLayout ptl) {
		if(ptl == null) {
			return(false);
		}
		var tprop = ptl.get_text_properties();
		if(tprop == null) {
			return(false);
		}
		var cr = this.cr;
		Color textcolor = tprop.get_color();
		Color outlinecolor = tprop.get_outline_color();
		int outwidth = 3;
		int align = tprop.get_alignment();
		double tr = textcolor.get_r(), tg = textcolor.get_g(), tb = textcolor.get_b(), ta = textcolor.get_a();
		double or, og, ob, oa;
		if(outlinecolor != null) {
			or = outlinecolor.get_r();
			og = outlinecolor.get_g();
			ob = outlinecolor.get_b();
			oa = outlinecolor.get_a();
		}
		var layout = ptl.get_pango_layout();
		if(layout != null) {
			int width = ptl.get_width();
			int height = ptl.get_height();
			int lx = x;
			double alpha = 1.0;
			if(align == 1) {
				lx = x - (width/2);
			}
			if(vt != null) {
				int tlx = lx + (width/2);
				int tly = y + (height/2);
				double tlra = vt.get_rotate_angle();
				double tlsx = vt.get_scale_x(), tlsy = vt.get_scale_y();
				alpha = vt.get_alpha();
				embed "c" {{{
					cairo_save(cr);
					cairo_translate(cr, tlx, tly);
					cairo_rotate(cr, tlra * M_PI/180); 
					cairo_scale(cr, tlsx, tlsy);
					cairo_translate(cr, -tlx, -tly);
				}}}
			}
			embed "c" {{{
				if(outlinecolor != NULL && outwidth > 0) {
					cairo_move_to(cr, lx, y);
					cairo_set_source_rgba(cr, or, og, ob, oa * alpha);
					cairo_set_line_width(cr, outwidth);
					pango_cairo_layout_path(cr, layout);
					cairo_stroke(cr);
				}
				cairo_move_to(cr, lx, y);
				cairo_set_source_rgba(cr, tr, tg, tb, ta * alpha);
				pango_cairo_show_layout(cr, layout);
			}}}
			if(vt != null) {
				embed "c" {{{
					cairo_restore(cr);
				}}}
			}
		}
		return(true);
	}

	public bool draw_text(int x, int y, VgTransform vt, TextLayout text) {
		if(text == null) {
			return(false);
		}
		var ptl = text as PangoTextLayout;
		if(ptl != null) {
			draw_pango_text(x, y, vt, ptl);
			return(true);
		}
		var ftf = text as FreeTypeTextLayout;
		if(ftf != null) {
			draw_freetype_text(x, y, vt, ftf);
			return(true);
		}
		return(false);
	}

	public bool draw_graphic(int x, int y, VgTransform vt, Image graphic) {
		if(graphic == null) {
			return(false);
		}
		if(graphic is CodeImage) {
			((CodeImage)graphic).render(this, x, y, vt);
			return(true);
		}
		ptr cr = this.cr;
		double sx = 1.0;
		double sy = 1.0;
		double rot = 0.0;
		double vtalpha = 1.0;
		if(vt != null) {
			sx = vt.get_scale_x();
			sy = vt.get_scale_y();
			rot = vt.get_rotate_angle();
			vtalpha = vt.get_alpha();
		}
		var gwidth = graphic.get_width();
		var gheight = graphic.get_height();
		var gw = (sx * gwidth) / 2;
		var gh = (sy * gheight) / 2;
		embed "c" {{{
			cairo_save(cr);
		}}}
		if(vt != null && vt.get_flip_horizontal()) {
			// FIXME: Support vertical flipping also; and support the flips also in non-bitmap drawings
			embed "c" {{{
				cairo_matrix_t newm, origm, flipm;
				cairo_get_matrix(cr, &origm);
				cairo_matrix_init(&flipm, -1.0, 0, 0, 1.0, 2*(x+gw), 0);
				cairo_matrix_multiply(&newm, &origm, &flipm);
				cairo_set_matrix(cr, &newm);
			}}}
		}
		embed "c" {{{
			if(rot != 0.0) {
				cairo_translate(cr, (double)(x+gw), (double)(y+gh));
				cairo_rotate(cr, rot);
				cairo_translate(cr, (double)(-gw), (double)(-gh));
			}
			else if(x != 0 || y != 0) {
				cairo_translate(cr, (double)x, (double)y);
			}
			if(sx != 1.0 || sy != 1.0) {
				double w2 =  gwidth/2.0;
				double h2 =  gheight/2.0;
				cairo_translate(cr, w2, h2);
				cairo_scale(cr, sx, sy);
				cairo_translate(cr, -w2, -h2);
			}
		}}}
		if(graphic is GtkFileImage) {
			var img = ((GtkFileImage)graphic).get_gtk_image();
			if(img != null) {
				embed "c" {{{
					gdk_cairo_set_source_pixbuf(cr, img, 0, 0);
					cairo_paint_with_alpha(cr, vtalpha);
				}}}
			}
		}
		else if(graphic is GtkRenderableImage) {
			var s = ((GtkRenderableImage)graphic).get_surface();
			embed "c" {{{
				cairo_set_source_surface(cr, s, 0, 0); //x, y);
				cairo_paint_with_alpha(cr, vtalpha);
			}}}
		}
		embed "c" {{{
			cairo_restore(cr);
		}}}
		return(true);
	}

	public bool clip(int x, int y, VgPath vp, VgTransform vt) {
		ptr cr = this.cr;
		if(saved == false) {
			embed "c" {{{
				cairo_save(cr);
			}}}
			saved = true;
		}
		if(apply_path(x, y, vp, vt)) {
			embed "c" {{{
				cairo_clip(cr);
			}}}
		}
		return(true);
	}

	public bool clip_clear() {
		ptr cr = this.cr;
		if(saved) {
			embed "c" {{{
				cairo_restore(cr);
			}}}
			saved = false;
		}
		return(true);
	}

	public Rectangle get_clip() {
		ptr cr = this.cr;
		double x1, y1, x2, y2;
		embed "c" {{{
			cairo_clip_extents(cr, &x1, &y1, &x2, &y2);
		}}}
		return(Rectangle.instance( (int)x1, (int)y1, (int)(x2-x1), (int)(y2-y1) ));
	}
}
