
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

namespace eq.gui.sysdep.wpcs
{
	using System;
	using System.Windows;
	using System.Windows.Controls;
	using System.Windows.Input;
	using System.Windows.Media;

	public class ContainerSurfaceCanvas : Canvas, eq.gui.Surface, eq.gui.Size, eq.gui.Position
	{
		bool intercept_horizontal = false;
		bool intercept_vertical = false;
		bool is_renderable = false;

		public ContainerSurfaceCanvas() {
			is_renderable = this is eq.gui.Renderable;
		}
	
		Point get_ui_position(Canvas canvas) {
			Point v = new Point(0, 0);
			if(canvas != null) {
				var gt = canvas.TransformToVisual(canvas.Parent as UIElement);
				v = gt.Transform(new Point(0, 0));
			}
			return(v);
		}
	
		bool is_valid_double(double v) {
			return(double.IsNaN(v) == false  && v  > 0);
		}

		public double get_height() {
			double v = 0;
			if(is_valid_double(this.ActualHeight)) {
				v = this.ActualHeight;
			}
			else if(is_valid_double(this.Height)) {
				v = this.Height;
			}
			return(v);
		}

		public double get_width() {
			double v = 0;
			if(is_valid_double(this.ActualWidth)) {
				v = this.ActualWidth;
			}
			else if(is_valid_double(this.Width)) {
				v = this.Width;
			}
			return(v);
		}

		public double get_x() {
			return(get_ui_position((Canvas)this).X);
		}

		public double get_y() {
			return(get_ui_position((Canvas)this).Y);
		}

		public void resize(double w, double h) {
			if(is_valid_double(w) && is_valid_double(h)) {
				this.Height = h;
				this.Width = w;
				update_clip(w, h);
			}
		}
		
		public void move(double x, double y) {			
			layout_override(x, y, 0, 0);
		}

		public void move_resize(double x, double y, double w, double h) {
			layout_override(x, y, w, h);
			update_clip(w, h);
		}
		
		void layout_override(double x, double y, double w, double h) {
			Canvas.SetLeft(this, x);
			Canvas.SetTop(this, y);
			if(is_valid_double(w) && is_valid_double(h)) {
				this.Width = w;
				this.Height = h;
				update_clip(w, h);
			}
		}
		
		void update_clip(double w, double h) {
			Clip = new RectangleGeometry() { Rect = new Rect(0, 0, w, h) };
		}

		double _alpha = 1.0;

		public void set_alpha(double a) {
			if(a != _alpha) {
				this.Opacity = a;
			}
			_alpha = a;
		}

		ScaleTransform scale = null;
		RotateTransform rotate = null;

		public void set_scale(double sx, double sy) {
			if(RenderTransform is TransformGroup == false) {
				RenderTransform = new TransformGroup();
			}
			if(scale == null) {
				scale = new ScaleTransform() { ScaleX = sx, ScaleY = sy, CenterX = ActualWidth/2, CenterY = ActualHeight/2  };
				((TransformGroup)RenderTransform).Children.Add(scale);
			}
			else {
				scale.ScaleX = sx;
				scale.ScaleY = sy;
			}
		}

		public void set_rotation_angle(double ra) {
			double aa = ra * 180 / eq.api.MathConstant.M_PI;
			if(RenderTransform is TransformGroup == false) {
				RenderTransform = new TransformGroup();
			}
			if(rotate == null) {
				rotate = new RotateTransform() { Angle = aa, CenterX = ActualWidth/2, CenterY = ActualHeight/2 };
				((TransformGroup)RenderTransform).Children.Add(rotate);
			}
			else {
				rotate.Angle = aa;
				rotate.CenterX = ActualWidth/2;
				rotate.CenterY = ActualHeight/2;
			}
		}

		public double get_scale_x() {
			if(scale != null) {
				return(scale.ScaleX);
			}
			return(1.0);
		}

		public double get_scale_y() {
			if(scale != null) {
				return(scale.ScaleY);
			}
			return(1.0);
		}

		public double get_alpha() {
			return(_alpha);
		}
		
		public double get_rotation_angle() {
			if(rotate != null) {
				return(rotate.Angle * (eq.api.MathConstant.M_PI / 180));
			}
			return(0);
		}

		private eq.api.Object eqstr(System.String csstr) {
			return((eq.api.Object)eq.api.StringStatic.eq_api_StringStatic_for_strptr(csstr));
		}
	}
}
