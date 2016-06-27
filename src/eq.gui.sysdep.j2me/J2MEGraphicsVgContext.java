
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

package eq.gui.sysdep.j2me;

import javax.microedition.lcdui.*;

public class J2MEGraphicsVgContext implements eq.gui.vg.VgContext
{
	private Graphics graphics = null;
	private int width = 0;
	private int height = 0;

	public J2MEGraphicsVgContext(Graphics graphics, int width, int height) {
		this.graphics = graphics;
		this.width = width;
		this.height = height;
	}
	
	private boolean fill_transparent_rectangle(int x, int y, int w, int h, eq.gui.Color c, double a) {
		int fillcolor = color_to_int(c, a);
		int colors[] = new int[w * h];
		for(int i = 0; i < (w*h); i++) {
			colors[i] = fillcolor;
		}
		draw_buffer(colors, x, y, w, h);
		return(true);
	}

	private void stroke_custom_path(int x, int y, eq.gui.vg.VgPathCustom vpc, eq.gui.vg.VgTransform vt) {
		eq.api.Iterator itr = vpc.iterate();
		int cx = vpc.get_start_x() + x;
		int cy = vpc.get_start_y() + y;
		while(itr!=null) {
			eq.gui.vg.VgPathElement vpe = (eq.gui.vg.VgPathElement)itr.next();
			if(vpe == null) {
				break;
			}
			int next_x = 0;
			int next_y = 0;
			int op = vpe.get_operation();
			if(op == eq.gui.vg.VgPathElement.OP_LINE) {
				next_x = vpe.get_x1() + x;
				next_y = vpe.get_y1() + y;
				graphics.drawLine(cx, cy, next_x, next_y);
			}
			else if(op == eq.gui.vg.VgPathElement.OP_CURVE) {
				int x1 = vpe.get_x1() + x;
				int y1 = vpe.get_y1() + y;
				int x2 = vpe.get_x2() + x;
				int y2 = vpe.get_y2() + y;
				next_x = vpe.get_x3() + x;
				next_y = vpe.get_y3() + y;
				graphics.drawLine(cx, cy, x1, y1);
				graphics.drawLine(x1, y1, x2, y2);
				graphics.drawLine(x2, y2, next_x, next_y);
			}
			else if(op == eq.gui.vg.VgPathElement.OP_ARC) {
				int radius = vpe.get_radius();
				int hw = radius * 2;
				int tx = vpe.get_x1() + x;
				int ty = vpe.get_y1() + y;
				int x1 = (int)((Math.cos((float)vpe.get_angle1()) * radius) + tx);
				int y1 = (int)((Math.sin((float)vpe.get_angle1()) * radius) + ty);
				int a1 = (int)(vpe.get_angle1() * 180.0 / java.lang.Math.PI);
				int a2 = (int)(vpe.get_angle2() * 180.0 / java.lang.Math.PI);
				if(a2 < a1) {
					int t = a2;
					a2 = a1;
					a1 = t;
				}
				a2 -= a1;
				while(a1 < 0) {
					a1 += 360.0;
				}
				while(a1 >= 360.0) {
					a1 -= 360.0;
				}
				graphics.drawLine(cx, cy, x1, y1);
				graphics.drawArc(tx - radius, ty - radius, hw, hw, -a1, -a2);
				next_x = (int)((Math.cos((float)vpe.get_angle2()) * radius) + tx);
				next_y = (int)((Math.sin((float)vpe.get_angle2()) * radius) + ty);
			}
			cx = next_x;
			cy = next_y;
		}
	}
	
	private void fill_custom_path(int x, int y, eq.gui.vg.VgPathCustom vpc, eq.gui.vg.VgTransform vt) {
		eq.api.Iterator itr = vpc.iterate();
		int cx = vpc.get_start_x() + x;
		int cy = vpc.get_start_y() + y;
		while(itr!=null) {
			eq.gui.vg.VgPathElement vpe = (eq.gui.vg.VgPathElement)itr.next();
			if(vpe == null) {
				break;
			}
			int next_x = 0;
			int next_y = 0;
			int op = vpe.get_operation();
			if(op == eq.gui.vg.VgPathElement.OP_LINE) {
				next_x = vpe.get_x1() + x;
				next_y = vpe.get_y1() + y;
				graphics.drawLine(cx, cy, next_x, next_y);
			}
			else if(op == eq.gui.vg.VgPathElement.OP_CURVE) {
				int x1 = vpe.get_x1() + x;
				int y1 = vpe.get_y1() + y;
				int x2 = vpe.get_x2() + x;
				int y2 = vpe.get_y2() + y;
				next_x = vpe.get_x3() + x;
				next_y = vpe.get_y3() + y;
				graphics.drawLine(cx, cy, x1, y1);
				graphics.drawLine(x1, y1, x2, y2);
				graphics.drawLine(x2, y2, next_x, next_y);
			}
			else if(op == eq.gui.vg.VgPathElement.OP_ARC) {
				int radius = vpe.get_radius();
				int hw = radius * 2;
				int tx = vpe.get_x1() + x;
				int ty = vpe.get_y1() + y;
				int x1 = (int)((Math.cos((float)vpe.get_angle1()) * radius) + tx);
				int y1 = (int)((Math.sin((float)vpe.get_angle1()) * radius) + ty);
				int a1 = (int)(vpe.get_angle1() * 180.0 / java.lang.Math.PI);
				int a2 = (int)(vpe.get_angle2() * 180.0 / java.lang.Math.PI);
				if(a2 < a1) {
					int t = a2;
					a2 = a1;
					a1 = t;
				}
				a2 -= a1;
				while(a1 < 0) {
					a1 += 360.0;
				}
				while(a1 >= 360.0) {
					a1 -= 360.0;
				}
				graphics.drawLine(cx, cy, x1, y1);
				graphics.fillArc(tx - radius, ty - radius, hw, hw, -a1, -a2);
				next_x = (int)((Math.cos((float)vpe.get_angle2()) * radius) + tx);
				next_y = (int)((Math.sin((float)vpe.get_angle2()) * radius) + ty);
			}
			cx = next_x;
			cy = next_y;
		}
	}
	
	private int color_to_int(eq.gui.Color c, double alpha) {
		if(c == null) {
			return(0);
		}
		byte ca = (byte)((c.get_a()*alpha) * 255), cr = (byte)(c.get_r() * 255), cg = (byte)(c.get_g() * 255), cb = (byte)(c.get_b() * 255);
		return(((ca & 0xFF) << 24) + ((cr & 0xFF) << 16) + ((cg & 0xFF) << 8) + (cb & 0xFF));
	}

	private int mixed_gradient_colors_to_int(eq.gui.Color c, eq.gui.Color c2) {
		byte cr = (byte)(c.get_r() * 255), cg = (byte)(c.get_g() * 255), cb = (byte)(c.get_b() * 255);
		byte cr2 = (byte)(c2.get_r() * 255), cg2 = (byte)(c2.get_g() * 255), cb2 = (byte)(c2.get_b() * 255);
		byte fcr = (byte)((cr + cr2)/2) , fcg = (byte)((cg + cg2)/2), fcb = (byte)((cb + cb2)/2);
		return(((fcr & 0xFF) << 16) + ((fcg & 0xFF) << 8) + (fcb & 0xFF));
	}

	public boolean stroke(int x, int y, eq.gui.vg.VgPath vp, eq.gui.vg.VgTransform vt, eq.gui.Color c, int linewidth, int style) {
		if(vp == null || c == null) {
			return(false);
		}
		if(style > 2 || style < 0) {
			eq.api.Log.eq_api_Log_warning((eq.api.Object)eq.api.StringStatic.eq_api_StringStatic_for_strptr("Stroke style not supported. 0 = SOLID, 1 = DOTTED"), null, null);
		}
		int w = vp.get_w();
		int h = vp.get_h();
		int vx = vp.get_x()+x;
		int vy = vp.get_y()+y;
		graphics.setColor(color_to_int(c, 1.0));
		if(vp instanceof eq.gui.vg.VgPathRoundedRectangle) {
			eq.gui.vg.VgPathRoundedRectangle vprr = (eq.gui.vg.VgPathRoundedRectangle)vp;
			int i;
			for(i=0;i<linewidth;i++) {
				int diameter = (vprr.get_radius()-i) * 2;
				graphics.drawRoundRect(vx+i, vy+i, w-i, h-i, diameter, diameter);
			}
		}
		else if(vp instanceof eq.gui.vg.VgPathRectangle) {
			int i;
			for(i=0;i<linewidth;i++) {
				graphics.drawRect(vx+i, vy+i, w-i, h-i);
			}
		}
		else if(vp instanceof eq.gui.vg.VgPathCircle) {
			eq.gui.vg.VgPathCircle vpc = (eq.gui.vg.VgPathCircle)vp;
			int i;
			vx += linewidth/2;
			vy += linewidth/2;
			int rad = vpc.get_radius() - (linewidth/2);
			for(i=0;i<linewidth;i++) {
				int hw = (rad-i) * 2;
				graphics.drawArc(vx+i, vy+i, hw, hw, 0, 360);
			}
		}
		else if(vp instanceof eq.gui.vg.VgPathCustom) {
			if(linewidth > 1) {
				eq.api.Log.eq_api_Log_warning((eq.api.Object)eq.api.StringStatic.eq_api_StringStatic_for_strptr("Custom path's line width is fixed to 1px only."), null, null);
			}
			stroke_custom_path(x, y, (eq.gui.vg.VgPathCustom)vp, vt);
		}
		return(true);
	}

	public boolean fill_color(int x, int y, eq.gui.vg.VgPath vp, eq.gui.vg.VgTransform vt, eq.gui.Color c) {
		if(vp == null || c == null) {
			return(false);
		}
		double alpha = 1.0;
		if(vt!=null) {
			alpha = vt.get_alpha();
		}
		int w = vp.get_w();
		int h = vp.get_h();
		int vx = vp.get_x()+x;
		int vy = vp.get_y()+y;
		if(alpha < 1.0 || c.get_a() < 1.0) {
			return(fill_transparent_rectangle(vx, vy, w, h, c, alpha));
		}
		graphics.setColor(color_to_int(c, 1.0));
		if(vp instanceof eq.gui.vg.VgPathRectangle) {
			graphics.fillRect(vx, vy, w, h);
		}
		else if(vp instanceof eq.gui.vg.VgPathRoundedRectangle) {
			eq.gui.vg.VgPathRoundedRectangle vprr = (eq.gui.vg.VgPathRoundedRectangle)vp;
			int diameter = vprr.get_radius() * 2;
			graphics.fillRoundRect(vx, vy, w, h, diameter, diameter);
		}
		else if(vp instanceof eq.gui.vg.VgPathCircle) {
			eq.gui.vg.VgPathCircle vpc = (eq.gui.vg.VgPathCircle)vp;
			int hw = vpc.get_radius() * 2;
			graphics.fillArc(vx, vy, hw, hw, 0, 360);
		}
		else if(vp instanceof eq.gui.vg.VgPathCustom) {
			fill_custom_path(x, y, (eq.gui.vg.VgPathCustom)vp, vt);
		}
		return(true);
	}
	
	void draw_buffer(int[] buffer, int x, int y, int w, int h) {
		try {
			Image gradient = Image.createRGBImage(buffer, w, h, true);
			graphics.drawImage(gradient, x, y, Graphics.TOP | Graphics.LEFT);
		}
		catch(Exception e) {
		}
	}

	private boolean fill_gradient(int x, int y, eq.gui.vg.VgPath vp, eq.gui.vg.VgTransform vt, eq.gui.Color a, eq.gui.Color b) {
		if(vp == null || a == null || b == null) {
			return(false);
		}
		int w = vp.get_w();
		int h = vp.get_h();
		int vx = vp.get_x()+x;
		int vy = vp.get_y()+y;
		graphics.setColor(mixed_gradient_colors_to_int(a, b));
		if(vp instanceof eq.gui.vg.VgPathRectangle) {
			graphics.fillRect(vx, vy, w, h);
		}
		else if(vp instanceof eq.gui.vg.VgPathRoundedRectangle) {
			eq.gui.vg.VgPathRoundedRectangle vprr = (eq.gui.vg.VgPathRoundedRectangle)vp;
			int diameter = vprr.get_radius() * 2;
			graphics.fillRoundRect(vx, vy, w, h, diameter, diameter);
		}
		else if(vp instanceof eq.gui.vg.VgPathCircle) {
			eq.gui.vg.VgPathCircle vpc = (eq.gui.vg.VgPathCircle)vp;
			int hw = vpc.get_radius() * 2;
			graphics.fillArc(vx, vy, hw, hw, 0, 360);
		}
		return(true);
	}

	public boolean fill_vertical_gradient(int x, int y, eq.gui.vg.VgPath vp, eq.gui.vg.VgTransform vt, eq.gui.Color a, eq.gui.Color b) {
		if(a == null || b == null || vp == null) {
			return(false);
		}
		double xalpha = 1.0;
		if(vt != null) {
			xalpha = vt.get_alpha();
		}
		if(vp instanceof eq.gui.vg.VgPathRectangle) {
			int ax = x + vp.get_x(), ay = y + vp.get_y();
			int h = vp.get_h(), w = vp.get_w();
			int color1 = color_to_int(a, xalpha);
			int color2 = color_to_int(b, xalpha);
			int as = (color1 & 0xFF000000) >> 24;
			int rs = (color1 & 0x00FF0000) >> 16;
			int gs = (color1 & 0x0000FF00) >> 8;
			int bs =  color1 & 0x000000FF;
			int ae = (color2 & 0xFF000000) >> 24;
			int re = (color2 & 0x00FF0000) >> 16;
			int ge = (color2 & 0x0000FF00) >> 8;
			int be =  color2 & 0x000000FF;
			int[] argb = new int[w * h];
			for (int row = 0; row < h; ++row) {
				int rr = ((re - rs) * row / h) + rs;
				int gg = ((ge - gs) * row / h) + gs;
				int bb = ((be - bs) * row / h) + bs;
				int aa = ((ae - as) * row / h) + as;
				int color = (aa << 24) | (rr << 16) | (gg << 8) | bb;
				for (int col = 0; col < w; ++col) {
					argb[row * w + col] = color;
				}
			}
			draw_buffer(argb, ax, ay, w, h);
			return(true);
		}
		return(fill_gradient(x, y, vp, vt, a, b));
	}

	public boolean fill_horizontal_gradient(int x, int y, eq.gui.vg.VgPath vp, eq.gui.vg.VgTransform vt, eq.gui.Color a, eq.gui.Color b) {
		if(a == null || b == null || vp == null) {
			return(false);
		}
		double xalpha = 1.0;
		if(vt != null) {
			xalpha = vt.get_alpha();
		}
		if(vp instanceof eq.gui.vg.VgPathRectangle) {
			int ax = x + vp.get_x(), ay = y + vp.get_y();
			int h = vp.get_h(), w = vp.get_w();
			int color1 = color_to_int(a, xalpha);
			int color2 = color_to_int(b, xalpha);
			int as = (color1 & 0xFF000000) >> 24;
			int rs = (color1 & 0x00FF0000) >> 16;
			int gs = (color1 & 0x0000FF00) >> 8;
			int bs =  color1 & 0x000000FF;
			int ae = (color2 & 0xFF000000) >> 24;
			int re = (color2 & 0x00FF0000) >> 16;
			int ge = (color2 & 0x0000FF00) >> 8;
			int be =  color2 & 0x000000FF;
			int[] argb = new int[w * h];
			for (int row = 0; row < h; ++row) {
				for (int col = 0; col < w; ++col) {
					int rr = ((re - rs) * col / w) + rs;
					int gg = ((ge - gs) * col / w) + gs;
					int bb = ((be - bs) * col / w) + bs;
					int aa = ((ae - as) * col / w) + as;
					int color = (aa << 24) | (rr << 16) | (gg << 8) | bb;
					argb[row * w + col] = color;
				}
			}
			draw_buffer(argb, ax, ay, w, h);
			return(true);
		}
		return(fill_gradient(x, y, vp, vt, a, b));
	}

	public boolean fill_radial_gradient(int x, int y, eq.gui.vg.VgPath vp, eq.gui.vg.VgTransform vt, int radius, eq.gui.Color a, eq.gui.Color b) {
		return(fill_gradient(x, y, vp, vt, a, b));
	}

	public boolean fill_diagonal_gradient(int x, int y, eq.gui.vg.VgPath vp, eq.gui.vg.VgTransform vt, eq.gui.Color a, eq.gui.Color b, int direction) {
		return(fill_gradient(x, y, vp, vt, a, b));
	}

	public boolean draw_text(int ax, int ay, eq.gui.vg.VgTransform vt, eq.gui.TextLayout text) {
		if(text instanceof J2METextLayout == false) {
			return(false);
		}
		eq.gui.TextProperties props = text.get_text_properties();
		java.util.Vector vec = ((J2METextLayout)text).get_layout();
		java.util.Vector lines = (java.util.Vector)vec.elementAt(1);
		Boolean wrap = (Boolean)vec.elementAt(2);
		int align = 0, liney = 0;
		int fontColor = ((J2METextLayout)text).get_font_color(), outLineColor = ((J2METextLayout)text).get_font_outline_color(); 
		int x = ax, y = ay;
		if(props.get_alignment() == 1) {
			align = Graphics.TOP | Graphics.HCENTER;
		}
		else if(props.get_alignment() == 2) {
			align = Graphics.TOP | Graphics.RIGHT;
			x = ax + (int)((J2METextLayout)text).get_width();
		}
		else {
			align = Graphics.TOP | Graphics.LEFT;
		}
		graphics.setFont((Font)vec.elementAt(0));
		if(wrap.booleanValue() == true) {
			for (int i = 0; i < lines.size(); i++) {
				liney = y + (i * ((Font)vec.elementAt(0)).getHeight());
				if(outLineColor > 0) {
					graphics.setColor(outLineColor);
					graphics.drawString((String)lines.elementAt(i), x + 1, liney + 1, align);
				}
				graphics.setColor(fontColor);
				graphics.drawString((String)lines.elementAt(i), x, liney, align);
			}
		}
		else {					
			eq.api.String str = props.get_text();
			if(str == null) {
				str = eq.api.StringStatic.eq_api_StringStatic_for_strptr("");
			}
			if(outLineColor > 0) {
				graphics.setColor(outLineColor);
				graphics.drawString(str.to_strptr(), x + 1, y + 1, align);
			}
			graphics.setColor(fontColor);
			graphics.drawString(str.to_strptr(), x, y, align);
		}
		return(true);
	}

	public boolean draw_graphic(int x, int y, eq.gui.vg.VgTransform vt, eq.gui.Image agraphic) {
		if(agraphic == null) {
			return(false);
		}
		if(agraphic instanceof eq.gui.vg.CodeImage) {
			((eq.gui.vg.CodeImage)agraphic).render(this, x, y, vt);
			return(true);
		}
		if(agraphic instanceof J2MEImage == false) {
			return(false);
		}
		J2MEImage img = (J2MEImage)agraphic;
		graphics.drawImage(img.get_midlet_image(), x, y, Graphics.TOP | Graphics.LEFT);
		return(true);
	}

	public boolean clip(int x, int y, eq.gui.vg.VgPath vp, eq.gui.vg.VgTransform vt) {
		boolean v = true;
		if(vp instanceof eq.gui.vg.VgPathRectangle) {
			int w = vp.get_w();
			int h = vp.get_h();
			int vx = vp.get_x()+x;
			int vy = vp.get_y()+y;
			graphics.clipRect(vx, vy, w, h);
		}
		else {
			v = false;
		}
		return(v);
	}

	public boolean clip_clear() {
		graphics.setClip(0, 0, this.width, this.height);
		return(true);
	}
	
	public boolean clear(int x, int y, eq.gui.vg.VgPath vp, eq.gui.vg.VgTransform vt) {
		graphics.fillRect(0, 0, width, height);
		return(true);
	}
}
