
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

public class ImageSheet
{
	property Image sheet;
	property int cols = -1;
	property int rows = -1;
	property int source_skip_x = 0;
	property int source_skip_y = 0;
	property int source_image_width = -1;
	property int source_image_height = -1;
	property int max_images = -1;

	public Array to_images(int resize_to_width = -1, int resize_to_height = -1) {
		if(sheet == null) {
			return(null);
		}
		var cols = this.cols;
		var rows = this.rows;
		int fwidth = source_image_width;
		if(fwidth < 1) {
			fwidth = (sheet.get_width() - source_skip_x) / cols;
		}
		else {
			cols = (sheet.get_width() - source_skip_x) / fwidth;
		}
		int fheight = source_image_height;
		if(fheight < 1) {
			fheight = (sheet.get_height() - source_skip_y) / rows;
		}
		else {
			rows = (sheet.get_height() - source_skip_y) / fheight;
		}
		var frames = Array.create();
		int x, y;
		for(y=0; y<rows; y++) {
			for(x=0 ;x<cols; x++) {
				var img = sheet.crop(x*fwidth, y*fheight, fwidth, fheight);
				if(resize_to_width > 0) {
					img = img.resize(resize_to_width, resize_to_height);
				}
				frames.add(img);
				if(max_images > 0 && frames.count() >= max_images) {
					return(frames);
				}
			}
		}
		return(frames);
	}
}
