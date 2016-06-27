
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

public interface Image : Size
{
	public static bool is_image_file(File file) {
		if(GUI.engine == null) {
			return(false);
		}
		return(GUI.engine.is_image_file(file));
	}

	public static Image create_image_for_buffer(ImageBuffer buffer) {
		if(GUI.engine == null || buffer == null) {
			return(null);
		}
		return(GUI.engine.create_image_for_buffer(buffer));
	}

	public static Image for_file(File file, int w = -1, int h = -1) {
		if(GUI.engine == null) {
			return(null);
		}
		return(GUI.engine.create_image_for_file(file, w, h));
	}

	public static Image for_resource(String id, int w = -1, int h = -1) {
		if(GUI.engine == null) {
			return(null);
		}
		return(GUI.engine.create_image_for_resource(id, w, h));
	}

	public void release();
	public Image resize(int w, int h);
	public Image crop(int x, int y, int w, int h);
	public Buffer encode(String type);
}

