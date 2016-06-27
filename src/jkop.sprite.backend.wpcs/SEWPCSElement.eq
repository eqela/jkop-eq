
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

public class SEWPCSElement : SEElement
{
	public SEWPCSElement() {
		embed "cs" {{{
			canvas = new System.Windows.Controls.Canvas() { Background = null };
		}}}
	}

	embed "cs" {{{
		System.Windows.Media.ScaleTransform scale = null;
		System.Windows.Media.RotateTransform rotate = null;
		System.Windows.Controls.Canvas canvas;
			
		public System.Windows.Controls.Canvas BackendCanvas
		{
			get {
				return(canvas);
			}
		}
	}}}

	property SEResourceCache rsc;
	int x;
	int y;

	public double get_x() {
		return(x);
	}

	public double get_y() {
		return(y);
	}

	public double get_width() {
		double v;
		embed "cs" {{{
			v = canvas.ActualWidth;
		}}}
		return(v);
	}

	public double get_height() {
		double v;
		embed "cs" {{{
			v = canvas.ActualHeight;
		}}}
		return(v);
	}

	public void move(double x, double y) {
		if(this.x == x && this.y == y) {
			return;
		}
		this.x = x;
		this.y = y;
		embed "cs" {{{
			System.Windows.Controls.Canvas.SetLeft(canvas, x);
			System.Windows.Controls.Canvas.SetTop(canvas, y);
		}}}
	}
		
	public void resize_backend(double w, double h) {
		embed "cs" {{{
			if(w > 0 && h > 0) {
				canvas.Width = w;
				canvas.Height = h;
			}
		}}}
	}

	public void set_scale(double s) {
		embed "cs" {{{
			if(canvas.RenderTransform is System.Windows.Media.TransformGroup == false) {
				canvas.RenderTransform = new System.Windows.Media.TransformGroup();
			}
			if(scale == null) {
				scale = new System.Windows.Media.ScaleTransform() { ScaleX = s, ScaleY = s, CenterX = canvas.ActualWidth/2, CenterY = canvas.ActualHeight/2  };
				((System.Windows.Media.TransformGroup)canvas.RenderTransform).Children.Add(scale);
			}
			else {
				scale.ScaleX = s;
				scale.ScaleY = s;
			}
		}}}
	}

	double _alpha = 1.0;

	public void set_alpha(double a) {
		embed "cs" {{{
			if(a != _alpha) {
				canvas.Opacity = a;
			}
		}}}
		_alpha = a;
	}

	double _rotation = 0.0;

	public void set_rotation(double ra) {
		if(_rotation == ra) {
			return;
		}
		_rotation = ra;
		double aa = ra  * 180 / eq.api.MathConstant.M_PI;
		embed "cs" {{{
			if(canvas.RenderTransform is System.Windows.Media.TransformGroup == false) {
				canvas.RenderTransform = new System.Windows.Media.TransformGroup();
			}
			if(rotate == null) {
				rotate = new System.Windows.Media.RotateTransform() { Angle = aa, CenterX = canvas.ActualWidth/2, CenterY = canvas.ActualHeight/2 };
				((System.Windows.Media.TransformGroup)canvas.RenderTransform).Children.Add(rotate);
			}
			else {
				rotate.Angle = aa;
				rotate.CenterX = canvas.ActualWidth/2;
				rotate.CenterY = canvas.ActualHeight/2;
			}
		}}}
	}

	public double get_scale() {
		embed "cs" {{{
			if(scale != null) {
				return(scale.ScaleX);
			}
		}}}
		return(1.0);
	}

	public double get_alpha() {
		return(_alpha);
	}
		
	public double get_rotation() {
		return(_rotation);
	}

	public void remove_from_container() {
		embed "cs" {{{
			var p = canvas.Parent as System.Windows.Controls.Canvas;
			if(p != null) {
				p.Children.Remove(BackendCanvas);
			}
		}}}
	}
}
