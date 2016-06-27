
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

class ImageFilterUtil
{
	public static int clamp(double v) {
		if(v > 255) {
			return(255);
		}
		if(v < 0) {
			return(0);
		}
		return((int)v);
	}

	public static int get_safe_byte(Pointer p, int sz, int idx) {
		var i = idx;
		if(i >= sz) {
			i = sz-1;
		}
		else if(i < 0) {
			i = 0;
		}
		IFDEF("target_java") {
			return(p.get_byte(i) & 0xff);
		}
		ELSE {
			return(p.get_byte(i));
		}
	}

	public static BitmapBuffer create_for_array_filter(BitmapBuffer bmpbuf, DoubleArray filter_array, int fw, int fh, double factor = 1.0, double bias = 1.0) {
		var srcbuf = bmpbuf.get_buffer();
		int w = bmpbuf.get_width(), h = bmpbuf.get_height();
		if(w < 1 || h < 1) {
			return(null);
		}
		var desbuf = DynamicBuffer.create(w*h*4);
		int x, y;
		var srcptr = srcbuf.get_pointer();
		var desptr = desbuf.get_pointer();
		int sz = srcbuf.get_size();
		for(x = 0; x < w; x++) {
			for(y = 0; y < h; y++) {
				double sr = 0.0, sg = 0.0, sb = 0.0, sa = 0.0;
				int fx, fy;
				for(fy = 0; fy < fh; fy++) {
					for(fx = 0; fx < fw; fx++) {
						int ix = (x - fw/2 + fx);
						int iy = (y - fh/2 + fy);
						sr += get_safe_byte(srcptr, sz, (iy*w+ix)*4+0) * filter_array.get_index(fy*fw+fx);
						sg += get_safe_byte(srcptr, sz, (iy*w+ix)*4+1) * filter_array.get_index(fy*fw+fx);
						sb += get_safe_byte(srcptr, sz, (iy*w+ix)*4+2) * filter_array.get_index(fy*fw+fx);
						sa += get_safe_byte(srcptr, sz, (iy*w+ix)*4+3) * filter_array.get_index(fy*fw+fx);
					}
				}
				desptr.set_byte((y*w+x)*4+0, clamp(factor * sr + bias));
				desptr.set_byte((y*w+x)*4+1, clamp(factor * sg + bias));
				desptr.set_byte((y*w+x)*4+2, clamp(factor * sb + bias));
				desptr.set_byte((y*w+x)*4+3, clamp(factor * sa + bias));
			}
		}
		return(BitmapBuffer.create(desbuf, w, h));
	}
}
