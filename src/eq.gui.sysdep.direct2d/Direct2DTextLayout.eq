
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

class Direct2DTextLayout : TextLayout, Size
{
	embed "c" {{{
		#include <windows.h>
		#include <d2d1.h>
		#include <dwrite.h>
	}}}

	TextProperties props;
	WideString widefontname;
	WideString widetext;
	int dpi;
	ptr write_textlayout;
	int width;
	int height;
	int text_width;

	~Direct2DTextLayout() {
		ptr write_textlayout = this.write_textlayout;
		embed "c++" {{{
			if(write_textlayout != NULL) {
				((IDWriteTextLayout*)write_textlayout)->Release();
			}
		}}}
	}

	public static Direct2DTextLayout create(TextProperties props, int dpi) {
		var v = new Direct2DTextLayout();
		v.props = props;
		v.dpi = dpi;
		if(v.initialize() == false) {
			v = null;
		}
		return(v);
	}

	static HashTable font_alias_table;

	String win_font_name(String fn) {
		if(fn == null) {
			return(fn);
		}
		if(font_alias_table == null) {
			font_alias_table = HashTable.create()
				.set("sans-serif", "Verdana")
				.set("sans", "Verdana")
				.set("monospace", "Lucida Console")
				.set("serif", "Times New Roman");
		}
		var v = font_alias_table.get_string(fn.lowercase());
		if(String.is_empty(v)) {
			return(fn);
		}
		return(v);
	}

	public bool initialize() {
		embed "c++" {{{
			IDWriteFactory* wfactory;
			DWriteCreateFactory(
				DWRITE_FACTORY_TYPE_SHARED,
				__uuidof(IDWriteFactory),
				reinterpret_cast<IUnknown**>(&wfactory)
			);
		}}}
		ptr write_format;
		ptr write_textlayout;
		var fn = props.get_font();
		String fname = win_font_name(fn.get_name());
		widefontname = WideString.for_string(fname);
		ptr widefontnameb = widefontname.get_buffer();
		int fontsize = Length.to_pixels(fn.get_size(), dpi);
		bool bold = fn.is_bold(), italic = fn.is_italic(), underline = fn.is_underline();
		int alignment = props.get_alignment();
		bool success;
		embed "c++" {{{
			DWRITE_FONT_WEIGHT weight = DWRITE_FONT_WEIGHT_NORMAL;
			DWRITE_FONT_STYLE style = DWRITE_FONT_STYLE_NORMAL;
			if(bold) {
				weight = DWRITE_FONT_WEIGHT_BOLD;
			}
			if(italic) {
				style = DWRITE_FONT_STYLE_ITALIC;
			}
			HRESULT r = wfactory->CreateTextFormat(
				(const WCHAR*)widefontnameb,
				NULL,
				weight,
				style,
				DWRITE_FONT_STRETCH_NORMAL,
				fontsize,
				L"",
				(IDWriteTextFormat**)&write_format
			);
			success = SUCCEEDED(r);
		}}}
		if(success == false) {
			Log.error("CreateTextFormat failed");
			embed "c++" {{{
				((IDWriteTextFormat*)write_format)->Release();
				wfactory->Release();
			}}}
			return(false);
		}
		String text = props.get_text();
		if(text == null) {
			text = "";
		}
		int length = text.get_length();
		widetext = WideString.for_string(text);
		var widetextb = widetext.get_buffer();
		int max_width = props.get_wrap_width();
		int aw, ah;
		embed "c++" {{{
			r = wfactory->CreateTextLayout(
			  (const WCHAR*) widetextb,
			  length,
			  (IDWriteTextFormat*)write_format,
			  INT_MAX,
			  0,
			  (IDWriteTextLayout**)&write_textlayout
			);
			success = SUCCEEDED(r);
		}}}
		if(success == false) {
			Log.error("CreateTextLayout (1) failed");
		}
		double tw = 0;
		embed "c++" {{{
			if(success) {
				if(alignment == 0) {
					((IDWriteTextFormat*)write_format)->SetTextAlignment(DWRITE_TEXT_ALIGNMENT_LEADING);
				}
				else if(alignment == 1) {
					((IDWriteTextFormat*)write_format)->SetTextAlignment(DWRITE_TEXT_ALIGNMENT_CENTER);
				}
				else if(alignment == 2) {
					((IDWriteTextFormat*)write_format)->SetTextAlignment(DWRITE_TEXT_ALIGNMENT_TRAILING);
				}
				else if(alignment == 3) {
					((IDWriteTextFormat*)write_format)->SetTextAlignment(DWRITE_TEXT_ALIGNMENT_LEADING);
				}
			}
			DWRITE_TEXT_METRICS metricsw;
			((IDWriteTextLayout*)write_textlayout)->GetMetrics(&metricsw);
			aw = (int)metricsw.width;
			if(max_width > 0 && aw > max_width) {
				aw = max_width;
				((IDWriteTextFormat*)write_format)->SetWordWrapping(DWRITE_WORD_WRAPPING_WRAP);
			}
			else {
				max_width = aw;
				((IDWriteTextFormat*)write_format)->SetWordWrapping(DWRITE_WORD_WRAPPING_NO_WRAP);
			}
			((IDWriteTextLayout*)write_textlayout)->Release();
			write_textlayout = NULL;
			r = ((IDWriteFactory*)wfactory)->CreateTextLayout(
			  (const WCHAR*)widetextb,
			  length,
			  (IDWriteTextFormat*)write_format,
			  max_width,
			  INT_MAX,
			  (IDWriteTextLayout**)&write_textlayout
			);
			success = SUCCEEDED(r);
		}}}
		if(success == false) {
			Log.error("CreateTextLayout (2) failed");
		}
		embed "c++" {{{
			if(success) {
				if(underline) {
					DWRITE_TEXT_RANGE range = {0, length-1};
					((IDWriteTextLayout*)write_textlayout)->SetUnderline(TRUE, range);
				}
			}
			DWRITE_TEXT_METRICS metricsh;
			((IDWriteTextLayout*)write_textlayout)->GetMetrics(&metricsh);
			ah = (int)metricsh.height;
			if(max_width > 0 && aw > max_width) {
				tw = max_width;
			}
			else {
				tw = (int)metricsh.width;
			}
			((IDWriteTextFormat*)write_format)->Release();
			((IDWriteFactory*)wfactory)->Release();
		}}}
		this.write_textlayout = write_textlayout;
		width = aw;
		height = ah;
		text_width = tw;
		return(true);
	}

	public TextProperties get_text_properties() {
		return(props);
	}

	public Rectangle get_cursor_position(int index) {
		double x, y, w, h;
		ptr layout = this.write_textlayout;
		if(layout!=null) {
			embed "c++" {{{
				DWRITE_HIT_TEST_METRICS metrics;
				((IDWriteTextLayout*)layout)->HitTestTextPosition(index, TRUE, (float*)&x, (float*)&y, &metrics);
				x += metrics.left;
				y += metrics.top;
				w = metrics.width;
				h = metrics.height;
			}}}
		}
		return(Rectangle.instance((int)x, (int)y, (int)w, (int)h));
	}

	public int xy_to_index(double x, double y) {
		int v;
		int len = 0;
		ptr layout = this.write_textlayout;
		var txt = props.get_text();
		if(String.is_empty(txt) == false) {
			len = txt.get_length();
		}
		int max;
		bool is_trailing, is_inside;
		embed "c++" {{{
			DWRITE_HIT_TEST_METRICS metrics;
			((IDWriteTextLayout*)layout)->HitTestPoint((float)x, (float)y, (BOOL*)&is_trailing, (BOOL*)&is_inside, &metrics);
			v = metrics.textPosition;
		}}}
		if(is_trailing) {
			v++;
		}
		return(v);
	}

	public int get_text_width() {
		return(text_width);
	}

	public double get_width() {
		return(width);
	}

	public double get_height() {
		return(height);
	}

	public ptr get_write_textlayout() {
		return(write_textlayout);
	}
}
