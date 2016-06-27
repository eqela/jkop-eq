
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

@class : @extends $magical<Windows.UI.Xaml.Controls.Canvas>, Surface, Size, Position, Renderable
	@imports eq.api
	@imports eq.gui
{
	@lang "cs" {{{
		TransformHelper helper = null;

		public XamlCanvasSurface() {
			helper = new TransformHelper(this);
		}

		public void move(double x, double y) {
			helper.translate(x, y);
		}

		public void resize(double w, double h) {
			if(w < 0 || h < 0) {
				return;
			}
			Width = w;
			Height = h;
			UpdateLayout();
			Clip = new Windows.UI.Xaml.Media.RectangleGeometry() { Rect = new Windows.Foundation.Rect(0, 0, w, h) };
		}

		public void move_resize(double x, double y, double w, double h) {
			move(x, y);
			resize(w, h);
		}

		public void set_scale(double sx, double sy) {
			helper.scale(sx, sy);
		}

		public void set_alpha(double f) {
			Opacity = f;
		}

		public void set_rotation_angle(double a) {
			helper.rotate(a);
		}

		public double get_width() {
			return((int)ActualWidth);
		}

		public double get_height() {
			return((int)ActualHeight);
		}

		public double get_x() {
			return(helper.get_x());
		}

		public double get_y() {
			return(helper.get_y());
		}

		public double get_scale_x() {
			return(helper.get_scale_x());
		}

		public double get_scale_y() {
			return(helper.get_scale_y());
		}

		public double get_alpha() {
			return(Opacity);
		}

		public double get_rotation_angle() {
			return(helper.get_rotation_angle());
		}

		public void render(eq.api.Collection ops) {
			this.Children.Clear();
			XamlCanvasRenderer.render_to(this, ops);
		}
	}}}
}