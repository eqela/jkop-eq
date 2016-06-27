
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

public class FreeTypeTextLayout : TextLayout, Size
{
	embed "c" {{{
		#include <ft2build.h>
		#include FT_GLYPH_H
		#include FT_FREETYPE_H
	}}}

	TextProperties tprops;
	Collection collection;
	DoubleArray advance_x = null;
	DoubleArray heights = null;
	double highest_height;
	double text_width;
	int offset_y;
	String font_name;
	ptr font_face = null;
	ptr ft_library = null;
	int dpi;

	public static FreeTypeTextLayout create(TextProperties tprops, int dpi, String font_name) {
		if(tprops == null) {
			return(null);
		}
		var ttf = new FreeTypeTextLayout();
		ttf.dpi = dpi;
		ttf.tprops = tprops;
		ttf.font_name = font_name;
		if(ttf.initialize() == false) {
			return(null);
		}
		return(ttf);
	}

	FreeTypeTextLayout() {
		advance_x = DoubleArray.create().set_size(128);
		heights = DoubleArray.create().set_size(128);
	}

	~FreeTypeTextLayout() {
		advance_x.clear();
		heights.clear();
		var font_face = this.font_face;
		var ft_library = this.ft_library;
		embed "c" {{{
			free_freetype((FT_Face)font_face, (FT_Library)ft_library);
		}}}
	}

	embed "c" {{{
		void free_freetype(FT_Face face, FT_Library library) {
			if(face != NULL) {
				FT_Done_Face(face);
			}
			if(library != NULL) {
				FT_Done_FreeType(library);
			}
		}
	}}}

	bool prepare_text_metrics() {
		ptr font_face;
		ptr ft_library;
		var heights = this.heights;
		var advance_x = this.advance_x;
		var font_name = this.font_name;
		var font_file = File.for_app_directory().entry(font_name);
		if(font_file.is_file() == false) {
			return(false);
		}
		var font_file_ptr = font_file.get_native_path().to_strptr();
		if(font_file_ptr == null) {
			return(false);
		}
		var font = tprops.get_font();
		var text = tprops.get_text();
		var text_ptr = text.to_strptr();
		int length = text.get_length();
		int font_size = Length.to_pixels(font.get_size(), dpi);
		embed "c" {{{
			FT_Library library;
			FT_Face face;
			if(FT_Init_FreeType(&library)) {
				free_freetype(NULL, library);
				return(FALSE);
			}
			if(FT_New_Face(library, font_file_ptr, 0, &face)) {
				free_freetype(face, library);
				return(FALSE);
			}
			if(FT_Set_Pixel_Sizes(face, font_size, font_size)) {
				free_freetype(face, library);
				return(FALSE);
			}
		}}}
		double text_width = 0;
		double highest_height;
		double height_val;
		double advance_x_val;
		int offset_y;
		int offset_y_val;
		int i;
		embed "c" {{{
			FT_BBox bbox;
			FT_Glyph glyph;
			FT_GlyphSlot slot;
			for(i = 0; i < 128; i++) {
				if(FT_Load_Char(face, i, FT_LOAD_RENDER)) {
					continue;
				}
				slot = face->glyph;
				if(FT_Get_Glyph(slot, &glyph)) {
					free_freetype(face, library);
					return(FALSE);
				}
				FT_Glyph_Get_CBox(glyph, FT_GLYPH_BBOX_PIXELS, &bbox);
				offset_y_val = abs(floor(bbox.yMin));
				if(offset_y < offset_y_val) {
					offset_y = offset_y_val;
				}
				height_val = (float)slot->bitmap.rows + offset_y;
				advance_x_val = (float)(slot->advance.x >> 6);
				if(highest_height < height_val) {
					highest_height = height_val;
				}
				FT_Done_Glyph(glyph);
			}}}
			advance_x.set_index(i, advance_x_val);
		embed "c" {{{
			}
			font_face = face;
			ft_library = library;
		}}}
		int j;
		for(j = 0; j < length; j++) {
			text_width += advance_x.get_index(text.get_char(j));
			heights.set_index(j, highest_height);
		}
		this.heights = heights;
		this.offset_y = offset_y;
		this.advance_x = advance_x;
		this.font_face = font_face;
		this.ft_library = ft_library;
		this.text_width = text_width;
		this.highest_height = highest_height;
		return(true);
	}

	public bool initialize() {
		var txt = tprops.get_text();
		if(String.is_empty(txt)) {
			return(false);
		}
		if(prepare_text_metrics() == false) {
			return(false);
		}
		double text_width = this.text_width;
		int wrap_width = tprops.get_wrap_width();
		if(wrap_width > 0 && text_width > wrap_width) {
			build_text(wrap_width);
		}
		return(true);
	}

	void build_text(int wrap_width) {
		int chr;
		int start;
		int space_index;
		int curr_index = 0;
		int line_count = 0;
		double h;
		double widest;
		double line_width;
		double init_width = 0;
		var text = tprops.get_text();
		var advance_x = this.advance_x;
		var heights = this.heights;
		var text_itr = text.iterate();
		while((chr = text.get_char(curr_index)) > 0) {
			if(chr == ' ' || chr == '\n') {
				space_index = curr_index;
				line_width = init_width;
			}
			init_width += advance_x.get_index(chr);
			h = heights.get_index(chr);
			if((init_width > wrap_width) || chr == '\n') {
				int end = curr_index;
				if(space_index > 0) {
					end = space_index;
				}
				double final_width = init_width - advance_x.get_index(chr);
				if(line_width > 0) {
					final_width = line_width;
				}
				add_to_collection(start, end, final_width, h);
				if(widest < init_width) {
					widest = init_width;
				}
				if(space_index > 0) {
					start = space_index + 1;
					if(chr == '\n') {
						start = space_index;
					}
					curr_index = start;
					space_index = 0;
				}
				else {
					start = curr_index;
				}
				line_count++;
				line_width = 0;
				init_width = advance_x.get_index(chr);
			}
			curr_index++;
		}
		add_to_collection(start, curr_index, init_width, h);
		this.text_width = widest;
		this.highest_height = (line_count - 1) * this.highest_height;
	}

	void add_to_collection(int start, int end, double width, double height) {
		if(collection == null) {
			collection = LinkedList.create();
		}
		var ftt = new FreeTypeText();
		var text = tprops.get_text();
		ftt.set_text(text.substring(start, end - start));
		ftt.set_width(width);
		ftt.set_height(height);
		collection.add(ftt);
	}

	public Collection get_wrapped_texts() {
		return(collection);
	}

	public int get_dpi() {
		return(dpi);
	}

	public ptr get_font_face() {
		return(font_face);
	}

	public double get_width() {
		return(text_width);
	}

	public double get_height() {
		return(highest_height);
	}

	public int get_offset_y() {
		return(offset_y);
	}

	public int xy_to_index(double x, double y) {
		double w = 0;
		var text = tprops.get_text();
		int i, c;
		var advance_x = this.advance_x;
		int len = text.get_length();
		for(i = 0; i < len; i++) {
			c = text.get_char(i);
			if((w + (advance_x.get_index(c) * 0.5)) >= x) {
				break;
			}
			w += advance_x.get_index(c);
		}
		return(i);
	}

	public Rectangle get_cursor_position(int index) {
		double x = 0, h = get_height();
		int i;
		var text = tprops.get_text();
		var advance_x = this.advance_x;
		for(i = 0; i < index; i++) {
			x += advance_x.get_index(text.get_char(i));
		}
		if(index != 0) {
			x -= advance_x.get_index(text.get_char(0)) * 0.07;
		}
		return(Rectangle.instance(x, 0, 1, h));
	}

	public TextProperties get_text_properties() {
		return(tprops);
	}
}
