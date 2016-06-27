
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

public class SEImage
{
	public static SEImage for_resource(String id) {
		return(new SEImage().set_resource(id));
	}

	public static SEImage for_image(Image image) {
		return(new SEImage().set_image(image));
	}

	public static SEImage for_texture(Object txt) {
		return(new SEImage().set_texture(txt));
	}

	property String resource;
	property Image image;
	property Object texture;

	public Object as_texture(SEResourceCache rsc) {
		var txt = get_texture();
		if(txt == null && rsc != null) {
			var img = get_image();
			if(img != null) {
				txt = rsc.image_to_texture(img);
			}
			if(txt == null) {
				txt = rsc.get_texture(get_resource());
			}
		}
		return(txt);
	}
}
