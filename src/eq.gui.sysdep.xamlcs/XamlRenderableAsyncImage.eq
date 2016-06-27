
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

public class XamlRenderableAsyncImage : XamlImage, RenderableImage, AsyncImage, Renderable
{
	class ImageRenderListener
	{
		property XamlRenderableAsyncImage image;
		property Collection op;
		public void on_image_has_rendered() {
			if(image != null && op != null) {
				image.render(op);
			}
		}
	}
	embed {{{
		Windows.UI.Xaml.Media.ImageSource render_bitmap;
	}}}
	double bitmap_width = 0.0;
	double bitmap_height = 0.0;
	const int STATUS_INVALID = 0;
	const int STATUS_RENDERING = 2;
	const int STATUS_CONVERTING = 4;
	const int STATUS_READY = 8;
	int status = 0;
	Collection render_listeners;

	public static XamlRenderableAsyncImage create_renderable_image(int width, int height) {
		if(width < 1 || height < 1) {
			return(null);
		}
		var v = new XamlRenderableAsyncImage();
		v.bitmap_width = width;
		v.bitmap_height = height;
		return(v);
	}

	public static XamlRenderableAsyncImage resize_image(XamlImage source, int width, int height) {
		double scalex = width / source.get_width(), scaley = height / source.get_height();
		if(height < 0) {
			scaley = scalex;
		}
		else if(width < 0) {
			scalex = scaley;
		}
		if(scaley == 0 || scalex == 0) {
			return(null);
		}
		XamlRenderableAsyncImage v = new XamlRenderableAsyncImage();
		v.bitmap_width = (int)(source.get_width() * scalex);
		v.bitmap_height = (int)(source.get_height() * scaley);
		var diffx = v.bitmap_width - source.get_width(), diffy = v.bitmap_height - source.get_height();
		var op = LinkedList.create()
			.add(new FillColorOperation()
				.set_color(Color.instance_double(0,0,0,0))
				.set_shape(RectangleShape.create(0,0,v.bitmap_width,v.bitmap_height))
			)
			.add(new DrawObjectOperation()
				.set_x(diffx/2).set_y(diffy/2)
				.set_transform(Transform.for_scale(scalex, scaley))
				.set_object(source));
		v.render(op);
		return(v);
	}

	public static XamlRenderableAsyncImage crop_image(XamlImage source, int x, int y, int width, int height) {
		var op = LinkedList.create()
			.add(new ClipOperation()
				.set_shape(RectangleShape.create(0,0,width,height))
			)
			.add(new FillColorOperation()
				.set_color(Color.instance_double(0,0,0,0))
				.set_shape(RectangleShape.create(0,0,width,height))
			)
			.add(new DrawObjectOperation()
				.set_x(-x)
				.set_y(-y)
				.set_object(source)
			);
		XamlRenderableAsyncImage v = new XamlRenderableAsyncImage();
		v.bitmap_width = (int)width;
		v.bitmap_height = (int)height;
		v.render(op);
		return(v);
	}

	embed {{{
		public override Windows.UI.Xaml.Media.ImageSource get_bitmap_source(Windows.UI.Core.CoreDispatcher dispatcher) {
			return(render_bitmap);
		}
	}}}

	void add_render_listener(ImageRenderListener irl) {
		if(render_listeners == null) {
			render_listeners = LinkedList.create();
		}
		render_listeners.append(irl);
	}

	public override double get_width() {
		return(bitmap_width);
	}

	public override double get_height() {
		return(bitmap_height);
	}

	public bool is_loaded() {
		return(status == STATUS_READY || status == STATUS_CONVERTING);
	}

	void on_image_has_rendered() {
		if(render_listeners != null && render_listeners.count() > 0) {
			foreach(ImageRenderListener irl in render_listeners) {
				irl.on_image_has_rendered();
			}
			render_listeners = null;
		}
	}

	bool async_image_ops_defer_rendering(XamlImage source, Collection op) {
		if(source is XamlRenderableAsyncImage) {
			if(((XamlRenderableAsyncImage)source).is_loaded() == false) {
				((XamlRenderableAsyncImage)source).add_render_listener(new ImageRenderListener()
					.set_image(this)
					.set_op(op)
				);
				return(true);
			}
		}
		return(false);
	}

	embed {{{
		void convert_to_writeable_bitmap() {
			var rtb = render_bitmap as Windows.UI.Xaml.Media.Imaging.RenderTargetBitmap;
			if(rtb == null) {
				return;
			}
			var ao_getpixels = rtb.GetPixelsAsync();
			ao_getpixels.Completed = (sender, args) => {
				if(status != STATUS_CONVERTING) { // Don't proceed if not converting anymore.
					return;
				}
				if(ao_getpixels.Status == Windows.Foundation.AsyncStatus.Completed) {
					var rbitmap = render_bitmap as Windows.UI.Xaml.Media.Imaging.RenderTargetBitmap;
					if(rbitmap == null) {
						return;
					}
					var buf = ao_getpixels.GetResults();
					var reader = Windows.Storage.Streams.DataReader.FromBuffer(buf);
					if(reader == null) {
						return;
					}
					byte[] pixels = new byte[buf.Capacity];
					reader.ReadBytes(pixels);
					if(rbitmap.PixelWidth < 1 || rbitmap.PixelHeight < 1) {
						return;						
					}
					var wbmp = new Windows.UI.Xaml.Media.Imaging.WriteableBitmap((int)rbitmap.PixelWidth, (int)rbitmap.PixelHeight);
					if(wbmp == null) {
						return;
					}
					using(System.IO.Stream stream = System.Runtime.InteropServices.WindowsRuntime.WindowsRuntimeBufferExtensions.AsStream(wbmp.PixelBuffer)) {
						stream.Write(pixels, 0, pixels.Length);
					}
					pixels = null;
					reader.DetachBuffer();
					reader = null;
					buf = null;
					status = STATUS_READY;
					render_bitmap = wbmp;
					on_image_has_rendered();
				}
			};
		}
	}}}

	public void render(Collection o) {
		if(o != null && o.count() > 0) {
			foreach(DrawObjectOperation op in o) {
				var rai = op.get_object() as XamlRenderableAsyncImage;
				if(rai != null) {
					if(async_image_ops_defer_rendering(rai, o)) {
						return;
					}
				}
			}
		}
		embed {{{
			var visualroot = eq.gui.sysdep.xamlcs.XamlPanelFrame.find_current_panel_frame();
			{
				var canvas = new XamlCanvasSurface();
				canvas.move_resize(-get_width(), -get_height(), get_width(), get_height());
				Windows.UI.Xaml.Media.Imaging.RenderTargetBitmap rtb = null;
				if(this.render_bitmap == null || this.render_bitmap is Windows.UI.Xaml.Media.Imaging.RenderTargetBitmap == false) {
					rtb = new Windows.UI.Xaml.Media.Imaging.RenderTargetBitmap();
					status = STATUS_INVALID;
				}
				else {
					rtb = (Windows.UI.Xaml.Media.Imaging.RenderTargetBitmap)render_bitmap;
				}
				status = STATUS_RENDERING;
				canvas.render(o);
				visualroot.Children.Add(canvas);
				var aa_render = rtb.RenderAsync(canvas);
				aa_render.Completed = (sender, args) => {
					if(aa_render.Status == Windows.Foundation.AsyncStatus.Completed && render_bitmap != null) {
						var rtb1 = render_bitmap as Windows.UI.Xaml.Media.Imaging.RenderTargetBitmap;
						this.status = STATUS_CONVERTING;
						visualroot.Children.Remove(canvas);
						convert_to_writeable_bitmap();
						on_image_has_rendered();
					}
				};
				render_bitmap = rtb;
			}
		}}}
	}
}