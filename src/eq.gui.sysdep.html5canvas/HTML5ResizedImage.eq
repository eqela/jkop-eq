
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

public class HTML5ResizedImage : Image, HTML5Image, AsyncImage, Size
{
	HTML5Image original;
	int width;
	int height;

	public static HTML5ResizedImage create(HTML5Image original, int w, int h) {
		if(original == null) {
			return(null);
		}
		var v = new HTML5ResizedImage();
		v.original = original;
		v.width = w;
		v.height = h;
		return(v);
	}

	public String get_url() {
		if(original != null) {
			return(original.get_url());
		}
		return(null);
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

	public double get_width() {
		int v = width;
		if(v < 1 && height > 0) {
			var oh = original.get_height();
			if(oh > 0) {
				double f = (double)height / (double)oh;
				v = (int)(f * original.get_width());
			}
		}
		if(v < 1) {
			v = original.get_width();
		}
		return(v);
	}

	public double get_height() {
		int v = height;
		if(v < 1 && width > 0) {
			var ow = original.get_width();
			if(ow > 0) {
				double f = (double)width / (double)ow;
				v = (int)(f * original.get_height());
			}
		}
		if(v < 1) {
			v = original.get_height();
		}
		return(v);
	}

	public ptr get_image() {
		return(original.get_image());
	}

	public Image resize(int w, int h) {
		return(original.resize(w, h));
	}

	public bool is_loaded() {
		return(original.is_loaded());
	}
}
