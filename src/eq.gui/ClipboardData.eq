
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

public interface ClipboardData : Stringable
{
	public static ClipboardData for_string(String str) {
		return(new StringClipboardData().set_string(str));
	}

	public static ClipboardData for_image(Image img) {
		Buffer buf;
		if(img != null) {
			buf = img.encode("image/png");
		}
		return(new BinaryClipboardData()
			.set_mimetype("image/png")
			.set_buffer(buf));
	}

	public static ClipboardData for_buffer(Buffer buf, String mimetype) {
		return(new BinaryClipboardData().set_buffer(buf).set_mimetype(mimetype));
	}

	public String get_mimetype();
	public Image to_image();
	public Buffer to_buffer();
}
