
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

public class AWTTextLayout : TextLayout, Size
{
	TextProperties props;
	double width;
	double height;

	embed {{{
		java.awt.font.FontRenderContext render_context;
		java.awt.font.TextLayout layout;
		java.text.AttributedString atstring;
	}}}

	public static AWTTextLayout create(TextProperties props, Frame f, int dpi) {
		var v = new AWTTextLayout();
		v.props = props;
		if(v.initialize(f, dpi) == false) {
			return(null);
		}
		return(v);
	}

	int to_pixels(String str, int dpi) {
		return(Length.to_pixels(str, dpi));
	}

	strptr as_strptr(Object str) {
		return(String.as_strptr(str));
	}

	embed {{{
		java.awt.Font to_awt_font(eq.gui.Font font, int dpi) {
			if(font == null) {
				return(null);
			}
			eq.api.String name = font.get_name();
			String n = as_strptr((eq.api.Object)name);
			if(n == null) {
				return(null);
			}
			int size = to_pixels(font.get_size(), dpi);
			java.awt.Font af = null;
			java.util.Map<java.awt.font.TextAttribute,Object> attr = new java.util.HashMap<java.awt.font.TextAttribute,Object>();
			attr.put(java.awt.font.TextAttribute.SIZE, size);
			if(font.is_bold()) {
				attr.put(java.awt.font.TextAttribute.WEIGHT, java.awt.font.TextAttribute.WEIGHT_BOLD);
			}
			if(font.is_italic()) {
				attr.put(java.awt.font.TextAttribute.POSTURE, java.awt.font.TextAttribute.POSTURE_OBLIQUE);
			}
			if(font.is_underline()) {
				attr.put(java.awt.font.TextAttribute.UNDERLINE, java.awt.font.TextAttribute.UNDERLINE_ON);
			}
			if(n.endsWith(".ttf") || n.endsWith(".otf")) {
				try {
					af = java.awt.Font.createFont(java.awt.Font.TRUETYPE_FONT, getClass().getClassLoader().getResourceAsStream(n));
				}
				catch(Exception e) {
				}
			}
			else {
				if("monospace".equalsIgnoreCase(n)) {
					af = new java.awt.Font(java.awt.Font.MONOSPACED, 0, size);
				}
				else if("sans".equalsIgnoreCase(n) || "sans-serif".equalsIgnoreCase(n)) {
					af = new java.awt.Font(java.awt.Font.SANS_SERIF, 0, size);
				}
				else if("serif".equalsIgnoreCase(n)) {
					af = new java.awt.Font(java.awt.Font.SERIF, 0, size);
				}
			}			
			if(af == null) {
				af = new java.awt.Font("Default", 0, size);
			}
			return(af.deriveFont(attr));
		}

		void measure_text(java.lang.String str, java.awt.Font af, int ww) {
			render_context = new java.awt.font.FontRenderContext(null, true, true);
			atstring = new java.text.AttributedString(str);
			atstring.addAttribute(java.awt.font.TextAttribute.FONT, af);
			layout = new java.awt.font.TextLayout(atstring.getIterator(), render_context);
			if(ww > 0) {
				java.awt.font.LineBreakMeasurer measurer = new java.awt.font.LineBreakMeasurer(atstring.getIterator(), render_context);
				double highest_width = 0, total_height = 0;
				while(measurer.getPosition() < str.length()) {
					java.awt.font.TextLayout tl = measurer.nextLayout(ww);
					double tlwidth = tl.getAdvance();
					if(highest_width < tlwidth) {
						highest_width = tlwidth;
					}
					total_height += tl.getAscent()+tl.getDescent()+tl.getLeading();
				}
				width = highest_width;
				height = (int)total_height;
			}
			else {
				width = layout.getAdvance();
				height = (int)(layout.getAscent()+layout.getDescent()+layout.getLeading());
			}
		}
	}}}

	bool initialize(Frame frame, int dpi) {
		if(props == null) {
			return(false);
		}
		var font = props.get_font();
		if(font == null) {
			return(false);
		}
		var text = props.get_text();
		if(text == null) {
			return(false);
		}
		if(String.is_empty(text)) {
			text = " ";
		}
		int fdpi = -1;
		if(frame != null) {
			fdpi = frame.get_dpi();
		}
		if(dpi > 0) {
			fdpi = dpi;
		}
		if(fdpi < 0) {
			fdpi = 96;
		}
		embed {{{
			java.awt.Font af = to_awt_font(font, fdpi);
			int ww = props.get_wrap_width();
			measure_text(as_strptr((eq.api.Object)text), af, ww);
		}}}
		return(true);
	}

	embed {{{
		public java.text.AttributedString get_attributed_string() {
			return(atstring);
		}

		public java.awt.font.FontRenderContext get_font_render_context() {
			return(render_context);
		}
	}}}

	public TextProperties get_text_properties() {
		return(props);
	}

	public double get_width() {
		return(width);
	}

	public double get_height() {
		return(height);
	}

	Rectangle _rectangle(int x, int y, int w, int h) {
		return(Rectangle.instance(x,y,w,h));
	}

	public Rectangle get_cursor_position(int index) {
		var text = props.get_text();
		if(String.is_empty(text)) {
			return(null);
		}
		embed {{{
			if(layout != null) {
				java.awt.font.TextHitInfo hit = java.awt.font.TextHitInfo.leading(index);
				java.awt.geom.Point2D.Double pt = new java.awt.geom.Point2D.Double(0,0);
				layout.hitToPoint(hit, pt);
				return(_rectangle((int)pt.x, (int)pt.y, 1, (int)get_height()));
			}
		}}}
		return(null);
	}

	public int xy_to_index(double x, double y) {
		if(x < 0) {
			return(0);
		}
		embed {{{
			if(layout != null) {
				java.awt.font.TextHitInfo hit = layout.hitTestChar((float)x, (float)y);
				int i = hit.getCharIndex();
				if(x > get_width()) {
					i++;
				}
				return(i);
			}
		}}}
		return(0);
	}
}