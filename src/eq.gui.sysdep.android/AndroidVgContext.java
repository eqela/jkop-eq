
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

import eq.gui.vg.*;
import eq.gui.*;

public class AndroidVgContext implements VgContext
{
	private android.graphics.Canvas canvas = null;
	boolean saved = false;

	public AndroidVgContext(android.graphics.Canvas canvas) {
		this.canvas = canvas;
	}

	private static int to_android_color(eq.gui.Color c) {
		if(c == null) {
			return(0);
		}
		return(android.graphics.Color.argb((int)(c.get_a() * 255), (int)(c.get_r() * 255), (int)(c.get_g() * 255), (int)(c.get_b() * 255)));
	}

	private android.graphics.Path apply_path(int x, int y, VgPath vp, VgTransform vt, int xadj, int yadj) {
		if(vp == null) {
			return(null);
		}
		android.graphics.Path v = new android.graphics.Path();
		float pivot_x = (float)0.0;
		float pivot_y = (float)0.0;
		if(vp instanceof VgPathRectangle) {
			VgPathRectangle vpr = (VgPathRectangle)vp;
			float left = x+vpr.get_x();
			float top = y+vpr.get_y();
			float right = left+vpr.get_w()+xadj;
			float bottom = top+vpr.get_h()+yadj;
			pivot_x = left + (vpr.get_w()/2);
			pivot_y = top + (vpr.get_h()/2);
			v.addRect(left, top, right, bottom, android.graphics.Path.Direction.CW);
		}
		else if(vp instanceof VgPathRoundedRectangle) {
			VgPathRoundedRectangle vpr = (VgPathRoundedRectangle)vp;
			float left = x+vpr.get_x();
			float top = y+vpr.get_y();
			float right = left+vpr.get_w()+xadj;
			float bottom = top+vpr.get_h()+yadj;
			float rad = (float)vpr.get_radius();
			pivot_x = left + (vpr.get_w()/2);
			pivot_y = top + (vpr.get_h()/2);
			v.addRoundRect(new android.graphics.RectF(left, top, right, bottom), rad, rad, android.graphics.Path.Direction.CW);
		}
		else if(vp instanceof VgPathCircle) {
			VgPathCircle c = (VgPathCircle)vp;
			pivot_x = x+c.get_xc();
			pivot_y = y+c.get_yc();
			v.addCircle((float)(x+c.get_xc()), (float)(y+c.get_yc()), (float)c.get_radius(), android.graphics.Path.Direction.CW);
		}
		else if(vp instanceof VgPathCustom) {
			VgPathCustom pc = (VgPathCustom)vp;
			v.moveTo((float)x+(float)pc.get_start_x(), (float)y+(float)pc.get_start_y());
			eq.api.Iterator it = ((eq.api.Iterateable)pc).iterate();
			float low_x = (float)x+(float)pc.get_start_x();
			float high_x = (float)low_x;
			float low_y = (float)y+(float)pc.get_start_y();
			float high_y = (float)low_y;
			while(it != null) {
				VgPathElement e = (VgPathElement)it.next();
				if(e == null) {
					break;
				}
				int op = e.get_operation();
				if(op == VgPathElement.Static.OP_LINE) {
					float x1 = (float)(x+e.get_x1()), y1 = (float)(y+e.get_y1());
					if(x1 < low_x) {
						low_x = x1;
					}
					else if(x1 > high_x) {
						high_x = x1;
					}
					if(y1 < low_y) {
						low_y = y1;
					}
					else if(y1 > high_y) {
						high_y = y1;
					}
					v.lineTo(x1, y1);
				}
				else if(op == VgPathElement.Static.OP_CURVE) {
					float x1 = (float)(x+e.get_x1()), y1 = (float)(y+e.get_y1());
					float x2 = (float)(x+e.get_x2()), y2 = (float)(y+e.get_y2());
					float x3 = (float)(x+e.get_x3()), y3 = (float)(y+e.get_y3());
					if(x1 < low_x) {
						low_x = x1;
					}
					else if(x2 < low_x) { 
						low_x = x2;
					}
					else if(x3 < low_x) {
						low_x = x3;
					}
					else if(x1 > high_x) {
						high_x = x1;
					}
					else if(x2 > high_x) {
						high_x = x2;
					}
					else if(x3 > high_x) {
						high_x = x3;
					}
					if(y1 < low_y) {
						low_y = y1;
					}
					else if(y2 < low_y) {
						low_y = y2;
					}
					else if(y3 < low_y) {
						low_y = y3;
					}
					else if(y1 > high_y) {
						high_y = y1;
					}
					else if(y2 > high_y) {
						high_y = y2;
					}
					else if(y3 > high_y) {
						high_y = y3;
					}
					v.cubicTo(x1, y1, x2, y2, x3, y3);
				}
				else if(op == VgPathElement.Static.OP_ARC) {
					float left = (float)(x + e.get_x1() - e.get_radius());
					float top = (float)(y + e.get_y1() - e.get_radius());
					float right = (float)(x + e.get_x1() + e.get_radius());
					float bottom = (float)(y + e.get_y1() + e.get_radius());	
					float a1 = (float)(e.get_angle1() * 180.0 / java.lang.Math.PI);
					float a2 = (float)(e.get_angle2() * 180.0 / java.lang.Math.PI);
					int adiff = (int)(a1 - a2);
					if(adiff < 0) {
						adiff = (int)(a2 - a1);
					}
					while(a1 < 0) {
						a1 += 360.0;
					}
					while(a1 >= 360.0) {
						a1 -= 360.0;
					}
					if(left < low_x) {
						low_x = left;
					}
					else if(left > high_x) {
						high_x = left;
					}
					if(top < low_y) {
						low_y = top;
					}
					else if(top > high_y) {
						high_y = top;
					}
					v.arcTo(new android.graphics.RectF(left, top, right, bottom), a1, adiff);
					if(adiff % 360 == 0) {								
						v.addCircle((float)(x+e.get_x1()), (float)(y+e.get_y1()), (float)e.get_radius(), android.graphics.Path.Direction.CW);
						float tpx = (float)((Math.cos((float)e.get_angle1()) * e.get_radius()) + x+e.get_x1());
						float tpy = (float)((Math.sin((float)e.get_angle1()) * e.get_radius()) + y+e.get_y1());
						v.moveTo(tpx, tpy);
					}
				}
				else {
					eq.api.Log.Static.error((eq.api.Object)eq.api.String.Static.for_strptr("Unknown path element encountered."), null, null);
				}
			}
			pivot_x = (float)low_x + ((high_x-low_x) /2);
			pivot_y = (float)low_y + ((high_y-low_y) /2);
		}
		else {
			eq.api.Log.Static.error((eq.api.Object)eq.api.String.Static.for_strptr("Unknown path type encountered."), null, null);
		}
		if(vt != null) {
			float scale_x = (float)vt.get_scale_x();
			float scale_y = (float)vt.get_scale_y();
			canvas.save();
			float rang = (float)vt.get_rotate_angle();
			if(rang != 0.0) {
				canvas.rotate(rang, pivot_x, pivot_y);
			}
			if(scale_x != 1.0 || scale_y != 1.0) {
				canvas.scale(scale_x, scale_y, pivot_x, pivot_y);
			}
		}
		return(v);
	}

	public boolean stroke(int x, int y, VgPath vp, VgTransform vt, Color c, int linewidth, int style) {
		if(vp instanceof VgPathCircle) {
			VgPathCircle vpc = (VgPathCircle)vp;
			int current = vpc.get_radius();
			vpc.set_radius(current - linewidth);
			vp = vpc;
		}
		android.graphics.Path path = apply_path(x, y, vp, vt, 0, 0); //-1, -1);
		if(path == null) {
			return(false);
		}
		if(style != 0) {
			eq.api.Log.Static.warning((eq.api.Object)eq.api.String.Static.for_strptr("Stroke style not implemented."), null, null); // FIXME
		}
		double alpha = 1.0;
		if(vt != null) {
			alpha = vt.get_alpha();
		}
		android.graphics.Paint paint = new android.graphics.Paint();
		paint.setAntiAlias(true);
		paint.setARGB((int)(c.get_a() * alpha * 255), (int)(c.get_r() * 255), (int)(c.get_g() * 255), (int)(c.get_b() * 255));
		paint.setStrokeWidth(linewidth);
		paint.setStyle(android.graphics.Paint.Style.STROKE);
		canvas.drawPath(path, paint);
		if(vt != null) {
			canvas.restore();
		}
		return(true);
	}

	public boolean clear(int x, int y, VgPath vp, VgTransform vt) {
		if(vp == null || vp instanceof VgPathRectangle == false) {
			return(false);
		}
		VgPathRectangle vpr = (VgPathRectangle)vp;
		android.graphics.Paint paint = new android.graphics.Paint();
		paint.setColor(android.graphics.Color.TRANSPARENT);
		canvas.drawRect(x+vpr.get_x(), y+vpr.get_y(), x+vpr.get_x()+vpr.get_w(), y+vpr.get_y()+vpr.get_h(), paint);
		return(true);
	}

	public boolean fill_color(int x, int y, VgPath vp, VgTransform vt, Color c) {
		android.graphics.Path path = apply_path(x, y, vp, vt, 0, 0);
		if(path == null) {
			return(false);
		}
		double alpha = 1.0;
		if(vt != null) {
			alpha = vt.get_alpha();
		}
		android.graphics.Paint paint = new android.graphics.Paint();
		paint.setAntiAlias(true);
		paint.setARGB((int)(c.get_a() * alpha * 255), (int)(c.get_r() * 255), (int)(c.get_g() * 255), (int)(c.get_b() * 255));
		canvas.drawPath(path, paint);
		if(vt!=null) {
			canvas.restore();
		}
		return(true);
	}

	public boolean fill_vertical_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b) {
		android.graphics.Path path = apply_path(x, y, vp, vt, 0, 0);
		if(path == null) {
			return(false);
		}
		android.graphics.Paint paint = new android.graphics.Paint();
		paint.setAntiAlias(true);
		android.graphics.LinearGradient gr = new android.graphics.LinearGradient(
			x+vp.get_x(),
			y+vp.get_y(),
			x+vp.get_x(),
			y+vp.get_y()+vp.get_h(),
			to_android_color(a),
			to_android_color(b),
			android.graphics.Shader.TileMode.MIRROR);
		paint.setShader(gr);
		if(vt != null) {
			double alpha = vt.get_alpha();
			if(alpha < 1.0) {
				paint.setAlpha((int)(alpha * 255));
			}
		}
		canvas.drawPath(path, paint);
		if(vt!=null) {
			canvas.restore();
		}
		return(true);
	}

	public boolean fill_horizontal_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b) {
		android.graphics.Path path = apply_path(x, y, vp, vt, 0, 0);
		if(path == null) {
			return(false);
		}
		android.graphics.Paint paint = new android.graphics.Paint();
		paint.setAntiAlias(true);
		android.graphics.LinearGradient gr = new android.graphics.LinearGradient(
			x+vp.get_x(),
			y+vp.get_y(),
			x+vp.get_x()+vp.get_w(),
			y+vp.get_y(),
			to_android_color(a),
			to_android_color(b),
			android.graphics.Shader.TileMode.MIRROR);
		paint.setShader(gr);
		if(vt != null) {
			double alpha = vt.get_alpha();
			if(alpha < 1.0) {
				paint.setAlpha((int)(alpha * 255));
			}
		}
		canvas.drawPath(path, paint);
		if(vt != null) {
			canvas.restore();
		}
		return(true);
	}

	public boolean fill_radial_gradient(int x, int y, VgPath vp, VgTransform vt, int radius, Color a, Color b) {
		if(radius < 1) {
			return(true);
		}
		android.graphics.Paint paint = new android.graphics.Paint();
		paint.setAntiAlias(true);
		android.graphics.RadialGradient gr = new android.graphics.RadialGradient(
			x+vp.get_x()+(vp.get_w() / 2),
			y+vp.get_y()+(vp.get_h() / 2),
			radius,
			to_android_color(a),
			to_android_color(b),
			android.graphics.Shader.TileMode.CLAMP);
		paint.setShader(gr);
		if(vt != null) {
			double alpha = vt.get_alpha();
			if(alpha < 1.0) {
				paint.setAlpha((int)(alpha * 255));
			}
		}
		if(vp instanceof VgPathRectangle) {
			VgPathRectangle rr = (VgPathRectangle)vp;
			canvas.drawRect((float)(x+rr.get_x()), (float)(y+rr.get_y()), (float)(x+rr.get_x()+rr.get_w()), (float)(y+rr.get_y()+rr.get_h()), paint);
		}
		else if(vp instanceof VgPathCircle) {
			VgPathCircle cc = (VgPathCircle)vp;
			canvas.drawCircle((float)x+(float)cc.get_xc(), (float)y+(float)cc.get_yc(), (float)cc.get_radius(), paint);
		}
		else {
			android.graphics.Path path = apply_path(x, y, vp, vt, 0, 0);
			if(path == null) {
				return(false);
			}
			canvas.drawPath(path, paint);
		}
		if(vt != null) {
			canvas.restore();
		}
		return(true);
	}

	public boolean fill_diagonal_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b, int direction) {
		android.graphics.Path path = apply_path(x, y, vp, vt, 0, 0);
		if(path == null) {
			return(false);
		}
		android.graphics.Paint paint = new android.graphics.Paint();
		paint.setAntiAlias(true);
		android.graphics.LinearGradient gr = new android.graphics.LinearGradient(
			x+vp.get_x(),
			y+vp.get_y(),
			x+vp.get_x()+vp.get_w(),
			y+vp.get_y()+vp.get_h(),
			to_android_color(a),
			to_android_color(b),
			android.graphics.Shader.TileMode.MIRROR);
		paint.setShader(gr);
		if(vt != null) {
			double alpha = vt.get_alpha();
			if(alpha < 1.0) {
				paint.setAlpha((int)(alpha * 255));
			}
		}
		canvas.drawPath(path, paint);
		if(vt != null) {
			canvas.restore();
		}
		return(true);
	}

	public boolean draw_text(int x, int y, VgTransform vt, TextLayout atext) {
		AndroidTextLayout text = (AndroidTextLayout)atext;
		android.text.StaticLayout layout = text.get_layout();
		android.text.StaticLayout outline = text.get_outline_layout();
		eq.gui.TextProperties props = text.get_text_properties();
		if(props.get_alignment() == 1) {
			x -= text.get_width() / 2;
		}
		canvas.save();
		if(vt!=null) {
			float pivot_x = x + (float)(text.get_width() / 2);
			float pivot_y = y + (float)(text.get_height() / 2);
			float scale_x = (float)vt.get_scale_x();
			float scale_y = (float)vt.get_scale_y();
			float rang = (float)vt.get_rotate_angle();
			if(rang != 0.0) {
				canvas.rotate(rang, pivot_x, pivot_y);
			}
			if(scale_x != 1.0 || scale_y != 1.0) {
				canvas.scale(scale_x, scale_y, pivot_x, pivot_y);
			}
		}
		canvas.translate(x, y);
		if(outline != null) {
			android.text.TextPaint paint = ((android.text.Layout)outline).getPaint();
			paint.setAntiAlias(true);
			int oa = paint.getAlpha();
			if(vt != null) {
				paint.setAlpha((int)(vt.get_alpha() * oa));
			}
			outline.draw(canvas);
			paint.setAlpha(oa);
		}
		if(layout != null) {
			android.text.TextPaint paint = ((android.text.Layout)layout).getPaint();
			paint.setAntiAlias(true);
			int oa = paint.getAlpha();
			if(vt != null) {
				paint.setAlpha((int)(vt.get_alpha() * oa));
			}
			layout.draw(canvas);
			paint.setAlpha(oa);
		}
		canvas.restore();
		return(true);
	}

	public boolean draw_graphic(int x, int y, VgTransform vt, Image agraphic) {
		if(agraphic == null) {
			return(false);
		}
		if(agraphic instanceof AndroidBitmapImage == false) {
			return(false);
		}
		AndroidBitmapImage graphic = (AndroidBitmapImage)agraphic;
		android.graphics.Bitmap abm = graphic.get_android_bitmap();
		if(abm == null) {
			return(false);
		}
		double rotate = 0.0d;
		android.graphics.Paint paint = null;
		if(vt != null) {
			paint = new android.graphics.Paint();
			paint.setFilterBitmap(true);
			paint.setAlpha((int)(vt.get_alpha() * 255));
			float scale_x = (float)vt.get_scale_x(), scale_y = (float)vt.get_scale_y();
			rotate = vt.get_rotate_angle();
			float pivot_x = x + abm.getWidth()/2;
			float pivot_y = y + abm.getHeight()/2;
			canvas.save();
			// FIXME: The pivot point for rotation is not right.
			if(rotate != 0.0) {
				canvas.rotate((float)(rotate * 180 / Math.PI), pivot_x, pivot_y);
			}
			if(scale_x != 1.0 || scale_y != 1.0) {
				canvas.scale(scale_x, scale_y, pivot_x, pivot_y);
			}
			if(vt.get_flip_horizontal()) {
			    canvas.scale(-1.0f, 1.0f);
			    canvas.translate(-abm.getWidth(), 0);
			}
		}
		canvas.drawBitmap(abm, x, y, paint);
		if(vt != null) {
			canvas.restore();
		}
		return(true);
	}

	public boolean clip(int x, int y, VgPath vp, VgTransform vt) {
		if(vt == null && vp != null && vp instanceof VgPathRectangle) {
			if(saved == false) {
				canvas.save();
				saved = true;
			}
			VgPathRectangle rr = (VgPathRectangle)vp;
			canvas.clipRect(x+rr.get_x(), y+rr.get_y(), x+rr.get_x()+rr.get_w(), y+rr.get_y()+rr.get_h());
			return(true);
		}
		android.graphics.Path path = apply_path(x, y, vp, vt, 0, 0);
		if(path == null) {
			return(false);
		}
		if(saved == false) {
			if(vt == null) { 
				canvas.save();
			}
			saved = true;
		}
		try {
			canvas.clipPath(path);
		}
		catch(Exception e) {
			return(false);
		}
		return(true);
	}

	public boolean clip_clear() {
		if(saved) {
			canvas.restore();
			saved = false;
		}
		return(true);
	}

	public eq.gui.Rectangle get_clip() {
		android.graphics.Rect rect = canvas.getClipBounds();
		if(rect == null) {
			return(eq.gui.Rectangle.Static.instance(0, 0, canvas.getWidth(), canvas.getHeight()));
		}
		return(eq.gui.Rectangle.Static.instance(rect.left, rect.top, rect.right-rect.left, rect.bottom-rect.top));
	}
}
