
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

public class RichTextWikiMarkupParser
{
	public static RichTextDocument parse_file(File file) {
		return(new RichTextWikiMarkupParser().set_file(file).parse());
	}

	public static RichTextDocument parse_string(String data) {
		return(new RichTextWikiMarkupParser().set_data(data).parse());
	}

	property File file;
	property String data;

	String skip_empty_lines(InputStream ins) {
		String line;
		while((line = ins.readline()) != null) {
			line = line.strip();
			if(line != null && line.has_prefix("#")) {
				continue;
			}
			if(String.is_empty(line) == false) {
				break;
			}
		}
		return(line);
	}

	RichTextPreformattedParagraph read_preformatted_paragraph(String id, InputStream ins) {
		var sb = StringBuffer.create();
		String line;
		while((line = ins.readline()) != null) {
			if(line.has_prefix("---") && line.has_suffix("---")) {
				var lid = line.substring(3, line.get_length()-6);
				if(lid != null) {
					lid = lid.strip();
				}
				if(String.is_empty(id)) {
					if(String.is_empty(lid)) {
						break;
					}
				}
				else if(id.equals(lid)) {
					break;
				}
			}
			sb.append(line);
			sb.append_c((int)'\n');
		}
		return(new RichTextPreformattedParagraph().set_id(id).set_text(sb.to_string()));
	}

	RichTextBlockParagraph read_block_paragraph(String id, InputStream ins) {
		var sb = StringBuffer.create();
		String line;
		while((line = ins.readline()) != null) {
			if(line.has_prefix("--") && line.has_suffix("--")) {
				var lid = line.substring(2, line.get_length()-4);
				if(lid != null) {
					lid = lid.strip();
				}
				if(String.is_empty(id)) {
					if(String.is_empty(lid)) {
						break;
					}
				}
				else if(id.equals(lid)) {
					break;
				}
			}
			sb.append(line);
			sb.append_c((int)'\n');
		}
		return(new RichTextBlockParagraph().set_id(id).set_text(sb.to_string()));
	}

	bool process_input(InputStream ins, RichTextDocument doc) {
		var line = skip_empty_lines(ins);
		if(line == null) {
			return(false);
		}
		if("-".equals(line)) {
			doc.add_paragraph(new RichTextSeparatorParagraph());
			return(true);
		}
		if(line.has_prefix("@content ")) {
			var id = line.substring(9);
			if(id != null) {
				id = id.strip();
			}
			doc.add_paragraph(new RichTextContentParagraph().set_content_id(id));
			return(true);
		}
		if(line.has_prefix("@image ")) {
			var ref = line.substring(7);
			if(ref != null) {
				ref = ref.strip();
			}
			doc.add_paragraph(new RichTextImageParagraph().set_filename(ref));
			return(true);
		}
		if(line.has_prefix("@image100 ")) {
			var ref = line.substring(10);
			if(ref != null) {
				ref = ref.strip();
			}
			doc.add_paragraph(new RichTextImageParagraph().set_filename(ref));
			return(true);
		}
		if(line.has_prefix("@image75 ")) {
			var ref = line.substring(9);
			if(ref != null) {
				ref = ref.strip();
			}
			doc.add_paragraph(new RichTextImageParagraph().set_filename(ref).set_width(75));
			return(true);
		}
		if(line.has_prefix("@image50 ")) {
			var ref = line.substring(9);
			if(ref != null) {
				ref = ref.strip();
			}
			doc.add_paragraph(new RichTextImageParagraph().set_filename(ref).set_width(50));
			return(true);
		}
		if(line.has_prefix("@image25 ")) {
			var ref = line.substring(9);
			if(ref != null) {
				ref = ref.strip();
			}
			doc.add_paragraph(new RichTextImageParagraph().set_filename(ref).set_width(25));
			return(true);
		}
		if(line.has_prefix("@reference ")) {
			var ref = line.substring(11);
			if(ref != null) {
				ref = ref.strip();
			}
			var sq = QuotedString.to_collection(ref, (int)' ');
			var rrf = String.as_string(sq.get(0));
			var txt = String.as_string(sq.get(1));
			doc.add_paragraph(new RichTextReferenceParagraph().set_reference(rrf).set_text(txt));
			return(true);
		}
		if(line.has_prefix("@set ")) {
			var link = line.substring(5);
			if(link != null) {
				link = link.strip();
			}
			var sq = QuotedString.to_collection(link, (int)' ');
			var key = String.as_string(sq.get(0));
			var val = String.as_string(sq.get(1));
			if(String.is_empty(key)) {
				return(true);
			}
			doc.set_metadata(key, val);
			return(true);
		}
		if(line.has_prefix("@link ")) {
			var link = line.substring(6);
			if(link != null) {
				link = link.strip();
			}
			var sq = QuotedString.to_collection(link, (int)' ');
			var url = String.as_string(sq.get(0));
			var txt = String.as_string(sq.get(1));
			var flags = String.as_string(sq.get(2));
			if(String.is_empty(txt)) {
				txt = url;
			}
			var v = new RichTextLinkParagraph();
			v.set_link(url);
			v.set_text(txt);
			if("popup".equals(flags)) {
				v.set_popup(true);
			}
			doc.add_paragraph(v);
			return(true);
		}
		if(line.has_prefix("---") && line.has_suffix("---")) {
			var id = line.substring(3, line.get_length()-6);
			if(id != null) {
				id = id.strip();
			}
			if(String.is_empty(id)) {
				id = null;
			}
			doc.add_paragraph(read_preformatted_paragraph(id, ins));
			return(true);
		}
		if(line.has_prefix("--") && line.has_suffix("--")) {
			var id = line.substring(2, line.get_length() - 4);
			if(id != null) {
				id = id.strip();
			}
			if(String.is_empty(id)) {
				id = null;
			}
			doc.add_paragraph(read_block_paragraph(id, ins));
			return(true);
		}
		var sb = StringBuffer.create();
		int pc = 0;
		do
		{
			line = line.strip();
			if(String.is_empty(line)) {
				break;
			}
			if(line.has_prefix("#") == false) {
				var it = line.iterate();
				int c;
				if(sb.count() > 0 && pc != ' ') {
					sb.append_c((int)' ');
					pc = (int)' ';
				}
				while((c = it.next_char()) > 0) {
					if(c == ' ' || c == '\t' || c == '\r' || c == '\n') {
						if(pc == ' ') {
							continue;
						}
						c = (int)' ';
					}
					sb.append_c(c);
					pc = c;
				}
			}
		}
		while((line = ins.readline()) != null);
		var s = sb.to_string();
		if(String.is_empty(s)) {
			return(false);
		}
		doc.add_paragraph(RichTextStyledParagraph.for_string(s));
		return(true);
	}

	public RichTextDocument parse() {
		InputStream ins;
		if(file != null) {
			ins = InputStream.create(file.read());
		}
		else if(data != null) {
			ins = InputStream.create(StringReader.for_string(data));
		}
		if(ins == null) {
			return(null);
		}
		var v = new RichTextDocument();
		while(process_input(ins, v)) {
			; // continue;
		}
		return(v);
	}
}
