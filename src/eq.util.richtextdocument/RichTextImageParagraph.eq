
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

public class RichTextImageParagraph : RichTextParagraph
{
	property String filename;
	property int width = 100;

	public override String to_markup() {
		if(width >= 100) {
			return("@image %s\n".printf().add(filename).to_string());
		}
		if(width >= 75) {
			return("@image75 %s\n".printf().add(filename).to_string());
		}
		if(width >= 50) {
			return("@image50 %s\n".printf().add(filename).to_string());
		}
		return("@image25 %s\n".printf().add(filename).to_string());
	}

	public override String to_text() {
		return("[image:%s]\n".printf().add(filename).to_string());
	}

	public override HashTable to_json() {
		return(HashTable.create().set("type", "image").set("width", width).set("filename", filename));
	}

	public override String to_html(RichTextDocumentReferenceResolver refs, String xclass) {
		var sb = StringBuffer.create();
		if(width >= 100) {
			sb.append("<div class=\"_rtd_img100\">");
		}
		else if(width >= 75) {
			sb.append("<div class=\"_rtd_img75\">");
		}
		else if(width >= 50) {
			sb.append("<div class=\"_rtd_img50\">");
		}
		else {
			sb.append("<div class=\"_rtd_img25\">");
		}
		sb.append("<img src=\"%s\" />".printf().add(HTMLString.sanitize(filename)).to_string());
		sb.append("</div>\n");
		return(sb.to_string());
	}
}
