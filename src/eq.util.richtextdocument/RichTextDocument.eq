
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

public class RichTextDocument
{
	public static RichTextDocument for_wiki_markup_file(File file) {
		return(RichTextWikiMarkupParser.parse_file(file));
	}

	public static RichTextDocument for_wiki_markup_string(String str) {
		return(RichTextWikiMarkupParser.parse_string(str));
	}

	HashTable metadata;
	property Collection paragraphs;

	public RichTextDocument() {
		metadata = HashTable.create();
	}

	public String get_title() {
		return(metadata.get_string("title"));
	}

	public RichTextDocument set_title(String v) {
		metadata.set("title", v);
		return(this);
	}

	public String get_metadata(String k) {
		return(metadata.get_string(k));
	}

	public RichTextDocument set_metadata(String k, String v) {
		metadata.set(k, v);
		return(this);
	}

	public RichTextDocument add_paragraph(RichTextParagraph rtp) {
		if(rtp == null) {
			return(this);
		}
		if(paragraphs == null) {
			paragraphs = LinkedList.create();
		}
		paragraphs.add(rtp);
		if(get_title() == null && rtp is RichTextStyledParagraph && ((RichTextStyledParagraph)rtp).get_heading() == 1) {
			set_title(((RichTextStyledParagraph)rtp).get_text_content());
		}
		return(this);
	}

	public HashTable to_json() {
		var v = HashTable.create();
		v.set("metadata", metadata);
		v.set("title", get_title());
		var pp = LinkedList.create();
		foreach(RichTextParagraph par in paragraphs) {
			var pj = par.to_json();
			if(pj != null) {
				pp.add(pj);
			}
		}
		v.set("paragraphs", pp);
		return(v);
	}

	public String to_html(RichTextDocumentReferenceResolver refs) {
		var sb = StringBuffer.create();
		foreach(RichTextParagraph paragraph in get_paragraphs()) {
			var html = paragraph.to_html(refs, null);
			if(String.is_empty(html) == false) {
				sb.append(html);
				sb.append_c((int)'\n');
			}
		}
		return(sb.to_string());
	}
}
