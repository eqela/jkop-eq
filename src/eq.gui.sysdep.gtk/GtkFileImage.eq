
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

public class GtkFileImage : Image, Size
{
	embed "c" {{{
		#include <gtk/gtk.h>
	}}}

	ptr image;
	int width;
	int height;

	public Image resize(int w, int h) {
		if(w < 0 && h < 0) {
			return(this);
		}
		int tw = w, th = h;
		if(tw < 0 && th >= 0) {
			tw = (int)((double)get_width() / ((double)get_height() / (double)th));
		}
		if(th < 0 && tw >= 0) {
			th = (int)((double)get_height() / ((double)get_width() / (double)tw));
		}
		if(get_width() == tw && get_height() == th) {
			return(this);
		}
		ptr resized_image;
		var imga = new GtkFileImage();
		if(imga != null) {
			if(tw > 1 && th > 1) {
				var v = get_gtk_image();
				embed "c" {{{
					GdkPixbuf *pix;
					pix = gdk_pixbuf_scale_simple(v, tw, th, GDK_INTERP_BILINEAR);
					resized_image = pix;
				}}}
				imga.set_gtk_image(resized_image);
			}
			imga.set_width(tw);
			imga.set_height(th);
		}
		return(imga);
	}

	public Image crop(int x, int y, int w, int h) {
		return(GuiEngine.crop(this, x, y, w, h));
	}

	public Buffer encode(String type) {
		return(null); // FIXME
	}

	public ptr get_gtk_image() {
		return(image);
	}

	public static GtkFileImage for_file(File file) {
		if(file == null) {
			return(null);
		}
		var filename = file.get_native_path();
		if(filename == null) {
			return(null);
		}
		var v = new GtkFileImage();
		if(v.initialize_file(filename) == false) {
			v = null;
		}
		return(v);
	}

	public ~GtkFileImage() {
		release();
	}

	public void release() {
		ptr image = this.image;
		if(image != null) {
			embed "c" {{{
				g_object_unref((GdkPixbuf*)image);
			}}}
			this.image = null;
		}
	}

	public bool initialize_file(String file) {
		var ptrfn = file.to_strptr();
		bool v = false;
		ptr image;
		int w;
		int h;
		Log.debug("Reading image via GDK pixbuf: `%s'".printf().add(file));
		Gtk.init();
		embed "c" {{{
			GdkPixbuf *piximage = NULL;
			piximage = gdk_pixbuf_new_from_file(ptrfn, NULL);
			if(piximage) {
				image = piximage;
				w = gdk_pixbuf_get_width(piximage);
				h = gdk_pixbuf_get_height(piximage);
			}
		}}}
		this.image = image;
		this.width = w;
		this.height = h;
		if(this.image != null) {
			v = true;
		}
		return(v);
	}

	public double get_width() {
		return(width);
	}

	public void set_gtk_image(ptr img) {
		this.image = img;
	}

	public double get_height() {
		return(height);
	}

	public void set_width(int w) {
		this.width = w;
	}

	public void set_height(int h) {
		this.height = h;
	}
}
