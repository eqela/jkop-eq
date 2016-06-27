
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

class J2METextLayout : TextLayout, Size
{
	TextProperties props;
	String proptext = null;
	int dpi = 0;
	int width = 0;
	int height = 0;
	int font_size = 0;
	bool wrap = true;
	embed "Java" {{{
		private javax.microedition.lcdui.Font font = null; 
		private java.util.Vector lines = null;
	}}}

	public static J2METextLayout create(TextProperties props, int dpi) {
		var v = new J2METextLayout();
		v.props = props;
		v.dpi = dpi;
		v.initialize();
		return(v);
	}

	embed "Java" {{{
		public java.util.Vector wrap (String text, int width) {
			java.util.Vector result = new java.util.Vector();
			String remaining = text;
			while(remaining.length()>=0)	{
		    	int index = getSplitIndex(remaining, width);
		    	if(index == -1) {
		    		break;
		    	}
		    	result.addElement(remaining.substring(0,index));
		    	remaining = remaining.substring(index);
		    	if(index == 0) {
		    		break;
		    	}
	    	}
	    	return(result);
		}

		private int getSplitIndex(String bigString, int width) {
			int index = -1;
			int lastSpace = -1;
			String smallString="";
			boolean spaceEncountered = false;
			boolean maxWidthFound = false;
			for(int i=0; i < bigString.length(); i++)	{
				char current = bigString.charAt(i);
				smallString += current;
				if(current == ' ') {
					lastSpace = i;
					spaceEncountered = true;
				}			
				int linewidth = font.charsWidth(smallString.toCharArray(), 0, smallString.length());
				if(linewidth > width) {
					if(spaceEncountered) {
						index = lastSpace+1;
					}
					else {
						index = i;
					}
					maxWidthFound = true;
					break;
				}
			}
			if(!maxWidthFound) {
				index = bigString.length();
			}
			return index;
		}
	}}}

	public void initialize() {
		if(props == null) {
   		return;
     	}
		proptext = props.get_text();
		if(proptext == null) {
			proptext = "";
		}
		var textptr = proptext.to_strptr();
		var _font = props.get_font();
		int textwrapw = props.get_wrap_width(), font_style = 0;
		font_size = Length.to_pixels(_font.get_size(), dpi);
		embed "Java" {{{
			if(font_size <= 10) {
				font_size = javax.microedition.lcdui.Font.SIZE_SMALL;
			}
			else if(font_size <= 32 && font_size >= 11) {
				font_size = javax.microedition.lcdui.Font.SIZE_MEDIUM;
			}
			else {
				font_size = javax.microedition.lcdui.Font.SIZE_LARGE;
			}
			if(_font.is_bold()) {
				font_style = javax.microedition.lcdui.Font.STYLE_BOLD;			
			}
			else if(_font.is_italic()) {
				font_style = javax.microedition.lcdui.Font.STYLE_ITALIC;	
			}
			else {
				font_style = javax.microedition.lcdui.Font.STYLE_PLAIN;
			}
			font = javax.microedition.lcdui.Font.getFont(javax.microedition.lcdui.Font.FACE_MONOSPACE, font_style, font_size);
			lines = wrap(textptr, textwrapw);
			if(textwrapw < 1) {
				textwrapw = font.charsWidth(textptr.toCharArray(), 0, textptr.length());
				wrap = false;
			}
			if(lines.size() <= 1) { 
				width = font.charsWidth(textptr.toCharArray(), 0, textptr.length());
				height = font.getHeight(); 		
			}
			else {
				width = textwrapw;
				for (int i = 0; i < lines.size(); i++) {
					height = (i * font.getHeight());
				}
			}
		}}}
	}

	embed "Java" {{{
		public java.util.Vector get_layout() {
			java.util.Vector result = new java.util.Vector();
			result.addElement(font);
			result.addElement(lines);
			if(wrap == true) {
				result.addElement(Boolean.TRUE);
			}
			else {
				result.addElement(Boolean.FALSE);
			}
			return(result);
		}

		public int get_font_color() {
			byte cr = 0, cg = 0, cb = 0;
			eq.gui.Color font_color = props.get_color();
			if(font_color != null) {
				cr = (byte)(font_color.get_r()*255);
				cg = (byte)(font_color.get_g()*255);
				cb = (byte)(font_color.get_b()*255);
			}
			return(((cr & 0xFF) << 16) + ((cg & 0xFF) << 8) + (cb & 0xFF));
		}
		
		public int get_font_outline_color() {
			byte ocr = 0, ocg = 0, ocb = 0;
			eq.gui.Color outlinecolor = props.get_outline_color();
			if(outlinecolor != null) {
				ocr = (byte)(outlinecolor.get_r()*255);
				ocg = (byte)(outlinecolor.get_g()*255);
				ocb = (byte)(outlinecolor.get_b()*255);
				return(((ocr & 0xFF) << 16)  + ((ocg & 0xFF) << 8) + (ocb & 0xFF));
			}
			return(0);
		}
	}}}

	public TextProperties get_text_properties() {
		return(props);
	}

	public Rectangle get_cursor_position(int index) {
		int x = 0, y = 0, w = 2, h = this.height;
		var str = proptext.substring(0, index);
		embed "Java" {{{
			x = font.charsWidth(str.to_strptr().toCharArray(), 0, str.to_strptr().length());
		}}}
		return(Rectangle.instance(x, y, w, h));
	}

	public int xy_to_index(double x, double y) {
		var text = this.props.get_text();
		if(text == null || "".equals(text)) {
			return(0);
		}
		int tw = 0;
		embed "Java" {{{
			tw = font.charsWidth(text.to_strptr().toCharArray(), 0, text.to_strptr().length());
		}}}
		if(x >= tw) {
			return(text.get_length());
		}
		else {
			int c = 0;
			int t = 0;
			for(c = 0 ; c < text.get_length() ; c++) {
				var str = String.for_character(text.get_char(c));
				embed "Java" {{{
					t += font.charsWidth(str.to_strptr().toCharArray(), 0, str.to_strptr().length());
				}}}
				if(x < t) {
					return(c);
				}
			}
		}
		return(0);
	}

	public double get_width() {
		return(width);
	}

	public double get_height() {
		return(height);
	}
}
