
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

public class VgRenderer
{
	static VgPath as_vg_path(Shape shape) {
		if(shape == null) {
			return(null);
		}
		if(shape is CircleShape) {
			var cs = (CircleShape)shape;
			return(VgPathCircle.create(cs.get_xc(), cs.get_yc(), cs.get_radius()));
		}
		else if(shape is RoundedRectangleShape) {
			var rs = (RoundedRectangleShape)shape;
			return(VgPathRoundedRectangle.create(rs.get_x(), rs.get_y(), rs.get_width(), rs.get_height(), rs.get_radius()));
		}
		else if(shape is RectangleShape) {
			var rs = (RectangleShape)shape;
			return(VgPathRectangle.create(rs.get_x(), rs.get_y(), rs.get_width(), rs.get_height()));
		}
		else if(shape is CustomShape) {
			var rs = (CustomShape)shape;
			var vp = VgPathCustom.create(rs.get_start_x(), rs.get_start_y());
			var it = rs.iterate();
			CustomShapeElement cse;
			while((cse = it.next() as CustomShapeElement) != null) {
				if(cse.get_operation() == CustomShapeElement.OP_LINE) {
					vp.line(cse.get_x1(), cse.get_y1());
				}
				else if(cse.get_operation() == CustomShapeElement.OP_CURVE) {
					vp.curve(cse.get_x1(), cse.get_y1(), cse.get_x2(), cse.get_y2(), cse.get_x3(), cse.get_y3());
				}
				else if(cse.get_operation() == CustomShapeElement.OP_ARC) {
					vp.arc(cse.get_x1(), cse.get_y1(), cse.get_radius(), cse.get_angle1(), cse.get_angle2());
				}
			}
			return(vp);
		}
		return(null);
	}

	static VgTransform as_vg_transform(Transform transform) {
		if(transform == null) {
			return(null);
		}
		var v = new VgTransform();
		v.set_scale_x(transform.get_scale_x());
		v.set_scale_y(transform.get_scale_y());
		v.set_rotate_angle(transform.get_rotate_angle());
		v.set_alpha(transform.get_alpha());
		v.set_flip_horizontal(transform.get_flip_horizontal());
		v.set_flip_vertical(transform.get_flip_vertical());
		return(v);
	}

	public static void render_to_vg_context(Collection ops, VgContext ctx, int x = 0, int y = 0) {
		if(ctx == null || ops == null) {
			return;
		}
		foreach(var o in ops) {
			if(o is FillColorOperation) {
				var fco = (FillColorOperation)o;
				ctx.fill_color((int)(x+fco.get_x()), (int)(y+fco.get_y()), as_vg_path(fco.get_shape()),
					as_vg_transform(fco.get_transform()), fco.get_color());
			}
			else if(o is ClearOperation) {
				var oo = (ClearOperation)o;
				ctx.clear((int)(x+oo.get_x()), (int)(y+oo.get_y()), as_vg_path(oo.get_shape()), as_vg_transform(oo.get_transform()));
			}
			else if(o is ClipClearOperation) {
				var oo = (ClipClearOperation)o;
				ctx.clip_clear();
			}
			else if(o is ClipOperation) {
				var oo = (ClipOperation)o;
				ctx.clip((int)(x+oo.get_x()), (int)(y+oo.get_y()), as_vg_path(oo.get_shape()), as_vg_transform(oo.get_transform()));
			}
			else if(o is DrawObjectOperation) {
				var oo = (DrawObjectOperation)o;
				var ob = oo.get_object();
				if(ob is Image) {
					ctx.draw_graphic((int)(x+oo.get_x()), (int)(y+oo.get_y()), as_vg_transform(oo.get_transform()), (Image)ob);
				}
				else if(ob is TextLayout) {
					ctx.draw_text((int)(x+oo.get_x()), (int)(y+oo.get_y()), as_vg_transform(oo.get_transform()), (TextLayout)ob);
				}
			}
			else if(o is FillGradientOperation) {
				var oo = (FillGradientOperation)o;
				if(oo.get_type() == FillGradientOperation.VERTICAL) {
					ctx.fill_vertical_gradient((int)(x+oo.get_x()), (int)(y+oo.get_y()), as_vg_path(oo.get_shape()),
						as_vg_transform(oo.get_transform()), oo.get_color1(), oo.get_color2());
				}
				else if(oo.get_type() == FillGradientOperation.HORIZONTAL) {
					ctx.fill_horizontal_gradient((int)(x+oo.get_x()), (int)(y+oo.get_y()), as_vg_path(oo.get_shape()),
						as_vg_transform(oo.get_transform()), oo.get_color1(), oo.get_color2());
				}
				else if(oo.get_type() == FillGradientOperation.RADIAL) {
					ctx.fill_radial_gradient((int)(x+oo.get_x()), (int)(y+oo.get_y()), as_vg_path(oo.get_shape()),
						as_vg_transform(oo.get_transform()), oo.get_radius(), oo.get_color1(), oo.get_color2());
				}
				else if(oo.get_type() == FillGradientOperation.DIAGONAL_TLBR) {
					ctx.fill_diagonal_gradient((int)(x+oo.get_x()), (int)(y+oo.get_y()), as_vg_path(oo.get_shape()),
						as_vg_transform(oo.get_transform()), oo.get_color1(), oo.get_color2(), 0);
				}
				else if(oo.get_type() == FillGradientOperation.DIAGONAL_TRBL) {
					ctx.fill_diagonal_gradient((int)(x+oo.get_x()), (int)(y+oo.get_y()), as_vg_path(oo.get_shape()),
						as_vg_transform(oo.get_transform()), oo.get_color1(), oo.get_color2(), 1);
				}
				else if(oo.get_type() == FillGradientOperation.DIAGONAL_BRTL) {
					ctx.fill_diagonal_gradient((int)(x+oo.get_x()), (int)(y+oo.get_y()), as_vg_path(oo.get_shape()),
						as_vg_transform(oo.get_transform()), oo.get_color1(), oo.get_color2(), 2);
				}
				else if(oo.get_type() == FillGradientOperation.DIAGONAL_BLTR) {
					ctx.fill_diagonal_gradient((int)(x+oo.get_x()), (int)(y+oo.get_y()), as_vg_path(oo.get_shape()),
						as_vg_transform(oo.get_transform()), oo.get_color1(), oo.get_color2(), 3);
				}
			}
			else if(o is StrokeOperation) {
				var oo = (StrokeOperation)o;
				ctx.stroke((int)(x+oo.get_x()), (int)(y+oo.get_y()), as_vg_path(oo.get_shape()), as_vg_transform(oo.get_transform()),
					oo.get_color(), oo.get_width(), 0);
			}
		}
	}
}
