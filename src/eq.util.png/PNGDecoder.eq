
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

IFDEF("target_c")
{
	public class PNGDecoder
	{
		IFDEF("target_cpp") {
			embed {{{
				extern "C" int mz_uncompress(unsigned char *pDest, unsigned long *pDest_len, const unsigned char *pSource, unsigned long source_len);
			}}}
		}
		ELSE IFDEF("target_c") {
			embed {{{
				int mz_uncompress(unsigned char *pDest, unsigned long *pDest_len, const unsigned char *pSource, unsigned long source_len);
			}}}
		}

		embed {{{
			//Paeth predicter, used by PNG filter type 4
			int paeth_predictor(int a, int b, int c)
			{
				int p = a + b - c;
				int pa = p > a ? p - a : a - p;
				int pb = p > b ? p - b : b - p;
				int pc = p > c ? p - c : c - p;
				if(pa <= pb && pa <= pc) {
					return(a);
				}
				else if(pb <= pc) {
					return(b);
				}
				else {
					return(c);
				}
			}

			int unfilter_scanline(unsigned char *recon, const unsigned char *scanline, const unsigned char *precon, unsigned long bytewidth, unsigned char filtertype, unsigned long length)
			{
				unsigned long i;
				int status = 1;
				if(filtertype == 0) {
					for(i = 0; i < length; i++)
						recon[i] = scanline[i];
				}
				else if(filtertype == 1) {
					for(i = 0; i < bytewidth; i++)
						recon[i] = scanline[i];
					for(i = bytewidth; i < length; i++)
						recon[i] = scanline[i] + recon[i - bytewidth];
				}
				else if(filtertype == 2) {
					if(precon) {
						for(i = 0; i < length; i++)
							recon[i] = scanline[i] + precon[i];
					}
					else {
						for(i = 0; i < length; i++)
							recon[i] = scanline[i];
					}
				}
				else if(filtertype == 3) {
					if(precon) {
						for(i = 0; i < bytewidth; i++)
							recon[i] = scanline[i] + precon[i] / 2;
						for(i = bytewidth; i < length; i++)
							recon[i] = scanline[i] + ((recon[i - bytewidth] + precon[i]) / 2);
					}
					else {
						for(i = 0; i < bytewidth; i++)
							recon[i] = scanline[i];
						for(i = bytewidth; i < length; i++)
							recon[i] = scanline[i] + recon[i - bytewidth] / 2;
					}
				}
				else if(filtertype == 4) {
					if(precon) {
						for (i = 0; i < bytewidth; i++)
							recon[i] = (unsigned char)(scanline[i] + paeth_predictor(0, precon[i], 0));
						for (i = bytewidth; i < length; i++)
							recon[i] = (unsigned char)(scanline[i] + paeth_predictor(recon[i - bytewidth], precon[i], precon[i - bytewidth]));
					}
					else {
						for (i = 0; i < bytewidth; i++)
							recon[i] = scanline[i];
						for (i = bytewidth; i < length; i++)
							recon[i] = (unsigned char)(scanline[i] + paeth_predictor(recon[i - bytewidth], 0, 0));
					}
				}
				else {
					status = -1;
				}
				return(status);
			}

			int unfilter(unsigned char *unfiltered, const unsigned char *filtered, unsigned w, unsigned h, unsigned bpp)
			{ 
				unsigned y;
				unsigned char *prevline = 0;
				unsigned long bytewidth = (bpp + 7) / 8;
				unsigned long linebytes = (w * bpp + 7) / 8;
				int status = 0;
				for(y = 0; y < h; y++) {
					unsigned long unfilteredindex = linebytes * y;
					unsigned long filteredindex = (1 + linebytes) * y;
					unsigned char filtertype = filtered[filteredindex];
					status = unfilter_scanline(&unfiltered[unfilteredindex], &filtered[filteredindex + 1], prevline, bytewidth, filtertype, linebytes);
					if(status == -1) {
					return(status);
					}
				prevline = &unfiltered[unfilteredindex];
				}
				return(status);
			}

			void *read_png_buffer_to_pixels(const void *pSrc_Buffer, int source_size, size_t *pLen_out, size_t *pWidth_out, size_t *pHeight_out)
			{
				unsigned char* source = pSrc_Buffer;
				unsigned char* chunk;
				unsigned char* compressed;
				unsigned char* inflated;
				unsigned char* final_buf;
				unsigned long compressed_size = 0, compressed_index = 0, inflated_size, final_size;
				int width = 0, height = 0, color_depth = 0, color_type = 0, bpp = 0, components = 4;
				if((source[0] == 137 && source[1] == 80 && source[2] == 78 && source[3] == 71 && source[4] == 13 && source[5] == 10 && source[6] == 26 && source[7] == 10) == 0) { //check if png
					return(NULL);
				}
				if((source[12] == 73 && source[13] == 72 && source[14] == 68 && source[15] == 82) == 0) { //check if ihdr
					return(NULL);
				}
				width = (source[16] << 24) + ((source[17]&0xff) << 16) + ((source[18]&0xff)<< 8) + (source[19]&0xff);
				height = (source[20] << 24) + ((source[21]&0xff) << 16) + ((source[22]&0xff)<< 8) + (source[23]&0xff);
				color_depth = source[24];
				color_type = source[25];
				bpp = color_depth * components;
				if(color_type != 6) {
					return(NULL);
				}
				if(bpp != 32) {
					return(NULL);
				}
				chunk = source + 33; // first byte of the first chunk after the header
				while(chunk < source + source_size) {
					unsigned long length;
					unsigned char *data;
					if((unsigned long)(chunk - source + 12) > source_size) {
						return(NULL);
					}
					length = (chunk[0] << 24) + ((chunk[1]&0xff) << 16) + ((chunk[2]&0xff)<< 8) + (chunk[3]&0xff);
					if ((unsigned long)(chunk - source + length + 12) > source_size) {
						return(NULL);
					}
					data = chunk + 8;
					if(chunk[4] == 73 && chunk[5] == 68&& chunk[6] == 65 && chunk[7] == 84){ // check if IDAT
						compressed_size += length;
					} 
					else if(chunk[4] == 73 && chunk[5] == 69 && chunk[6] == 78 && chunk[7] == 68) { // check if IEND
						break;
					} 
					else if(((chunk)[4] & 32) == 0) { // check if chunk is critical
						return(NULL);
					}
					chunk += length + 12;
				}
				compressed = (unsigned char*)malloc(compressed_size);
				if(compressed == NULL) {
					return(NULL);
				}
				chunk = source + 33;
				while (chunk < source + source_size) {
					unsigned long length;
					const unsigned char *data;
					length = (chunk[0] << 24) + ((chunk[1]&0xff) << 16) + ((chunk[2]&0xff)<< 8) + (chunk[3]&0xff);
					data = chunk + 8;
					if(chunk[4] == 73 && chunk[5] == 68&& chunk[6] == 65 && chunk[7] == 84) { // check if idat
						memcpy(compressed + compressed_index, data, length);
						compressed_index += length;
					} else if(chunk[4] == 73 && chunk[5] == 69 && chunk[6] == 78 && chunk[7] == 68) { // check if iend
						break;
					}
					chunk += length + 12;
				}
				inflated_size = ((width * (height * bpp + 7)) / 8) + height;
				inflated = (unsigned char*)malloc(inflated_size);
				if (inflated == NULL) {
					free(compressed);
					return(NULL);
				}
				//decompress image data
				int status = mz_uncompress((void *)inflated, &inflated_size, (void *)compressed, compressed_size);
				free(compressed);
				if(status != 0) {
					return(NULL);
				}
				final_size = (height *width * bpp + 7) / 8;
				final_buf = (unsigned char*)malloc(final_size);
				if(final_buf == NULL) {
					free(inflated);
					return(NULL);
				}
				int unfilter_status = unfilter(final_buf, inflated, width, height, bpp);
				free(inflated);
				if(unfilter_status == -1) {
					return(NULL);
				}
				*pLen_out = final_size;
				*pWidth_out = width;
				*pHeight_out = height;
				return(final_buf);
			}
		}}}

		public static RGBAImageBuffer decode(Buffer data) {
			if(data == null) {
				return(null);
			}
			int buf_size = data.get_size();
			IFDEF("target_c") {
				var ptrdata = data.get_pointer();
				if(ptrdata == null) {
					return(null);
				}
				var np = ptrdata.get_native_pointer();
				if(np == null) {
					return(null);
				}
				int len, w, h;
				ptr pngptr = null;
				embed {{{
					size_t lent, wt, ht;
					pngptr = read_png_buffer_to_pixels(np, buf_size, &lent, &wt, &ht);
					len = lent;
					w = wt;
					h = ht;
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
				var img_buf = new RGBAImageBuffer();
				img_buf.set_buffer(Buffer.for_owned_pointer(Pointer.create(pngptr), len));
				img_buf.set_width(w);
				img_buf.set_height(h);
				return(img_buf);
			}
			ELSE {
				return(null);
			}
		}
	}
}

ELSE
{
	public class PNGDecoder
	{
		public static RGBAImageBuffer decode(Buffer data) {
			return(null);
		}
	}
}
