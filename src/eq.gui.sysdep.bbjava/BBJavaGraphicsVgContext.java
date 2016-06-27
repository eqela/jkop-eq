
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

package eq.gui.sysdep.bbjava;

import java.util.*;
import net.rim.device.api.ui.*;
import net.rim.device.api.ui.container.*;

public class BBJavaGraphicsVgContext implements eq.gui.vg.VgContext
{
	private net.rim.device.api.ui.Graphics graphics = null;

	public BBJavaGraphicsVgContext(Graphics graphics) {
		this.graphics = graphics;
	}

	private int to_blackberry_color(eq.gui.Color c) {
		if(c == null) {
			return(0);
		}
		byte cr = (byte)(c.get_r() * 255), cg = (byte)(c.get_g() * 255), cb = (byte)(c.get_b() * 255), ca = (byte)(c.get_a()*255);				
		return((ca << 24) + ((cr & 0xFF) << 16) + ((cg & 0xFF) << 8) + (cb & 0xFF));
	}

	private int middle_color(eq.gui.Color c, eq.gui.Color c2) {
		byte cr = (byte)(c.get_r() * 255), cg = (byte)(c.get_g() * 255), cb = (byte)(c.get_b() * 255), ca = (byte)(c.get_a() * 255);
		byte cr2 = (byte)(c2.get_r() * 255), cg2 = (byte)(c2.get_g() * 255), cb2 = (byte)(c2.get_b() * 255), ca2 = (byte)(c2.get_a() * 255);
		byte fcr = (byte)((cr + cr2)) , fcg = (byte)((cg + cg2)), fcb = (byte)((cb + cb2)), fca = (byte)((ca + ca2));
		return((fca << 24) + ((fcr & 0xFF) << 16) + ((fcg & 0xFF) << 8) + (fcb & 0xFF));
	}

	private void draw_gradient_shape(int x, int y, eq.gui.vg.VgPath vp, eq.gui.vg.VgTransform vt, eq.gui.Color color1, eq.gui.Color color2, int direction) {
		int shape = -1;
		int w = vp.get_w();
		int h = vp.get_h();
		int[] px = null;
		int[] py = null;
		byte[] ptypes = null;
		int ax = x+vp.get_x();
		int ay = y+vp.get_y();
		if(vp instanceof eq.gui.vg.VgPathRectangle) {
			shape = 0;
			int[] _px = { ax, ax + w, ax + w, ax };
			int[] _py = { ay, ay, ay + h, ay + h };
			px = _px;
			py = _py;
		}
		else if(vp instanceof eq.gui.vg.VgPathRoundedRectangle) {
			shape = 1;
			eq.gui.vg.VgPathRoundedRectangle vpr = (eq.gui.vg.VgPathRoundedRectangle)vp;
			int radius = vpr.get_radius();
			byte[] _ptypes = {
				net.rim.device.api.ui.Graphics.CURVEDPATH_END_POINT, 
				net.rim.device.api.ui.Graphics.CURVEDPATH_QUADRATIC_BEZIER_CONTROL_POINT,
			  	net.rim.device.api.ui.Graphics.CURVEDPATH_END_POINT, 
			 	net.rim.device.api.ui.Graphics.CURVEDPATH_END_POINT, 
			 	net.rim.device.api.ui.Graphics.CURVEDPATH_QUADRATIC_BEZIER_CONTROL_POINT,
			 	net.rim.device.api.ui.Graphics.CURVEDPATH_END_POINT, 
			 	net.rim.device.api.ui.Graphics.CURVEDPATH_END_POINT, 
			 	net.rim.device.api.ui.Graphics.CURVEDPATH_QUADRATIC_BEZIER_CONTROL_POINT,
			 	net.rim.device.api.ui.Graphics.CURVEDPATH_END_POINT, 
			 	net.rim.device.api.ui.Graphics.CURVEDPATH_END_POINT, 
			 	net.rim.device.api.ui.Graphics.CURVEDPATH_QUADRATIC_BEZIER_CONTROL_POINT,
			 	net.rim.device.api.ui.Graphics.CURVEDPATH_END_POINT, 
			};
			int[] _px = {
				ax, ax, ax + radius, ax + w - radius, ax + w, ax + w,
				ax + w, ax + w, ax + w - radius, ax + radius, ax, ax
			};
			int[] _py = {
				ay + radius, ay, ay, ay, ay, ay + radius,
				ay + h - radius, ay + h, ay + h, ay + h, ay + h, ay + h - radius
			};
			px = _px;
			py = _py;
			ptypes = _ptypes;
		}
		else if(vp instanceof eq.gui.vg.VgPathCircle) {
			shape = 2;
			eq.gui.vg.VgPathCircle c = (eq.gui.vg.VgPathCircle)vp;
			int r = c.get_radius();
			int yc = r;
			int xc = r;
			int[] _px = { (xc-r), (xc-r), xc, (xc+r), (xc+r), (xc+r), xc, (	xc-r) };
			int[] _py = { yc, (yc-r), (yc-r), (yc-r), yc, (yc+r), (yc+r), (yc+r) };
			byte[] _ptypes = { 
				net.rim.device.api.ui.Graphics.CURVEDPATH_END_POINT, 
				net.rim.device.api.ui.Graphics.CURVEDPATH_QUADRATIC_BEZIER_CONTROL_POINT,
			  	net.rim.device.api.ui.Graphics.CURVEDPATH_END_POINT, 
				net.rim.device.api.ui.Graphics.CURVEDPATH_QUADRATIC_BEZIER_CONTROL_POINT,
				net.rim.device.api.ui.Graphics.CURVEDPATH_END_POINT, 
				net.rim.device.api.ui.Graphics.CURVEDPATH_QUADRATIC_BEZIER_CONTROL_POINT,
				net.rim.device.api.ui.Graphics.CURVEDPATH_END_POINT, 
				net.rim.device.api.ui.Graphics.CURVEDPATH_QUADRATIC_BEZIER_CONTROL_POINT 
			};
			px = _px;
			py = _py;
			ptypes = _ptypes;
		}
		int bbc1 = to_blackberry_color(color1);
		int bbc2 = to_blackberry_color(color2);
		int bbc3 = middle_color(color1, color2);
		int[] colors = null;
		if(direction == 0) { //vertical
			if(shape == 0) {
				int[] _colors = {
					bbc1, bbc1, bbc2, bbc2
				};
				colors = _colors;
			}
			else if(shape == 1) {
				int[] _colors = {
					    bbc1, bbc1, bbc1, bbc1, bbc1, bbc1,
					    bbc2, bbc2, bbc2, bbc2, bbc2, bbc2
				};
				colors = _colors;
			}
			else if(shape == 2) {
				int[] _colors = { 
					bbc3, bbc1, bbc1, bbc1, bbc3, 
					bbc2, bbc2, bbc2 
				};
				colors = _colors;
			}
		}
		else if(direction == 1) { //horizontal
			if(shape == 0) {
				int[] _colors = {
					bbc1, bbc2, bbc2, bbc1
				};
				colors = _colors;
			}
			else if(shape == 1) {
				int[] _colors = {
					bbc1, bbc1, bbc1, bbc2, bbc2, bbc2,
					bbc2, bbc2, bbc2, bbc1, bbc1, bbc1
				};
				colors = _colors;
			}
			else if(shape == 2) {
				int[] _colors = { 
					bbc1, bbc1, bbc3, bbc2, 
					bbc2, bbc2, bbc3, bbc1 
				};
				colors = _colors;
			}
		}
		else if(direction == 2) { //diagonal
			if(shape == 0) {
				int[] _colors = {
					bbc1, bbc3, bbc2, bbc3
				};
				colors = _colors;
			}
			else if(shape == 1) {
				int[] _colors = {
					bbc1, bbc1, bbc1, bbc1, bbc3, bbc3,
					bbc2, bbc2, bbc2, bbc3, bbc3, bbc3
				};
				colors = _colors;
			}
			else if(shape == 2) {
				//FIXME
			}
		}
		else if(direction == 3) { //radial
			//FIXME
		}
		graphics.drawShadedFilledPath(px, py, ptypes, colors, null);
	}

	private void draw_custom_path(int x, int y, eq.gui.vg.VgPathCustom vpc, eq.gui.vg.VgTransform vt) {
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
				int[] px = { x1, x2, next_x };
				int[] py = { y1, y2, next_y };
				byte[] ptypes = {
					net.rim.device.api.ui.Graphics.CURVEDPATH_END_POINT,
					net.rim.device.api.ui.Graphics.CURVEDPATH_QUADRATIC_BEZIER_CONTROL_POINT,
					net.rim.device.api.ui.Graphics.CURVEDPATH_END_POINT
				};
				graphics.drawOutlinedPath(px, py, ptypes, null, false);
			}
			else if(op == eq.gui.vg.VgPathElement.OP_ARC) {
				int radius = vpe.get_radius();
				int hw = radius * 2;
				int tx = vpe.get_x1() + x;
				int ty = vpe.get_y1() + y;
				int x1 = (int)((eq.api.Math.eq_api_Math_cos((float)vpe.get_angle1()) * radius) + tx);
				int y1 = (int)((eq.api.Math.eq_api_Math_sin((float)vpe.get_angle1()) * radius) + ty);
				int a1 = (int)(vpe.get_angle1() * 180.0 / eq.api.MathConstant.M_PI);
				int a2 = (int)(vpe.get_angle2() * 180.0 / eq.api.MathConstant.M_PI);
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
				next_x = (int)((eq.api.Math.eq_api_Math_cos((float)vpe.get_angle2()) * radius) + tx);
				next_y = (int)((eq.api.Math.eq_api_Math_sin((float)vpe.get_angle2()) * radius) + ty);
			}
			cx = next_x;
			cy = next_y;
		}
	}
	
	private boolean fill_custom_path(int x, int y, eq.gui.vg.VgPathCustom vp, eq.gui.vg.VgTransform vt, eq.gui.Color color1, eq.gui.Color color2, int direction) {
		eq.api.Iterator itr = ((eq.api.Iterateable)vp).iterate();
		int c = 1;
		boolean use_array = false;
		while(itr != null) {
			eq.gui.vg.VgPathElement e = (eq.gui.vg.VgPathElement)itr.next();
			if(e == null) {
				break;
			}
			int op = e.get_operation();
			if(op == eq.gui.vg.VgPathElement.OP_LINE) {
				use_array = true;
				c++;
			}
			else if(op == eq.gui.vg.VgPathElement.OP_CURVE) {
				use_array = true;
				c += 3;
			}
		}
		int[] px = null;
		int[] py = null;
		byte[] ptypes = null;
		int cx =  x + vp.get_start_x();	
		int cy =  y + vp.get_start_y();
		if(use_array == true) {
			px = new int[c];
			py = new int[c];
			ptypes = new byte[c];
			ptypes[0] = net.rim.device.api.ui.Graphics.CURVEDPATH_END_POINT;	
			px[0] = cx;
			py[0] = cy;
		}
		eq.api.Iterator it = ((eq.api.Iterateable)vp).iterate();
		int count = 0;
		while(it != null) {
			eq.gui.vg.VgPathElement e = (eq.gui.vg.VgPathElement)it.next();
			if(e == null) {
				break;
			}
			int op = e.get_operation();
			if(use_array == true && op == eq.gui.vg.VgPathElement.OP_LINE) {
				ptypes[count] = net.rim.device.api.ui.Graphics.CURVEDPATH_END_POINT;
				cx = px[count] = x+e.get_x1();
				cy = py[count++] = y+e.get_y1();
			}
			else if(use_array == true && op == eq.gui.vg.VgPathElement.OP_CURVE) {
				ptypes[count] = net.rim.device.api.ui.Graphics.CURVEDPATH_END_POINT;
				px[count] = x+e.get_x1();
				py[count++] = y+e.get_y1();
				ptypes[count] = net.rim.device.api.ui.Graphics.CURVEDPATH_QUADRATIC_BEZIER_CONTROL_POINT;
				px[count] = x+e.get_x2();
				py[count++] = y+e.get_y2();
				ptypes[count] = net.rim.device.api.ui.Graphics.CURVEDPATH_END_POINT;
				cx = px[count] = x+e.get_x3();
				cy = py[count++] = y+e.get_y3();
			}
			else if(op == eq.gui.vg.VgPathElement.OP_ARC) {
				int radius = e.get_radius();
				int hw = radius * 2;
				int tx = e.get_x1() + x;
				int ty = e.get_y1() + y;
				int x1 = (int)((eq.api.Math.eq_api_Math_cos((float)e.get_angle1()) * radius) + tx);
				int y1 = (int)((eq.api.Math.eq_api_Math_sin((float)e.get_angle1()) * radius) + ty);
				int a1 = (int)(e.get_angle1() * 180.0 / eq.api.MathConstant.M_PI);
				int a2 = (int)(e.get_angle2() * 180.0 / eq.api.MathConstant.M_PI);
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
				cx = (int)((eq.api.Math.eq_api_Math_cos((float)e.get_angle2()) * radius) + tx);
				cy = (int)((eq.api.Math.eq_api_Math_sin((float)e.get_angle2()) * radius) + ty);
				if(use_array == true) {
					ptypes[count] = net.rim.device.api.ui.Graphics.CURVEDPATH_END_POINT;
					px[count] = cx;
					py[count++] = cy;
				}
			}
		}
		if(use_array == true && color1 != null) {
			int bbc1 = to_blackberry_color(color1);
			int[] colors = null;
			if(color2 != null) {
				int bbc2 = to_blackberry_color(color2);
				int bbc3 = middle_color(color1, color2);
				if(direction == 0) { //vertical
					int[] _colors = {
					    bbc1, bbc1, bbc1, bbc1, bbc1, bbc1,
					    bbc2, bbc2, bbc2, bbc2, bbc2, bbc2
					};
					colors = _colors;
				}
				else if(direction == 1) { //horizontal
					int[] _colors = {
					    bbc1, bbc1, bbc1, bbc2, bbc2, bbc2,
					    bbc2, bbc2, bbc2, bbc1, bbc1, bbc1
					};
					colors = _colors;
				}
				else if(direction == 2) { //diagonal
					int[] _colors = {
				    bbc1, bbc1, bbc1, bbc1, bbc3, bbc3,
				    bbc2, bbc2, bbc2, bbc3, bbc3, bbc3
					};
					colors = _colors;
				}
				else if(direction == 3) { //radial
					//FIXME
				}
			}
			else {
				int[] _colors = {
					bbc1, bbc1, bbc1, bbc1, bbc1, bbc1,
					bbc1, bbc1, bbc1, bbc1, bbc1, bbc1
				};
				colors = _colors;
			}
			graphics.drawShadedFilledPath(px, py, ptypes, colors, null);
		}
		return(true);
	}

	public boolean stroke(int x, int y, eq.gui.vg.VgPath vp, eq.gui.vg.VgTransform vt, eq.gui.Color c, int linewidth, int style) {
		int color1 = to_blackberry_color(c);
		int vx = x + vp.get_x(), vy = y + vp.get_y();
		int w = vp.get_w(), h = vp.get_h();
		graphics.setColor(color1);
		double alpha = c.get_a() * 255;
		if(vt != null) {
			alpha *= vt.get_alpha();
		}
		graphics.setGlobalAlpha((int)alpha);
		if(vp instanceof eq.gui.vg.VgPathRectangle) {
			int i;
			for(i=0;i<linewidth;i++) {
				graphics.drawRect(vx+i, vy+i, w-i, h-i);
			}
		}
		else if(vp instanceof eq.gui.vg.VgPathRoundedRectangle) {
			eq.gui.vg.VgPathRoundedRectangle vprr = (eq.gui.vg.VgPathRoundedRectangle)vp;
			int i;
			for(i=0;i<linewidth;i++) {
				int diameter = (vprr.get_radius()-i) * 2;
				graphics.drawRoundRect(vx+i, vy+i, w-i, h-i, diameter, diameter);
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
			draw_custom_path(x, y, (eq.gui.vg.VgPathCustom)vp, vt);
		}
		graphics.setGlobalAlpha(255);
		return(true);
	}

	public boolean fill_color(int x, int y, eq.gui.vg.VgPath vp, eq.gui.vg.VgTransform vt, eq.gui.Color c) {
		int color1 = to_blackberry_color(c);
		int vx = x + vp.get_x(), vy = y + vp.get_y();
		int w = vp.get_w(), h = vp.get_h();
		graphics.setColor(color1);
		double alpha = c.get_a() * 255;
		if(vt != null) {
			alpha *= vt.get_alpha();
		}
		graphics.setGlobalAlpha((int)alpha);
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
			fill_custom_path(x, y, (eq.gui.vg.VgPathCustom)vp, vt, c, null, 0);
		}
		graphics.setGlobalAlpha(255);
		return(true);
	}

	public boolean fill_vertical_gradient(int x, int y, eq.gui.vg.VgPath vp, eq.gui.vg.VgTransform vt, eq.gui.Color a, eq.gui.Color b) {
		if(vp == null || a == null || b == null) {
			return(false);
		}
		double alpha = ((a.get_a()+b.get_a())/2) * 255;
		if(vt != null) {
			alpha *= vt.get_alpha();
		}
		graphics.setGlobalAlpha((int)alpha);
		if(vp instanceof eq.gui.vg.VgPathCustom) {
			fill_custom_path(x, y, (eq.gui.vg.VgPathCustom)vp, vt, a, b, 0);
		}
		else {
			draw_gradient_shape(x, y, vp, vt, a, b, 0);
		}
		graphics.setGlobalAlpha(255);
		return(true);
	}

	public boolean fill_horizontal_gradient(int x, int y, eq.gui.vg.VgPath vp, eq.gui.vg.VgTransform vt, eq.gui.Color a, eq.gui.Color b) {
		double alpha = ((a.get_a()+b.get_a())/2) * 255;
		if(vt != null) {
			alpha *= vt.get_alpha();
		}
		graphics.setGlobalAlpha((int)alpha);
		if(vp instanceof eq.gui.vg.VgPathCustom) {
			fill_custom_path(x, y, (eq.gui.vg.VgPathCustom)vp, vt, a, b, 1);
		}
		else {
			draw_gradient_shape(x, y, vp, vt, a, b, 1);
		}
		graphics.setGlobalAlpha(255);
		return(true);
	}

	public boolean fill_radial_gradient(int x, int y, eq.gui.vg.VgPath vp, eq.gui.vg.VgTransform vt, int radius, eq.gui.Color a, eq.gui.Color b) {
		if(vp == null || vp instanceof eq.gui.vg.VgPathCustom || a == null || b == null) {
			return(false);
		}
		double alpha = ((a.get_a()+b.get_a())/2) * 255;
		if(vt != null) {
			alpha *= vt.get_alpha();
		}
		graphics.setGlobalAlpha((int)alpha);
		int w = vp.get_w(), h = vp.get_h();
		fill_color(x, y, vp, vt, b);
		int color1 = to_blackberry_color(a);
		graphics.setColor(color1);
		int vx = x + vp.get_x(), vy = y + vp.get_y();
		int hw = radius * 2;
		graphics.fillArc(vx, vy, hw, hw, 0, 360);
		graphics.setGlobalAlpha(255);
		return(true);
	}

	public boolean fill_diagonal_gradient(int x, int y, eq.gui.vg.VgPath vp, eq.gui.vg.VgTransform vt, eq.gui.Color a, eq.gui.Color b, int direction) {
		double alpha = ((a.get_a()+b.get_a())/2) * 255;
		if(vt != null) {
			alpha *= vt.get_alpha();
		}
		graphics.setGlobalAlpha((int)alpha);
		if(vp instanceof eq.gui.vg.VgPathCustom) {
			fill_custom_path(x, y, (eq.gui.vg.VgPathCustom)vp, vt, a, b, 1);
		}
		else {
			draw_gradient_shape(x, y, vp, vt, a, b, 2);
		}
		graphics.setGlobalAlpha(255);
		return(true);
	}

	public boolean draw_text(int ax, int y, eq.gui.vg.VgTransform vt, eq.gui.TextLayout text) {
		if(text == null) {
			return(false);
		}
		eq.gui.Color c = text.get_text_properties().get_color();
		double alpha = 1.0;
		if(c != null) {
			alpha = c.get_a() * 255;
		}
		if(vt != null) {
			alpha *= vt.get_alpha();
		}
		graphics.setGlobalAlpha((int)alpha);
		eq.gui.TextProperties props = text.get_text_properties();
		java.util.Vector vec = ((BBJavaTextLayout)text).get_layout();
		java.util.Vector lines = (Vector)vec.elementAt(1);
		Boolean wrap = (Boolean)vec.elementAt(2);
		int align = 0, liney = 0, width = (int)((BBJavaTextLayout)text).get_width();
		int fontColor = ((BBJavaTextLayout)text).get_font_color(), outLineColor = ((BBJavaTextLayout)text).get_font_outline_color(); 
		int x = ax;
		if(props.get_alignment() == 1) {
			int tw = width;
			x = x - (tw / 2);
			align = net.rim.device.api.ui.DrawStyle.HCENTER;
		}
		else if(props.get_alignment() == 2) {
			align = net.rim.device.api.ui.DrawStyle.RIGHT;
			x = ax-1;
		}
		else {
			align = net.rim.device.api.ui.DrawStyle.HDEFAULT;
		}
		net.rim.device.api.ui.Font font = (net.rim.device.api.ui.Font)vec.elementAt(0);
		if(font != null) {
			graphics.setFont(font);
		}
		if(wrap.booleanValue() == true) {
			for (int i = 0; i < lines.size(); i++) 
			{
				liney = y + (i * ((net.rim.device.api.ui.Font)vec.elementAt(0)).getHeight());
				if(outLineColor > 0) {
					graphics.setColor(outLineColor);
					graphics.drawText((String)lines.elementAt(i), x + 1, liney + 1, align, width);
				}
				graphics.setColor(fontColor);
				graphics.drawText((String)lines.elementAt(i), x, liney, align, width);
			}
		}
		else {
			eq.api.String str = props.get_text();
			if(str == null) {
				str = eq.api.StringStatic.eq_api_StringStatic_for_strptr("");
			}
			if(outLineColor > 0) {
				graphics.setColor(outLineColor);
				graphics.drawText(str.to_strptr(), x + 1, y + 1, align, width);
			}
			graphics.setColor(fontColor);
			graphics.drawText(str.to_strptr(), x, y, align);
		}
		graphics.setGlobalAlpha(255);
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
		if(agraphic instanceof BBJavaImage == false) {
			return(false);
		}
		BBJavaImage img = (BBJavaImage)agraphic;
		if(vt != null) {
			graphics.setGlobalAlpha((int)(vt.get_alpha() * 255));
		}
		graphics.drawBitmap(x, y, (int)img.get_width(), (int)img.get_height(), img.get_bb_bitmap(), 0, 0);
		graphics.setGlobalAlpha(255);
		return(true);
	}

	int clips = 0;

	public boolean clip(int x, int y, eq.gui.vg.VgPath vp, eq.gui.vg.VgTransform vt) {
		boolean v = true;
		if(vp instanceof eq.gui.vg.VgPathRectangle) {
			int ax = x + vp.get_x(), ay = y + vp.get_y();
			int width = vp.get_w(), height = vp.get_h();
			graphics.pushContext(new net.rim.device.api.ui.XYRect(ax, ay, width, height), 0, 0);
			clips++;
		}
		else {
			v = false;
		}
		return(v);
	}

	public boolean clip_clear() {
		int i;
		for(i = 0; i < clips; i++) {
			graphics.popContext();
		}
		clips = 0;
		return(true);
	}

	public boolean clear(int x, int y, eq.gui.vg.VgPath vp, eq.gui.vg.VgTransform vt) {
		/*int w = vp.get_w(), h = vp.get_h();
		graphics.setGlobalAlpha(0);
		graphics.clear(x, y, w , h);
		graphics.setGlobalAlpha(255);*/
		return(false);
	}
}
