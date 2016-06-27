
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

public class PaperConfiguration
{
	public static PaperConfiguration for_default() {
		return(PaperConfiguration.for_a4_portrait());
	}

	public static PaperConfiguration for_a4_portrait() {
		return(new PaperConfiguration()
			.set_size(PaperSize.for_value(PaperSize.A4))
			.set_orientation(PaperOrientation.for_value(PaperOrientation.PORTRAIT)));
	}

	public static PaperConfiguration for_a4_landscape() {
		return(new PaperConfiguration()
			.set_size(PaperSize.for_value(PaperSize.A4))
			.set_orientation(PaperOrientation.for_value(PaperOrientation.LANDSCAPE)));
	}

	property PaperSize size;
	property PaperOrientation orientation;

	public Size get_size_inches() {
		var sz = get_raw_size_inches();
		if(PaperOrientation.matches(orientation, PaperOrientation.LANDSCAPE)) {
			return(Size.instance(sz.get_height(), sz.get_width()));
		}
		return(sz);
	}

	public Size get_raw_size_inches() {
		if(PaperSize.matches(size, PaperSize.LETTER)) {
			return(Size.instance(8.5, 11));
		}
		if(PaperSize.matches(size, PaperSize.LEGAL)) {
			return(Size.instance(8.5, 14));
		}
		if(PaperSize.matches(size, PaperSize.A3)) {
			return(Size.instance(11.7, 16.5));
		}
		if(PaperSize.matches(size, PaperSize.A4)) {
			return(Size.instance(8.27, 11.7));
		}
		if(PaperSize.matches(size, PaperSize.A5)) {
			return(Size.instance(5.8, 8.3));
		}
		if(PaperSize.matches(size, PaperSize.B4)) {
			return(Size.instance(9.8, 13.9));
		}
		if(PaperSize.matches(size, PaperSize.B5)) {
			return(Size.instance(6.9, 9.8));
		}
		return(Size.instance(8.27, 11.7));
	}

	public Size get_size_dots(int dpi) {
		var szi = get_size_inches();
		return(Size.instance(szi.get_width() * dpi, szi.get_height() * dpi));
	}
}
