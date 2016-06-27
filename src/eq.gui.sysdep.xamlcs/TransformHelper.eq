
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

@class
{
	@lang "cs" {{{
		Windows.UI.Xaml.Media.TransformGroup render_transform;
		Windows.UI.Xaml.Media.TranslateTransform ttranslate;
		Windows.UI.Xaml.Media.ScaleTransform tscale;
		Windows.UI.Xaml.Media.RotateTransform trotate;
		Windows.UI.Xaml.FrameworkElement element;

		public TransformHelper(Windows.UI.Xaml.FrameworkElement element) {
			this.element = element;
			render_transform = new Windows.UI.Xaml.Media.TransformGroup();
			element.RenderTransform = render_transform;
		}

		public void scale(double sx, double sy) {
			if(tscale == null) {
				tscale = new Windows.UI.Xaml.Media.ScaleTransform();
				render_transform.Children.Add(tscale);
			}
			tscale.ScaleX = sx;
			tscale.ScaleY = sy;
			tscale.CenterX = element.ActualWidth / 2;
			tscale.CenterY = element.ActualHeight / 2;
		}

		public void rotate(double a) {
			var aa = a * 180 / eq.api.MathConstant.M_PI;
			if(trotate == null) {
				trotate = new Windows.UI.Xaml.Media.RotateTransform();
				render_transform.Children.Insert(0, trotate);
			}
			trotate.Angle = aa;
			trotate.CenterX = element.ActualWidth / 2;
			trotate.CenterY = element.ActualHeight /2;			
		}

		public void translate(double x, double y) {
			if(ttranslate == null) {
				ttranslate = new Windows.UI.Xaml.Media.TranslateTransform();
				render_transform.Children.Add(ttranslate);
			}
			ttranslate.X = x;
			ttranslate.Y = y;
		}

		public double get_x() {
			if(ttranslate != null) {
				return(ttranslate.X);
			}
			return(0);
		}

		public double get_y() {
			if(ttranslate != null) {
				return(ttranslate.Y);
			}
			return(0);
		}

		public double get_scale_x() {
			if(tscale != null) {
				return(tscale.ScaleX);
			}
			return(1.0);			
		}

		public double get_scale_y() {
			if(tscale != null) {
				return(tscale.ScaleY);
			}
			return(1.0);
		}

		public double get_rotation_angle() {
			if(trotate != null) {
				return(trotate.Angle * (eq.api.MathConstant.M_PI / 180));
			}
			return(0.0);
		}
	}}}
}