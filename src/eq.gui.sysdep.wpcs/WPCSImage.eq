
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

public class WPCSImage : Image, Size, VgRenderableImage, VgRenderable, RenderableImage, Renderable
{
	public static int UNKNOWN = 0;
	public static int RENDERABLE_IMAGE = 1;
	public static int FILE_IMAGE = 2;
	public static int BUFFER_IMAGE = 3;

	embed "cs" {{{
		System.Windows.Media.Imaging.BitmapSource bmp;
		System.Windows.Controls.Canvas offscreen_canvas;
	}}}

	property File file;
	property Buffer buffer;
	property String resource_name;
	property double ocwidth;
	property double ocheight;
	bool is_modified = false;
	property int type;

	~WPCSImage() {
	}

	embed "cs" {{{
		public static WPCSImage create_from_native_bitmap(System.Windows.Media.Imaging.BitmapSource bmp, eq.api.Buffer buffer = null) {
			var v = new WPCSImage();
			v.bmp = bmp;
			v.buffer = buffer;
			return(v);
		}
	}}}

	public WPCSImage initialize() {
		if(get_type() == WPCSImage.RENDERABLE_IMAGE) {
			embed "cs" {{{
				offscreen_canvas = new System.Windows.Controls.Canvas() { Width = ocwidth, Height = ocheight };
				bmp = new System.Windows.Media.Imaging.WriteableBitmap((int)ocwidth, (int)ocheight);
			}}}
		}
		else if(get_type() == WPCSImage.FILE_IMAGE) {
			var path = file.get_native_path();
			embed "cs" {{{
				var sptr = path.to_strptr();
				bmp = new System.Windows.Media.Imaging.BitmapImage();
				using(var iso = System.IO.IsolatedStorage.IsolatedStorageFile.GetUserStoreForApplication()) {
					using(var stream = iso.OpenFile(sptr, System.IO.FileMode.Open, System.IO.FileAccess.Read)) {
						try {
							bmp.SetSource(stream);
						}
						catch(System.Exception e) {
							return(null);
						}
					}
				}
			}}}
		}
		else if(get_type() == WPCSImage.BUFFER_IMAGE) {
			if(buffer != null) {
				var ptr = buffer.get_pointer().get_native_pointer();
				int size = buffer.get_size();
				embed "cs" {{{
					var stream = new System.IO.MemoryStream(size);
					var bwriter = new System.IO.BinaryWriter(stream);
					if(bwriter!=null) {
						bwriter.Write(ptr);
					}
					bmp = new System.Windows.Media.Imaging.BitmapImage();
					try {
						bmp.SetSource(stream);
					}
					catch(System.Exception e) {
						return(null);
					}
				}}}
			}
		}
		return(this);
	}

	public VgContext get_vg_context() {
		if(get_type() != WPCSImage.RENDERABLE_IMAGE) {
			Log.error("Image is not made to be renderable.");
			return(null);
		}
		VgContext v;
		embed "cs" {{{
			v = WPCSVgContext.create(offscreen_canvas);
		}}}
		return(v);
	}

	public void render(Collection ops) {
		var ctx = get_vg_context();
		if(ctx == null) {
			return;
		}
		ctx.clear(0, 0, VgPathRectangle.create(0, 0, get_ocwidth(), get_ocheight()), null);
		VgRenderer.render_to_vg_context(ops, ctx);
		embed "cs" {{{
			if(bmp is System.Windows.Media.Imaging.WriteableBitmap) {
				((System.Windows.Media.Imaging.WriteableBitmap)bmp).Render(offscreen_canvas, null);
				((System.Windows.Media.Imaging.WriteableBitmap)bmp).Invalidate();
			}
		}}}
	}

	public double get_height() {
		double v;
		embed "cs" {{{
			var bmp = get_bmp();
			if(bmp!=null) {
				v = bmp.PixelHeight;
			}
		}}}
		return(v);
	}

	public double get_width() {
		double v;
		embed "cs" {{{
			var bmp = get_bmp();
			if(bmp!=null) {
				v = bmp.PixelWidth;
			}
		}}}
		return(v);
	}

	public void release() {
		embed "cs" {{{
			if(get_type() == WPCSImage.RENDERABLE_IMAGE && offscreen_canvas != null) {
				offscreen_canvas.Children.Clear();
				offscreen_canvas = null;
			}
			bmp = null;
		}}}
	}

	public Image resize(int aw, int ah) {
		if(aw < 0 && ah < 0) {
			return(this);
		}
		var v = new WPCSImage().set_type(type);
		int w = aw, h = ah;
		if(w < 0 && h >= 0) {
			w = (int)(get_width() / (get_height() / (double)h));
		}
		if(h < 0 && w >= 0) {
			h = (int)(get_height() / (get_width() / (double)w));
		}
		embed "cs" {{{
			if(h > 0 && w > 0) {
				double sy = (double)h/bmp.PixelHeight;
				double sx = (double)w/bmp.PixelWidth;
				var scaler = new System.Windows.Media.ScaleTransform() { ScaleX = sx, ScaleY = sy };
				var img = new System.Windows.Controls.Image() { Width = get_width(), Height = get_height(), Source = bmp };
				v.bmp = new System.Windows.Media.Imaging.WriteableBitmap(img, scaler);
			}
		}}}
		v.buffer = buffer;
		v.file = file;
		return(v);
	}

	public Image crop(int x, int y, int w, int h) {
		var v = new WPCSImage();
		embed "cs" {{{
			if(bmp == null) {
				return(null);
			}
			var c = new System.Windows.Controls.Canvas() { Width = w, Height = h };
			var img = new System.Windows.Controls.Image() { Width = get_width(), Height = get_height(), Source = bmp };
			c.Clip = new System.Windows.Media.RectangleGeometry() { Rect = new System.Windows.Rect(x, y, w, h) };
			c.Children.Add(img);
			v.bmp = new System.Windows.Media.Imaging.WriteableBitmap(c, new System.Windows.Media.TranslateTransform() { X = -x, Y = -y} );
		}}}
		return(v);
	}

	public Buffer encode(String type) {
		if(type != null && type.equals("image/jpeg") && (file != null && file.has_extension("jpg"))) {
			return(file.get_contents_buffer());
		}
		return(buffer);
	}

	embed "cs" {{{
		public System.Windows.Media.Imaging.BitmapSource get_bmp() {
			return(bmp);			
		}
	}}}
}
