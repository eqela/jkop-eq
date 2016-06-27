
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

public class RichTextLinkParagraph : RichTextParagraph
{
	property String link;
	property String text;
	property bool popup = false;

	public String to_markup() {
		var sb = StringBuffer.create();
		sb.append("@link ");
		sb.append(link);
		sb.append_c((int)' ');
		sb.append_c((int)'"');
		if(String.is_empty(text) == false) {
			sb.append(text);
		}
		sb.append_c((int)'"');
		if(popup) {
			sb.append(" popup");
		}
		return(sb.to_string());
	}

	public String to_text() {
		var v = text;
		if(String.is_empty(v)) {
			v = link;
		}
		return(v);
	}

	public HashTable to_json() {
		return(HashTable.create()
			.set("type", "link")
			.set("link", link)
			.set("text", text));
	}

	public String to_html(RichTextDocumentReferenceResolver refs, String xclass) {
		var href = link;
		var tt = text;
		if(String.is_empty(tt)) {
			tt = href;
		}
		if(String.is_empty(tt)) {
			tt = "(empty link)";
		}
		var xclassh = "";
		if(String.is_empty(xclass) == false) {
			xclassh = " ".append(xclass);
		}
		var targetblank = "";
		if(popup) {
			targetblank = " target=\"_blank\"";
		}
		return("<p class=\"_rtd_link%s\"><a href=\"%s\"%s>%s</a></p>\n".printf().add(xclassh).add(href).add(targetblank).add(tt).to_string());
	}
}
