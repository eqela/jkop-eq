
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

@class : XamlPanelFrame
{
	@lang "cs" {{{
		Windows.UI.Core.CoreDispatcher main_dispatcher;
		int id;

		public XamlSecondaryPanelFrame(Windows.UI.Core.CoreDispatcher dispatcher) {
			main_dispatcher = dispatcher;
		}

		public override void close() {
			base.close();
			var pp = Parent as Windows.UI.Xaml.Controls.Primitives.Popup;
			if(pp != null) {
				var ppp = pp.Parent as XamlPanelFrame;
				if(ppp != null) {
					ppp.enable_inputs();
					ppp.Children.Remove(pp);
				}
				pp.IsOpen = false;
				return;
			}
			if(main_dispatcher != Windows.UI.Xaml.Window.Current.Dispatcher) {
				Windows.UI.Xaml.Window.Current.Close();
			}
		}

		public void reposition_popup(double w, double h) {
			var pp = Parent as Windows.UI.Xaml.Controls.Primitives.Popup;
			if(pp != null) {
				var pf = pp.Parent as XamlPanelFrame;
				if(pf == null) {
					return;
				}
				var gt = pf.TransformToVisual(null);
				var pt = gt.TransformPoint(new Windows.Foundation.Point(0, 0));
				pp.HorizontalOffset = w/2-(ActualWidth / 2) - pt.X;
				pp.VerticalOffset = h/2-(ActualHeight / 2) - pt.Y;
			}
		}

		public override void on_window_resized(object sender, Windows.UI.Core.WindowSizeChangedEventArgs args) {
			var sz = args.Size;
			if(sz != null) {
				reposition_popup(sz.Width, sz.Height);
			}
		}

		public override void on_unloaded(object sender, Windows.UI.Xaml.RoutedEventArgs e) {
		}

		public override void on_loaded(object sender, Windows.UI.Xaml.RoutedEventArgs e) {
			base.on_loaded(sender, e);
			var bounds = Windows.UI.Xaml.Window.Current.Bounds;
			if(bounds != null) {
				reposition_popup(bounds.Width, bounds.Height);
			}
		}
	}}}
}
