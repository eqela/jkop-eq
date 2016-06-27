
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

class RGBAPixelIntegerBuffer
{
	Buffer buffer;
	Pointer pointer;
	int width;
	int height;
	IntegerBuffer cache;

	public static RGBAPixelIntegerBuffer create(Buffer b, int w, int h) {
		var v = new RGBAPixelIntegerBuffer();
		v.buffer = b;
		v.width = w;
		v.height = h;
		v.pointer = b.get_pointer();
		return(v);
	}

	public int get_width() {
		return(width);
	}

	public int get_height() {
		return(height);
	}

	public IntegerBuffer get_rgba_pixel(int x, int y, bool newbuffer = false) {
		if(cache == null && newbuffer == false) {
			cache = IntegerBuffer.create(4);
		}
		var v = cache;
		if(newbuffer) {
			v = IntegerBuffer.create(4);
		}
		int i;
		if(x < 0 || x >= width || y < 0 || y >= height) {
			return(v);
		}
		for(i = 0; i < 4; i++) {
			v.set_index(i, pointer.get_byte((y*width+x) * 4 + i));
		}
		return(v);
	}
}