
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

public class XamlImage : Image, Size
{
	class ImageProperties
	{
		property int w;
		property int h;
	}
	class ImageDataProperties : ImageProperties
	{
		property Buffer data;
	}
	class ImageFileProperties : ImageProperties
	{
		property File file;
	}
	class ImageResourceProperties : ImageProperties
	{
		property String resource;
	}
	embed {{{
		Windows.UI.Xaml.Media.ImageSource image = null;
		Windows.UI.Core.CoreDispatcher dispatcher;
		System.Uri uri;
	}}}
	int width;
	int height;
	ImageProperties props;

	public XamlImage() {
		embed {{{
			var cw = Windows.UI.Core.CoreWindow.GetForCurrentThread();
			if(cw != null) {
				dispatcher = cw.Dispatcher;
			}
		}}}
	}

	public static XamlImage create_image_from_file(File f, int w, int h) {
		var rs = f.get_native_path();
		if(rs == null) {
			return(null);
		}
		var crs = rs.to_strptr();
		XamlImage v = null;
		embed {{{
			var mutex = new System.Threading.ManualResetEvent(false);
			var ao_file = Windows.Storage.StorageFile.GetFileFromPathAsync(crs);
			ao_file.Completed = (sender, args) => {
				mutex.Set();
			};
			mutex.WaitOne();
			mutex.Reset();
			Windows.Storage.StorageFile file = null;
			try {
				file = ao_file.GetResults();
			}
			catch(System.Exception) {
			}
			finally {
				ao_file.Close();
			}
			if(file != null) {
				v = new XamlImage();
				var ao_stream = file.OpenReadAsync();
				ao_stream.Completed = (sender, args) => {
					mutex.Set();
				};
				mutex.WaitOne();
				mutex.Reset();
				try {
					using(var stream = ao_stream.GetResults()) {
						var img = new Windows.UI.Xaml.Media.Imaging.BitmapImage() { DecodePixelWidth = w, DecodePixelHeight = h };
						img.SetSource(stream);
						v.image = img;
						v.width = img.PixelWidth;
						v.height = img.PixelHeight;
					}
				}
				catch(System.Exception e) {
					v = null;
					System.Diagnostics.Debug.WriteLine("Failed to open the file: " + e.Message);
				}
				finally {
					ao_stream.Close();
				}
				v.uri = new System.Uri(crs);
			}	
		}}}
		if(v != null) {
			v.props = new ImageFileProperties().set_file(f).set_w(w).set_h(h);
		}
		return(v);
	}

	public static XamlImage create_image_from_pixels(Buffer data, int w, int h) {
		if(data == null) {
			return(null);
		}
		int size = data.get_size();
		if(size != w*h*4) {
			return(null);
		}
		var bgra_data = DynamicBuffer.create(w*h*4);
		var rgbap = data.get_pointer();
		var bgrap = bgra_data.get_pointer();
		int i;
		for(i = 0; i < w*h; i++) {
			var r = rgbap.get_byte(i*4+0);
			var g = rgbap.get_byte(i*4+1);
			var b = rgbap.get_byte(i*4+2);
			var a = rgbap.get_byte(i*4+3);
			bgrap.set_byte(i*4+0, b);
			bgrap.set_byte(i*4+1, g);
			bgrap.set_byte(i*4+2, r);
			bgrap.set_byte(i*4+3, a);
		}
		var bd = bgrap.get_native_pointer();
		var v = new XamlImage();
		v.width = w;
		v.height = h;
		embed {{{
			var wrbmp = new Windows.UI.Xaml.Media.Imaging.WriteableBitmap(w, h);
			using(System.IO.Stream stream = System.Runtime.InteropServices.WindowsRuntime.WindowsRuntimeBufferExtensions.AsStream(wrbmp.PixelBuffer)) {
				stream.Write(bd, 0, bd.Length);
			}
			v.image = wrbmp;
		}}}
		if(v != null) {
			v.props = new ImageDataProperties().set_data(data).set_w(w).set_h(h);
		}
		return(v);
	}

	public static XamlImage create_image_from_resource(String id, int w, int h) {
		if(String.is_empty(id)) {
			return(null);
		}
		var app = File.for_app_directory();
		if(app == null || app.is_directory() == false) {
			return(null);
		}
		var res = app.entry("Assets").entry(id.append(".png"));
		if(res.is_file() == false) {
			res = app.entry("Assets").entry(id.append(".jpg"));
		}
		if(res.is_file() == false) {
			res = app.entry("Assets").entry(id.append(".jpeg"));
		}
		var v = create_image_from_file(res, w, h);
		if(v != null) {
			v.props = new ImageResourceProperties().set_resource(id).set_w(w).set_h(h);
		}
		return(v);
	}

	embed {{{
		public virtual Windows.UI.Xaml.Media.ImageSource get_bitmap_source(Windows.UI.Core.CoreDispatcher dispatcher) {
			if(dispatcher != this.dispatcher) {
				XamlImage tmp = null;
				if(props is ImageFileProperties) {
					tmp = XamlImage.create_image_from_file(((ImageFileProperties)props).get_file(), props.get_w(), props.get_h());
				}
				else if(props is ImageDataProperties) {
					tmp = XamlImage.create_image_from_pixels(((ImageDataProperties)props).get_data(), props.get_w(), props.get_h());
				}
				else if(props is ImageResourceProperties) {
					tmp = XamlImage.create_image_from_resource(((ImageResourceProperties)props).get_resource(), props.get_w(), props.get_h());
				}
				if(tmp != null) {
					this.dispatcher = tmp.dispatcher;
					this.image = tmp.image;
				}
			}
			return(image);
		}

		public System.Uri get_uri() {
			return(uri);
		}
	}}}

	public Image resize(int width, int height) {
		if(width == get_width() && height == get_height()) {
			return(this);
		}
		if(width < 0 && height < 0) {
			return(this);
		}
		if(width == 0 || height == 0) {
			return(null);
		}
		return(XamlRenderableAsyncImage.resize_image(this, width, height));
	}

	public Image crop(int x, int y, int width, int height) {
		return(XamlRenderableAsyncImage.crop_image(this, x, y, width, height));
	}

	public Buffer encode(String type) {
		return(null); //FIXME
	}

	public void release() {
	}

	public virtual double get_width() {
		return(width);
	}

	public virtual double get_height() {
		return(height);
	}
}