
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

public class VgContextDrawOperations : VgContext
{
	property Collection operations;

	public VgContextDrawOperations() {
		operations = LinkedList.create();
	}

	Shape as_shape(VgPath path) {
		if(path == null) {
			return(null);
		}
		if(path is VgPathCircle) {
			var pc = (VgPathCircle)path;
			return(CircleShape.create(pc.get_xc(), pc.get_yc(), pc.get_radius()));
		}
		else if(path is VgPathRoundedRectangle) {
			var pr = (VgPathRoundedRectangle)path;
			return(RoundedRectangleShape.create(pr.get_x(), pr.get_y(), pr.get_w(), pr.get_h(), pr.get_radius()));
		}
		else if(path is VgPathRectangle) {
			var pr = (VgPathRectangle)path;
			return(RectangleShape.create(pr.get_x(), pr.get_y(), pr.get_w(), pr.get_h()));
		}
		else if(path is VgPathCustom) {
			var pc = (VgPathCustom)path;
			var cs = CustomShape.create(pc.get_start_x(), pc.get_start_y());
			foreach(VgPathElement vpe in pc.iterate()) {
				if(vpe.get_operation() == VgPathElement.OP_LINE) {
					cs.line(vpe.get_x1(), vpe.get_y1());
				}
				else if(vpe.get_operation() == VgPathElement.OP_CURVE) {
					cs.curve(vpe.get_x1(), vpe.get_y1(), vpe.get_x2(), vpe.get_y2(), vpe.get_x3(), vpe.get_y3());
				}
				else if(vpe.get_operation() == VgPathElement.OP_ARC) {
					cs.arc(vpe.get_x1(), vpe.get_y1(), vpe.get_radius(), vpe.get_angle1(), vpe.get_angle2());
				}
			}
			return(cs);
		}
		return(null);
	}

	Transform as_transform(VgTransform vt) {
		if(vt == null) {
			return(null);
		}
		var v = new Transform();
		v.set_scale_x(vt.get_scale_x());
		v.set_scale_y(vt.get_scale_y());
		v.set_rotate_angle(vt.get_rotate_angle());
		v.set_alpha(vt.get_alpha());
		v.set_flip_horizontal(vt.get_flip_horizontal());
		v.set_flip_vertical(vt.get_flip_vertical());
		return(v);
	}

	public bool stroke(int x, int y, VgPath vp, VgTransform vt, Color c, int linewidth = 1, int style = 0) {
		operations.append(new StrokeOperation().set_x(x).set_y(y).set_shape(as_shape(vp))
			.set_transform(as_transform(vt)).set_color(c).set_width(linewidth));
		return(true);
	}

	public bool fill_color(int x, int y, VgPath vp, VgTransform vt, Color c) {
		operations.append(new FillColorOperation().set_x(x).set_y(y).set_shape(as_shape(vp))
			.set_transform(as_transform(vt)).set_color(c));
		return(true);
	}

	FillGradientOperation get_gradient_operation(int x, int y, VgPath vp, VgTransform vt, Color a, Color b) {
		return(new FillGradientOperation().set_x(x).set_y(y).set_shape(as_shape(vp))
			.set_transform(as_transform(vt)).set_color1(a).set_color2(b));
	}

	public bool fill_vertical_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b) {
		operations.append(get_gradient_operation(x, y, vp, vt, a, b).set_type(FillGradientOperation.VERTICAL));
		return(true);
	}

	public bool fill_horizontal_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b) {
		operations.append(get_gradient_operation(x, y, vp, vt, a, b).set_type(FillGradientOperation.HORIZONTAL));
		return(true);
	}

	public bool fill_radial_gradient(int x, int y, VgPath vp, VgTransform vt, int radius, Color a, Color b) {
		operations.append(get_gradient_operation(x, y, vp, vt, a, b).set_type(FillGradientOperation.RADIAL)
			.set_radius(radius));
		return(true);
	}

	public bool fill_diagonal_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b, int direction) {
		if(direction == 0) {
			operations.append(get_gradient_operation(x, y, vp, vt, a, b).set_type(FillGradientOperation.DIAGONAL_TLBR));
		}
		else if(direction == 1) {
			operations.append(get_gradient_operation(x, y, vp, vt, a, b).set_type(FillGradientOperation.DIAGONAL_TRBL));
		}
		else if(direction == 2) {
			operations.append(get_gradient_operation(x, y, vp, vt, a, b).set_type(FillGradientOperation.DIAGONAL_BRTL));
		}
		else if(direction == 3) {
			operations.append(get_gradient_operation(x, y, vp, vt, a, b).set_type(FillGradientOperation.DIAGONAL_BLTR));
		}
		return(true);
	}

	public bool draw_text(int x, int y, VgTransform vt, TextLayout text) {
		operations.append(new DrawObjectOperation().set_x(x).set_y(y).set_transform(as_transform(vt))
			.set_object(text));
		return(true);
	}

	public bool draw_graphic(int x, int y, VgTransform vt, Image agraphic) {
		operations.append(new DrawObjectOperation().set_x(x).set_y(y).set_transform(as_transform(vt))
			.set_object(agraphic));
		return(true);
	}

	public bool clear(int x, int y, VgPath vp, VgTransform vt) {
		operations.append(new ClearOperation().set_x(x).set_y(y).set_shape(as_shape(vp))
			.set_transform(as_transform(vt)));
		return(true);
	}

	public bool clip(int x, int y, VgPath vp, VgTransform vt) {
		operations.append(new eq.gui.ClipOperation().set_x(x).set_y(y).set_shape(as_shape(vp))
			.set_transform(as_transform(vt)));
		return(true);
	}

	public bool clip_clear() {
		operations.append(new ClipClearOperation());
		return(true);
	}
}
