
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

@class :
	@imports eq.gui
	@imports "Windows.UI.Xaml.Controls"
{
	@lang "cs" {{{
		public static Windows.UI.Color to_ui_color(Color color) {
			if(color == null) {
				return(Windows.UI.Colors.Black);
			}
			return(Windows.UI.Color.FromArgb((byte)(color.get_a() * 255),
				(byte)(color.get_r() * 255),
				(byte)(color.get_g() * 255),
				(byte)(color.get_b() * 255))
			);
		}

		static Windows.UI.Xaml.Shapes.Shape to_xaml_shape(Shape shape) {
			Windows.UI.Xaml.Shapes.Shape v = null;
			if(shape is RoundedRectangleShape) {
				double radius = ((RoundedRectangleShape)shape).get_radius();
				v = new Windows.UI.Xaml.Shapes.Rectangle() { 
					RadiusX = radius,
					RadiusY = radius
				};
			}
			else if(shape is RectangleShape) {
				v = new Windows.UI.Xaml.Shapes.Rectangle();
			}
			else if(shape is CircleShape) {
				v = new Windows.UI.Xaml.Shapes.Ellipse();
			}
			if(v != null) {
				v.Width = shape.get_width();
				v.Height = shape.get_height();
				return(v);
			}
			if(shape is CustomShape) {
				var cshape = (CustomShape)shape;
				double cx = cshape.get_x(), cy = cshape.get_y();
				var figure = new Windows.UI.Xaml.Media.PathFigure() {
					StartPoint = new Windows.Foundation.Point() { X = cshape.get_start_x()-cx, Y = cshape.get_start_y()-cy }
				};
				var elements = cshape.iterate();
				CustomShapeElement e = null;
				while((e = elements.next() as CustomShapeElement) != null) {
					int op = e.get_operation();
					if(op == CustomShapeElement.OP_LINE) {
						
						figure.Segments.Add(new Windows.UI.Xaml.Media.LineSegment() {
							Point = new Windows.Foundation.Point() { X = e.get_x1()-cx, Y = e.get_y1()-cy }
						});
					}
					else if(op == CustomShapeElement.OP_CURVE) {
						figure.Segments.Add(new Windows.UI.Xaml.Media.BezierSegment() {
							Point1 = new Windows.Foundation.Point() { X = e.get_x1()-cx, Y = e.get_y1()-cy },
							Point2 = new Windows.Foundation.Point() { X = e.get_x2()-cx, Y = e.get_y2()-cy },
							Point3 = new Windows.Foundation.Point() { X = e.get_x3()-cx, Y = e.get_y3()-cy }
						});
					}
					else if(op == CustomShapeElement.OP_ARC) {
						double x1 = e.get_x1()-cx, y1 = e.get_y1()-cy;
						double init_angle = e.get_angle1(), termi_angle = e.get_angle2();
						int size = (int)e.get_radius();
						double initx = eq.api.Math.cos(init_angle) * size + x1;
						double inity = eq.api.Math.sin(init_angle) * size + y1;
						double termx = eq.api.Math.cos(termi_angle) * size + x1;
						double termy = eq.api.Math.sin(termi_angle) * size + y1;
						double a1 = init_angle/eq.api.MathConstant.M_PI*180;
						double a2 = termi_angle/eq.api.MathConstant.M_PI*180;
						int adiff = (int)(a1-a2);
						if(adiff < 0) {
							adiff = (int)(a2-a1);
						}
						figure.Segments.Add(new Windows.UI.Xaml.Media.LineSegment() {
							Point = new Windows.Foundation.Point() { X = initx, Y = inity }
						});
						var arcsize = new Windows.Foundation.Size() { Width = size, Height = size };
						if(adiff % 360 > 180 || adiff % 360 == 0) {
							double mid_angle = init_angle + eq.api.MathConstant.M_PI;
							double midx = eq.api.Math.cos(mid_angle) * size + x1;
							double midy = eq.api.Math.sin(mid_angle) * size + y1;
							figure.Segments.Add(new Windows.UI.Xaml.Media.ArcSegment() {
								Point = new Windows.Foundation.Point() { X = midx, Y = midy },
								Size = arcsize,
								RotationAngle = mid_angle,
								SweepDirection = Windows.UI.Xaml.Media.SweepDirection.Clockwise,
								IsLargeArc = false
							});
						}
						figure.Segments.Add(new Windows.UI.Xaml.Media.ArcSegment() {
							Point = new Windows.Foundation.Point() { X = termx, Y = termy },
							Size = arcsize,
							RotationAngle = termi_angle,
							SweepDirection = Windows.UI.Xaml.Media.SweepDirection.Clockwise,
							IsLargeArc = false
						});
					}
					else {
					}
				}
				var pgeometry = new Windows.UI.Xaml.Media.PathGeometry() { FillRule = Windows.UI.Xaml.Media.FillRule.Nonzero };
				pgeometry.Figures.Add(figure);
				v = new Windows.UI.Xaml.Shapes.Path() {
					Data = pgeometry
				};
				return(v);
			}
			return(null);
		}

		static Windows.UI.Xaml.Media.TranslateTransform xy_to_translate(double x, double y) {
			return(new Windows.UI.Xaml.Media.TranslateTransform() { X = x, Y = y });
		}

		static void apply_transform(Windows.UI.Xaml.FrameworkElement element, Transform transform, double x, double y) {
			Windows.UI.Xaml.Media.Transform tt = xy_to_translate(x, y);
			if(transform != null) {
				double sx = transform.get_scale_x(), sy = transform.get_scale_y(), rot = transform.get_rotate_angle();
				var tg = new Windows.UI.Xaml.Media.TransformGroup();
				double w = element.ActualWidth, h = element.ActualHeight;
				if(sx != 1.0 || sy != 1.0) {
					tg.Children.Add(new Windows.UI.Xaml.Media.ScaleTransform() {
						ScaleX = sx,
						ScaleY = sy,
						CenterX = w/2,
						CenterY = h/2
					});
				}
				if(rot != 0.0) {
					tg.Children.Add(new Windows.UI.Xaml.Media.RotateTransform() {
						Angle = rot * 180 / System.Math.PI,
						CenterX = w/2,
						CenterY = h/2
					});
				}
				if(transform.get_flip_horizontal()) {
					tg.Children.Add(new Windows.UI.Xaml.Media.ScaleTransform() {
						ScaleX = -1.0,
						ScaleY = 1.0,
						CenterX = w/2,
					});
				}
				tg.Children.Add(tt);
				tt = tg;
				element.Opacity = transform.get_alpha();
			}
			element.RenderTransform = tt;
		}

		static void canvas_fill_color(Canvas canvas, double x, double y, Shape shape, Color color, Transform transform) {
			var xshape = to_xaml_shape(shape);
			if(xshape != null) {
				xshape.Fill = new Windows.UI.Xaml.Media.SolidColorBrush() { Color = to_ui_color(color) };
				apply_transform(xshape, transform, x+shape.get_x(), y+shape.get_y());
				canvas.Children.Add(xshape);
			}
		}

		static void canvas_clip(Canvas canvas, double x, double y, Shape shape, Transform transform) {
			canvas.Clip = new Windows.UI.Xaml.Media.RectangleGeometry() {
				Rect = new Windows.Foundation.Rect() {
					X = shape.get_x() + x,
					Y = shape.get_y() + y,
					Width = shape.get_width(),
					Height = shape.get_height()
				}
			};
		}

		static void canvas_clear(Canvas canvas, double x, double y, Shape shape, Transform transform) {
			//FIXME
		}

		static void canvas_fill_linear_gradient(Canvas canvas, double x, double y, Shape shape, Color color1, Color color2, Transform transform, Windows.Foundation.Point sp, Windows.Foundation.Point ep) {
			if(color1 == null || color2 == null) {
				return;
			}
			var gsc = new Windows.UI.Xaml.Media.GradientStopCollection();
			gsc.Add(new Windows.UI.Xaml.Media.GradientStop() {
				Color = to_ui_color(color1),
				Offset = 0.0	
			});
			gsc.Add(new Windows.UI.Xaml.Media.GradientStop() {
				Color = to_ui_color(color2),
				Offset = 1.0
			});
			var lgbrush = new Windows.UI.Xaml.Media.LinearGradientBrush() {
				GradientStops = gsc,
				StartPoint = sp,
				EndPoint = ep
			};
			var xshape = to_xaml_shape(shape);
			if(xshape != null) {
				xshape.Fill = lgbrush;
				apply_transform(xshape, transform, x+shape.get_x(), y+shape.get_y());
				canvas.Children.Add(xshape);
			}
		}

		static void canvas_fill_radial_gradient(Canvas canvas, double x, double y, Shape shape, Color color1, Color color2, Transform transform, double radius) {
			//FIXME: the radial gradient is not available in WinRT
			var circle = eq.gui.CircleShape.create(shape.get_x() + radius, shape.get_y() + radius, radius);
			var c1 = color1;
			var c2 = color2;
			if(c1 == null) {
				c1 = Color.black();
			}
			if(c2 == null) {
				c2 = Color.black();
			}
			Color mixed_colors = Color.instance_double((c1.get_r()+c2.get_r())/2, (c1.get_g()+c2.get_g())/2, (c1.get_b()+c2.get_b())/2, (c1.get_a()+c2.get_a())/2);
			canvas_fill_color(canvas, x, y, circle, mixed_colors, transform);
		}

		static void canvas_stroke(Canvas canvas, double x, double y, Shape shape, Color color, Transform transform, double width) {
			var xshape = to_xaml_shape(shape);
			double ax = x, ay = y;
			if(xshape != null) {
				if(width > 1) {
					ax += width/2;
					ay += width/2;
					xshape.StrokeThickness = width;
					xshape.Width = xshape.Width - width;
					xshape.Height = xshape.Height - width;
				}
				xshape.Stroke = new Windows.UI.Xaml.Media.SolidColorBrush() { Color = to_ui_color(color) };
				apply_transform(xshape, transform, ax+shape.get_x(), ay+shape.get_y());
				canvas.Children.Add(xshape);
			}
		}

		static void canvas_draw_image(Canvas canvas, double x, double y, eq.gui.Image image, Transform transform, Windows.UI.Core.CoreDispatcher d) {
			var ximage = image as XamlImage;
			if(ximage != null) {
				var bmp = ximage.get_bitmap_source(d);
				if(bmp == null) {
					return;
				}
				var imagecontrol = new Windows.UI.Xaml.Controls.Image() {
					Source = bmp,
					Width = ximage.get_width(),
					Height = ximage.get_height()
				};
				apply_transform(imagecontrol, transform, x, y);
				canvas.Children.Add(imagecontrol);
			}
		}

		static void canvas_draw_text_layout(Canvas canvas, double x, double y, TextLayout text, Transform transform) {
			var xtext = text as XamlTextLayout;
			if(xtext != null) {
				double ax = x, ay = y;
				var tp = text.get_text_properties();
				var tpsz = text as Size;
				int align = tp.get_alignment();
				if(align == TextProperties.CENTER) {
					ax = x - (tpsz.get_width()/2);
				}
				else if(align == TextProperties.RIGHT) {
					ax = x - tpsz.get_width();
				}
				var tb = xtext.get_text_block();
				apply_transform(tb, transform, ax, y);
				canvas.Children.Add(tb);
			}
		}
	
		public static void render_to(Canvas acanvas, eq.api.Collection ops) {
			if(acanvas == null || ops == null) {
				return;
			}
			int count = ops.count();
			Canvas clipcontainer = null;
			var canvas = acanvas;
			var dispatcher = Windows.UI.Core.CoreWindow.GetForCurrentThread().Dispatcher;
			for(int i = 0; i < count; i++) {
				eq.api.Object op = ops.get_index(i);
				if(op is FillColorOperation) {
					var fcop = (FillColorOperation)op;
					canvas_fill_color(canvas,
						fcop.get_x(),
						fcop.get_y(),
						fcop.get_shape(),
						fcop.get_color(),
						fcop.get_transform()
					);
				}
				else if(op is FillGradientOperation) {
					var fgop = (FillGradientOperation)op;
					double x = fgop.get_x(), y = fgop.get_y();
					Color c1 = fgop.get_color1(), c2 = fgop.get_color2();
					Shape shape = fgop.get_shape();
					Transform transform = fgop.get_transform();
					int type = fgop.get_type();
					Windows.Foundation.Point sp, ep;
					if(type != FillGradientOperation.RADIAL) {
						sp = new Windows.Foundation.Point(0.0, 0.0);
						ep = new Windows.Foundation.Point(0.0, 0.0);
					}
					if(type == FillGradientOperation.VERTICAL) {
						sp.X = 0.5; sp.Y = 0.0;
						ep.X = 0.5; ep.Y = 1.0;
						canvas_fill_linear_gradient(canvas, x, y, shape, c1, c2, transform, sp, ep);
					}
					else if(type == FillGradientOperation.HORIZONTAL) {
						sp.X = 0.0; sp.Y = 0.5;
						ep.X = 1.0; ep.Y = 0.5;
						canvas_fill_linear_gradient(canvas, x, y, shape, c1, c2, transform, sp, ep);
					}
					else if(type == FillGradientOperation.DIAGONAL_TLBR) {
						sp.X = 0.0; sp.Y = 0.0;
						ep.X = 1.0; ep.Y = 1.0;
						canvas_fill_linear_gradient(canvas, x, y, shape, c1, c2, transform, sp, ep);
					}
					else if(type == FillGradientOperation.DIAGONAL_TRBL) {
						sp.X = 1.0; sp.Y = 0.0;
						ep.X = 0.0; ep.Y = 1.0;
						canvas_fill_linear_gradient(canvas, x, y, shape, c1, c2, transform, sp, ep);
					}
					else if(type == FillGradientOperation.DIAGONAL_BRTL) {
						sp.X = 1.0; sp.Y = 1.0;
						ep.X = 0.0; ep.Y = 0.0;
						canvas_fill_linear_gradient(canvas, x, y, shape, c1, c2, transform, sp, ep);
					}
					else if(type == FillGradientOperation.DIAGONAL_BLTR) {
						sp.X = 0.0; sp.Y = 1.0;
						ep.X = 1.0; ep.Y = 0.0;
						canvas_fill_linear_gradient(canvas, x, y, shape, c1, c2, transform, sp, ep);					
					}
					else if(type == FillGradientOperation.RADIAL) {
						canvas_fill_radial_gradient(canvas, x, y, shape, c1, c2, transform, fgop.get_radius());						
					}
				}
				else if(op is StrokeOperation) {
					var stkop = (StrokeOperation)op;
					canvas_stroke(canvas,
						stkop.get_x(),
						stkop.get_y(),
						stkop.get_shape(),
						stkop.get_color(),
						stkop.get_transform(),
						stkop.get_width()
					);
				}
				else if(op is DrawObjectOperation) {
					var doop = (DrawObjectOperation)op;
					double x = doop.get_x(), y = doop.get_y();
					Transform transform = doop.get_transform();
					eq.api.Object o = doop.get_object();
					if(o is eq.gui.Image) {
						canvas_draw_image(canvas, x, y, (eq.gui.Image)o, transform, dispatcher);
					}
					else if(o is TextLayout) {
						canvas_draw_text_layout(canvas, x, y, (TextLayout)o, transform);
					}
				}
				else if(op is ClearOperation) {
					acanvas.Children.Clear();
				}
				else if(op is ClipOperation) {
					if(clipcontainer == null) {
						clipcontainer = new Canvas();
						canvas.Children.Add(clipcontainer);
					}
					canvas = new Canvas();
					var clop = (ClipOperation)op;
					canvas_clip(canvas,
						clop.get_x(),
						clop.get_y(),
						clop.get_shape(),
						clop.get_transform()
					);
					clipcontainer.Children.Add(canvas);
				}
				else if(op is ClipClearOperation) {
					if(clipcontainer != null) {
						canvas = acanvas;
						clipcontainer = null;
					}
				}
			}
		}
	}}}
}