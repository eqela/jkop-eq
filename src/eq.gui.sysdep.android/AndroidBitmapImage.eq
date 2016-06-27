
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

public class AndroidBitmapImage : Image, Size, VgRenderable, VgRenderableImage, Renderable, RenderableImage
{
	public static AndroidBitmapImage for_size(int w, int h) {
		var v = new AndroidBitmapImage();
		embed "java" {{{
			try {
				v.bitmap = android.graphics.Bitmap.createBitmap(w, h, android.graphics.Bitmap.Config.ARGB_8888);
			}
			catch(Exception e) {
				v.bitmap = null;
			}
			if(v.bitmap == null) {
				return(null);
			}
		}}}
		return(v);
	}

	embed "java" {{{
		public static AndroidBitmapImage for_android_bitmap(android.graphics.Bitmap bitmap) {
			if(bitmap == null) {
				return(null);
			}
			AndroidBitmapImage v = new AndroidBitmapImage();
			v.bitmap = bitmap;
			return(v);
		}
	}}}

	embed "java" {{{
		public android.graphics.Bitmap bitmap = null;

		public android.graphics.Bitmap get_android_bitmap() {
			return(bitmap);
		}
	}}}

	public void release() {
		embed "java" {{{
			if(bitmap != null) {
				bitmap.recycle();
			}
			bitmap = null;
		}}}
	}

	public Image resize(int aw, int ah) {
		if(aw < 0 && ah < 0) {
			return(this);
		}
		var w = aw;
		var h = ah;
		if(w < 0 && h >= 0) {
			w = (int)((double)get_width() / ((double)get_height() / (double)h));
		}
		if(h < 0 && w >= 0) {
			h = (int)((double)get_height() / ((double)get_width() / (double)w));
		}
		Image v = null;
		embed "java" {{{
			android.graphics.Bitmap bm = null;
			if(w > 0 && h > 0) {
				try {
					bm = android.graphics.Bitmap.createScaledBitmap(get_android_bitmap(), w, h, true);
				}
				catch(Exception e) {
					bm = null;
				}
			}
			v = AndroidBitmapImage.for_android_bitmap(bm);
		}}}
		return(v);
	}

	public Image crop(int x, int y, int w, int h) {
		Image v = null;
		embed "java" {{{
			if(bitmap == null) {
				return(null);
			}
			android.graphics.Bitmap cropped = android.graphics.Bitmap.createBitmap(bitmap, x, y, w, h, null, false);
			v = AndroidBitmapImage.for_android_bitmap(cropped);
		}}}
		return(v);
	}

	public Buffer encode(String type) {
		eq.api.DynamicBuffer v = null;
		embed "java" {{{
			android.graphics.Bitmap.CompressFormat cf = null;
		}}}
		if("image/jpeg".equals_ignore_case(type) || "jpg".equals_ignore_case(type) || "jpeg".equals_ignore_case(type)) {
			embed "java" {{{
				cf = android.graphics.Bitmap.CompressFormat.JPEG;
			}}}
		}
		else if("png".equals_ignore_case(type)) {
			embed "java" {{{
				cf = android.graphics.Bitmap.CompressFormat.PNG;
			}}}
		}
		else {
			Log.warning("Image type `%s' is not supported. Not compressing it.".printf().add(type));
		}
		embed "java" {{{
			if(cf != null) {
				java.io.ByteArrayOutputStream imgstream = new java.io.ByteArrayOutputStream();
				android.graphics.Bitmap bitmap = get_android_bitmap();
				if(bitmap.compress(cf, 70, imgstream)) {
					v = eq.api.DynamicBuffer.Static.create(imgstream.size());
					byte[] dst = ((eq.api.Buffer)v).get_pointer().get_native_pointer();
					byte[] src = null;
					try {
						src = imgstream.toByteArray();
					}
					catch(Exception e) {
						System.err.println("Failed to write compressed image stream to buffer: " + e);
					}
					System.arraycopy(src,0,dst,0, src.length);
					src = null;
				}
				else {
					eq.api.Log.Static.warning((eq.api.Object)eq.api.String.Static.for_strptr("Image was not commpressed to type `" + type.to_strptr() + "'."), null, null);
				}
			}
			if(v == null) {
				android.graphics.Bitmap bitmap = get_android_bitmap();
				java.nio.ByteBuffer bb = java.nio.ByteBuffer.allocate(bitmap.getRowBytes() * bitmap.getWidth());
				v = eq.api.DynamicBuffer.Static.create(bitmap.getRowBytes() * bitmap.getWidth());
				if(bb != null) {
					bitmap.copyPixelsToBuffer(bb);
				}
				if(v != null) {
					byte[] dst = ((eq.api.Buffer)v).get_pointer().get_native_pointer();
					byte[] src = bb.array();
					System.arraycopy(src,0,dst,0, src.length);
					src = null;
				}
				bb.clear();
			}
		}}}
		return(v);
	}

	public VgContext get_vg_context() {
		VgContext v;
		embed "java" {{{
			v = new AndroidVgContext(new android.graphics.Canvas(bitmap));
		}}}
		return(v);
	}

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
		ctx.clear(0, 0, VgPathRectangle.create(0, 0, get_width(), get_height()), null);
		VgRenderer.render_to_vg_context(ops, ctx);
	}
}
