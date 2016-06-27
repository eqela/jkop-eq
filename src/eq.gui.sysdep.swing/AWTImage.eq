
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

public class AWTImage : RenderableImage, Image, Size, Renderable
{
	embed {{{
		public java.awt.image.BufferedImage awtimage;
	}}}

	public static AWTImage for_file(File file) {
		var v = new AWTImage();
		if(v.read_file(file) == false) {
			v = null;
		}
		return(v);
	}

	public static AWTImage for_resource(String res) {
		var v = new AWTImage();
		if(v.read_resource(res) == false) {
			v = null;
		}
		return(v);
	}

	public static AWTImage for_buffer(ImageBuffer ib) {
		var v = new AWTImage();
		if(v.decode(ib) == false) {
			v = null;
		}
		return(v);
	}

	public static AWTImage for_bitmap(int width, int height) {
		if(width < 1 || height < 1) {
			return(null);
		}
		var v = new AWTImage();
		embed {{{
			v.awtimage = new java.awt.image.BufferedImage(width, height, java.awt.image.BufferedImage.TYPE_INT_ARGB);
		}}}
		return(v);
	}

	public bool decode(ImageBuffer ib) {
		if(ib == null) {
			return(false);
		}
		var type = ib.get_type();
		var buffer = ib.get_buffer();
		if(String.is_empty(type) || buffer == null) {
			return(false);
		}
		if("image/x-rgba".equals(type)) {
			int w = ib.get_width(), h = ib.get_height();
			if(w < 1 || h < 1 || buffer.get_size() < w*h*4) {
				return(false);
			}
			var pix = buffer.get_pointer().get_native_pointer();
			embed {{{
				int[] argb = new int[w*h];
				for(int i = 0; i < argb.length; i++) {
					int pa = (pix[4*i+3] & 0xff) << 24;
					int pr = (pix[4*i+0] & 0xff) << 16;
					int pg = (pix[4*i+1] & 0xff) << 8;
					int pb = (pix[4*i+2] & 0xff);
					argb[i] = pa+pr+pg+pb;
				}
			}}}
			embed {{{
				awtimage = new java.awt.image.BufferedImage(w, h, java.awt.image.BufferedImage.TYPE_INT_ARGB);
				awtimage.setRGB(0,0,w,h,argb,0,w);
			}}}
			return(true);
		}
		if(type.has_prefix("image/")) {
			var pointer = buffer.get_pointer();
			if(pointer != null) {
				var bytes = pointer.get_native_pointer();
				embed {{{
					try {
						awtimage = javax.imageio.ImageIO.read(new java.io.ByteArrayInputStream(bytes));
					}
					catch(java.io.IOException e) {
					}
					if(awtimage == null) {
						return(false);
					}
				}}}
			}
		}
		return(false);
	}

	public bool read_file(File file) {
		if(file == null) {
			return(false);
		}
		var pp = file.get_native_path();
		if(pp == null) {
			return(false);
		}
		embed {{{
			try {
				awtimage = javax.imageio.ImageIO.read(new java.io.File(pp.to_strptr()));
			}
			catch(Exception e) {
				e.printStackTrace();
				awtimage = null;
			}
			if(awtimage == null) {
				return(false);
			}
		}}}
		return(true);
	}

	public bool read_resource(String res) {
		if(read_resource_file("%s.png".printf().add(res).to_string())) {
			return(true);
		}
		if(read_resource_file("%s.jpg".printf().add(res).to_string())) {
			return(true);
		}
		Log.debug("Failed to load image resource: `%s'".printf().add(res));
		return(false);
	}

	public bool read_resource_file(String res) {
		if(res == null) {
			return(false);
		}
		var pp = res.to_strptr();
		if(pp == null) {
			return(false);
		}
		embed {{{
			java.io.InputStream ins = getClass().getResourceAsStream("/" + pp);
			if(ins == null) {
				}}} Log.debug("Failed to open image resource stream: ".append(res)); embed {{{
				return(false);
			}
			try {
				awtimage = javax.imageio.ImageIO.read(ins);
			}
			catch(Exception e) {
				e.printStackTrace();
				awtimage = null;
			}
			if(awtimage == null) {
				return(false);
			}
		}}}
		return(true);
	}

	embed {{{
		public java.awt.image.BufferedImage get_awt_image() {
			return(awtimage);
		}
	}}}

	public double get_width() {
		double v = 0;
		embed {{{
			if(awtimage != null) {
				v = awtimage.getWidth();
			}
		}}}
		return(v);
	}

	public double get_height() {
		double v = 0;
		embed {{{
			if(awtimage != null) {
				v = awtimage.getHeight();
			}
		}}}
		return(v);
	}

	public void release() {
		embed {{{
			awtimage = null;
		}}}
	}

	public Image resize(int w, int h) {
		if(w < 0 && h < 0) {
			return(this);
		}
		if(w == 0 || h == 0) {
			return(null);
		}
		double scale_y = h / get_height(), scale_x = w / get_width();
		if(w < 0) {
			scale_x = scale_y;
		}
		if(h < 0) {
			scale_y = scale_x;
		}
		int tw = (int)(get_width()*scale_x), th = (int)(get_height()*scale_y);
		if(get_width() == tw && get_height() == th) {
			return(this);
		}
		var v = new AWTImage();
		embed {{{
			if(awtimage == null) {
				return(null);
			}
			java.awt.Image simage = awtimage.getScaledInstance(tw, th, java.awt.Image.SCALE_SMOOTH);
			if(simage == null) {
				return(null);
			}
			java.awt.image.BufferedImage newimage = new java.awt.image.BufferedImage(tw, th, java.awt.image.BufferedImage.TYPE_INT_ARGB);
			java.awt.geom.AffineTransform trans = new java.awt.geom.AffineTransform();
			trans.scale(scale_x, scale_y);
			java.awt.image.AffineTransformOp op = new java.awt.image.AffineTransformOp(trans, java.awt.image.AffineTransformOp.TYPE_BILINEAR);
			newimage = op.filter(awtimage, newimage);
			v.awtimage = newimage;
		}}}
		return(v);
	}

	public Image crop(int x, int y, int w, int h) {
		embed {{{
			if(awtimage != null) {
				AWTImage v = new AWTImage();
				v.awtimage = awtimage.getSubimage(x, y, w, h);
				return(v);
			}
		}}}
		return(null);
	}

	public void render(Collection o) {
		embed {{{
			if(awtimage != null && o != null && o.count() > 0) {
				java.awt.Graphics g = awtimage.createGraphics();
				if(g != null && g instanceof java.awt.Graphics2D) {
					AWTGraphics2DRenderer.render_with((java.awt.Graphics2D)g, o);
				}
			}
		}}}
	}

	public Buffer encode(String type) {
		embed {{{
			if(awtimage == null) {
				return(null);
			}
		}}}
		var imgtype = type;
		if(String.is_empty(imgtype) || imgtype.has_prefix("image/") == false) {
			return(null);
		}
		imgtype = imgtype.substring(6);
		if("x-rgba".equals(imgtype)) {
			var v = DynamicBuffer.create(get_width() * get_height() * 4);
			if(v == null) {
				return(null);
			}
			var bytes = v.get_pointer().get_native_pointer();
			embed {{{
				int[] argb = awtimage.getRGB(0,0,(int)get_width(),(int)get_height(), null, 0, (int)get_width());
				if(argb == null || argb.length < 1) {
					return(null);
				}
				for(int i = 0; i < argb.length; i++) {
					int pixel = argb[i];
					byte pa = (byte) (pixel >> 24);
					byte pr = (byte)((pixel >> 16) & 0xff);
					byte pg = (byte)((pixel >> 8) & 0xff);
					byte pb = (byte) (pixel & 0xff);
					bytes[4*i+0] = (byte)pr;
					bytes[4*i+1] = (byte)pg;
					bytes[4*i+2] = (byte)pb;
					bytes[4*i+3] = (byte)pa;
				}
			}}}
			return(v);
		}
		ptr bytes = null;
		int sz = 0;
		embed {{{
			java.io.ByteArrayOutputStream os = new java.io.ByteArrayOutputStream();
			try {
				if(javax.imageio.ImageIO.write(awtimage, imgtype.to_strptr(), os) == false) {
					return(null);
				}
			}
			catch(java.io.IOException e) {
			}
			bytes = os.toByteArray();
			sz = bytes.length;
		}}}
		return(Buffer.for_pointer(Pointer.create(bytes), sz));
	}
}
