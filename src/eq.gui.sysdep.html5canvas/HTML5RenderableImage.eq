
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

public class HTML5RenderableImage : Image, VgRenderable, VgRenderableImage, Size, Renderable, RenderableImage
{
	public int width;
	public int height;
	public ptr element;
	public HTML5CanvasVgContext context;

	public static HTML5RenderableImage create(int w, int h) {
		var v = new HTML5RenderableImage();
		ptr e;
		embed "js" {{{
			e = document.createElement('canvas');
			e.width = w;
			e.height = h;
		}}}
		v.element = e;
		v.width = w;
		v.height = h;
		return(v);
	}

	public void release() {
	}

	public Image crop(int x, int y, int w, int h) {
		return(ImageCropper.crop(this, x, y, w, h));
	}

	public Buffer encode(String type) {
		// FIXME
		return(null);
	}

	public ptr get_element() {
		return(element);
	}

	public double get_width() {
		return(width);
	}

	public double get_height() {
		return(height);
	}

	public VgContext get_vg_context() {
		if(context == null) {
			context = HTML5CanvasVgContext.for_canvas_element(element);
		}
		return(context);
	}

	public Image resize(int aw, int ah) {
		var w = aw;
		var h = ah;
		if(w < 1 && h > 0) {
			w = (int)((double)width / ((double)height / (double)h));
		}
		if(h < 1 && w > 0) {
			h = (int)((double)height / ((double)width / (double)w));
		}
		if(w < 1 || h < 1) {
			return(null);
		}
		var v = new HTML5RenderableImage();
		v.width = w;
		v.height = h;
		ptr oo = this.element;
		ptr ee;
		embed {{{
			ee = document.createElement('canvas');
			var ctx = ee.getContext('2d');
			ee.width = w;
			ee.height = h;
			ctx.drawImage(oo, 0, 0, oo.width, oo.height, 0, 0, w, h);
		}}}
		v.element = ee;
		return(v);
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
