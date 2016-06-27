
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

public class SEWPCSSprite : SEWPCSElement, SESprite
{
	embed "cs" {{{
		System.Windows.Controls.Image imagecontrol;
		System.Windows.FrameworkElement drawabletext;
	}}}

	Font font;
	double color_width;
	double color_height;

	public void set_color(Color color, double width, double height) {		
		if(color != null) {
			this.color_width = width;
			this.color_height = height;
			byte ca = (byte)(color.get_a()*255), cr = (byte)(color.get_r()*255), cg = (int)(color.get_g()*255), cb = (byte)(color.get_b()*255);
			embed "cs" {{{
				BackendCanvas.Width = width;
				BackendCanvas.Height = height;
				BackendCanvas.Background = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromArgb(ca,cr,cg,cb));
				if(drawabletext!=null) {
					remove_from_surface(drawabletext, false);
				}
				remove_from_surface(imagecontrol, false);
			}}}
		}
		else {
			embed "cs" {{{
				remove_from_surface(null);
			}}}
		}
	}

	public void set_image(SEImage img) {
		var rsc = get_rsc();
		Image image;
		embed {{{
			BackendCanvas.Width = 0;
			BackendCanvas.Height = 0;
		}}}
		if(img != null) {
			image = img.get_texture() as Image;
			if(image == null) {
				image = img.get_image();
			}
			var resource = img.get_resource();
			if(String.is_empty(resource) == false) {
				image = rsc.get_texture(resource) as Image;
			}
			if(image != null && image is WPCSImage) {
				double iw = image.get_width(), ih = image.get_height();
				embed "cs" {{{
					if(imagecontrol == null) {
						imagecontrol = new System.Windows.Controls.Image();
						add_to_surface(imagecontrol, iw, ih);
					}
					else {
						add_to_surface(null, iw, ih);
					}
					imagecontrol.Width = iw;
					imagecontrol.Height = ih;
					imagecontrol.Source = ((com.eqela.libwpcsgui.WPCSImage)image).get_bmp();
				}}}
			}
		}
		else {
			embed "cs" {{{
				remove_from_surface(imagecontrol);
				imagecontrol = null;
			}}}
		}
	}

	public void set_text(String text, String fontid) {
		embed {{{
			BackendCanvas.Width = 0;
			BackendCanvas.Height = 0;
		}}}
		if(text == null) {
			embed "cs" {{{
				if(drawabletext != null) {
					remove_from_surface(drawabletext);
				}
				drawabletext = null;
			}}}
		}
		else {
			var rsc = get_rsc();
			if(rsc == null) {
				return;
			}
			Font font;
			if(fontid == null && this.font != null) {
				font = this.font;
			}
			else {
				font = rsc.get_font(fontid);
			}
			bool remake;
			embed "cs" {{{
				if(drawabletext==null || this.font != font) {
					remake = true;
					remove_from_surface(drawabletext);
				}
				else {
					if(drawabletext != null && drawabletext is System.Windows.Controls.TextBlock) {
						((System.Windows.Controls.TextBlock)drawabletext).Text = text.to_strptr();
					}
					else if(drawabletext != null && drawabletext is System.Windows.Controls.Canvas) {
						foreach(System.Windows.Controls.TextBlock tb in ((System.Windows.Controls.Canvas)drawabletext).Children) {
							tb.Text = text.to_strptr();
						}
					}
					add_to_surface(null, drawabletext.ActualWidth, drawabletext.ActualHeight);
				}
			}}}
			if(remake) {
				var textlayout = TextLayout.for_properties(TextProperties.for_string(text).set_font(font), rsc.get_frame(), rsc.get_dpi()) as WPCSTextLayout;
				if(textlayout!=null) {
					embed "cs" {{{
						drawabletext = textlayout.get_drawable_text();
						add_to_surface(drawabletext, drawabletext.ActualWidth, drawabletext.ActualHeight);
					}}}
				}
				this.font = font;
			}					
			embed "cs" {{{
				remove_from_surface(imagecontrol);
			}}}
		}
	}
		
	embed "cs" {{{
		public void add_to_surface(System.Windows.FrameworkElement element, double width, double height) {
			if(element!=null) {
				BackendCanvas.Children.Add(element);
			}
			if(width != get_width() || height != get_height()) {
				resize_backend(width, height);
			}
		}

		public void remove_from_surface(System.Windows.FrameworkElement element, bool remove_background = true) {
			if(element != null) {
				BackendCanvas.Children.Remove(element);
			}
			if(remove_background) {
				BackendCanvas.Background = null;
			}
		}
	}}}
}
