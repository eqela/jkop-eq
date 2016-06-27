
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

class J2MEImage : Image, Size, VgRenderableImage, VgRenderable, RenderableImage, Renderable
{
	private int w = 0;
	private int h = 0;
	private int bpp = 0;
	private int stride = 0;

	embed "java" {{{
		javax.microedition.lcdui.Image image = null;

		public static J2MEImage create(javax.microedition.lcdui.Image image) {
			if(image == null) {
				return(null);
			}
			J2MEImage v = new J2MEImage();
			v.image = image;
			return(v);
		}
		
		public static J2MEImage buffer_to_image(eq.api.Buffer buffer) {
			if(buffer == null) {
				return(null);
			}
			J2MEImage v = new J2MEImage();
			byte[] ptr = buffer.get_pointer().get_native_pointer();
			int sz = buffer.get_size();
			v.image = javax.microedition.lcdui.Image.createImage(ptr, 0, sz);
			if(v.image == null) {
				return(null);
			}
			return(v);
		}
		
		public static J2MEImage read_image_file(eq.api.String url) {
			if(url == null) {
				return(null);
			}
			J2MEImage v = new J2MEImage();
			try {
				v.image = javax.microedition.lcdui.Image.createImage(url.to_strptr());
			}
			catch(Exception e) {
				v = null;
				System.out.println(e);
			}
			if(v == null && url.has_prefix(eq.api.StringStatic.eq_api_StringStatic_for_strptr("file:"))) {
				try {
					javax.microedition.io.file.FileConnection f = (javax.microedition.io.file.FileConnection)javax.microedition.io.Connector.open(url.to_strptr());
					v.image = javax.microedition.lcdui.Image.createImage(f.openInputStream());
				}
				catch(Exception e) {
					v = null;
				} 
			}
			return(v);
		}

		public static J2MEImage create_bitmap_image(int w, int h, eq.api.Buffer buffer, int bpp, int stride) {
			if(bpp != 32) {
				eq.api.Log.eq_api_Log_warning((eq.api.Object)eq.api.StringStatic.eq_api_StringStatic_for_strptr("Non-32bpp bitmap not supported."), null, null);
				return(null);
			}
			if(w < 1 || h < 1) {
				eq.api.Log.eq_api_Log_warning((eq.api.Object)eq.api.StringStatic.eq_api_StringStatic_for_strptr("Zero-sized bitmap cannot be created."), null, null);
				return(null);
			}
			J2MEImage v = new J2MEImage();
			v.w = w;
			v.h = h;
			v.stride = stride;
			if(v.stride < 0) {
				v.stride = w * 4;
			}
			v.bpp = 32;
			try {
				if(buffer != null) {
					byte[] rgb_bytes = buffer.get_pointer().get_native_pointer();
					int[] argb = v.rgba_to_argb(rgb_bytes, v.h * v.w);
					v.image = javax.microedition.lcdui.Image.createRGBImage(argb, v.w, v.h, true); 
				}
				else {
					v.image = javax.microedition.lcdui.Image.createImage(v.w, v.h); 
				}
			}
			catch(Exception e) {
				java.lang.String err_stat = "Failed to create bitmap: " + e;
				eq.api.Log.eq_api_Log_error((eq.api.Object)eq.api.StringStatic.eq_api_StringStatic_for_strptr(err_stat), null, null);
			}
			return(v);
		}

		public javax.microedition.lcdui.Image get_midlet_image() {
			javax.microedition.lcdui.Image v = image;
			if(image.isMutable()) {
				int w = (int)get_width(), h = (int)get_height();
				int[] rgba = new int[w * h];
				v.getRGB(rgba, 0, w, 0, 0, w, h);
				v = javax.microedition.lcdui.Image.createRGBImage(rgba, w, h, true);
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

	public Image crop(int x, int y, int w, int h) {
		// FIXME
		return(this);
	}

	public Buffer encode(String type) {
		return(null); //FIXME
	}

	public Image resize(int aw, int ah) {
		if(aw < 0 && ah < 0) {
			return(this);
		}
		J2MEImage v = new J2MEImage();
		int w = aw, h = ah;
		int ow = get_width(), oh = get_height();
		if(aw < 1 && ah > 0) {
			w = (int)((double)ow / ((double)oh / (double)ah));
		}
		if(ah < 1 && aw > 0) {
			h = (int)((double)oh / ((double)ow / (double)aw));
		}
		embed "java" {{{
			try {
				javax.microedition.lcdui.Image midlet_image = image;
				int[] rawInput = new int[oh * ow];
				midlet_image.getRGB(rawInput, 0, ow, 0, 0, ow, oh);
				int[] rawOutput = new int[w * h];      
				int yd = (oh / h) * ow - ow; 
				int yr = oh % h;
				int xd = ow / w;
				int xr = ow % w;        
				int outOffset = 0;
				int inOffset = 0;
				for(int y = h, ye = 0; y > 0; y--) {            
					for(int x = w, xe = 0; x > 0; x--) {
						rawOutput[outOffset++] = rawInput[inOffset];
						inOffset += xd;
						xe += xr;
						if(xe >= w) {
							xe -= w;
							inOffset++;
						}
					}            
					inOffset+= yd;
					ye += yr;
					if(ye >= h) {
						ye -= h;     
						inOffset += ow;
					}
				}    
				v.image = javax.microedition.lcdui.Image.createRGBImage(rawOutput, w, h, true);
			}
			catch(Exception e) {
				v = null;
			}
		}}}
		return(v);
	}

	public void release() {
		embed "java" {{{
			image = null;
		}}}
	}

	public void render(Collection ops) {
		var ctx = get_vg_context();
		if(ctx == null) {
			return;
		}
		ctx.clear(0, 0, VgPathRectangle.create(0, 0, get_width(), get_height	()), null);
		VgRenderer.render_to_vg_context(ops, ctx);
	}

	public Pointer get_buffer() {
		return(null);
	}
	public int get_bpp() {
		return(bpp);
	}

	public int get_size() {
		return((int)(get_stride() * get_height()));
	}

	public int get_stride() {
		return(stride);
	}

	public double get_width() {
		int v = 0;
		embed "java" {{{
			if(image != null) {
				v = image.getWidth();
			}
		}}}
		return((double)v);
	}

	public double get_height() {
		int v = 0;
		embed "java" {{{
			if(image != null) {
				v = image.getHeight();
			}
		}}}
		return((double)v);
	}

	public VgContext get_vg_context() {
		VgContext v = null;
		embed "java" {{{
			v = new J2MEGraphicsVgContext(image.getGraphics(), (int)get_width(), (int)get_height());
		}}}
		return(v);
	}
}
