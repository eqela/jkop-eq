
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

class BBJavaTextLayout : TextLayout, Size
{
	TextProperties props;
	String str;
	int dpi = 0;
	int width = 0;
	int height = 0;
	int font_size = 0;
	bool wrap = true;

	embed "Java" {{{
		private net.rim.device.api.ui.Font jFont = null; 
		private java.util.Vector lines = null; 
	}}}

	public static BBJavaTextLayout create(TextProperties props, int dpi) {
		var v = new BBJavaTextLayout();
		v.props = props;
		v.str = v.props.get_text();
		if(v.str == null) {
			v.str = "";
		}
		v.dpi = dpi;
		v.initialize();
		return(v);
	}

	embed "Java" {{{
		public java.util.Vector wrap (String text, int width) {
			java.util.Vector result = new java.util.Vector();
			String remaining = text;
			while (remaining.length()>=0)	{
		    	int index = getSplitIndex(remaining, width);
		    	if (index == -1) {
		    		break;
		    	}
		    	result.addElement(remaining.substring(0,index));
		    	remaining = remaining.substring(index);
		    	if (index == 0) {
		    		break;
		    	}
	    	}
	    	return(result);
		}
	
		private int getSplitIndex(String bigString, int width) {
			int index = -1;
			int lastSpace = -1;
			String smallString = "";
			boolean spaceEncountered = false;
			boolean maxWidthFound = false;
			for(int i=0; i < bigString.length(); i++) {
				char current = bigString.charAt(i);
				smallString += current;
				if(current == ' ') {
					lastSpace = i;
					spaceEncountered = true;
				}			
				int linewidth = jFont.getAdvance(smallString,0,  smallString.length());
				if(linewidth > width) {
					if (spaceEncountered) {
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
		var textptr = str.to_strptr();
		var font = props.get_font();
		var fontColor = props.get_color();
		var outlineColor = props.get_outline_color();
		int textwrapw = props.get_wrap_width(), font_style = 0;
		font_size = Length.to_pixels(font.get_size(), dpi);
		embed "Java" {{{
			if(font.is_bold()) {
				font_style = net.rim.device.api.ui.Font.BOLD;			
			}
			else if(font.is_italic()) {
				font_style = net.rim.device.api.ui.Font.ITALIC;	
			}
			else {
				font_style = net.rim.device.api.ui.Font.PLAIN;
			}
			jFont = net.rim.device.api.ui.Font.getDefault().derive(font_style, font_size);
			lines = wrap(textptr, textwrapw);
			if(textwrapw < 1) {
				textwrapw = jFont.getAdvance(textptr);
				wrap = false;
			}
			if(lines.size() <= 1) { 
				width = jFont.getAdvance(textptr);
				height = jFont.getHeight(); 		
			}
			else {
				width = textwrapw;
				height = ((lines.size()-1)* jFont.getHeight());
			}
		}}}
	}

	embed "Java" {{{
		public java.util.Vector get_layout() {
		    	 java.util.Vector result = new java.util.Vector();
		    	 result.addElement(jFont);
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
			eq.gui.Color fontColor = props.get_color();
			if(fontColor != null) {
				cr = (byte)(fontColor.get_r()*255);
				cg = (byte)(fontColor.get_g()*255);
				cb = (byte)(fontColor.get_b()*255);
			}
			return(((cr & 0xFF) << 16)  + ((cg & 0xFF) << 8) + (cb & 0xFF));
		}
		
		public int get_font_outline_color() {
			byte ocr = 0, ocg = 0, ocb = 0;
			eq.gui.Color outLineColor = props.get_outline_color();
			if(outLineColor != null) {
				ocr = (byte)(outLineColor.get_r()*255);
				ocg = (byte)(outLineColor.get_g()*255);
				ocb = (byte)(outLineColor.get_b()*255);
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
		var text = this.str;
		var str = text.substring(0, index);
		embed "Java" {{{
			x = jFont.getAdvance(str.to_strptr());
		}}}
		return(Rectangle.instance(x, y, w, h));
	}

	public int xy_to_index(double dx, double dy) {
		var text = str;
		int v = 0;
		if("".equals(text)) {
			return(v);
		}
		else {
			int x = (int)dx, y = (int)dy;
			int c = 0;
			int w = 0;
			var itr = text.iterate();
			while((c = itr.next_char()) > 0) {
				embed "Java" {{{
					int adv = jFont.getAdvance((char)c);
					w+=adv;
					if((w-(adv/2)) >= x) {
						break;
					}
					if(w != 0) {
						v++;
					}
				}}}
			}
		}
		return(v);
	}

	public double get_width() {
		return(width);
	}

	public double get_height() {
		return(height);
	}
}

