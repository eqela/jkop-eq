
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

class GreyscaleImage
{
	public static BitmapBuffer create_greyscale(BitmapBuffer bmpbuf, double rf = 1.0, double gf = 1.0, double bf = 1.0, double af = 1.0) {
		int w = bmpbuf.get_width(), h = bmpbuf.get_height();
		var srcbuf = bmpbuf.get_buffer();
		if(srcbuf == null || w < 1 || h < 1) {
			return(null);
		}
		var desbuf = DynamicBuffer.create(w*h*4);
		if(desbuf == null) {
			Log.error("Failed to allocate memory new image");
			return(null);
		}
		int ss = srcbuf.get_size();
		var srcptr = srcbuf.get_pointer();
		var desptr = desbuf.get_pointer();
		int x, y;
		for(y = 0; y < h; y++) {
			for(x = 0; x < w; x++) {
				double sr = ImageFilterUtil.get_safe_byte(srcptr, ss, (y*w+x)*4+0) * 0.2126;
				double sg = ImageFilterUtil.get_safe_byte(srcptr, ss, (y*w+x)*4+1) * 0.7152;
				double sb = ImageFilterUtil.get_safe_byte(srcptr, ss, (y*w+x)*4+2) * 0.0722;
				double sa = ImageFilterUtil.get_safe_byte(srcptr, ss, (y*w+x)*4+3);
				int sbnw = (int)(sr+sg+sb);
				desptr.set_byte((y*w+x)*4+0, ImageFilterUtil.clamp(sbnw * rf));
				desptr.set_byte((y*w+x)*4+1, ImageFilterUtil.clamp(sbnw * gf));
				desptr.set_byte((y*w+x)*4+2, ImageFilterUtil.clamp(sbnw * bf));
				desptr.set_byte((y*w+x)*4+3, ImageFilterUtil.clamp(sa * af));
			}
		}
		return(BitmapBuffer.create(desbuf, w, h));
	}

	public static BitmapBuffer create_red_sepia(BitmapBuffer imgbuf) {
		return(create_greyscale(imgbuf, 110.0/255.0+1.0, 66.0/255.0+1.0, 20.0/255.0+1.0));
	}
}
