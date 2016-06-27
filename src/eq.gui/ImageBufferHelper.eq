
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

public class ImageBufferHelper
{
	public static Image buffer_to_image(Buffer buffer, String type) {
		String ext;
		if(buffer == null || type == null) {
			return(null);
		}
		if("image/jpg".equals(type) || "image/jpeg".equals(type) || type.str("jpg") >= 0 || type.str("jpeg") >= 0) {
			ext = "jpg";
		}
		else if("image/png".equals(type) || type.str("png") >= 0) {
			ext = "png";
		}
		else if("image/tiff".equals(type)) {
			ext = "tiff";
		}
		if(String.is_empty(ext)) {
			Log.warning("Converting image of unknown type: `%s'".printf().add(type));
			return(null);
		}
		int n = 0;
		File tmpfile;
		while(true)
		{
			var id = "image_buffer_%d_%d".printf().add((int)SystemClock.seconds()).add(Math.random(100, 1000000)).to_string();
			var ff = File.for_eqela_path("/tmp/%s.%s".printf().add(id).add(ext).to_string());
			if(ff.exists() == false) {
				tmpfile = ff;
				break;
			}
			n++;
			if(n > 10) {
				break;
			}
		}
		if(tmpfile == null) {
			return(null);
		}
		if(tmpfile.set_contents_buffer(buffer) == false) {
			return(null);
		}
		var img = Image.for_file(tmpfile);
		if(img == null) {
			Log.warning("Failed to read temporary image file of type `%s': `%s'".printf()
				.add(type).add(tmpfile));
		}
		tmpfile.remove();
		return(img);
	}
}
