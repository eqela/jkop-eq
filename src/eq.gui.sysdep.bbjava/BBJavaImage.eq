
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

class BBJavaImage : Image, Renderable, VgRenderable, VgRenderableImage, Size, RenderableImage
{
	private int w = 0;
	private int h = 0;
	private int bpp = 0;
	private int stride = 0;
	embed "java" {{{
		private net.rim.device.api.system.Bitmap bitmap = null;
		private net.rim.device.api.ui.Graphics g = null;
		
		public static BBJavaImage create(net.rim.device.api.system.Bitmap bitImg) {
			if(bitImg == null) {
				return(null);
			}
			BBJavaImage v = new BBJavaImage();
			v.bitmap = bitImg;
			return(v);
		}

		public net.rim.device.api.system.Bitmap get_bb_bitmap() {
			return(bitmap);
		}
	
		public static BBJavaImage create_bitmap_image(int w, int h, eq.api.Buffer buffer, int bpp, int stride) {
			if(buffer != null && bpp != 32) {
				System.out.println("[WARNING] Non-32bpp bitmap not supported.");
				return(null);
			}
			if(w < 1 || h < 1) {
				System.out.println("[WARNING] Zero-sized bitmap cannot be created.");
				return(null);
			}
			BBJavaImage v = new BBJavaImage();
			v.w = w;
			v.h = h;
			v.stride = stride;
			if(v.stride < 0) {
				v.stride = w * 4;
			}
			v.bpp = 32;
			try {
				if(buffer != null) {
					byte[] rgba_bytes = buffer.get_pointer().get_native_pointer();
					net.rim.device.api.system.Bitmap bit = new net.rim.device.api.system.Bitmap(v.w, v.h); 
					int[] argb = v.rgba_to_argb(rgba_bytes, v.h * v.w);
					bit.setARGB(argb, 0, v.w, 0, 0, v.w, v.h);
					v.bitmap = bit;
				}
				else {
					v.bitmap = new net.rim.device.api.system.Bitmap(w, h);
					v.bitmap.setARGB(new int[w*h], 0, w, 0, 0, w, h);
				}
			}
			catch(Exception e) {
				java.lang.String err_stat = "Failed to create bitmap: " + e;
				System.out.println("[ERROR] " + err_stat);
			}
			return(v);
		}

		private int[] rgba_to_argb(byte[] colors, int size) {
			int[] v = new int[size];
			int channels = bpp/4;
			int c = 0;
			int clen = colors.length;
			for(int i = 0; i < size; i++) {
				int pix = 0;
				for(int j = 3; j >= 0; j--, c++) {
					int shift = j * channels;
					if((c+3) < clen && c % 4 == 0) {
						pix += (((int)colors[c + 3] & 0xFF) << shift);
					}
					else {
						pix += (((int)colors[c-1] & 0xFF) << shift);
					}
				}
				v[i] = pix;
			}
			return(v);
		}
	}}}

	public double get_width() {
		double v = 0;
		embed "java" {{{
			if(bitmap != null) {
				v = bitmap.getWidth();
			}
		}}}
		return(v);
	}

	public double get_height() {
		double v = 0;
		embed "java" {{{
			if(bitmap != null) {
				v = bitmap.getHeight();
			}
		}}}
		return(v);
	}

	public void render(Collection ops) {
		var ctx = get_vg_context();
		if(ctx == null) {
			return;
		}
		ctx.clear(0, 0, VgPathRectangle.create(0, 0, get_width(), get_height	()), null);
		VgRenderer.render_to_vg_context(ops, ctx);
	}

	public void release() {
		embed "java" {{{
			bitmap = null;
		}}}
	}

	public Image crop(int x, int y, int w, int h) {
		BBJavaImage v = null;
		embed "java" {{{
			try {
				net.rim.device.api.system.Bitmap bitmapCropped = new net.rim.device.api.system.Bitmap(w, h);
				net.rim.device.api.system.Bitmap tempBitmap = bitmap;
				bitmapCropped.createAlpha(net.rim.device.api.system.Bitmap.ALPHA_BITDEPTH_8BPP);
				tempBitmap.scaleInto(x, y, w, h, bitmapCropped, 0, 0, w, h, net.rim.device.api.system.Bitmap.FILTER_BOX);
				v = BBJavaImage.create(bitmapCropped);
			}
			catch(Exception e) {
				System.out.println("Unknown error: `" + e + "'");
				v = null;
			}
		}}}
		return(v);
	}

	public Image resize(int w, int h) {
		if(w < 0 && h < 0) {
			return(this);
		}
		BBJavaImage v = null;
		int width = w;
		int height = h;
		if(w < 1 && h > 0) {
			width = (int)((double)get_width() / ((double)get_height() / (double)h));
		}
		if(h < 1 && w > 0) {
			height = (int)((double)get_height() / ((double)get_width() / (double)w));
		}
		embed "java" {{{
			try {
				net.rim.device.api.system.Bitmap bitmapScaled = new net.rim.device.api.system.Bitmap(width, height);
				net.rim.device.api.system.Bitmap tempBitmap = bitmap;
				bitmapScaled.createAlpha(net.rim.device.api.system.Bitmap.ALPHA_BITDEPTH_8BPP);
				tempBitmap.scaleInto(bitmapScaled, net.rim.device.api.system.Bitmap.FILTER_BOX);
				v = BBJavaImage.create(bitmapScaled);
			}
			catch(Exception e) {
				System.out.println("Unknown error: `" + e + "'");
				v = null;
			}
		}}}
		return(v);
	}

	public Buffer encode(String type) {
		Buffer v = null;
		if(type != null && (type.has_suffix("jpg") || type.has_suffix("jpeg"))) {
			ptr e;
			int sz;
			embed "java" {{{
				if(bitmap != null) {
					net.rim.device.api.system.JPEGEncodedImage jpege = net.rim.device.api.system.JPEGEncodedImage.encode(bitmap, 70);
					e = jpege.getData();
					sz = e.length;
				}
			}}}
			v = Buffer.for_pointer(Pointer.create(e), sz);
		}
		return(Buffer.dup(v));
	}

	public VgContext get_vg_context() {
		VgContext v = null;
		embed "Java" {{{
			if(g == null) {
				g = net.rim.device.api.ui.Graphics.create(bitmap);
			}
			v = new BBJavaGraphicsVgContext(g);
		}}}
		return(v);
	}
}
