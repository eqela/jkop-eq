
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

public class RichTextStyledParagraph : RichTextParagraph
{
	public static RichTextStyledParagraph for_string(String text) {
		return(new RichTextStyledParagraph().parse(text));
	}

	property int heading = 0;
	property Collection segments;

	public bool is_heading() {
		if(heading > 0) {
			return(true);
		}
		return(false);
	}

	public String get_text_content() {
		var sb = StringBuffer.create();
		foreach(RichTextSegment segment in segments) {
			sb.append(segment.get_text());
		}
		return(sb.to_string());
	}

	public HashTable to_json() {
		var segs = LinkedList.create();
		foreach(RichTextSegment segment in segments) {
			var segj = segment.to_json();
			if(segj != null) {
				segs.add(segj);
			}
		}
		return(HashTable.create()
			.set("type", "styled")
			.set_int("heading", heading)
			.set("segments", segs)
		);
	}

	public String to_text() {
		var sb = StringBuffer.create();
		foreach(RichTextSegment sg in segments) {
			sb.append(sg.get_text());
			var link = sg.get_link();
			if(String.is_empty(link) == false) {
				sb.append(" (%s)".printf().add(link).to_string());
			}
			var ref = sg.get_reference();
			if(String.is_empty(ref) == false) {
				sb.append(" {%s}".printf().add(ref).to_string());
			}
		}
		return(sb.to_string());
	}

	public String to_html(RichTextDocumentReferenceResolver refs, String xclass) {
		var sb = StringBuffer.create();
		var tag = "p";
		var style = "text";
		if(heading > 0) {
			style = "heading%d".printf().add(heading).to_string();
			tag = "h%d".printf().add(heading).to_string();
		}
		var xclassh = "";
		if(String.is_empty(xclass) == false) {
			xclassh = " ".append(xclass);
		}
		sb.append("<%s class=\"_rtd_%s%s\">".printf().add(tag).add(style).add(xclassh).to_string());
		foreach(RichTextSegment sg in segments) {
			var a_open = false;
			var text = sg.get_text();
			var link = sg.get_link();
			if(String.is_empty(link) == false) {
				if(sg.get_is_inline()) {
					// FIXME: Should allow other content types as well, not just images
					sb.append("<img src=\"%s\" />".printf().add(link).to_string());
				}
				else {
					var targetblank = "";
					if(sg.get_link_popup()) {
						targetblank = " target=\"_blank\"";
					}
					sb.append("<a%s href=\"%s\">".printf().add(targetblank).add(link).to_string());
					a_open = true;
				}
			}
			if(String.is_empty(sg.get_reference()) == false) {
				var ref = sg.get_reference();
				String href;
				if(refs != null) {
					href = refs.get_reference_href(ref);
					if(String.is_empty(text)) {
						text = refs.get_reference_title(ref);
					}
				}
				if(String.is_empty(href) == false) {
					if(String.is_empty(text)) {
						text = ref;
					}
					sb.append("<a href=\"%s\">".printf().add(href).to_string());
					a_open = true;
				}
			}
			var span = false;
			if(sg.get_bold() || sg.get_italic() || sg.get_underline() || String.is_empty(sg.get_color()) == false) {
				span = true;
				sb.append("<span style=\"");
				if(sg.get_bold()) {
					sb.append(" font-weight: bold;");
				}
				if(sg.get_italic()) {
					sb.append(" font-style: italic;");
				}
				if(sg.get_underline()) {
					sb.append(" text-decoration: underline;");
				}
				if(String.is_empty(sg.get_color()) == false) {
					sb.append(" color: %s".printf().add(sg.get_color()).to_string());
				}
				sb.append("\">");
			}
			if(sg.get_is_inline() == false) {
				sb.append(text);
			}
			if(span) {
				sb.append("</span>");
			}
			if(a_open) {
				sb.append("</a>");
			}
		}
		sb.append("</%s>".printf().add(tag).to_string());
		return(sb.to_string());
	}

	public RichTextParagraph add_segment(RichTextSegment rts) {
		if(rts == null) {
			return(this);
		}
		if(segments == null) {
			segments = LinkedList.create();
		}
		segments.add(rts);
		return(this);
	}

	void set_segment_link(RichTextSegment seg, String alink) {
		if(alink == null) {
			seg.set_link(null);
			return;
		}
		var link = alink;
		if(link.has_prefix(">")) {
			seg.set_is_inline(true);
			link = link.substring(1);
		}
		if(link.has_prefix("!")) {
			seg.set_link_popup(true);
			link = link.substring(1);
		}
		seg.set_link(link);
	}

	void parse_segments(String txt) {
		if(txt == null) {
			return;
		}
		StringBuffer segmentsb, linksb;
		var sb = StringBuffer.create();
		var it = txt.iterate();
		int c;
		int pc = 0;
		var seg = new RichTextSegment();
		while((c = it.next_char()) > 0) {
			if(pc == '[') {
				if(c == '[') {
					sb.append_c(c);
					pc = 0;
					continue;
				}
				if(sb.count() > 0) {
					seg.set_text(sb.to_string());
					add_segment(seg);
				}
				seg = new RichTextSegment();
				linksb = StringBuffer.create();
				linksb.append_c(c);
				pc = c;
				continue;
			}
			if(linksb != null) {
				if(c == '|') {
					set_segment_link(seg, linksb.to_string());
					pc = c;
					continue;
				}
				if(c == ']') {
					var xt = linksb.to_string();
					if(seg.get_link() == null) {
						set_segment_link(seg, xt);
					}
					else {
						seg.set_text(xt);
					}
					if(String.is_empty(seg.get_text())) {
						var ll = xt;
						if(ll.has_prefix("http://")) {
							ll = ll.substring(7);
						}
						seg.set_text(ll);
					}
					add_segment(seg);
					seg = new RichTextSegment();
					linksb = null;
				}
				else {
					linksb.append_c(c);
				}
				pc = c;
				continue;
			}
			if(pc == '{') {
				if(c == '{') {
					sb.append_c(c);
					pc = 0;
					continue;
				}
				if(sb.count() > 0) {
					seg.set_text(sb.to_string());
					add_segment(seg);
				}
				seg = new RichTextSegment();
				segmentsb = StringBuffer.create();
				segmentsb.append_c(c);
				pc = c;
				continue;
			}
			if(segmentsb != null) {
				if(c == '|') {
					seg.set_reference(segmentsb.to_string());
					pc = c;
					continue;
				}
				if(c == '}') {
					var xt = segmentsb.to_string();
					if(seg.get_reference() == null) {
						seg.set_reference(xt);
					}
					else {
						seg.set_text(xt);
					}
					add_segment(seg);
					seg = new RichTextSegment();
					segmentsb = null;
				}
				else {
					segmentsb.append_c(c);
				}
				pc = c;
				continue;
			}
			if(pc == '*') {
				if(c == '*') {
					if(sb.count() > 0) {
						seg.set_text(sb.to_string());
						add_segment(seg);
					}
					if(seg.get_bold()) {
						seg = new RichTextSegment().set_bold(false);
					}
					else {
						seg = new RichTextSegment().set_bold(true);
					}
				}
				else {
					sb.append_c(pc);
					sb.append_c(c);
				}
				pc = 0;
				continue;
			}
			if(pc == '_') {
				if(c == '_') {
					if(sb.count() > 0) {
						seg.set_text(sb.to_string());
						add_segment(seg);
					}
					if(seg.get_underline()) {
						seg = new RichTextSegment().set_underline(false);
					}
					else {
						seg = new RichTextSegment().set_underline(true);
					}
				}
				else {
					sb.append_c(pc);
					sb.append_c(c);
				}
				pc = 0;
				continue;
			}
			if(pc == '\'') {
				if(c == '\'') {
					if(sb.count() > 0) {
						seg.set_text(sb.to_string());
						add_segment(seg);
					}
					if(seg.get_italic()) {
						seg = new RichTextSegment().set_italic(false);
					}
					else {
						seg = new RichTextSegment().set_italic(true);
					}
				}
				else {
					sb.append_c(pc);
					sb.append_c(c);
				}
				pc = 0;
				continue;
			}
			if(c != '*' && c != '_' && c != '\'' && c != '{' && c != '[') {
				sb.append_c(c);
			}
			pc = c;
		}
		if(pc == '*' || pc == '_' || pc == '\'' && pc != '{' && pc != '[') {
			sb.append_c(pc);
		}
		if(sb.count() > 0) {
			seg.set_text(sb.to_string());
			add_segment(seg);
		}
	}

	RichTextStyledParagraph parse(String _text) {
		if(_text == null) {
			return(this);
		}
		var txt = _text;
		var prefixes = Array.create().add("=").add("==").add("===").add("====").add("=====");
		int n;
		for(n=0 ;n<prefixes.count(); n++) {
			var key = prefixes.get(n) as String;
			if(txt.has_prefix(key.append(" ")) && txt.has_suffix(" ".append(key))) {
				set_heading(n+1);
				txt = txt.substring(key.get_length()+1, txt.get_length()-key.get_length()*2-2);
				if(txt != null) {
					txt = txt.strip();
				}
				break;
			}
		}
		parse_segments(txt);
		return(this);
	}

	public String to_markup() {
		String ident;
		if(heading == 1) {
			ident = "=";
		}
		else if(heading == 2) {
			ident = "==";
		}
		else if(heading == 3) {
			ident = "===";
		}
		else if(heading == 4) {
			ident = "====";
		}
		else if(heading == 5) {
			ident = "=====";
		}
		var sb = StringBuffer.create();
		if(String.is_empty(ident) == false) {
			sb.append(ident);
			sb.append_c((int)' ');
		}
		foreach(RichTextSegment segment in segments) {
			sb.append(segment.to_markup());
		}
		if(String.is_empty(ident) == false) {
			sb.append_c((int)' ');
			sb.append(ident);
		}
		return(sb.to_string());
	}
}
