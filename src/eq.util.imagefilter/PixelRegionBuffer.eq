
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

class PixelRegionBuffer
{
	RGBAPixelIntegerBuffer src;
	int rangew;
	int rangeh;
	Buffer cache;

	public static PixelRegionBuffer for_rgba_pixels(RGBAPixelIntegerBuffer src, int w, int h) {
		var v = new PixelRegionBuffer();
		v.src = src;
		v.rangew = w;
		v.rangeh = h;
		return(v);
	}

	public int get_stride() {
		return(rangew * 4);
	}

	public Buffer get_buffer_region(int x, int y, bool newbuffer = false) {
		if(cache == null && newbuffer == false) {
			cache = DynamicBuffer.create(rangew*rangeh*4);
		}
		Buffer v = cache;
		if(newbuffer) {
			v = DynamicBuffer.create(rangew*rangeh*4);
		}
		var p = v.get_pointer();
		if(p == null) {
			return(null);
		}
		int i,j;
		for(i = 0; i < rangeh; i++) {
			for(j = 0; j < rangew; j++) {
				var pix = src.get_rgba_pixel(x+j, y+i);
				p.set_byte((i*rangew+j)* 4 + 0, pix.get_index(0));
				p.set_byte((i*rangew+j)* 4 + 1, pix.get_index(1));
				p.set_byte((i*rangew+j)* 4 + 2, pix.get_index(2));
				p.set_byte((i*rangew+j)* 4 + 3, pix.get_index(3));
			}
		}
		return(v);
	}
}