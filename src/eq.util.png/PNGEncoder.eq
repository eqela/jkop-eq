
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

public class PNGEncoder
{
	IFDEF("target_cpp") {
		embed {{{
			extern "C" void* tdefl_write_image_to_png_file_in_memory(const void *pImage, int w, int h, int num_chans, size_t *pLen_out);
		}}}
	}
	ELSE IFDEF("target_c") {
		embed {{{
			void* tdefl_write_image_to_png_file_in_memory(const void *pImage, int w, int h, int num_chans, size_t *pLen_out);
		}}}
	}

	public static Buffer encode(Buffer data, int width, int height) {
		if(data == null || width < 1 || height < 1) {
			return(null);
		}
		IFDEF("target_c") {
			var ptr = data.get_pointer();
			if(ptr == null) {
				return(null);
			}
			var np = ptr.get_native_pointer();
			if(np == null) {
				return(null);
			}
			int len;
			ptr pngptr = null;
			embed {{{
				size_t lent;
				pngptr = tdefl_write_image_to_png_file_in_memory(np, width, height, 4, &lent);
				len = lent;
			}}}
			if(pngptr == null) {
				return(null);
			}
			if(len < 1) {
				embed {{{
					free(pngptr);
				}}}
				return(null);
			}
			return(Buffer.for_owned_pointer(Pointer.create(pngptr), len));
		}
		ELSE {
			return(null);
		}
	}
}
