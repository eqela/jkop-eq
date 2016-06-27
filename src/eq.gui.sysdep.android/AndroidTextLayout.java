
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

package eq.gui.sysdep.android;

import eq.gui.*;

public class AndroidTextLayout extends eq.api.Object implements TextLayout, Size
{
	private eq.api.String str = null;
	private android.text.StaticLayout layout = null;
	private android.text.StaticLayout outline_layout = null;
	private TextProperties props = null;
	private int dpi = 0;
	
	private static int to_android_color(Color c) {
		if(c == null) {
			return(0);
		}
		return(android.graphics.Color.argb((int)(c.get_a() * 255), (int)(c.get_r() * 255), (int)(c.get_g() * 255), (int)(c.get_b() * 255)));
	}

	public static AndroidTextLayout create(TextProperties props, int dpi) {
		AndroidTextLayout v = new AndroidTextLayout();
		v.dpi = dpi;
		v.str = props.get_text();
		if(v.str == null) {
			v.str = eq.api.String.Static.for_strptr("");
		}
		android.text.TextPaint tp = new android.text.TextPaint();
		tp.setAntiAlias(true);
		tp.setColor(to_android_color(props.get_color()));
		font_to_paint(props.get_font(), tp, dpi);
		android.text.Layout.Alignment al = android.text.Layout.Alignment.ALIGN_NORMAL;
		if(props.get_alignment() == 1) {
			al = android.text.Layout.Alignment.ALIGN_CENTER;
		}
		if(props.get_alignment() == 2) {
			al = android.text.Layout.Alignment.ALIGN_OPPOSITE;
		}
		java.lang.String sp = v.str.to_strptr();
		int wrapwidth = props.get_wrap_width();
		if(wrapwidth < 1) {
			wrapwidth = (int)android.text.Layout.getDesiredWidth(sp, tp) + 1;
		}
		v.layout = new android.text.StaticLayout(sp, tp, wrapwidth, al, (float)1.0, (float)0.0, false);
		Color outlinecolor = props.get_outline_color();
		int outlinewidth = 3; //(int)props.get_outline_width();
		if(outlinecolor != null && outlinewidth > 0) {
			android.text.TextPaint tpo = new android.text.TextPaint();
			tpo.setAntiAlias(true);
			font_to_paint(props.get_font(), tpo, dpi);
			tpo.setColor(to_android_color(outlinecolor));
			tpo.setStrokeWidth(outlinewidth);
			tpo.setStyle(android.graphics.Paint.Style.STROKE);
			v.outline_layout = new android.text.StaticLayout(sp, tpo, wrapwidth, al, (float)1.0, (float)0.0, false);
		}
		v.props = props;
		return(v);
	}

	private static java.util.Hashtable<String, android.graphics.Typeface> typefacecache = null;

	static android.graphics.Typeface get_cached_typeface(android.content.Context c, String assetPath) {
		if(typefacecache == null) {
			typefacecache = new java.util.Hashtable<String, android.graphics.Typeface>();
		}
		if(typefacecache.containsKey(assetPath) == false) {
			try {
				android.graphics.Typeface t = android.graphics.Typeface.createFromAsset(c.getAssets(), assetPath);
				typefacecache.put(assetPath, t);
			}
			catch(Exception e) {
				e.printStackTrace();
				return null;
			}
		}
		return(typefacecache.get(assetPath));
	}

	public static android.graphics.Typeface font_to_typeface(Font font) {
		String fontname = null;
		int style = android.graphics.Typeface.NORMAL;
		if(font != null) {
			if(font.is_bold() && font.is_italic()) {
				style = android.graphics.Typeface.BOLD_ITALIC;
			}
			else if(font.is_bold()) {
				style = android.graphics.Typeface.BOLD;
			}
			else if(font.is_italic()) {
				style = android.graphics.Typeface.ITALIC;
			}
			if(font.get_name() != null) {
				fontname = font.get_name().to_strptr();
			}
		}
		if(fontname == null) {
			fontname = "";
		}
		android.graphics.Typeface typeface;
		if(fontname.indexOf('.') < 0) {
			typeface = android.graphics.Typeface.create(fontname, style);
		}
		else if(eq.api.Android.context != null) {
			typeface = get_cached_typeface(eq.api.Android.context, fontname);
		}
		else {
			typeface = android.graphics.Typeface.create("Arial", style);
		}
		return(typeface);
	}

	private static void font_to_paint(Font font, android.text.TextPaint pt, int dpi) {
		if(font == null) {
			return;
		}
		if(pt != null) {
			String fontname = null;
			eq.api.String fnn = font.get_name();
			if(fnn != null) {
				fontname = fnn.to_strptr();
			}
			pt.setTypeface(font_to_typeface(font));
			pt.setTextSize((float)Length.Static.to_pixels(font.get_size(), dpi));
			if(fontname != null && (fontname.contains(".ttf") || fontname.contains(".otf"))) {
				if(font.is_italic()) {
					pt.setTextSkewX(-0.25f);
				}
			}
		}
	}

	public TextProperties get_text_properties() {
		return(props);
	}

	public eq.api.String get_text() {
		return(str);
	}

	public double get_width() {
		int v = 0;
		if(layout != null) {
			v = layout.getWidth();
		}
		return((double)v);
	}

	public double get_height() {
		int v = 0;
		if(layout != null) {
			v = layout.getHeight();
		}
		return((double)v);
	}

	public Rectangle get_cursor_position(int index) {
		int x=0, y=0, w=0, h=0;
		if(layout != null) {
			android.graphics.Path mypath = new android.graphics.Path();
			layout.getCursorPath(index, mypath, str.to_strptr());
			android.graphics.RectF rf = new android.graphics.RectF();
			mypath.computeBounds(rf, true);
			x = (int)rf.left;
			y = (int)rf.top;
			w = (int)rf.right - (int)rf.left + 1;
			h = (int)rf.bottom - (int)rf.top + 1;
		}
		return(Rectangle.Static.instance(x,y,w,h));
	}

	public int xy_to_index(double x, double y) {
		java.lang.String txt = str.to_strptr();
		int w = 0;
		android.text.TextPaint tp = new android.text.TextPaint();
		font_to_paint(props.get_font(), tp, dpi);
		for(int i = 0; i < txt.length(); i++) {
			java.lang.String ss = txt.substring(i, i+1);
			int wrapwidth = props.get_wrap_width();
			if(wrapwidth < 1) {
				wrapwidth = (int)android.text.Layout.getDesiredWidth(ss, tp);
			}
			int cw = new android.text.StaticLayout(ss,
				 tp,
				 wrapwidth,
				 layout.getAlignment(),
				 (float)1.0,
				 (float)0.0,
				 false).getWidth();
			w += cw;
			if((w - (cw/2)) >= x) {	
				return(i);
			}
		}
		return(txt.length());
	}

	public android.text.StaticLayout get_layout() {
		return(layout);
	}

	public android.text.StaticLayout get_outline_layout() {
		return(outline_layout);
	}
}

