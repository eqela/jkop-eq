
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

public class GtkRenderableImage : Image, Size, VgRenderable, VgRenderableImage, Renderable, RenderableImage
{
	embed "c" {{{
		#include <gtk/gtk.h>
	}}}

	int width;
	int height;
	ptr surface;
	ptr context;

	public static GtkRenderableImage create(int w, int h) {
		var v = new GtkRenderableImage();
		if(v.initialize(w, h) == false) {
			v = null;
		}
		return(v);
	}

	public ~GtkRenderableImage() {
		release();
	}

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
		var ni = GtkRenderableImage.create(tw, th);
		if(ni == null) {
			return(null);
		}
		if(tw < 2 || th < 2) {
			return(ni);
		}
		var vg = ni.get_vg_context();
		if(vg == null) {
			return(null);
		}
		if(get_width() > 0 && get_height() > 0) {
			vg.draw_graphic(0, 0, VgTransform.create().scale((double)tw / (double)get_width(),
				(double)th / (double)get_height()), this);
		}
		return(ni);
	}

	public Image crop(int x, int y, int w, int h) {
		return(GuiEngine.crop(this, x, y, w, h));
	}

	public Buffer encode(String type) {
		return(null); // FIXME
	}

	public void release() {
		var c = this.context;
		if(c != null) {
			embed "c" {{{
				cairo_destroy(c);
			}}}
			this.context = null;
		}
		var s = this.surface;
		if(s != null) {
			embed "c" {{{
				cairo_surface_destroy(s);
			}}}
			this.surface = null;
		}
	}

	public ptr get_surface() {
		return(surface);
	}

	public bool initialize(int w, int h) {
		ptr s;
		embed "c" {{{
			s = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, w, h);
		}}}
		if(s == null) {
			return(false);
		}
		/*
		ptr c;
		embed "c" {{{
			c = cairo_create(s);
		}}}
		if(c == null) {
			return(false);
		}
		this.context = c;
		*/
		this.surface = s;
		this.width = w;
		this.height = h;
		return(true);
	}

	public double get_width() {
		return(width);
	}

	public double get_height() {
		return(height);
	}

	public Pointer get_buffer() {
		return(null);
	}

	public int get_bpp() {
		return(32);
	}

	public int get_stride()	{
		return(width * 4);
	}

	public int get_size() {
		return(width * height * 4);
	}

	public VgContext get_vg_context() {
		var c = this.context;
		if(c != null) {
			embed "c" {{{
				cairo_destroy(c);
			}}}
			this.context = null;
		}
		var s = this.surface;
		embed "c" {{{
			c = cairo_create(s);
		}}}
		this.context = c;
		return(new GtkVgContext().set_cr(this.context));
	}

	public void render(Collection ops) {
		var ctx = get_vg_context();
		if(ctx == null) {
			return;
		}
		ctx.clear(0, 0, VgPathRectangle.create(0, 0, get_width(), get_height()), null);
		VgRenderer.render_to_vg_context(ops, ctx);
	}
}
