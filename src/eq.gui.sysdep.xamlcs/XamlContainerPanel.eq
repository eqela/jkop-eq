
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

#public @class : @extends $magical<Windows.UI.Xaml.Controls.Panel>, Size
	@imports eq.gui
{
	@lang "cs" {{{
		protected override Windows.Foundation.Size MeasureOverride(Windows.Foundation.Size ms) {
			Windows.Foundation.Size s = base.MeasureOverride(ms);
			foreach(Windows.UI.Xaml.FrameworkElement element in this.Children) {
				element.Measure(ms);
			}
			return(s);
		}

		protected override Windows.Foundation.Size ArrangeOverride(Windows.Foundation.Size fs) {
			var cc = Children.Count;
			for(int i = 0; i < cc; i++) {
				var element = Children[i] as Windows.UI.Xaml.FrameworkElement;
				if(element != null && element is Surface) {
					var surf = (Surface)element;
					element.Arrange(new Windows.Foundation.Rect(
						0,0,
						element.DesiredSize.Width,
						element.DesiredSize.Height)
					);
				}
			}
			return(fs);
		}

		public double get_width() {
			return(ActualWidth);
		}

		public double get_height() {
			return(ActualHeight);
		}
	}}}
}