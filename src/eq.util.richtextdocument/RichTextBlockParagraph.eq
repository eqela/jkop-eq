
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

public class RichTextBlockParagraph : RichTextParagraph
{
	property String id;
	property String text;

	public String to_markup() {
		var sb = StringBuffer.create();
		String delim;
		if(String.is_empty(id)) {
			delim = "-- ";
		}
		else {
			delim = "-- %s --".printf().add(id).to_string();
		}
		sb.append(delim);
		sb.append_c((int)'\n');
		if(text != null) {
			sb.append(text);
			if(text.has_suffix("\n") == false) {
				sb.append_c((int)'\n');
			}
		}
		sb.append(delim);
		return(sb.to_string());
	}

	public String to_text() {
		return(text);
	}

	public HashTable to_json() {
		return(HashTable.create()
			.set("type", "block")
			.set("id", id)
			.set("text", text));
	}

	public String to_html(RichTextDocumentReferenceResolver refs, String xclass) {
		var ids = "";
		if(String.is_empty(id) == false) {
			ids = " ".append(id);
		}
		var xclassh = "";
		if(String.is_empty(xclass) == false) {
			xclassh = " ".append(xclass);
		}
		var content = RichTextStyledParagraph.for_string(text);
		return("<div class=\"_rtd_block%s%s\">%s</div>".printf().add(xclassh).add(ids).add(content.to_html(refs, "")).to_string());
	}
}