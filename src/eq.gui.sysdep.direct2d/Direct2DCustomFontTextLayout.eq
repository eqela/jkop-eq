
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

public class Direct2DCustomFontTextLayout : TextLayout, Size
{
	embed "c++" {{{
		#include <windows.h>
		#include <dwrite.h>
		#include <d2d1.h>
	}}}

	int dpi;
	String font_name;
	double layout_width;
	double layout_height;
	double initial_height;
	double tail_height;
	ptr dwrite_font_face;
	ptr path_geometry;
	TextProperties tprops;
	Collection wrapped_texts;
	DoubleArray advance_width = null;

	public static Direct2DCustomFontTextLayout create(TextProperties tprops, int dpi, String font_name) {
		if(tprops == null) {
			return(null);
		}
		var d = new Direct2DCustomFontTextLayout();
		d.tprops = tprops;
		d.dpi = dpi;
		d.font_name = font_name;
		if(d.initialize() == false) {
			return(null);
		}
		return(d);
	}

	public Direct2DCustomFontTextLayout() {
		wrapped_texts = LinkedList.create();
		advance_width = DoubleArray.create().set_size(128);
	}

	~Direct2DCustomFontTextLayout() {
		if(advance_width != null) {
			advance_width.clear();
		}
		if(wrapped_texts != null) {
			foreach(Direct2DCustomFontText cft in wrapped_texts) {
				ptr path = cft.get_path_geometry();
				embed "c++" {{{
					((ID2D1PathGeometry*)path)->Release();
				}}}
			}
			wrapped_texts.clear();
		}
		ptr path_geometry = this.path_geometry;
		ptr dwrite_font_face = this.dwrite_font_face;
		embed "c++" {{{
			if(path_geometry != NULL) {
				((ID2D1PathGeometry*)path_geometry)->Release();
			}
			if(dwrite_font_face != NULL) {
				((IDWriteFontFace*)dwrite_font_face)->Release();
			}
		}}}
	}

	bool initialize() {
		var text = tprops.get_text();
		if(text == null) {
			return(false);
		}
		if(prepare_text_metrics() == false) {
			return(false);
		}
		int wrap_width = tprops.get_wrap_width();
		if(wrap_width > 0 && this.layout_width > wrap_width) {
			build_wrapped_text(wrap_width);
		}
		else {
			if(text.chr('\n') > 0) {
				build_wrapped_text(layout_width);
				return(true);
			}
			ptr glyph_indices = create_glyphs(text);
			path_geometry = create_path_geometry(text.get_length(), glyph_indices);
			embed "c++" {{{
				delete [] (UINT16*)glyph_indices;
			}}}
		}
		return(true);
	}

	bool prepare_text_metrics() {
		var file_path = File.for_app_directory().entry(font_name);
		if(file_path.is_file() == false) {
			return(false);
		}
		var npath = file_path.get_native_path();
		var wpath = WideString.for_string(npath);
		ptr wpath_ptr = wpath.get_buffer();
		if(wpath_ptr == null) {
			return(false);
		}
		bool success = false;
		embed "c++" {{{
			IDWriteFactory* dwrite_factory;
			HRESULT hr = DWriteCreateFactory(
				DWRITE_FACTORY_TYPE_SHARED,
				__uuidof(IDWriteFactory),
				reinterpret_cast<IUnknown**>(&dwrite_factory)
			);
			success = SUCCEEDED(hr);
		}}}
		if(success == false) {
			return(false);
		}
		ptr dwrite_font_face = null;
		var text = tprops.get_text();
		int len = text.get_length();
		embed "c++" {{{
			IDWriteFontFile* dwrite_font_file = NULL;
			hr = dwrite_factory->CreateFontFileReference(
				(const WCHAR*)wpath_ptr,
				NULL,
				&dwrite_font_file
			);
			success = SUCCEEDED(hr);
		}}}
		if(success == false) {
			embed "c++" {{{
				dwrite_factory->Release();
			}}}
			return(false);
		}
		embed "c++" {{{
			IDWriteFontFile* dwrite_font_files[] = { dwrite_font_file };
			hr = dwrite_factory->CreateFontFace(
				DWRITE_FONT_FACE_TYPE_TRUETYPE,
				1,
				dwrite_font_files,
				0,
				DWRITE_FONT_SIMULATIONS_NONE,
				(IDWriteFontFace**)&dwrite_font_face
			);
			success = SUCCEEDED(hr);
			if(dwrite_font_file != NULL) {
				dwrite_font_file->Release();
			}
		}}}
		embed "c++" {{{
			dwrite_factory->Release();
		}}}
		if(success == false) {
			return(false);
		}
		this.dwrite_font_face = dwrite_font_face;
		int ascent;
		int descent;
		int em_size;
		embed "c++" {{{
			DWRITE_FONT_METRICS dwrite_font_metrics;
			((IDWriteFontFace*)dwrite_font_face)->GetMetrics(&dwrite_font_metrics);
			ascent = dwrite_font_metrics.ascent;
			descent = dwrite_font_metrics.descent;
			em_size = dwrite_font_metrics.designUnitsPerEm;
		}}}
		int j = 0, curr_chr;
		double w, adv_width, layout_width = 0;
		var font_size = Length.to_pixels(tprops.get_font().get_size(), dpi);
		while((curr_chr = text.get_char(j)) > 0) {
			if(curr_chr == '\n') {
				j++;
				continue;
			}
			ptr gi = create_glyphs(String.for_character(curr_chr));
			embed "c++" {{{
				DWRITE_GLYPH_METRICS dwrite_glyph_metrics;
				((IDWriteFontFace*)dwrite_font_face)->GetDesignGlyphMetrics(
					(UINT16*)gi,
					1,
					&dwrite_glyph_metrics,
					TRUE
				);
				adv_width = dwrite_glyph_metrics.advanceWidth;
			}}}
			w = (double)((font_size * adv_width) / em_size);
			advance_width.set_index(curr_chr, w);
			layout_width += w;
			embed "c++" {{{
				delete [] (UINT16*)gi;
			}}}
			j++;
		}
		this.layout_width = layout_width;
		tail_height = (double)((font_size * descent) / em_size);
		layout_height = (double)((font_size * (ascent + descent)) / em_size);
		initial_height = layout_height;
		return(true);
	}

	ptr create_glyphs(String text) {
		int len = text.get_length();
		ptr glyph_indices;
		embed "c++" {{{
			UINT* cp = new UINT[len];
			UINT16* gi = new UINT16[len];
		}}}
		int c, i = 0;
		while((c = text.get_char(i)) > 0) {
			embed "c++" {{{
				cp[i] = (UINT)c;
			}}}
			i++;
		}
		bool success = false;
		ptr dwrite_font_face = this.dwrite_font_face;
		embed "c++" {{{
			HRESULT hr = ((IDWriteFontFace*)dwrite_font_face)->GetGlyphIndices(cp, len, gi);
			success = SUCCEEDED(hr);
		}}}
		if(success == false) {
			embed "c++" {{{
				((IDWriteFontFace*)dwrite_font_face)->Release();
			}}}
			return(null);
		}
		embed "c++" {{{
			glyph_indices = gi;
			if(cp != NULL) {
				delete [] cp;
			}
		}}}
		return(glyph_indices);
	}

	ptr create_path_geometry(int text_length, ptr glyph_indices) {
		ptr factory = Direct2DFactory.instance();
		ptr path_geometry = null;
		bool success = false;
		embed "c++" {{{
			HRESULT hr = ((ID2D1Factory*)factory)->CreatePathGeometry((ID2D1PathGeometry**)&path_geometry);
			success = SUCCEEDED(hr);
		}}}
		if(success == false) {
			return(null);
		}
		int dpi = this.dpi;
		int font_size = Length.to_pixels(tprops.get_font().get_size(), dpi);
		ptr dwrite_font_face = this.dwrite_font_face;
		embed "c++" {{{
			ID2D1GeometrySink* geo_sink = NULL;
			hr = ((ID2D1PathGeometry*)path_geometry)->Open(&geo_sink);
			success = SUCCEEDED(hr);
		}}}
		if(success == true) {
			embed "c++" {{{
				((IDWriteFontFace*)dwrite_font_face)->GetGlyphRunOutline(
					font_size,
					(UINT16*)glyph_indices,
					NULL,
					NULL,
					text_length,
					FALSE,
					FALSE,
					geo_sink
				);
				geo_sink->Close();
				if(geo_sink != NULL) {
					geo_sink->Release();
				}
			}}}
		}
		return(path_geometry);
	}

	void add_to_collection(int start, int end, double width, double height) {
		if(wrapped_texts == null) {
			wrapped_texts = LinkedList.create();
		}
		var cft = new Direct2DCustomFontText();
		var substr = tprops.get_text().substring(start, end - start);
		if(substr == null) {
			return;
		}
		ptr glyph_indices = create_glyphs(substr);
		cft.set_path_geometry(create_path_geometry(substr.get_length(), glyph_indices));
		cft.set_width(width);
		cft.set_height(height);
		wrapped_texts.add(cft);
		embed "c++" {{{
			delete [] (UINT16*)glyph_indices;
		}}}
	}

	void build_wrapped_text(int wrap_width) {
		int chr;
		int start;
		int space_index;
		int curr_index = 0;
		int line_count = 0;
		double widest;
		double line_width;
		double init_width = 0;
		double init_height = this.layout_height;
		var text = tprops.get_text();
		while((chr = text.get_char(curr_index)) > 0) {
			if(chr == ' ') {
				space_index = curr_index;
				line_width = init_width;
			}
			init_width += advance_width.get_index(chr);
			if(init_width > wrap_width) {
				int end = curr_index;
				if(space_index > 0) {
					end = space_index;
				}
				double final_width = init_width - advance_width.get_index(chr);
				if(line_width > 0) {
					final_width = line_width;
				}
				add_to_collection(start, end, final_width, init_height);
				if(widest < init_width) {
					widest = init_width;
				}
				if(space_index > 0) {
					start = space_index + 1;
					curr_index = start;
					space_index = 0;
				}
				else {
					start = curr_index;
				}
				line_count++;
				line_width = 0;
				init_width = advance_width.get_index(chr);
			}
			else if(chr == '\n') {
				add_to_collection(start, curr_index, init_width, init_height);
				double lw = init_width;
				if(widest < lw) {
					widest = lw;
				}
				start = curr_index + 1;
				init_width = 0;
				line_count++;
			}
			curr_index++;
		}
		add_to_collection(start, curr_index, init_width, init_height);
		this.layout_width = widest;
		this.layout_height = line_count * init_height;
	}

	public double get_initial_height() {
		return(initial_height);
	}

	public Collection get_wrapped_texts() {
		return(wrapped_texts);
	}

	public ptr get_path_geometry() {
		return(path_geometry);
	}

	public double get_tail_height() {
		return(tail_height);
	}

	public double get_width() {
		return(layout_width);
	}

	public double get_height() {
		return(layout_height);
	}

	public TextProperties get_text_properties() {
		return(tprops);
	}

	public Rectangle get_cursor_position(int index) {
		int i;
		double x = 0;
		var text = tprops.get_text();
		for(i = 0; i < index; i++) {
			x += advance_width.get_index(text.get_char(i));
		}
		return(Rectangle.instance(x, 0, 1, get_height()));
	}

	public int xy_to_index(double x, double y) {
		int i, chr;
		double w = 0;
		var text = tprops.get_text();
		for(i = 0; i < text.get_length(); i++) {
			chr = text.get_char(i);
			if((w + (advance_width.get_index(chr) * 0.5)) >= x) {
				break;
			}
			w += advance_width.get_index(chr);
		}
		return(i);
	}
}
