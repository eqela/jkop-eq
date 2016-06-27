
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

class Direct2DVgContext : VgContext
{
	embed "c++" {{{
		#include <d2d1.h>
	}}}

	ptr target;
	ptr factory;
	bool is_cache;
	ClipOperation clip_ops;

 	public static Direct2DVgContext create(ptr target, ptr factory) {
 		var v = new Direct2DVgContext();
 		v.target = target;
 		v.factory = factory;
 		v.clip_ops = ClipOperation.create(target, factory);
 		return(v);
 	}

	public ptr to_solidcolorbrush(Color c) {
		ptr target = this.target;
		ptr v;
		double cr = c.get_r(), cg = c.get_g(), cb = c.get_b(), ca = c.get_a();
		embed "c++" {{{
			((ID2D1RenderTarget*)target)->CreateSolidColorBrush(D2D1::ColorF(cr, cg, cb, ca), (ID2D1SolidColorBrush**)&v);
		}}}
		return(v);
	}

	private ptr to_gradientbrush(Color c1, Color c2, int width, int height, int direction, int radius = 0, int ddirection = 0, int offset = 0) {
		ptr target = this.target;
		double cr1 = c1.get_r(), cg1 = c1.get_g(), cb1 = c1.get_b(), ca1 = c1.get_a();
		double cr2 = c2.get_r(), cg2 = c2.get_g(), cb2 = c2.get_b(), ca2 = c2.get_a();
		double mcr = (cr1+cr2)/2, mcg = (cg1+cg2)/2, mcb = (cb1+cb2)/2, mca = (ca1+ca2)/2;
		ptr v;
		embed "c++" {{{
			ID2D1GradientStopCollection* gsc;
			D2D1_GRADIENT_STOP gs[3];
			gs[0].color = D2D1::ColorF(cr1, cg1, cb1, ca1);
			gs[0].position = 0.0f;
			gs[1].color = D2D1::ColorF(mcr, mcg, mcb, mca);
			gs[1].position = 0.5f;
			gs[2].color = D2D1::ColorF(cr2, cg2, cb2, ca2);
			gs[2].position = 1.0f;
			((ID2D1RenderTarget*)target)->CreateGradientStopCollection(
				gs,
				3,
				D2D1_GAMMA_2_2,
				D2D1_EXTEND_MODE_CLAMP,
				&gsc
			);
		}}}
		if(direction == GradientWrapper.HORIZONTAL) {
			embed "c++" {{{
				((ID2D1RenderTarget*)target)->CreateLinearGradientBrush(D2D1::LinearGradientBrushProperties(
					D2D1::Point2F(-offset, 0),
					D2D1::Point2F(width-offset, 0)),
					gsc,
					(ID2D1LinearGradientBrush**)&v
				);
			}}}
		}
		else if(direction == GradientWrapper.VERTICAL) {
			embed "c++" {{{
				((ID2D1RenderTarget*)target)->CreateLinearGradientBrush(D2D1::LinearGradientBrushProperties(
					D2D1::Point2F(0, -offset),
					D2D1::Point2F(0, height-offset)),
					gsc,
					(ID2D1LinearGradientBrush**)&v
				);
			}}}
		}
		else if(direction == GradientWrapper.DIAGONAL) {
			embed "c++" {{{
				D2D1_POINT_2F p1 = D2D1::Point2F(-offset, -offset);
				D2D1_POINT_2F p2 = D2D1::Point2F(width-offset, height-offset);
				if(ddirection == 1) {
					p1 = D2D1::Point2F(0, height);
					p2 = D2D1::Point2F(width, 0);
				}
				((ID2D1RenderTarget*)target)->CreateLinearGradientBrush(D2D1::LinearGradientBrushProperties(p1, p2),
					gsc,
					(ID2D1LinearGradientBrush**)&v
				);
			}}}
		}
		else if(direction == GradientWrapper.RADIAL) {
			embed "c++" {{{
				((ID2D1RenderTarget*)target)->CreateRadialGradientBrush(D2D1::RadialGradientBrushProperties(
					D2D1::Point2F((width/2) - offset, (height/2) - offset),
					D2D1::Point2F(0, 0),
					radius,
					radius),
					gsc,
					(ID2D1RadialGradientBrush**)&v
				);
			}}}
		}
		embed "c++" {{{
			gsc->Release();
		}}}
		return(v);
	}

	private bool paint_shape(PaintWrapper paint) {
		ptr target = this.target;
		var vp = paint.get_path();
		int x = paint.get_x();
		int y = paint.get_y();
		int ax = x+vp.get_x(), ay = y+vp.get_y();
		int width = vp.get_w(), height = vp.get_h();
		ptr brush;
		var vt = paint.get_transform();
		double rotate = 0.0, pivx = 0.0, pivy = 0.0;
		double trans_alpha = 1.0;
		double scale_x = 1.0, scale_y = 1.0;
		if(vt != null) {
			scale_x = vt.get_scale_x();
			scale_y = vt.get_scale_y();
			rotate = vt.get_rotate_angle() * 180.0 / MathConstant.M_PI;
			pivx = ax + (width/2);
			pivy = ay + (height/2);
			trans_alpha = vt.get_alpha();
		}
		if(vp is VgPathCircle) {
			int radius = ((VgPathCircle)vp).get_radius();
			ax += radius;
			ay += radius;
		}
		embed "c++" {{{
			D2D1::Matrix3x2F matrix = D2D1::Matrix3x2F::Translation(D2D1::SizeF(ax, ay));
			if(rotate != 0) {
				matrix = matrix.operator*(D2D1::Matrix3x2F::Rotation(rotate, D2D1::Point2F(pivx, pivy)));
			}
			if(scale_x != 1 || scale_y != 1) {
				matrix = matrix.operator*(D2D1::Matrix3x2F::Scale(D2D1::SizeF(scale_x, scale_y), D2D1::Point2F(pivx, pivy)));
			}
			((ID2D1RenderTarget*)target)->SetTransform(matrix);
		}}}
		if(paint is GradientWrapper) {
			var gpaint = (GradientWrapper)paint;
			if(vp is VgPathCircle) {
				brush = to_gradientbrush(gpaint.get_color(), gpaint.get_color2(), width, height, gpaint.get_direction(), gpaint.get_radius(), gpaint.get_ddirection(), width/2);
			}
			else {
				brush = to_gradientbrush(gpaint.get_color(), gpaint.get_color2(), width, height, gpaint.get_direction(), gpaint.get_radius(), gpaint.get_ddirection(), 0);
			}
			if(brush!=null) {
				embed "c++" {{{
					((ID2D1Brush*)brush)->SetOpacity(trans_alpha);
				}}}
			}
			if(vp is VgPathRectangle) {
				embed "c++" {{{
					D2D1_RECT_F r = D2D1::RectF(0, 0, (float)width, (float)height);
					((ID2D1RenderTarget*)target)->FillRectangle(&r, (ID2D1Brush*)brush);
				}}}
			}
			else if(vp is VgPathRoundedRectangle) {
				int rad = ((VgPathRoundedRectangle)vp).get_radius();
				embed "c++" {{{
					D2D1_ROUNDED_RECT r = D2D1::RoundedRect(D2D1::RectF(0, 0, (float)width, (float)height), rad, rad);
					((ID2D1RenderTarget*)target)->FillRoundedRectangle(&r, (ID2D1Brush*)brush);
				}}}
			}
			else if(vp is VgPathCircle) {
				var ellipse = (VgPathCircle)vp;
				int rad = ellipse.get_radius();
				int xc = ellipse.get_xc();
				int yc = ellipse.get_yc();
				embed "c++" {{{
					D2D1_ELLIPSE e = D2D1::Ellipse(D2D1::Point2F(0, 0), rad, rad);
					((ID2D1RenderTarget*)target)->FillEllipse(&e, (ID2D1Brush*)brush);
				}}}
			}
		}
		else {
			brush = to_solidcolorbrush(paint.get_color());
			if(brush!=null) {
				embed "c++" {{{
					((ID2D1Brush*)brush)->SetOpacity(trans_alpha);
				}}}
			}
			if(paint is StrokeWrapper) {
				ptr factory = this.factory;
				int style = ((StrokeWrapper)paint).get_style();
				int linewidth = ((StrokeWrapper)paint).get_linewidth();
				embed "c++" {{{
					ID2D1StrokeStyle* custom_stroke = NULL;
					if(style != 0) {
						((ID2D1Factory*)factory)->CreateStrokeStyle(
						D2D1::StrokeStyleProperties(
							D2D1_CAP_STYLE_FLAT,
							D2D1_CAP_STYLE_FLAT,
							D2D1_CAP_STYLE_ROUND,
							D2D1_LINE_JOIN_MITER,
							10.0f,
							(D2D1_DASH_STYLE)style,
							0.0f),
						NULL,
						0,
						&custom_stroke);
					}
				}}}
				if(vp is VgPathRectangle) {
					embed "c++" {{{
						D2D1_RECT_F r = D2D1::RectF(0, 0, (float)width, (float)height);
						((ID2D1RenderTarget*)target)->DrawRectangle(&r, (ID2D1Brush*)brush, linewidth, custom_stroke);
					}}}
				}
				else if(vp is VgPathRoundedRectangle) {
					int rad = ((VgPathRoundedRectangle)vp).get_radius();
					embed "c++" {{{
						D2D1_ROUNDED_RECT r = D2D1::RoundedRect(D2D1::RectF(0, 0, (float)width, (float)height), rad, rad);
						((ID2D1RenderTarget*)target)->DrawRoundedRectangle(&r, (ID2D1Brush*)brush, linewidth, custom_stroke);
					}}}
				}
				else if(vp is VgPathCircle) {
					var ellipse = (VgPathCircle)vp;
					int rad = ellipse.get_radius();
					int xc = ellipse.get_xc();
					int yc = ellipse.get_yc();
					int dr = linewidth;
					embed "c++" {{{
						D2D1_ELLIPSE e = D2D1::Ellipse(D2D1::Point2F(0, 0), rad-dr, rad-dr);
						((ID2D1RenderTarget*)target)->DrawEllipse(&e, (ID2D1Brush*)brush, linewidth, custom_stroke);
					}}}
				}
				embed "c++" {{{
					if(custom_stroke != NULL) {
						custom_stroke->Release();
					}
				}}}
			}
			else if(paint is FillWrapper) {
				if(vp is VgPathRectangle) {
					embed "c++" {{{
						D2D1_RECT_F r = D2D1::RectF(0, 0, (float)width, (float)height);
						((ID2D1RenderTarget*)target)->FillRectangle(&r, (ID2D1Brush*)brush);
					}}}
				}
				else if(vp is VgPathRoundedRectangle) {
					int rad = ((VgPathRoundedRectangle)vp).get_radius();
					embed "c++" {{{
						D2D1_ROUNDED_RECT r = D2D1::RoundedRect(D2D1::RectF(0, 0, (float)width, (float)height), rad, rad);
						((ID2D1RenderTarget*)target)->FillRoundedRectangle(&r, (ID2D1Brush*)brush);
					}}}
				}
				else if(vp is VgPathCircle) {
					var ellipse = (VgPathCircle)vp;
					int rad = ellipse.get_radius();
					int xc = ellipse.get_xc();
					int yc = ellipse.get_yc();
					embed "c++" {{{
						D2D1_ELLIPSE e = D2D1::Ellipse(D2D1::Point2F(0, 0), rad, rad);
						((ID2D1RenderTarget*)target)->FillEllipse(&e, (ID2D1Brush*)brush);
					}}}
				}
			}
		}
		embed "c++" {{{
			if(brush != NULL) {
				((ID2D1Brush*)brush)->Release();
			}
		}}}
		return(true);
	}

	private bool paint_path(PaintWrapper paint) {
		var custom = (VgPathCustom)paint.get_path();
		ptr factory = this.factory;
		ptr target = this.target;
		int sx = custom.get_start_x(), sy = custom.get_start_y();
		ptr geometry;
		int type = 0;
		int tx = paint.get_x(), ty = paint.get_y();
		if(paint is StrokeWrapper) {
			type = 1;
		}
		embed "c++" {{{
			ID2D1GeometrySink* sink;
			((ID2D1Factory*)factory)->CreatePathGeometry((ID2D1PathGeometry**)&geometry);
			((ID2D1PathGeometry*)geometry)->Open(&sink);
			sink->BeginFigure(D2D1::Point2F(sx, sy), (D2D1_FIGURE_BEGIN)type);
		}}}
		foreach(VgPathElement e in custom.iterate()) {
			if(e.get_operation() == VgPathElement.OP_LINE) {
				int x1 = e.get_x1(), y1 = e.get_y1();
				embed "c++" {{{
					sink->AddLine(D2D1::Point2F(x1, y1));
					if(type == 1) {
						sink->EndFigure(D2D1_FIGURE_END_OPEN);
						sink->BeginFigure(D2D1::Point2F(x1, y1), (D2D1_FIGURE_BEGIN)type);
					}
				}}}
			}
			else if(e.get_operation() == VgPathElement.OP_CURVE) {
				int x1 = e.get_x1(), y1 = e.get_y1();
				int x2 = e.get_x2(), y2 = e.get_y2();
				int x3 = e.get_x3(), y3 = e.get_y3();
				embed "c++" {{{
					sink->AddBezier(D2D1::BezierSegment(
						D2D1::Point2F(x1, y1),
						D2D1::Point2F(x2, y2),
						D2D1::Point2F(x3, y3)
					));
				}}}
			}
			else if(e.get_operation() == VgPathElement.OP_ARC) {
				int x1 = e.get_x1(), y1 = e.get_y1();
				double sangle = e.get_angle1(), tangle = e.get_angle2();
				int radius = e.get_radius();
				double inix = (Math.cos(sangle) * radius) + x1;
				double iniy = (Math.sin(sangle) * radius) + y1;
				double termix = (Math.cos(tangle) * radius) + x1;
				double termiy = (Math.sin(tangle) * radius) + y1;
				double a1 = (sangle/MathConstant.M_PI*180), a2 = (tangle/MathConstant.M_PI*180);
				int adiff = (int)(a1 - a2);
				if(adiff < 0) {
					adiff = (int)(a2 - a1);
				}
				if(adiff % 360 == 0) {
					var ellipse = VgPathCircle.create(x1, y1, radius);
					paint_shape(paint.set_path(ellipse).set_x(0).set_y(0));
				}
				embed "c++" {{{
					sink->AddLine(D2D1::Point2F(inix, iniy));
					sink->AddArc(D2D1::ArcSegment(
						D2D1::Point2F(termix, termiy),
						D2D1::SizeF(radius, radius),
						tangle,
						D2D1_SWEEP_DIRECTION_CLOCKWISE,
						D2D1_ARC_SIZE_SMALL
					));
				}}}
			}
			else {
				Log.error("Invalid custom path operation");
			}
		}
		var vt = paint.get_transform();
		double rotate = 0.0, pivx = 0.0, pivy = 0.0;
		double scale_x = 1.0, scale_y = 1.0;
		double trans_alpha = 1.0;
		if(vt != null) {
			rotate = vt.get_rotate_angle();
			scale_x = vt.get_scale_x();
			scale_y = vt.get_scale_y();
			pivx = tx+custom.get_x() + (custom.get_w()/2);
			pivy = ty+custom.get_y() + (custom.get_h()/2);
			trans_alpha = vt.get_alpha();
		}
		embed "c++" {{{
			sink->EndFigure(D2D1_FIGURE_END_OPEN);
			sink->Close();
			sink->Release();
			D2D1::Matrix3x2F matrix = D2D1::Matrix3x2F::Translation(D2D1::SizeF(tx, ty));
			if(rotate != 0) {
				matrix = matrix.operator*(D2D1::Matrix3x2F::Rotation(rotate, D2D1::Point2F(pivx, pivy)));
			}
			if(scale_x != 1 || scale_y != 1) {
				matrix = matrix.operator*(D2D1::Matrix3x2F::Scale(D2D1::SizeF(scale_x, scale_y), D2D1::Point2F(pivx, pivy)));
			}
			((ID2D1RenderTarget*)target)->SetTransform(matrix);
		}}}
		ptr brush;
		if(paint is GradientWrapper) {
			var gpaint = (GradientWrapper)paint;
			brush = to_gradientbrush(gpaint.get_color(), gpaint.get_color2(), custom.get_w(), custom.get_h(), gpaint.get_direction(), gpaint.get_radius(), gpaint.get_ddirection());
			if(brush!=null) {
				embed "c++" {{{
					((ID2D1Brush*)brush)->SetOpacity(trans_alpha);
				}}}
			}
			embed "c++" {{{
				((ID2D1RenderTarget*)target)->FillGeometry((ID2D1PathGeometry*)geometry, (ID2D1Brush*)brush);
			}}}
		}
		else {
			brush = to_solidcolorbrush(paint.get_color());
			if(brush!=null) {
				embed "c++" {{{
					((ID2D1Brush*)brush)->SetOpacity(trans_alpha);
				}}}
			}
			if(paint is FillWrapper) {
				embed "c++" {{{
					((ID2D1RenderTarget*)target)->FillGeometry((ID2D1PathGeometry*)geometry, (ID2D1Brush*)brush);
				}}}
			}
			else if(paint is StrokeWrapper) {
				int linewidth = ((StrokeWrapper)paint).get_linewidth();
				int style = ((StrokeWrapper)paint).get_style();
				embed "c++" {{{
					ID2D1StrokeStyle* custom_stroke = NULL;
					if(style != 0) {
						((ID2D1Factory*)factory)->CreateStrokeStyle(
						D2D1::StrokeStyleProperties(
							D2D1_CAP_STYLE_FLAT,
							D2D1_CAP_STYLE_FLAT,
							D2D1_CAP_STYLE_ROUND,
							D2D1_LINE_JOIN_MITER,
							10.0f,
							(D2D1_DASH_STYLE)style,
							0.0f),
						NULL,
						0,
						&custom_stroke);
					}
					((ID2D1RenderTarget*)target)->DrawGeometry((ID2D1PathGeometry*)geometry, (ID2D1Brush*)brush, linewidth, custom_stroke);
					if(custom_stroke!=NULL) {
						custom_stroke->Release();
					}
				}}}
			}
		}
		embed "c++" {{{
			if(brush != NULL) {
				((ID2D1Brush*)brush)->Release();
			}
			((ID2D1PathGeometry*)geometry)->Release();
		}}}
		return(true);
	}

	public bool stroke(int x, int y, VgPath vp, VgTransform vt, Color c, int linewidth = 1, int style = 0) {
		if(c == null) {
			return(false);
		}
		var s = new StrokeWrapper()
			.set_linewidth(linewidth)
			.set_style(style)
			.set_x(x)
			.set_y(y)
			.set_path(vp)
			.set_transform(vt)
			.set_color(c);
		if(vp is VgPathCustom) {
			return(paint_path(s));
		}
		else {
			return(paint_shape(s));
		}
		return(false);
	}

	public bool fill_color(int x, int y, VgPath vp, VgTransform vt, Color c) {
		if(c == null) {
			return(false);
		}
		var f = new FillWrapper()
			.set_color(c)
			.set_transform(vt)
			.set_path(vp)
			.set_x(x)
			.set_y(y);
		if(vp is VgPathCustom) {
			return(paint_path(f));
		}
		else {
			return(paint_shape(f));
		}
		return(false);
	}

	public bool fill_vertical_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b) {
		if(a == null || b == null) {
			return(false);
		}
		var vgradient = new GradientWrapper()
			.set_direction(GradientWrapper.VERTICAL)
			.set_color2(b)
			.set_color(a)
			.set_x(x)
			.set_y(y)
			.set_path(vp)
			.set_transform(vt);
		if(vp is VgPathCustom) {
			return(paint_path(vgradient));
		}
		else {
			return(paint_shape(vgradient));
		}
		return(false);
	}

	public bool fill_horizontal_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b) {
		if(a == null || b == null) {
			return(false);
		}
		var hgradient = new GradientWrapper()
			.set_direction(GradientWrapper.HORIZONTAL)
			.set_color2(b)
			.set_color(a)
			.set_x(x)
			.set_y(y)
			.set_path(vp)
			.set_transform(vt);
		if(vp is VgPathCustom) {
			return(paint_path(hgradient));
		}
		else {
			return(paint_shape(hgradient));
		}
		return(false);
	}

	public bool fill_radial_gradient(int x, int y, VgPath vp, VgTransform vt, int radius, Color a, Color b) {
		if(a == null || b == null) {
			return(false);
		}
		var rgradient = new GradientWrapper()
			.set_direction(GradientWrapper.RADIAL)
			.set_radius(radius)
			.set_color2(b)
			.set_color(a)
			.set_x(x)
			.set_y(y)
			.set_path(vp)
			.set_transform(vt);
		if(vp is VgPathCustom) {
			return(paint_path(rgradient));
		}
		else {
			return(paint_shape(rgradient));
		}
		return(false);
	}

	public bool fill_diagonal_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b, int direction) {
		if(a == null || b == null) {
			return(false);
		}
		var dgradient = new GradientWrapper()
			.set_direction(GradientWrapper.DIAGONAL)
			.set_ddirection(direction)
			.set_color2(b)
			.set_color(a)
			.set_x(x)
			.set_y(y)
			.set_path(vp)
			.set_transform(vt);
		if(vp is VgPathCustom) {
			return(paint_path(dgradient));
		}
		else {
			return(paint_shape(dgradient));
		}
		return(false);
	}

	public bool draw_text(int x, int y, VgTransform vt, TextLayout text) {
		if(text is Direct2DTextLayout) {
			var dtl = (Direct2DTextLayout)text;
			draw_regular_font_text(x, y, vt, dtl);
			return(true);
		}
		else if(text is Direct2DCustomFontTextLayout) {
			var ctl = (Direct2DCustomFontTextLayout)text;
			draw_custom_font_text(x, y, vt, ctl);
			return(true);
		}
		return(false);
	}

	public bool draw_custom_font_text(int x, int y, VgTransform vt, Direct2DCustomFontTextLayout custom_layout) {
		var tprops = custom_layout.get_text_properties();
		if(tprops == null) {
			return(false);
		}
		int alignment = tprops.get_alignment();
		int wrap_width = tprops.get_wrap_width();
		double x_pos = x;
		double y_pos = y;
		double width = custom_layout.get_width();
		double height = custom_layout.get_height();
		double tail_height = custom_layout.get_tail_height();
		if(alignment == TextProperties.CENTER) {
			x_pos = x - (width * 0.5);
		}
		if((width > wrap_width && wrap_width > 0) || tprops.get_text().chr('\n') >= 0) {
			var wrapped_texts = custom_layout.get_wrapped_texts();
			if(wrapped_texts != null) {
				y_pos += custom_layout.get_initial_height() - tail_height;
				double pvot_x = x_pos + (custom_layout.get_width() / 2);
				double pvot_y = y_pos + (custom_layout.get_height() / 2);
				foreach(Direct2DCustomFontText cft in wrapped_texts) {
					double w = cft.get_width();
					double h = cft.get_height();
					ptr path = cft.get_path_geometry();
					if(alignment == TextProperties.CENTER) {
						x_pos = x - (w * 0.5);
					}
					else if(alignment == TextProperties.RIGHT) {
						x_pos = wrap_width - w;
					}
					draw_glyph(path, x_pos, y_pos, 0, w, h, vt, tprops, pvot_x, pvot_y);
					y_pos += h;
				}
			}
		}
		else {
			draw_glyph(custom_layout.get_path_geometry(), x_pos, y_pos, height - tail_height, width, height, vt, tprops);
		}
		return(true);
	}

	void draw_glyph(ptr path_geometry, double x, double y, double offset_y, double width, double height, VgTransform vt, TextProperties tprops, double pvot_x = 0, double pvot_y = 0) {
		ptr brush = to_solidcolorbrush(tprops.get_color());
		if(brush == null) {
			return;
		}
		ptr target = this.target;
		var ocolor = tprops.get_outline_color();
		double alpha = 1.0;
		double scale_x = 1.0, scale_y = 1.0;
		double rotate = 0.0, pivx = pvot_x, pivy = pvot_y;
		if(vt != null) {
			rotate = vt.get_rotate_angle() * 180.0 / MathConstant.M_PI;
			scale_x = vt.get_scale_x();
			scale_y = vt.get_scale_y();
			if(pvot_x == 0 && pvot_y == 0) {
				pivx = x + (width / 2);
				pivy = y + (height / 2);
			}
			alpha = vt.get_alpha();
		}
		ptr outline_brush = null;
		if(ocolor != null) {
			outline_brush = to_solidcolorbrush(ocolor);
			embed "c++" {{{
				((ID2D1Brush*)outline_brush)->SetOpacity(alpha);
			}}}
		}
		if(alpha < 1.0) {
			embed "c++" {{{
				((ID2D1Brush*)brush)->SetOpacity(alpha);
			}}}
		}
		embed "c++" {{{
			ID2D1PathGeometry* path = (ID2D1PathGeometry*)path_geometry;
			D2D1::Matrix3x2F matrix = D2D1::Matrix3x2F::Translation(D2D1::SizeF(x, y + offset_y));
			if(rotate != 0) {
				matrix = matrix.operator*(D2D1::Matrix3x2F::Rotation(rotate, D2D1::Point2F(pivx, pivy)));
			}
			if(scale_x != 1 || scale_y != 1) {
				matrix = matrix.operator*(D2D1::Matrix3x2F::Scale(D2D1::SizeF(scale_x, scale_y), D2D1::Point2F(pivx, pivy)));
			}
			((ID2D1RenderTarget*)target)->SetTransform(matrix);
			if(outline_brush != NULL) {
				((ID2D1RenderTarget*)target)->DrawGeometry(path, (ID2D1Brush*)outline_brush, 3);	
			}
			((ID2D1RenderTarget*)target)->FillGeometry(path, (ID2D1Brush*)brush);
			((ID2D1Brush*)brush)->Release();
			if(outline_brush != NULL) {
				((ID2D1Brush*)outline_brush)->Release();
			}
		}}}
	}

	public bool draw_regular_font_text(int x, int y, VgTransform vt, Direct2DTextLayout d2dtextlayout) {
		var wlayout = d2dtextlayout.get_write_textlayout();
		var tprop = d2dtextlayout.get_text_properties();
		ptr brush = to_solidcolorbrush(tprop.get_color());
		var target = this.target;
		int lx = x;
		int align = tprop.get_alignment();
		int width = d2dtextlayout.get_width();
		int height = d2dtextlayout.get_height();
		if(align == 1) {
			lx = x - (width/2);
		}
		else if(align == 2) {
			lx = x;
		}
		int outline_width = 3;
		var ocolor = tprop.get_outline_color();
		ptr outline_brush;
		if(outline_width > 0 && ocolor != null) {
			outline_brush = to_solidcolorbrush(ocolor);
		}
		if(wlayout != null) {
			double rotate = 0.0, pivx = 0.0, pivy = 0.0;
			double scale_x = 1.0, scale_y = 1.0;
			double trans_alpha = 1.0;
			if(vt != null) {
				rotate = vt.get_rotate_angle() * 180.0 / MathConstant.M_PI;
				scale_x = vt.get_scale_x();
				scale_y = vt.get_scale_y();
				pivx = lx + (width/2);
				pivy = y + (height/2);
				trans_alpha = vt.get_alpha();
			}
			if(brush!=null) {
				embed "c++" {{{
					((ID2D1Brush*)brush)->SetOpacity(trans_alpha);
				}}}
			}
			if(outline_brush!=null) {
				embed "c++" {{{
					((ID2D1Brush*)outline_brush)->SetOpacity(trans_alpha);
				}}}
			}
			embed "c++" {{{
				D2D1::Matrix3x2F matrix = D2D1::Matrix3x2F::Translation(D2D1::SizeF(lx, y));
				if(rotate != 0) {
					matrix = matrix.operator*(D2D1::Matrix3x2F::Rotation(rotate, D2D1::Point2F(pivx, pivy)));
				}
				if(scale_x != 1 || scale_y != 1) {
					matrix = matrix.operator*(D2D1::Matrix3x2F::Scale(D2D1::SizeF(scale_x, scale_y), D2D1::Point2F(pivx, pivy)));
				}
				((ID2D1RenderTarget*)target)->SetTransform(matrix);
				IDWriteTextLayout* ntv_wlayout = (IDWriteTextLayout*) wlayout;
				if(outline_width > 0 && outline_brush != NULL) {
					((ID2D1RenderTarget*)target)->DrawTextLayout(D2D1::Point2F(-1, -1), ntv_wlayout, (ID2D1Brush*)outline_brush);
					((ID2D1RenderTarget*)target)->DrawTextLayout(D2D1::Point2F( 0, -1), ntv_wlayout, (ID2D1Brush*)outline_brush);
					((ID2D1RenderTarget*)target)->DrawTextLayout(D2D1::Point2F( 1, -1), ntv_wlayout, (ID2D1Brush*)outline_brush);
					((ID2D1RenderTarget*)target)->DrawTextLayout(D2D1::Point2F(-1,  1), ntv_wlayout, (ID2D1Brush*)outline_brush);
					((ID2D1RenderTarget*)target)->DrawTextLayout(D2D1::Point2F( 1,  0), ntv_wlayout, (ID2D1Brush*)outline_brush);
					((ID2D1RenderTarget*)target)->DrawTextLayout(D2D1::Point2F(-1,  1), ntv_wlayout, (ID2D1Brush*)outline_brush);
					((ID2D1RenderTarget*)target)->DrawTextLayout(D2D1::Point2F( 0,  1), ntv_wlayout, (ID2D1Brush*)outline_brush);
					((ID2D1RenderTarget*)target)->DrawTextLayout(D2D1::Point2F( 1,  1), ntv_wlayout, (ID2D1Brush*)outline_brush);
				}
				((ID2D1RenderTarget*)target)->DrawTextLayout(D2D1::Point2F(0, 0), ntv_wlayout, (ID2D1Brush*)brush);
				((ID2D1Brush*)brush)->Release();
				if(outline_brush!=NULL) {
					((ID2D1Brush*)outline_brush)->Release();
				}
			}}}
		}
		else {
			return(false);
		}
		return(true);
	}

	public bool draw_graphic(int x, int y, VgTransform vt, Image agraphic) {
		if(agraphic == null) {
			return(false);
		}
		if(agraphic is CodeImage) {
			((CodeImage)agraphic).render(this, x, y, vt);
			return(true);
		}
		var d2dgraphic = agraphic as Direct2DBitmap;
		if(d2dgraphic != null) {
			ptr target = this.target;
			int w = d2dgraphic.get_width(), h = d2dgraphic.get_height();
			var d2dbitmap = d2dgraphic.get_d2dbitmap(target);
			if(d2dbitmap != null) {
				double rotate = 0.0, pivx = 0.0, pivy = 0.0;
				double scale_x = 1.0, scale_y = 1.0;
				double trans_alpha = 1.0;
				bool flipx = false;
				if(vt != null) {
					rotate = vt.get_rotate_angle() * 180.0 / MathConstant.M_PI;
					scale_x = vt.get_scale_x();
					scale_y = vt.get_scale_y();
					pivx = x + (w/2);
					pivy = y + (h/2);
					trans_alpha = vt.get_alpha();
					flipx = vt.get_flip_horizontal();
				}
				embed "c++" {{{
					D2D1::Matrix3x2F matrix = D2D1::Matrix3x2F::Translation(D2D1::SizeF(x, y));
					if(rotate != 0) {
						matrix = matrix.operator*(D2D1::Matrix3x2F::Rotation(rotate, D2D1::Point2F(pivx, pivy)));
					}
					if(scale_x != 1 || scale_y != 1) {
						matrix = matrix.operator*(D2D1::Matrix3x2F::Scale(D2D1::SizeF(scale_x, scale_y), D2D1::Point2F(pivx, pivy)));
					}
					if(flipx) {
						matrix = matrix.operator*(D2D1::Matrix3x2F(-1.0, 0.0, 0.0, 1.0, 2*(x+(((scale_x*w)/2))), 0.0));
					}
					((ID2D1RenderTarget*)target)->SetTransform(matrix);
					((ID2D1RenderTarget*)target)->SetAntialiasMode(D2D1_ANTIALIAS_MODE_PER_PRIMITIVE);
					((ID2D1RenderTarget*)target)->DrawBitmap(
						(ID2D1Bitmap*)d2dbitmap,
						D2D1::RectF(0, 0, w, h),
						(float)trans_alpha
					);
				}}}
			}
		}
		return(true);
	}

	public bool clear(int x, int y, VgPath vp, VgTransform vt) {
		clip_ops.push_clip(x, y, vp, vt);
		var target = this.target;
		embed "c++" {{{
			((ID2D1RenderTarget*)target)->Clear(D2D1::ColorF(D2D1::ColorF(0, 0.0f)));
		}}}
		clip_ops.pop_clip();
		return(true);
	}

	public bool clip(int x, int y, VgPath vp, VgTransform vt) {
		if(vp == null) {
			return(false);
		}
		clip_ops.push_clip(x, y, vp, vt);
		return(true);
	}

	public bool clip_clear() {
		clip_ops.clear();
		return(true);
	}
}
