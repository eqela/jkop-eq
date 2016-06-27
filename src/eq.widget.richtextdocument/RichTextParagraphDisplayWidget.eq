
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

class RichTextParagraphDisplayWidget : Widget, LayoutArrayWidget
{
	public static RichTextParagraphDisplayWidget for_paragraph(RichTextParagraph pp) {
		return(new RichTextParagraphDisplayWidget().set_paragraph(pp));
	}

	property HashTable styles;
	property RichTextParagraph paragraph;
	property String padding;
	property String line_spacing;
	property String space_width;
	property int alignment;
	Collection layouts;
	Collection draw_ops;

	public RichTextParagraphDisplayWidget() {
		space_width = "1mm";
		line_spacing = "500um";
		alignment = RichTextParagraphStyle.ALIGN_LEFT;
	}

	int compute_row_width(Collection row, int sp) {
		int w = 0;
		foreach(DrawObjectOperation op in row) {
			if(w > 0) {
				w += sp;
			}
			var ll = op.get_object() as TextLayout;
			if(ll != null) {
				w += ll.get_width();
			}
		}
		return(w);
	}

	void commit_row(Collection row, Collection v, int pad, int sp, bool last_row) {
		if(row == null) {
			return;
		}
		if(alignment == RichTextParagraphStyle.ALIGN_LEFT) {
			int x = pad;
			foreach(DrawObjectOperation op in row) {
				if(x > pad) {
					x += sp;
				}
				op.set_x(x);
				var ll = op.get_object() as TextLayout;
				if(ll != null) {
					x += ll.get_width();
				}
				v.add(op);
			}
		}
		else if(alignment == RichTextParagraphStyle.ALIGN_RIGHT) {
			var w = compute_row_width(row, sp);
			var x = get_width() - pad - w;
			var ix = x;
			foreach(DrawObjectOperation op in row) {
				op.set_x(x);
				if(x > ix) {
					x += sp;
				}
				var ll = op.get_object() as TextLayout;
				if(ll != null) {
					x += ll.get_width();
				}
				v.add(op);
			}
		}
		else if(alignment == RichTextParagraphStyle.ALIGN_CENTER) {
			var w = compute_row_width(row, sp);
			var x = (get_width() - pad - w) / 2;
			var ix = x;
			foreach(DrawObjectOperation op in row) {
				if(x > ix) {
					x += sp;
				}
				op.set_x(x);
				var ll = op.get_object() as TextLayout;
				if(ll != null) {
					x += ll.get_width();
				}
				v.add(op);
			}
		}
		else if(alignment == RichTextParagraphStyle.ALIGN_JUSTIFY) {
			var w = compute_row_width(row, 0);
			var x = pad;
			int c = row.count()-1;
			if(c < 1) {
				c = 1;
			}
			int mysp;
			if(last_row) {
				mysp = sp;
			}
			else {
				mysp = (get_width()-w-pad-pad) / c;
			}
			if(mysp < 0) {
				mysp = 0;
			}
			foreach(DrawObjectOperation op in row) {
				op.set_x(x);
				var ll = op.get_object() as TextLayout;
				if(ll != null) {
					x += ll.get_width();
				}
				x += mysp;
				v.add(op);
			}
		}
	}

	Collection create_draw_ops(int width, int height) {
		var pad = px(padding);
		var ls = px(line_spacing);
		var sp = px(space_width);
		double x = pad, y = pad;
		double lh = 0;
		var v = LinkedList.create();
		Collection row;
		foreach(TextLayout layout in layouts) {
			// FIXME: Handle those segments that do not have a space between them
			// (change of font properties within a word)
			if(x > pad) {
				x += sp;
			}
			var ww = layout.get_width();
			if(x > pad && width > 0 && x+ww > width-pad) {
				commit_row(row, v, pad, sp, false);
				row = null;
				x = pad;
				y += lh;
				y += ls;
				lh = 0;
			}
			var doo = new DrawObjectOperation();
			doo.set_y(y);
			doo.set_object(layout);
			if(row == null) {
				row = LinkedList.create();
			}
			row.add(doo);
			if(layout.get_height() > lh) {
				lh = layout.get_height();
			}
			x += layout.get_width();
			if(height > 0 && y > height) {
				break;
			}
		}
		if(row != null) {
			commit_row(row, v, pad, sp, true);
		}
		return(v);
	}

	Font get_font_for_style(String style) {
		Font f;
		if(styles != null && String.is_empty(style) == false) {
			var ss = styles.get(style) as RichTextCharacterStyle;
			if(ss != null) {
				f = ss.get_font();
			}
		}
		return(f);
	}

	void update_layouts_for_styled_paragraph(Array layouts, Color dc, Frame frame, int dpi, RichTextStyledParagraph p) {
		// FIXME: Handle those segments that do not have a space between them
		// (change of font properties within a word)
		foreach(RichTextSegment segment in p.get_segments()) {
			var font = Font.instance();
			var fs = StringBuffer.create();
			if(segment.get_bold()) {
				fs.append("bold ");
			}
			if(segment.get_italic()) {
				fs.append("italic ");
			}
			if(segment.get_underline()) {
				fs.append("underline ");
			}
			if(String.is_empty(segment.get_color()) == false) {
				fs.append("color=");
				fs.append(segment.get_color());
				fs.append_c((int)' ');
			}
			if(fs.count() > 0) {
				font = font.dup();
				font.modify(fs.to_string());
			}
			var txt = segment.get_text();
			if(txt == null) {
				continue;
			}
			var it = txt.iterate();
			if(it == null) {
				continue;
			}
			int c;
			var sb = StringBuffer.create();
			while(true) {
				c = it.next_char();
				if(c == '\r') {
					continue;
				}
				if(c == ' ' || c == '\t' || c == '\n' || c < 1) {
					var x = sb.to_string();
					if(String.is_empty(x) == false) {
						var tp = TextProperties.for_string(x);
						tp.set_default_color(dc);
						tp.set_font(font);
						var tl = TextLayout.for_properties(tp, frame, dpi);
						if(tl != null) {
							if(tl is ImageTextLayout) {
								// prepares and renders the image so that we won't
								// need to do that anymore in the main thread
								((ImageTextLayout)tl).get_image();
							}
							layouts.add(tl);
						}
					}
					if(c < 1) {
						break;
					}
					sb = StringBuffer.create();
				}
				else {
					sb.append_c(c);
				}
			}
		}
	}

	public Array create_layouts(Color draw_color, Frame frame, int dpi) {
		Array v = null;
		if(paragraph == null) {
		}
		else if(paragraph is RichTextStyledParagraph) {
			v = Array.create();
			update_layouts_for_styled_paragraph(v, draw_color, frame, dpi, (RichTextStyledParagraph)paragraph);
		}
		else if(paragraph is RichTextPreformattedParagraph) {
			Log.warning("FIXME: Implement support for RichTextPreformattedParagraph");
		}
		else if(paragraph is RichTextReferenceParagraph) {
			Log.warning("FIXME: Implement support for RichTextReferenceParagraph");
		}
		else {
			Log.error("Unknown paragraph type encountered.");
		}
		return(v);
	}

	void update_size_request_for_ops(Collection ops) {
		double x = 0, y = 0;
		foreach(DrawObjectOperation op in ops) {
			var ob = op.get_object() as TextLayout;
			if(ob == null) {
				continue;
			}
			var nx = op.get_x() + ob.get_width();
			var ny = op.get_y() + ob.get_height();
			if(nx > x) {
				x = nx;
			}
			if(ny > y) {
				y = ny;
			}
		}
		var pad = px(padding);
		if(x > 0) {
			x += pad;
		}
		if(y > 0) {
			y += pad;
		}
		set_size_request(x, y);
	}

	public void set_layouts(Array array) {
		layouts = array;
		var ww = get_width();
		if(available_width > 0) {
			ww = available_width;
		}
		draw_ops = create_draw_ops(ww, get_height());
		update_size_request_for_ops(draw_ops);
	}

	public void initialize() {
		base.initialize();
		if(styles != null && paragraph != null && paragraph is RichTextStyledParagraph) {
			String style;
			var heading = ((RichTextStyledParagraph)paragraph).get_heading();
			if(heading > 0) {
				style = "heading%d".printf().add(heading).to_string();
			}
			if(String.is_empty(style) == false) {
				var ss = styles.get(style) as RichTextParagraphStyle;
				if(ss != null) {
					line_spacing = ss.get_line_spacing();
					padding = ss.get_padding();
					alignment = ss.get_alignment();
				}
			}
		}
	}

	int available_width = -1;

	public void on_available_size(int w, int h) {
		if(w < 0) {
			return;
		}
		available_width = w;
		if(layouts != null) {
			update_size_request_for_ops(create_draw_ops(w, -1));
		}
	}

	public void on_resize() {
		if(layouts != null) {
			draw_ops = create_draw_ops(get_width(), get_height());
			update_size_request_for_ops(draw_ops);
		}
		base.on_resize();
	}

	public Collection render() {
		return(draw_ops);
	}
}
