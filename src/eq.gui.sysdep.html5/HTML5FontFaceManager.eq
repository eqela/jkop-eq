
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

public class HTML5FontFaceManager
{
	class HTML5FontFaceStyle
	{
		property ptr styleff;
	}
	static HashTable fontfaces;

	public static void add_font(Frame frame, String font) {
		if(font == null || (font.has_suffix(".ttf") == false && font.has_suffix(".otf") == false)) {
			return;
		}
		if(fontfaces == null) {
			fontfaces = HashTable.create();
		}
		if(fontfaces.get(font) != null) {
			return;
		}
		var ff = frame as HTML5Frame;
		if(ff != null) {
			var doc = ff.get_document();
			if(doc == null) {
				return;
			}
			var proper_name = font.substring(0, font.get_length()-4).replace_char('_', ' ');
			var pn_jstr =  proper_name.to_strptr();
			var name_jstr = font.to_strptr();
			ptr style;
			embed "js" {{{
				var head = doc.head;
				style = doc.createElement("style");
				style.appendChild(doc.createTextNode("@font-face { font-family: " + pn_jstr + "; src: url('" + name_jstr +  "');}"));
				head.appendChild(style);
			}}}
			fontfaces.set(font, new HTML5FontFaceStyle().set_styleff(style));
		}
	}

	public static void remove_font(String font) {
		if(fontfaces == null || font == null) {
			return;
		}
		var hffs = fontfaces.get(font) as HTML5FontFaceStyle;
		if(hffs!=null) {
			var style = hffs.get_styleff();
			embed {{{
				style.parentNode.removeChild(style);
			}}}
		}
	}
}
