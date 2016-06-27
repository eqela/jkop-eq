
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

public class ImageFilter
{
	public static const int RESIZE_TYPE_BILINEAR = 0;
	public static const int RESIZE_TYPE_BICUBIC = 1;

	public static BitmapBuffer resize_image(BitmapBuffer bmpbuf, int nw = -1, int nh = -1, int type = 0) {
		if(bmpbuf == null) {
			return(null);
		}
		if(type == RESIZE_TYPE_BICUBIC) {
			return(ImageResizer.resize_bicubic(bmpbuf, nw, nh));
		}
		return(ImageResizer.resize_bilinear(bmpbuf, nw, nh));
	}

	public static BitmapBuffer filter_greyscale(BitmapBuffer bmpbuf) {
		if(bmpbuf == null) {
			return(null);
		}
		return(GreyscaleImage.create_greyscale(bmpbuf));
	}

	public static BitmapBuffer filter_red_sepia(BitmapBuffer bmpbuf) {
		if(bmpbuf == null) {
			return(null);
		}
		return(GreyscaleImage.create_red_sepia(bmpbuf));
	}

	public static BitmapBuffer filter_blur(BitmapBuffer bmpbuf) {
		if(bmpbuf == null) {
			return(null);
		}
		var array = DoubleArray.create()
			.add(0).add(0).add(1).add(0).add(0)
			.add(0).add(1).add(1).add(1).add(0)
			.add(1).add(1).add(1).add(1).add(1)
			.add(0).add(1).add(1).add(1).add(0)
			.add(0).add(0).add(1).add(0).add(0);
		return(ImageFilterUtil.create_for_array_filter(bmpbuf, array, 5, 5, 1.0/13.0));
	}

	public static BitmapBuffer filter_sharpen(BitmapBuffer bmpbuf) {
		if(bmpbuf == null) {
			return(null);
		}
		var array = DoubleArray.create()
			.add(-1).add(-1).add(-1)
			.add(-1).add(9).add(-1)
			.add(-1).add(-1).add(-1);
		return(ImageFilterUtil.create_for_array_filter(bmpbuf, array, 3, 3));
	}

	public static BitmapBuffer filter_emboss(BitmapBuffer bmpbuf) {
		if(bmpbuf == null) {
			return(null);
		}
		var array = DoubleArray.create()
			.add(-2).add(-1).add(0)
			.add(-1).add(1).add(1)
			.add(0).add(1).add(2);
		return(ImageFilterUtil.create_for_array_filter(bmpbuf, array, 3, 3, 2.0, 0.0));
	}

	public static BitmapBuffer filter_motion_blur(BitmapBuffer bmpbuf) {
		if(bmpbuf == null) {
			return(null);
		}
		var array = DoubleArray.create()
			.add(1).add(0).add(0).add(0).add(0).add(0).add(0).add(0).add(0)
			.add(0).add(1).add(0).add(0).add(0).add(0).add(0).add(0).add(0)
			.add(0).add(0).add(1).add(0).add(0).add(0).add(0).add(0).add(0)
			.add(0).add(0).add(0).add(1).add(0).add(0).add(0).add(0).add(0)
			.add(0).add(0).add(0).add(0).add(1).add(0).add(0).add(0).add(0)
			.add(0).add(0).add(0).add(0).add(0).add(1).add(0).add(0).add(0)
			.add(0).add(0).add(0).add(0).add(0).add(0).add(1).add(0).add(0)
			.add(0).add(0).add(0).add(0).add(0).add(0).add(0).add(1).add(0)
			.add(0).add(0).add(0).add(0).add(0).add(0).add(0).add(0).add(1);
		return(ImageFilterUtil.create_for_array_filter(bmpbuf, array, 9, 9, 1.0/9.0));
	}
}
