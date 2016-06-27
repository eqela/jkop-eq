
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

public class WPCSTextLayout : TextLayout, Size
{
	embed "cs" {{{
		System.Windows.Controls.TextBlock textblock;
		System.Windows.Media.Imaging.WriteableBitmap bmp;
	}}}
	TextProperties text;
	String str;
	int dpi;

	public static TextLayout create(TextProperties text, int dpi) {
		var v = new WPCSTextLayout();
		v.text = text;
		v.dpi = dpi;
		if(text == null || v.initialize() == false) {
			v = null;
		}
		return(v);
	}

	~WPCSTextLayout() {
		embed "cs" {{{
			bmp = null;
			textblock = null;
		}}}
	}

	public bool initialize() {
		var font = text.get_font();
		var fgcolor = text.get_color();
		if(fgcolor == null) {
			fgcolor = Color.instance_double(0,0,0,0);
		}
		str = text.get_text();
		if(str == null) {
			str = "";
		}
		int wrap = text.get_wrap_width();
		int alignment = text.get_alignment();
		embed "cs" {{{
			byte fa = (byte)(fgcolor.get_a()*255), fr = (byte)(fgcolor.get_r()*255), fg = (byte)(fgcolor.get_g()*255), fb = (byte)(fgcolor.get_b()*255);
			textblock = new System.Windows.Controls.TextBlock() {
				Text = str.to_strptr(),
				Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromArgb(fa, fr, fg, fb)),
			};
			if(font != null && textblock != null) {
				textblock.FontSize = eq.gui.Length.eq_gui_Length_to_pixels(font.get_size(), dpi);
				if(font.is_italic()) {
					textblock.FontStyle = System.Windows.FontStyles.Italic;
				}
				if(font.is_bold()) {
					textblock.FontWeight = System.Windows.FontWeights.Bold;
				}
				var fontfile = font.get_name().to_strptr();
				if(fontfile != null && (fontfile.EndsWith(".ttf") || fontfile.EndsWith(".otf"))) {
					var uri = new System.Uri("Assets/" + fontfile, System.UriKind.RelativeOrAbsolute);
					System.Windows.Resources.StreamResourceInfo srinfo = System.Windows.Application.GetResourceStream(uri);
					if(srinfo != null) {
						var fontname = font.get_name().substring(0, fontfile.Length -4);
						textblock.FontSource = new System.Windows.Documents.FontSource(srinfo.Stream);
						textblock.FontFamily = new System.Windows.Media.FontFamily(fontname.to_strptr());
					}
					else {
						System.Diagnostics.Debug.WriteLine("Custom font not found: " + fontfile);
					}
				}
			}
			if(textblock != null) {
				if(alignment == eq.gui.TextProperties.LEFT) {
					textblock.TextAlignment = System.Windows.TextAlignment.Left;
				}
				else if(alignment == eq.gui.TextProperties.RIGHT) {
					textblock.TextAlignment = System.Windows.TextAlignment.Right;
				}
				else if(alignment == eq.gui.TextProperties.CENTER) {
					textblock.TextAlignment = System.Windows.TextAlignment.Center;
				}
				else if(alignment == eq.gui.TextProperties.JUSTIFY) {
					textblock.TextAlignment = System.Windows.TextAlignment.Justify;
				}
				if(wrap > 0 && (int)textblock.ActualWidth > wrap) {
					textblock.TextWrapping = System.Windows.TextWrapping.Wrap;
					textblock.Width = wrap;
				}
			}
		}}}
		return(true);
	}

	embed "cs" {{{
		public System.Windows.FrameworkElement get_drawable_text() {
			var oc = text.get_outline_color();
			if(oc != null) {
				return(get_outlined_color(oc));
			}
			else {
				return(make_copy_of(textblock));
			}
			return(null);
		}
	}}}

	embed "cs" {{{
		 System.Windows.Controls.Canvas get_outlined_color(eq.gui.Color oc) {
			if(oc != null) {
				var outlined = new System.Windows.Controls.Canvas() { Width = get_width(), Height = get_height() };
				var north = make_copy_of(textblock, true);
				var south = make_copy_of(textblock, true);
				var east = make_copy_of(textblock, true);
				var west = make_copy_of(textblock, true);
				var nw = make_copy_of(textblock, true);
				var ne = make_copy_of(textblock, true);
				var sw = make_copy_of(textblock, true);
				var se = make_copy_of(textblock, true);
				var basetext = make_copy_of(textblock);
				north.RenderTransform = new System.Windows.Media.TranslateTransform() { X = 1, Y = 0 };
				south.RenderTransform = new System.Windows.Media.TranslateTransform() { X = 1, Y = 2 };
				east.RenderTransform = new System.Windows.Media.TranslateTransform() { X = 0, Y = 1 };
				west.RenderTransform = new System.Windows.Media.TranslateTransform() { X = 2, Y = 1 };
				nw.RenderTransform = new System.Windows.Media.TranslateTransform() { X = 2, Y = 0 };
				ne.RenderTransform = new System.Windows.Media.TranslateTransform() { X = 0, Y = 0 };
				sw.RenderTransform = new System.Windows.Media.TranslateTransform() { X = 2, Y = 2 };
				se.RenderTransform = new System.Windows.Media.TranslateTransform() { X = 0, Y = 2 };
				basetext.RenderTransform = new System.Windows.Media.TranslateTransform() { X = 1, Y = 1 };
				outlined.Children.Add(north);
				outlined.Children.Add(south);
				outlined.Children.Add(east);
				outlined.Children.Add(west);
				outlined.Children.Add(nw);
				outlined.Children.Add(ne);
				outlined.Children.Add(sw);
				outlined.Children.Add(se);
				outlined.Children.Add(basetext);
				return(outlined);
			}
			return(null);
		}
		System.Windows.Controls.TextBlock make_copy_of(System.Windows.Controls.TextBlock src, bool for_outline = false) {
			if(src ==null) {
				return(null);
			}
			var v = new System.Windows.Controls.TextBlock() {
				Text = src.Text,
				Foreground = src.Foreground,
				FontSize = src.FontSize,
				FontStyle = src.FontStyle,
				FontWeight = src.FontWeight,
				TextAlignment = src.TextAlignment,
				TextWrapping = src.TextWrapping,
				FontSource = src.FontSource,
				FontFamily = src.FontFamily,
				Width = src.Width,
				Height = src.Height
			};
			if(for_outline) {
				var oc = text.get_outline_color();
				if(oc != null) {
					byte oa = (byte)(oc.get_a()*255), or = (byte)(oc.get_r()*255), og = (byte)(oc.get_g()*255), ob = (byte)(oc.get_b()*255);
					v.Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromArgb(oa, or, og, ob));
				}
			}
			return(v);
		}
	}}}

	public TextProperties get_text_properties() {
		return(text);
	}

	public Rectangle get_cursor_position(int index) {
		embed "cs" {{{
			if(textblock == null) {
				return(null);
			}
		}}}
		var substr = str.substring(0, index);
		int x, h;
		if(substr != null) {
			embed "cs" {{{
				textblock.Text = substr.to_strptr();
				x = (int)textblock.ActualWidth;
				h = (int)textblock.ActualHeight;
				textblock.Text = str.to_strptr();
			}}}
		}
		return(Rectangle.instance(x,0,1,h));
	}

	public int xy_to_index(double x, double y) {
		embed "cs" {{{
			if(textblock == null) {
				return(0);
			}
		}}}
		var itr = str.iterate();
		int index = 0;
		int cw = 0;
		int text_length = str.get_length();
		embed "cs" {{{
			while(itr!=null) {
				char tmp = (char)itr.next_char();
				if(tmp <= 0) {
					break;
				}
				textblock.Text = tmp.ToString();
				cw += (int)textblock.ActualWidth;
				index++;
				if(cw > x) {
					index--;
					break;
				}
			}
			if(cw >= x && index >= text_length) {
				index = -1;
			}
			textblock.Text = str.to_strptr();
		}}}
		return(index);
	}

	public double get_width() {
		double v;
		embed "cs" {{{
			if(textblock.TextWrapping == System.Windows.TextWrapping.Wrap) {
				v = textblock.Width;
			}
			else {
				v = textblock.ActualWidth;
			}
		}}}
		if(text.get_outline_color()!=null) {
			v += 2;
		}
		return(v);
	}

	public double get_height() {
		double v;
		embed "cs" {{{
			v = textblock.ActualHeight;
		}}}
		if(text.get_outline_color()!=null) {
			v += 2;
		}
		return(v);
	}
}

