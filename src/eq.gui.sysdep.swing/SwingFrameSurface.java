
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

package eq.gui.sysdep.swing;

import eq.gui.*;

public class SwingFrameSurface extends javax.swing.JComponent implements Surface, Size, Position
{
	double scale_x = 1.0;
	double scale_y = 1.0;
	double rot_angle = 0.0;
	double width;
	double height;
	double x;
	double y;
	double alpha = 1.0;

	public double get_x() {
		return(x);
	}

	public double get_y() {
		return(y);
	}

	public double get_width() {
		return(width);
	}

	public double get_height() {
		return(height);
	}

	void update_real_bounds() {
		int w = (int)width, h = (int)height;
		int x = (int)this.x, y = (int)this.y;
		if(rot_angle != 0.0 || scale_x != 1.0 || scale_y != 1.0) {
			w = (int)(w*scale_x);
			h = (int)(h*scale_y);
			if(rot_angle != 0.0) {
				if(h > w) {
					w = h;
				}
				else {
					h = w;
				}
			}
			x = (int)(x - (w/2)+(width/2));
			y = (int)(y - (h/2)+(height/2));
		}
		java.awt.Point pt = getLocation();
		if(x != pt.x || y != pt.y) {
			setLocation(x, y);
		}
		java.awt.Dimension sz = getSize();
		if(w != sz.width || h != sz.height) {
			setSize(w, h);
		}
	}

	public void move(double x, double y) {
		this.x = x;
		this.y = y;
		update_real_bounds();
	}

	public void resize(double w, double h) {
		width = w;
		height = h;
		update_real_bounds();
	}

	public void move_resize(double x, double y, double w, double h) {
		this.x = x;
		this.y = y;
		width = w;
		height = h;
		update_real_bounds();
		repaint();
	}

	public void set_scale(double sx, double sy) {
		scale_x = sx;
		scale_y = sy;
		update_real_bounds();
		repaint();
	}

	public void set_alpha(double f) {
		alpha = f;
		repaint();
	}

	public void set_rotation_angle(double a) {
		rot_angle = a;
		update_real_bounds();
		repaint();
	}

	public double get_scale_x() {
		return(scale_x);
	}

	public double get_scale_y() {
		return(scale_y);
	}

	public double get_alpha() {
		return(alpha);
	}

	public double get_rotation_angle() {
		return(rot_angle);
	}

	public void do_paint(java.awt.Graphics2D g) {
		
	}
	
	public void paintComponent(java.awt.Graphics g) {
		if(g instanceof java.awt.Graphics2D) {
			java.awt.Graphics2D gd = (java.awt.Graphics2D)g.create();
			super.paintComponent(gd);
			double sx = scale_x, sy = scale_y;
			double rot = rot_angle;
			if(alpha < 1.0) {
				java.awt.Composite atrans = java.awt.AlphaComposite.getInstance(java.awt.AlphaComposite.SRC_OVER, (float)alpha);
				gd.setComposite(atrans);
			}
			if(rot != 0.0 || sx != 1.0 || sy != 1.0) {
				java.awt.geom.AffineTransform trans = new java.awt.geom.AffineTransform();
				java.awt.Dimension sz = getSize();
				double w2 = sz.width/2-get_width()/2, h2 = sz.height/2-get_height()/2;
				java.awt.geom.AffineTransform save = gd.getTransform();
				trans.translate(w2,h2);
				trans.translate(get_width()/2, get_height()/2);
				trans.rotate(rot);
				trans.scale(sx, sy);
				trans.translate(-get_width()/2, -get_height()/2);
				gd.transform(trans);
				do_paint(gd);
				gd.setTransform(save);
			}
			else {
				do_paint(gd);
			}
		}
	}
}
