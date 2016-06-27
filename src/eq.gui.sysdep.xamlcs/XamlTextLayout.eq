
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

public class XamlTextLayout : TextLayout, Size
{
	embed {{{
		class LayoutDuplicateProperties
		{
			public double fontsize;
			public Windows.UI.Text.FontWeight fontweight;
			public Windows.UI.Text.FontStyle fontstyle;
			public string text;
			public double width;
			public Windows.UI.Xaml.TextWrapping textwrapping;
			public Windows.UI.Xaml.TextAlignment textalignment;
			public string fontname;
			public eq.gui.Color fore_color;
			
			public static LayoutDuplicateProperties for_textblock(Windows.UI.Xaml.Controls.TextBlock otb) {
				var v = new LayoutDuplicateProperties();
				v.fontsize = otb.FontSize;
				v.fontweight = otb.FontWeight;
				v.fontstyle = otb.FontStyle;
				v.text = otb.Text;
				v.width = otb.Width;
				v.textwrapping = otb.TextWrapping;
				v.textalignment = otb.TextAlignment;
				return(v);
			}

			public Windows.UI.Xaml.Media.Brush get_foreground() {
				return(new Windows.UI.Xaml.Media.SolidColorBrush() { Color = XamlCanvasRenderer.to_ui_color(fore_color) });
			}
		}
	}}}
	TextProperties textprop;
	int dpi;
	double space_width = 0;
	double width;
	double height;
	embed {{{
	LayoutDuplicateProperties dup_props = null;
		Windows.UI.Xaml.Controls.TextBlock text_block = null;
		Windows.UI.Xaml.Media.SolidColorBrush outline_brush;
	}}}

	public static XamlTextLayout create(TextProperties text, int dpi) {
		var v = new XamlTextLayout();
		v.textprop = text;
		v.dpi = dpi;
		if(v.initialize() == false) {
			v = null;
		}
		return(v);
	}

	embed {{{
		string get_proper_font_name(eq.gui.Font font) {
			var name = font.get_name();
			string font_name = "Arial";
			if(name != null) {
				font_name = name.to_strptr();
				if(font_name != null && font_name.EndsWith(".ttf")) {
					var ff = font_name.Substring(0, font_name.Length - 4);
					ff = ff.Replace('_', ' ');
					font_name = System.String.Format("Assets/{0}#{1}", font_name, ff);
				}
				else if(font_name != null) {
					if(font_name.Equals("monospace", System.StringComparison.OrdinalIgnoreCase)) {
						font_name = "Consolas";
					}
					else if(font_name.Equals("sans", System.StringComparison.OrdinalIgnoreCase)) {
						font_name = "Calibri";
					}
					else if(font_name.Equals("serif", System.StringComparison.OrdinalIgnoreCase)) {
						font_name = "Cambria";
					}
				}
			}
			return(font_name);
		}

		Windows.UI.Xaml.Controls.TextBlock create_text_block_from_font(eq.gui.Font font) {
			var v = new Windows.UI.Xaml.Controls.TextBlock() {
				FontSize = eq.gui.Length.to_pixels(font.get_size(), dpi),
				FontFamily = new Windows.UI.Xaml.Media.FontFamily(get_proper_font_name(font))
			};
			if(font.is_bold()) {
				v.FontWeight = Windows.UI.Text.FontWeights.Bold;
			}
			if(font.is_italic()) {
				v.FontStyle = Windows.UI.Text.FontStyle.Italic;
			}
			v.Text = "_ _";
			measure_arrange(v);
			var spaced = v.ActualWidth;
			v.Text = "__";
			measure_arrange(v);
			var non_spaced = v.ActualWidth;
			space_width = spaced - non_spaced;
			return(v);
		}

		void measure_arrange(Windows.UI.Xaml.Controls.TextBlock tb) {
			tb.Measure(new Windows.Foundation.Size(0, 0));
			tb.Arrange(new Windows.Foundation.Rect(0,0,0,0));
			tb.UpdateLayout();
		}

		Windows.UI.Xaml.Controls.TextBlock duplicate() {
			if(dup_props == null) {
				return(null);
			}
			var v = new Windows.UI.Xaml.Controls.TextBlock() {
				FontSize = dup_props.fontsize,
				FontFamily = new Windows.UI.Xaml.Media.FontFamily(dup_props.fontname),
				FontWeight = dup_props.fontweight,
				FontStyle = dup_props.fontstyle,
				Text = dup_props.text,
				Foreground = dup_props.get_foreground(),
				Width = dup_props.width,
				TextWrapping = dup_props.textwrapping,
				TextAlignment = dup_props.textalignment
			};
			measure_arrange(v);
			return(v);
		}

		public Windows.UI.Xaml.FrameworkElement get_text_block() {
			var tb = duplicate();
			if(outline_brush != null) {
				var canvas = new Windows.UI.Xaml.Controls.Canvas();
				int x = -1, y = -1;
				for(x = -1; x < 2; x++) {
					for(y = -1; y < 2; y++) {
						var outliner = duplicate();
						outliner.Foreground = outline_brush;
						outliner.RenderTransform = new Windows.UI.Xaml.Media.TranslateTransform() { X = x, Y = y };
						canvas.Children.Add(outliner);
					}
				}
				canvas.Children.Add(tb);
				return(canvas);
			}
			return(tb);
		}
	}}}

	public bool initialize() {
		if(textprop == null) {
			return(false);
		}
		var text = textprop.get_text();
		var font = textprop.get_font();
		var color = textprop.get_color();
		var outline_color = textprop.get_outline_color();
		int alignment = textprop.get_alignment();
		int wrapwidth = textprop.get_wrap_width();
		if(font != null) {
			embed {{{
				text_block = create_text_block_from_font(font);
				text_block.Text = text.to_strptr();
				text_block.Foreground = new Windows.UI.Xaml.Media.SolidColorBrush() { Color = XamlCanvasRenderer.to_ui_color(color) };
				if(wrapwidth > 0) {
					text_block.TextWrapping = Windows.UI.Xaml.TextWrapping.Wrap;
					text_block.Width = wrapwidth;
				}
				var ta = Windows.UI.Xaml.TextAlignment.Left;
				if(alignment == eq.gui.TextProperties.CENTER) {
					ta = Windows.UI.Xaml.TextAlignment.Center;
				}
				else if(alignment == eq.gui.TextProperties.RIGHT) {
					ta = Windows.UI.Xaml.TextAlignment.Right;
				}
				else if(alignment == eq.gui.TextProperties.JUSTIFY) {
					ta = Windows.UI.Xaml.TextAlignment.Justify;
				}
				text_block.TextAlignment = ta;
				measure_arrange(text_block);
				if(wrapwidth > 0) {
					width = (int)wrapwidth;
				}
				else {
					width = (int)text_block.ActualWidth;
				}
				height = (int)text_block.ActualHeight;
			}}}
		}
		if(outline_color != null) {
			embed {{{
				outline_brush = new Windows.UI.Xaml.Media.SolidColorBrush() { Color = XamlCanvasRenderer.to_ui_color(outline_color) };
			}}}
		}
		embed {{{
			dup_props = LayoutDuplicateProperties.for_textblock(text_block);
			dup_props.fore_color = color;
			dup_props.fontname = get_proper_font_name(font);
		}}}
		return(true);
	}

	public double get_width() {
		return(width);
	}

	public double get_height() {
		return(height);
	}

	public TextProperties get_text_properties() {
		return(textprop);
	}

	int end_space_count(String str) {
		if(str == null) {
			return(0);
		}
		int v = 0;
		int c;
		if(str.has_suffix(" ")) {
			int i = 0;
			for(i = str.get_length() -1; i > -1; i--) {
				c = str.get_char(i);
				if(c == ' ') {
					v++;
				}
				else {
					break;
				}
			}
		}
		return(v);
	}

	public Rectangle get_cursor_position(int index) {
		var str = textprop.get_text();
		var ss = str.substring(0, index);
		int sc = end_space_count(ss);
		double x, h;
		embed {{{
			var dup = duplicate();
			dup.Text = ss.to_strptr();
			measure_arrange(dup);
			x = dup.ActualWidth + (sc*space_width);
			h = dup.ActualHeight;
		}}}
		return(Rectangle.instance(x, 0, 1, h));
	}

	public int xy_to_index(double x, double y) {
		var str = textprop.get_text();
		if(String.is_empty(str)) {
			return(0);
		}
		int idx = -1, text_length = str.get_length();
		var itr = str.iterate();
		strptr cstr = str.to_strptr();
		embed {{{
			int i;
			var dup = duplicate();
			if(x > dup.ActualWidth) {
				idx = text_length;
			}
			else {
				for(i = 0; i < text_length; i++) {
					var subs = str.substring(0, i);
					int sc = end_space_count(subs);
					dup.Text = subs.to_strptr();
					measure_arrange(dup);
					if((int)(dup.ActualWidth + (sc*space_width)) >= x) {
						break;
					}
					idx++;
				}
			}
		}}}
		return(idx);
	}
}