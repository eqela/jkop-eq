
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

package eq.gui.sysdep.swing;

import eq.gui.*;

public class AWTGraphics2DRenderer
{
	static java.awt.geom.AffineTransform save_at = null;
	static eq.gui.CustomShapeElement _cshape = new eq.gui.CustomShapeElement();
	static eq.api.MathConstant _math = new eq.api.MathConstant();
	static eq.gui.TextProperties _text = new eq.gui.TextProperties();
	static eq.gui.FillGradientOperation _fgo = new eq.gui.FillGradientOperation();

	static void save_transform(java.awt.Graphics2D g) {
		if(save_at != null) {
			System.out.println("[WARNING] Saved new transform matrix without restoring the previously saved.");
		}
		save_at = g.getTransform();
	}

	static void restore_transform(java.awt.Graphics2D g) {
		if(save_at != null) {
			g.setTransform(save_at);
			save_at = null;
		}
	}

	static java.awt.geom.AffineTransform create_awt_transform(java.awt.Shape shape, Transform transform, int x, int y) {
		java.awt.geom.AffineTransform v = new java.awt.geom.AffineTransform();
		v.translate(x, y);
		if(transform != null && transform.is_noop() == false) {
			double sx = transform.get_scale_x(), sy = transform.get_scale_y(), rot = transform.get_rotate_angle();
			double w2 = shape.getBounds().width/2, h2 = shape.getBounds().height/2;
			double ox = shape.getBounds().x, oy = shape.getBounds().y;
			if(sx != 1.0 || sy != 1.0) {
				v.translate(ox+w2, oy+h2);
				v.scale(sx, sy);
				v.translate(-(ox+w2), -(oy+h2));
			}
			if(rot != 0.0) {
				v.translate(ox+w2, oy+h2);
				v.rotate(rot);
				v.translate(-(ox+w2), -(oy+h2));
			}
			if(transform.get_flip_horizontal()) {
				v.translate(ox+w2, oy);
				v.scale(-1, 1);
				v.translate(-(ox+w2), oy);
			}
		}
		return(v);
	}

	static double get_alpha(Transform t) {
		if(t != null) {
			return(t.get_alpha());
		}
		return(1.0);
	}

	static java.awt.Color get_awt_color(Color color, double alpha) {
		if(color == null) {
			return(java.awt.Color.black);
		}
		return(new java.awt.Color((int)(color.get_r()*255), (int)(color.get_g()*255), (int)(color.get_b()*255), (int)(color.get_a()*255*alpha)));
	}

	static java.awt.Shape to_awt_shape(Shape shape) {
		return(to_awt_shape(shape, 0));
	}

	static java.awt.Shape to_awt_shape(Shape shape, int sw) {
		java.awt.Shape v = null;
		if(shape instanceof RoundedRectangleShape) {
			RoundedRectangleShape rr = (RoundedRectangleShape)shape;
			double diameter = rr.get_radius() * 2;
			v = new java.awt.geom.RoundRectangle2D.Double(rr.get_x(), rr.get_y(), rr.get_width()-sw, rr.get_height(), diameter-sw, diameter-sw);
		}
		else if(shape instanceof RectangleShape) {
			RectangleShape r = (RectangleShape)shape;
			v = new java.awt.geom.Rectangle2D.Double(r.get_x(), r.get_y(), r.get_width()-sw, r.get_height()-sw);
		}
		else if(shape instanceof CircleShape) {
			CircleShape c = (CircleShape)shape;
			v  = new java.awt.geom.Ellipse2D.Double(c.get_x(), c.get_y(), c.get_width()-sw, c.get_height()-sw);
		}
		else if(shape instanceof CustomShape) {
			CustomShape cus = (CustomShape)shape;
			java.awt.geom.Path2D.Double path = new java.awt.geom.Path2D.Double();
			path.moveTo(cus.get_start_x()+sw, cus.get_start_y()-sw);
			eq.api.Iterator itr = cus.iterate();
			while(itr != null) {
				eq.gui.CustomShapeElement cse = (eq.gui.CustomShapeElement)itr.next();
				if(cse == null) {
					break;
				}
				int op = cse.get_operation();
				if(op == _cshape.OP_LINE) {
					path.lineTo(cse.get_x1()+sw, cse.get_y1()-sw);
				}
				else if(op == _cshape.OP_CURVE) {
					path.curveTo(
						cse.get_x1()+sw, cse.get_y1()-sw,
						cse.get_x2()+sw, cse.get_y2()-sw,
						cse.get_x3()+sw, cse.get_y3()-sw
					);
				}
				else if(op == _cshape.OP_ARC) {
					double a1 = cse.get_angle1() * 180/_math.M_PI;
					double a2 = cse.get_angle2() * 180/_math.M_PI;
					a1 %= 360;
					a2 %= 360;
					double sweep = 360-(a1-a2);
					if(a1 < a2) {
						sweep = a2-a1;
					}
					if(sweep == 0) {
						sweep = 360;
					}
					java.awt.geom.Arc2D.Double arc = new java.awt.geom.Arc2D.Double();
					arc.setArcByCenter(
						cse.get_x1()+sw, cse.get_y1()-sw,
						cse.get_radius(),
						-a1, -sweep,
						java.awt.geom.Arc2D.OPEN
					);
					path.append(arc.getPathIterator(null), true);
				}
			}
			v = path;
		}
		return(v);
	}

	static void graphics_fill_color(java.awt.Graphics2D g, int x, int y, Shape shape, Color color, Transform transform) {
		java.awt.Shape as = to_awt_shape(shape);
		if(as == null) {
			return;
		}
		g.setPaint(get_awt_color(color, get_alpha(transform)));
		java.awt.geom.AffineTransform trans = create_awt_transform(as, transform, x, y);
		save_transform(g);
		{
			g.transform(trans);
			g.fill(as);
		}
		restore_transform(g);
	}

	static void graphics_stroke(java.awt.Graphics2D g, int x, int y, Shape shape, Color color, Transform atransform, int width) {
		java.awt.Shape as = to_awt_shape(shape, width*2);
		if(as == null) {
			return;
		}
		Transform transform = atransform;
		g.setPaint(get_awt_color(color, get_alpha(transform)));
		java.awt.geom.AffineTransform trans = create_awt_transform(as, transform, x+width, y+width);
		save_transform(g);
		{
			g.transform(trans);
			g.setStroke(new java.awt.BasicStroke(width, java.awt.BasicStroke.CAP_SQUARE, java.awt.BasicStroke.JOIN_MITER));
			g.setRenderingHint(java.awt.RenderingHints.KEY_ANTIALIASING, java.awt.RenderingHints.VALUE_ANTIALIAS_ON);
			g.draw(as);
		}
		restore_transform(g);
	}

	static void graphics_fill_gradient(java.awt.Graphics2D g, int x, int y, java.awt.MultipleGradientPaint paint, java.awt.Shape awt_shape, Transform transform) {
		g.setPaint(paint);
		java.awt.geom.AffineTransform trans = create_awt_transform(awt_shape, transform, x, y);
		save_transform(g);
		{
			g.transform(trans);
			g.fill(awt_shape);
		}
		restore_transform(g);
	}

	static void graphics_draw_image(java.awt.Graphics2D g, int x, int y, Image img, Transform transform) {
		if(img == null || img instanceof AWTImage == false) {
			return;
		}
		AWTImage aimg = (AWTImage)img;
		java.awt.image.BufferedImage awt_image = aimg.get_awt_image();
		if(awt_image == null) {
			return;
		}
		java.awt.Shape awt_shape = new java.awt.geom.Rectangle2D.Double(0, 0, aimg.get_width(), aimg.get_height());
		java.awt.geom.AffineTransform trans = create_awt_transform(awt_shape, transform, x, y);
		{
			java.awt.image.AffineTransformOp op = new java.awt.image.AffineTransformOp(trans, java.awt.image.AffineTransformOp.TYPE_BILINEAR);
			g.drawImage(awt_image, op, 0, 0);
		}
	}

	static void draw_awt_text_layout(java.awt.Graphics2D g, java.awt.font.TextLayout tl, int alignment, int xoff, int yoff) {
		int ax = xoff, ay = yoff;
		if(alignment == _text.CENTER) {
			ax = (int)(ax-tl.getAdvance()/2);
		}
		else if(alignment == _text.RIGHT) {
			ax = (int)(ax+tl.getAdvance());
		}
		tl.draw(g, ax, ay);
	}

	static void graphics_draw_text_layout(java.awt.Graphics2D g, int x, int y, TextLayout layout, Transform transform) {
		if(layout == null || layout instanceof AWTTextLayout == false) {
			return;
		}
		AWTTextLayout tl = (AWTTextLayout)layout;
		java.awt.Shape awt_shape = new java.awt.geom.Rectangle2D.Double(0, 0, tl.get_width(), tl.get_height());
		java.text.AttributedString ats = tl.get_attributed_string();
		if(tl != null) {
			save_transform(g);
			{
				TextProperties tp = tl.get_text_properties();
				java.awt.Color cp = get_awt_color(tp.get_color(), get_alpha(transform));
				eq.api.String str = tp.get_text();
				int ta = tp.get_alignment();
				java.awt.geom.AffineTransform trans = create_awt_transform(awt_shape, transform, x, y);
				java.awt.font.FontRenderContext frc  = tl.get_font_render_context();
				int ww = tp.get_wrap_width();
				g.transform(trans);
				g.setPaint(cp);
				if(ww > 0) {
					java.awt.font.LineBreakMeasurer measurer = new java.awt.font.LineBreakMeasurer(ats.getIterator(), frc);
					int offset_y = 0;
					while(measurer.getPosition() < str.get_length()) {
						java.awt.font.TextLayout atl = measurer.nextLayout(ww);
						offset_y += atl.getAscent();
						draw_awt_text_layout(g, atl, ta, 0, offset_y);
						offset_y += atl.getLeading() + atl.getDescent();
					}
				}
				else {
					java.awt.font.TextLayout atl = new java.awt.font.TextLayout(ats.getIterator(), frc);
					int ay = (int)(atl.getAscent());
					draw_awt_text_layout(g, atl, ta, 0, ay);
				}
			}
			restore_transform(g);
		}
	}

	static void graphics_clip(java.awt.Graphics2D g, int x, int y, Shape shape, Transform transform) {
		java.awt.Shape as = to_awt_shape(shape);
		if(as == null) {
			return;
		}
		java.awt.geom.AffineTransform trans = create_awt_transform(as, transform, x, y);
		save_transform(g);
		{
			g.transform(trans);
			g.clip(as);
		}
		restore_transform(g);
	}

	public static void render_with(java.awt.Graphics2D graphics, eq.api.Collection ops) {
		if(ops == null || ops instanceof eq.api.Iterateable == false) {
			return;
		}
		eq.api.Iterator itr = ((eq.api.Iterateable)ops).iterate();
		Object op = null;
		while((op = itr.next()) != null) {
			if(op instanceof FillColorOperation) {
				FillColorOperation fcop = (FillColorOperation)op;
				graphics_fill_color(graphics,
					(int)fcop.get_x(),
					(int)fcop.get_y(),
					fcop.get_shape(),
					fcop.get_color(),
					fcop.get_transform()
				);
			}
			else if(op instanceof FillGradientOperation) {
				FillGradientOperation fgop = (FillGradientOperation)op;
				java.awt.Shape as  = to_awt_shape(fgop.get_shape());
				if(as == null) {
					continue;
				}
				Color c1 = fgop.get_color1(), c2 = fgop.get_color2();
				Transform transform = fgop.get_transform();
				int type = fgop.get_type();
				double x = fgop.get_x(), y = fgop.get_y();
				double w = as.getBounds().width, h = as.getBounds().height;
				double ox = as.getBounds().x, oy = as.getBounds().y;
				if(w == 0 || h == 0) {
					return;
				}
				java.awt.Color[] colors = { get_awt_color(c1, get_alpha(transform)), get_awt_color(c2, get_alpha(transform)) };
				float[] fract = { 0.0f, 1.0f };
				if(type == _fgo.VERTICAL) {
					java.awt.LinearGradientPaint vlgp = new java.awt.LinearGradientPaint(
						new java.awt.geom.Point2D.Double(ox+w/2, oy),
						new java.awt.geom.Point2D.Double(ox+w/2, oy+h),
						fract,
						colors
					);
					graphics_fill_gradient(graphics, (int)x, (int)y, vlgp, as, transform);
				}
				else if(type == _fgo.HORIZONTAL) {
					java.awt.LinearGradientPaint hlgp = new java.awt.LinearGradientPaint(
						new java.awt.geom.Point2D.Double(ox, oy+h/2),
						new java.awt.geom.Point2D.Double(ox+w, oy+h/2),
						fract,
						colors
					);
					graphics_fill_gradient(graphics, (int)x, (int)y, hlgp, as, transform);
				}
				else if(type == _fgo.DIAGONAL_TLBR) {
					java.awt.LinearGradientPaint tlbr = new java.awt.LinearGradientPaint(
						new java.awt.geom.Point2D.Double(ox,oy),
						new java.awt.geom.Point2D.Double(ox+w,oy+h),
						fract,
						colors
					);
					graphics_fill_gradient(graphics, (int)x, (int)y, tlbr, as, transform);
				}
				else if(type == _fgo.DIAGONAL_TRBL) {
					java.awt.LinearGradientPaint trbl = new java.awt.LinearGradientPaint(
						new java.awt.geom.Point2D.Double(ox+w,oy),
						new java.awt.geom.Point2D.Double(ox,oy+h),
						fract,
						colors
					);
					graphics_fill_gradient(graphics, (int)x, (int)y, trbl, as, transform);
				}
				else if(type == _fgo.DIAGONAL_BLTR) {
					java.awt.LinearGradientPaint bltr = new java.awt.LinearGradientPaint(
						new java.awt.geom.Point2D.Double(ox,oy+h),
						new java.awt.geom.Point2D.Double(ox+w,oy),
						fract,
						colors
					);
					graphics_fill_gradient(graphics, (int)x, (int)y, bltr, as, transform);
				}
				else if(type == _fgo.DIAGONAL_BRTL) {
					java.awt.LinearGradientPaint brtl = new java.awt.LinearGradientPaint(
						new java.awt.geom.Point2D.Double(ox+w,oy+h),
						new java.awt.geom.Point2D.Double(ox,oy),
						fract,
						colors
					);
					graphics_fill_gradient(graphics, (int)x, (int)y, brtl, as, transform);
				}
				else if(type == _fgo.RADIAL) {
					double radius = fgop.get_radius();
					java.awt.RadialGradientPaint rad = new java.awt.RadialGradientPaint(
						new java.awt.geom.Point2D.Double(ox+w/2,oy+h/2),
						(float)radius,
						fract,
						colors
					);
					graphics_fill_gradient(graphics, (int)x, (int)y, rad, as, transform);
				}
			}
			else if(op instanceof StrokeOperation) {
				StrokeOperation stkop = (StrokeOperation)op;
				graphics_stroke(graphics,
					(int)stkop.get_x(),
					(int)stkop.get_y(),
					stkop.get_shape(),
					stkop.get_color(),
					stkop.get_transform(),
					(int)stkop.get_width()
				);
			}
			else if(op instanceof DrawObjectOperation) {
				DrawObjectOperation doop = (DrawObjectOperation)op;
				int x = (int)doop.get_x(), y = (int)doop.get_y();
				Transform transform = doop.get_transform();
				eq.api.Object o = doop.get_object();
				if(o instanceof Image) {
					graphics_draw_image(graphics, x, y, (Image)o, transform);
				}
				else if(o instanceof TextLayout) {
					graphics_draw_text_layout(graphics, x, y, (TextLayout)o, transform);
				}
			}
			else if(op instanceof ClearOperation) {
				ClearOperation clrop = (ClearOperation)op;
				Shape shape = clrop.get_shape();
				if(shape == null) {
					continue;
				}
				graphics.clearRect((int)(clrop.get_x()+shape.get_x()), (int)(clrop.get_y()+shape.get_y()), (int)shape.get_width(), (int)shape.get_height());
			}
			else if(op instanceof ClipOperation) {
				ClipOperation cop = (ClipOperation)op;
				graphics_clip(graphics,
					(int)cop.get_x(),
					(int)cop.get_y(),
					cop.get_shape(),
					cop.get_transform()	
				);
			}
			else if(op instanceof ClipClearOperation) {
				graphics.setClip(null);
			}
		}
	}
}