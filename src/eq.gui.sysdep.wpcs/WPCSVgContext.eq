
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

class WPCSVgContext : VgContext
{
	Rectangle dirty_area;
	embed "cs" {{{
		System.Windows.Controls.Canvas canvas;
		ClipArea clipping_area;
	
		public static WPCSVgContext create(System.Windows.Controls.Canvas canvas) {
			var v = new WPCSVgContext();
			v.canvas = canvas;
			return(v);
		}
	}}}

	embed "cs" {{{
		private void set_transform(System.Windows.FrameworkElement ui, eq.gui.vg.VgTransform vt) {
			if(vt == null) {
				return;
			}
			double scx = vt.get_scale_x(), scy = vt.get_scale_y();
			double rot = vt.get_rotate_angle();
			double alpha = vt.get_alpha();
			var tg = new System.Windows.Media.TransformGroup();
			if(scx != 1.0 || scy != 1.0) {
				var st = new System.Windows.Media.ScaleTransform() { ScaleX = scx, ScaleY = scy };
				st.CenterX = ui.ActualWidth / 2;
				st.CenterY = ui.ActualHeight / 2;
				tg.Children.Add(st);
			}
			if(rot != 0.0) {
				var rt = new System.Windows.Media.RotateTransform() { Angle = rot };
				rt.CenterX = ui.ActualWidth / 2;
				rt.CenterY = ui.ActualHeight / 2;
				tg.Children.Add(rt);
			}
			if(vt.get_flip_horizontal()) {
				var fht = new System.Windows.Media.ScaleTransform() { ScaleX = -1.0, ScaleY = scy };
				fht.CenterX = ui.ActualWidth / 2;
				tg.Children.Add(fht);
			}
			ui.RenderTransform = tg;
			ui.Opacity = alpha;
		}

		private System.Windows.Shapes.Shape path_to_shape(int x, int y, eq.gui.vg.VgPath vp, int linewidth = 1) {
			if(vp != null) {	
				int ax1 = x+vp.get_x();
				int ay1 = y+vp.get_y();
				int ax2 = ax1+vp.get_w();
				int ay2 = ay1+vp.get_h();
			}
			System.Windows.Shapes.Shape v = null;
			if(vp is eq.gui.vg.VgPathRectangle) {
				int aw = vp.get_w(), ah = vp.get_h();
				if(aw > 0 && ah > 0) {
					var rect = new System.Windows.Shapes.Rectangle();
					rect.Width = aw;
					rect.Height = ah;
					v = rect;
				}
			}
			else if(vp is eq.gui.vg.VgPathRoundedRectangle) {
				var vpr = vp as eq.gui.vg.VgPathRoundedRectangle;
				int aw = vpr.get_w(), ah = vpr.get_h(), rd = vpr.get_radius();
				if(aw > 0 && ah > 0 && rd > 0) {
					var rrect = new System.Windows.Shapes.Rectangle();
					rrect.Width = aw;
					rrect.Height = ah;
					rrect.RadiusX = rd;
					rrect.RadiusY = rd;
					v = rrect;
				}
			}
			else if(vp is eq.gui.vg.VgPathCircle) {
				var vpc = vp as eq.gui.vg.VgPathCircle;
				int rd = vpc.get_radius();
				if(rd > 0) {
					var circle = new System.Windows.Shapes.Ellipse();
					circle.Width = (rd-linewidth) * 2;
					circle.Height = (rd-linewidth) * 2;
					v = circle;
				}
			}
			else if(vp is eq.gui.vg.VgPathCustom) {
				var cp = vp as eq.gui.vg.VgPathCustom;
				var itr = cp.iterate();
				var path = new System.Windows.Shapes.Path();
				var pg = new System.Windows.Media.PathGeometry();
				var figure = new System.Windows.Media.PathFigure() {
					StartPoint = new System.Windows.Point(x+cp.get_start_x(), y+cp.get_start_y())
				};
				while(itr!=null) {
					var vpe = itr.next() as eq.gui.vg.VgPathElement;
					if(vpe == null) {
						break;
					}
					System.Windows.Media.PathSegment segment = null;
					if(vpe.get_operation() == eq.gui.vg.VgPathElement.OP_LINE) {
						segment = new System.Windows.Media.LineSegment() {
							Point = new System.Windows.Point(x+vpe.get_x1(), y+vpe.get_y1())
						};
					}
					else if(vpe.get_operation() == eq.gui.vg.VgPathElement.OP_CURVE){
						segment = new System.Windows.Media.BezierSegment() {
							Point1 = new System.Windows.Point(x+vpe.get_x1(), y+vpe.get_y1()),
							Point2 = new System.Windows.Point(x+vpe.get_x2(), y+vpe.get_y2()),
							Point3 = new System.Windows.Point(x+vpe.get_x3(), y+vpe.get_y3())
						};
					}
					else if(vpe.get_operation() == eq.gui.vg.VgPathElement.OP_ARC) {
					}
					else {
					}
					if(segment != null) {	
						figure.Segments.Add(segment);
					}
				}
				pg.Figures.Add(figure);
				path.Data = pg;
				v = path;
			}
			if(v != null && vp is eq.gui.vg.VgPathCustom == false) {
				System.Windows.Controls.Canvas.SetLeft(v, x+vp.get_x());
				System.Windows.Controls.Canvas.SetTop(v, y+vp.get_y());
			}
			if(v != null && clipping_area != null) {
				try {
					v.Clip = clipping_area.get_clip(x+vp.get_x(), y+vp.get_y());
				}
				catch(System.Exception) {}
			}
			return(v);
		}
	}}}

	private bool draw_linear_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b, double angle, double oa = 0.0, double ob = 1.0) {
		embed "cs" {{{
			var shape = path_to_shape(x, y, vp);
			if(shape != null) {
				byte aa = (byte)(a.get_a()*255), ar = (byte)(a.get_r()*255), ag = (byte)(a.get_g()*255), ab = (byte)(a.get_b()*255);
				byte ba = (byte)(b.get_a()*255), br = (byte)(b.get_r()*255), bg = (byte)(b.get_g()*255), bb = (byte)(b.get_b()*255);
				var gsa = new System.Windows.Media.GradientStop() {
					Color = System.Windows.Media.Color.FromArgb(aa, ar, ag, ab),
					Offset = oa
				};
				var gsb = new System.Windows.Media.GradientStop() {
					Color = System.Windows.Media.Color.FromArgb(ba, br, bg, bb),
					Offset = ob
				};
				var gsc = new System.Windows.Media.GradientStopCollection();
				gsc.Add(gsa);
				gsc.Add(gsb);
				shape.Fill = new System.Windows.Media.LinearGradientBrush(gsc, angle);
				set_transform(shape, vt);
				canvas.Children.Add(shape);
			}
		}}}
		return(true);
	}

	public bool stroke(int x, int y, VgPath vp, VgTransform vt, Color c, int linewidth, int style) {
		embed "cs" {{{
			var lwd2 = linewidth/2;
			var shape = path_to_shape(x+lwd2, y+lwd2, vp, lwd2);
			if(shape != null) {
				byte ca = (byte)(c.get_a()*255), cr = (byte)(c.get_r()*255), cg = (byte)(c.get_g()*255), cb = (byte)(c.get_b()*255);
				shape.Stroke = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromArgb(ca,cr,cg,cb));
				shape.StrokeThickness = linewidth;
				canvas.Children.Add(shape);
			}
		}}}
		return(true);
	}

	public bool clear(int x, int y, VgPath vp, VgTransform vt) {
		embed "cs" {{{
			canvas.Children.Clear();
		}}}
		return(true);
	}

	public bool fill_color(int x, int y, VgPath vp, VgTransform vt, Color c) {
		embed "cs" {{{
			var shape = path_to_shape(x, y, vp);
			if(shape != null) {
				byte ca = (byte)(c.get_a()*255), cr = (byte)(c.get_r()*255), cg = (byte)(c.get_g()*255), cb = (byte)(c.get_b()*255);
				shape.Fill = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromArgb(ca,cr,cg,cb));
				set_transform(shape, vt);
				canvas.Children.Add(shape);
			}
		}}}
		return(false);
	}

	public bool fill_vertical_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b) {
		return(draw_linear_gradient(x, y, vp, vt, a, b, 90));
	}

	public bool fill_horizontal_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b) {
		return(draw_linear_gradient(x, y, vp, vt, a, b, 0));
	}

	public bool fill_radial_gradient(int x, int y, VgPath vp, VgTransform vt, int radius, Color a, Color b) {
		embed "cs" {{{
			var shape = path_to_shape(x, y, vp);
			if(shape != null) {
				byte aa = (byte)(a.get_a()*255), ar = (byte)(a.get_r()*255), ag = (byte)(a.get_g()*255), ab = (byte)(a.get_b()*255);
				byte ba = (byte)(b.get_a()*255), br = (byte)(b.get_r()*255), bg = (byte)(b.get_g()*255), bb = (byte)(b.get_b()*255);
				var gsa = new System.Windows.Media.GradientStop() {
					Color = System.Windows.Media.Color.FromArgb(aa, ar, ag, ab),
					Offset = 0.0
				};
				var gsb = new System.Windows.Media.GradientStop() {
					Color = System.Windows.Media.Color.FromArgb(ba, br, bg, bb),
					Offset = 1.0
				};
				var gsc = new System.Windows.Media.GradientStopCollection();
				gsc.Add(gsa);
				gsc.Add(gsb);
				shape.Fill = new System.Windows.Media.RadialGradientBrush(gsc) {
					RadiusX = (double)radius/vp.get_h(),
					RadiusY = (double)radius/vp.get_h()
				};
				set_transform(shape, vt);
				canvas.Children.Add(shape);
			}
		}}}
		return(true);
	}

	public bool fill_diagonal_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b, int direction) {
		return(draw_linear_gradient(x, y, vp, vt, a, b, -45, 0, 0.75));
	}

	public bool draw_text(int x, int y, VgTransform vt, TextLayout text) {
		if(text != null && text is WPCSTextLayout) {
			embed "cs" {{{
				var bl = (WPCSTextLayout)text;
				double ax = x, ay = y;
				double al = bl.get_text_properties().get_alignment();
				if(al == eq.gui.TextProperties.CENTER) {
					ax = x - (bl.get_width()/2);
				}
				else if(al == eq.gui.TextProperties.RIGHT) {
					ax = x-1;
				}
				var v = bl.get_drawable_text();
				if(v != null) {
					if(clipping_area != null) {
						try {
							v.Clip = clipping_area.get_clip(ax, ay);
						}
						catch(System.Exception) {}
					}
					System.Windows.Controls.Canvas.SetLeft(v, ax);
					System.Windows.Controls.Canvas.SetTop(v, ay);
					set_transform(v, vt);
					canvas.Children.Add(v);
				}
			}}}
		}
		return(true);
	}

	public bool draw_graphic(int x, int y, VgTransform vt, Image agraphic) {
		if(agraphic is CodeImage) {
			((CodeImage)agraphic).render(this, x, y, vt);
			return(true);
		}
		if(agraphic == null || agraphic is WPCSImage == false) {
			return(false);
		}
		embed "cs" {{{
			var slbmp = (WPCSImage)agraphic;
			var bmp = slbmp.get_bmp();
			if(bmp!=null) {
				var v = new System.Windows.Controls.Image() { Width = slbmp.get_width(), Height = slbmp.get_height(), Source = bmp };
				System.Windows.Controls.Canvas.SetLeft(v, x);
				System.Windows.Controls.Canvas.SetTop(v, y);
				if(clipping_area != null) {
					try {
						v.Clip = clipping_area.get_clip(x, y);
					}
					catch(System.Exception) {}
				}
				set_transform(v, vt);
				canvas.Children.Add(v);
			}
		}}}
		return(false);
	}

	public bool clip(int x, int y, VgPath vp, VgTransform vt) {
		if(vp == null || vp is VgPathRectangle == false) {
			return(false);
		}
		embed "cs" {{{
			if(clipping_area == null) {
				clipping_area = ClipArea.create(x, y, vp, vt);
			}
			else {
				double w, h;
				if(canvas is  eq.gui.Size) {
					w = ((eq.gui.Size)canvas).get_width();
					h = ((eq.gui.Size)canvas).get_height();
				}
				else {
					w = canvas.Width;
					h = canvas.Height;
				}				
				var top = clipping_area.get_clip_bounds();
				double aw = vp.get_w(), ah = vp.get_h();
				double ax = x+vp.get_x(), ay = y+vp.get_y();
				double tw = ((eq.gui.Size)top).get_width(), th = ((eq.gui.Size)top).get_height();
				double tx = ((eq.gui.Position)top).get_x(), ty = ((eq.gui.Position)top).get_y();
				if(ax > (tx+tw) || ay > (ty+th)) {
					ax = 0;
					ay = 0;
					ah = 0;
					aw = 0;
				}
				else {
					if(ax < tx) {
						double _w = ax+aw-tx;
						if(_w <= 0) {
							ax = 0;
						}
						else {
							ax = tx;
							aw = _w;
						}
					}
					if(ay < ty) {
						double _h = ay+ah-ty;
						if(_h <= 0) {
							ay = 0;
							ah = 0;
						}
						else {
							ay = ty;
							ah = _h;
						}
					}
					if(ax >= tx) {
						double ax2 = ax+aw, tx2 = tw+tx;
						if(ax2 > tx2) {
							aw = aw - (ax2-tx2);
						}
					}
					if(ay >= ty) {
						double ay2 = ay+ah, ty2 = th+ty;
						if(ay2 > ty2) {
							ah = ah - (ay2-ty2);
						}
					}
				}
				if((ax+aw) > w) {
					if(ax < 0) {
						aw = w;
						ax = 0;
					}
					else {
						aw = w - ax;
					}
				}
				if((ay+ah) > h) {
					if(ay < 0) {
						ah = w;
						ay = 0;
					}
					else {
						ah = w - ay;
					}
				}
				clipping_area = ClipArea.create(0, 0, eq.gui.vg.VgPathRectangle.eq_gui_vg_VgPathRectangle_create((int)ax, (int)ay, (int)aw, (int)ah), vt);
			}
		}}}
		return(true);
	}

	public bool clip_clear() {
		embed "cs" {{{
			clipping_area = null;
		}}}
		return(true);
	}
}

