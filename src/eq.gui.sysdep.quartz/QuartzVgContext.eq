
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

public class QuartzVgContext : VgContext
{
	public static QuartzVgContext for_context(ptr context, double scalefactor) {
		return(new QuartzVgContext().set_context(context).initialize(scalefactor));
	}

	property ptr context;

	embed "objc" {{{
		#import <CoreGraphics/CGContext.h>
		#import <CoreGraphics/CGBitmapContext.h>
		#import <math.h>
		#define DegreesToRadians(degrees) (degrees * M_PI / 180)
	}}}

	public QuartzVgContext initialize(double scalefactor) {
		var cc = this.context;
		embed "c" {{{
			CGContextConcatCTM((CGContextRef)cc, CGAffineTransformMakeScale(1.0 / scalefactor, 1.0 / scalefactor));
		}}}
		return(this);
	}

	private void play_custom_path(int x, int y, VgPathCustom path) {
		var contextp = this.context;
		int sx = x + path.get_start_x(), sy = y + path.get_start_y();
		embed "c" {{{
			CGContextRef context = (CGContextRef)contextp;
			CGContextMoveToPoint(context, sx, sy);
		}}}
		foreach(VgPathElement e in path) {
			int op = e.get_operation();
			switch(op) {
				case VgPathElement.OP_LINE: {
					int lx = x + e.get_x1(), ly = y + e.get_y1();
					embed "c" {{{
						CGContextAddLineToPoint(context, lx, ly);
					}}}
				}
				case VgPathElement.OP_CURVE: {
					int x1 = x+e.get_x1(), y1 = y+e.get_y1(), x2 = x+e.get_x2(), y2 = y+e.get_y2(), x3 = x+e.get_x3(), y3 = y+e.get_y3();
					embed "c" {{{
						CGContextAddCurveToPoint(context, x1,y1, x2,y2, x3,y3);
					}}}
				}
				case VgPathElement.OP_ARC: {
					int ax = x+e.get_x1(), ay = y+e.get_y1(), radius = e.get_radius();
					double angle1 = e.get_angle1(), angle2 = e.get_angle2();
					embed "c" {{{
						CGContextAddArc(context, ax, ay, radius, angle1, angle2, 0);
					}}}
				}
			}
		}
	}

	private bool apply_path(int x, int y, VgPath vp, VgTransform vt, double adjust = 0.0) {
		bool v = true;
		var contextp = this.context;
		embed "c" {{{
			CGContextRef context = (CGContextRef)contextp;
			CGContextBeginPath(context);
		}}}
		if(vt != null) {
			double a = vt.get_alpha();
			int tx = x+vp.get_x()+(vp.get_w()/2);
			int ty = y+vp.get_y()+(vp.get_h()/2);
			double rot = vt.get_rotate_angle();
			double scale_x = (double)vt.get_scale_x();
			double scale_y = (double)vt.get_scale_y();
			embed "c" {{{
				CGContextSaveGState(context);
				CGContextTranslateCTM(context, tx, ty);
				CGContextSetAlpha(context, a);
				CGContextRotateCTM(context, DegreesToRadians(rot));
				CGContextScaleCTM(context, (float)scale_x, (float)scale_y);
				CGContextTranslateCTM(context, -tx, -ty);
			}}}
		}
		if(vp == null) {
			v = false;
		}
		else if(vp is VgPathRectangle) {
			int rx = x + vp.get_x() + adjust, ry = y + vp.get_y() + adjust,
				rw = vp.get_w() - adjust*2, rh = vp.get_h() - adjust*2;
			embed "c" {{{
				CGRect rect;
				rect.origin.x = rx;
				rect.origin.y = ry;
				rect.size.width = rw;
				rect.size.height = rh;
				CGContextAddRect(context, rect);
			}}}
		}
		else if(vp is VgPathRoundedRectangle) {
			int aa = 0, ab = 0;
			if(adjust != 0.0) {
				aa = (int)Math.rint(adjust);
				ab = (int)Math.rint(adjust*2);
				if(adjust > 0.0 && aa < 1) {
					aa = 1;
					ab = 2;
				}
			}
 			int rx = x + vp.get_x() + aa, ry = y + vp.get_y() + aa,
				rw = vp.get_w() - ab, rh = vp.get_h() - ab;
			int radius = ((VgPathRoundedRectangle)vp).get_radius();
			embed "c" {{{
				CGRect rect;
				rect.origin.x = rx;
				rect.origin.y = ry;
				rect.size.width = rw;
				rect.size.height = rh;
				CGContextMoveToPoint(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect));
				CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3 * M_PI / 2, 0, 0);
				CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0, M_PI / 2, 0);
				CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, M_PI / 2, M_PI, 0);
				CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, M_PI, 3 * M_PI / 2, 0);	
				CGContextClosePath(context);
			}}}
		}
		else if(vp is VgPathCircle) {
			var circ = (VgPathCircle)vp;
			int xc = circ.get_xc()+x, yc = circ.get_yc()+y, radius = circ.get_radius() - adjust*2;
			embed "c" {{{
				CGContextAddArc(context, xc, yc, radius, 0, M_PI * 2, 0);
			}}}
		}
		else if(vp is VgPathCustom) {
			play_custom_path(x, y, (VgPathCustom)vp);
		}
		else {
			Log.warning("ERROR: VgPath(Other)");
			v = false;
		}
		return(v);
	}

	public bool stroke(int x, int y, VgPath vp, VgTransform vt, Color c, int linewidth, int style) {
		if(c == null) {
			return(false);
		}
		if(apply_path(x, y, vp, vt, (double)linewidth / 2.0) == false) {
			return(false);
		}
		if(style != 0) {
			Log.warning("FIXME: Line styles not implemented.");
		}
		var contextp = this.context;
		double cr = c.get_r(), cg = c.get_g(), cb = c.get_b(), ca = c.get_a();
		embed "c" {{{
			CGContextRef context = (CGContextRef)contextp;
			CGContextSetLineWidth(context, linewidth);
			CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
			CGFloat components[] = { cr, cg, cb, ca };
			CGColorRef color = CGColorCreate(colorspace, components);
			CGContextSetStrokeColorWithColor(context, color);
			CGContextStrokePath(context);
			CGColorSpaceRelease(colorspace);
			CGColorRelease(color);
		}}}
		if(vt!=null) {
			embed "c" {{{
				CGContextRestoreGState(context);
			}}}
		}
		return(true);
	}

	public bool clear(int x, int y, VgPath vp, VgTransform vt) {
		if(vp == null || vp is VgPathRectangle == false) {
			return(false);
		}
		var rr = (VgPathRectangle)vp;
		int _x = rr.get_x(), _y = rr.get_y(), _w = rr.get_w(), _h = rr.get_h();
		var contextp = this.context;
		embed "c" {{{
			CGContextRef context = (CGContextRef)contextp;
			CGRect rect;
			rect.origin.x = _x;
			rect.origin.y = _y;
			rect.size.width = _w;
			rect.size.height = _h;
			CGContextClearRect(context, rect);
		}}}
		return(false);
	}

	public bool fill_color(int x, int y, VgPath vp, VgTransform vt, Color c) {
		if(vp is VgPathRectangle == false) {
			if(apply_path(x, y, vp, vt) == false) {
				return(false);
			}
		}
		var contextp = this.context;
		double cr = c.get_r(), cg = c.get_g(), cb = c.get_b(), ca = c.get_a();
		embed "c" {{{
			CGContextRef context = (CGContextRef)contextp;
			CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
			CGFloat components[] = { cr, cg, cb, ca };
			CGColorRef color = CGColorCreate(colorspace, components);
			CGContextSetFillColorWithColor(context, color);
		}}}
		if(vp is VgPathRectangle) {
			int rx = x + ((VgPathRectangle)vp).get_x(), ry = y + ((VgPathRectangle)vp).get_y(),
				rw = ((VgPathRectangle)vp).get_w(), rh = ((VgPathRectangle)vp).get_h();
			embed "c" {{{
				CGContextFillRect(context, CGRectMake(rx,ry,rw,rh));
			}}}
		}
		else {
			embed "c" {{{
				CGContextFillPath(context);
			}}}
		}
		embed "c" {{{
			CGColorSpaceRelease(colorspace);
			CGColorRelease(color);
		}}}
		if(vt!=null) {
			embed "c" {{{
				CGContextRestoreGState(context);
			}}}
		}
		return(true);
	}

	private bool fill_linear_gradient(int sx, int sy, int ex, int ey, Color a, Color b) {
		double ar = a.get_r(), ag = a.get_g(), ab = a.get_b(), aa = a.get_a(),
			br = b.get_r(), bg = b.get_g(), bb = b.get_b(), ba = b.get_a();
		var contextp = this.context;
		embed "c" {{{
			CGContextRef context = (CGContextRef)contextp;
			CGGradientRef myGradient;
			CGColorSpaceRef myColorSpace;
			CGFloat locationList[] = { 0.0, 1.0 };
			size_t locationCount = 2;
			CGFloat colorList[] = {
				(float)ar, (float)ag, (float)ab, (float)aa,
				(float)br, (float)bg, (float)bb, (float)ba
			};
			myColorSpace = CGColorSpaceCreateDeviceRGB();
			myGradient = CGGradientCreateWithColorComponents(myColorSpace, colorList,
				locationList, locationCount);
			CGPoint startPoint, endPoint;
			startPoint.x = sx;
			startPoint.y = sy;
			endPoint.x = ex;
			endPoint.y = ey;
			CGContextDrawLinearGradient(context, myGradient, startPoint, endPoint, 0);
			CGGradientRelease(myGradient);
		}}}
		return(true);
	}

	private void clip_to_path() {
		var contextp = this.context;
		embed "c" {{{
			CGContextSaveGState((CGContextRef)contextp);
			CGContextClip((CGContextRef)contextp);
		}}}
	}

	private void undo_clip() {
		var contextp = this.context;
		embed "c" {{{
			CGContextRestoreGState((CGContextRef)contextp);
		}}}
	}

	public bool fill_vertical_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b) {
		if(apply_path(x, y, vp, vt) == false) {
			return(false);
		}
		clip_to_path();
		fill_linear_gradient(
			x + vp.get_x(),
			y + vp.get_y(),
			x + vp.get_x(),
			y + vp.get_y() + vp.get_h(),
			a, b);
		undo_clip();
		if(vt!=null) {
			var contextp = this.context;
			embed "c" {{{					
				CGContextRestoreGState((CGContextRef)contextp);
			}}}
		}
		return(true);
	}

	public bool fill_horizontal_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b) {
		if(apply_path(x, y, vp, vt) == false) {
			return(false);
		}
		clip_to_path();
		fill_linear_gradient(
			x + vp.get_x(),
			y + vp.get_y(),
			x + vp.get_x() + vp.get_w(),
			y + vp.get_y(),
			a, b);
		undo_clip();
		if(vt!=null) {
			var contextp = this.context;
			embed "c" {{{					
				CGContextRestoreGState((CGContextRef)contextp);
			}}}
		}
		return(true);
	}

	public bool fill_radial_gradient(int x, int y, VgPath vp, VgTransform vt, int radius, Color a, Color b) {
		if(apply_path(x, y, vp, vt) == false) {
			return(false);
		}
		clip_to_path();
		var contextp = this.context;
		double ar = a.get_r(), ag = a.get_g(), ab = a.get_b(), aa = a.get_a(),
			br = b.get_r(), bg = b.get_g(), bb = b.get_b(), ba = b.get_a();
		double r = (double)radius;
		int w = vp.get_w(), h = vp.get_h(), xx = vp.get_x(), yy = vp.get_y();
		embed "c" {{{
			CGContextRef context = (CGContextRef)contextp;
			CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();				
			CGFloat locationList[] = { 0.0, 1.0 };
			CGFloat colorList[] = {
				(float)ar, (float)ag, (float)ab, (float)aa,
				(float)br, (float)bg, (float)bb, (float)ba
			};
			size_t locationCount = 2;
			CGGradientRef myGradient = CGGradientCreateWithColorComponents(myColorSpace, colorList,
				locationList, locationCount);
			CGPoint startPoint = CGPointMake(x+xx+(w/2),y+yy+(h/2));
			CGPoint endPoint = CGPointMake(x+yy+(w/2), y+yy+(h/2));
			CGContextDrawRadialGradient(context, myGradient, startPoint, 0.0, endPoint, (float)radius, kCGGradientDrawsAfterEndLocation);
			CGGradientRelease(myGradient);
		}}}
		undo_clip();
		if(vt!=null) {
			embed "c" {{{					
				CGContextRestoreGState((CGContextRef)contextp);
			}}}
		}
		return(true);
	}

	public bool fill_diagonal_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b, int direction) {
		if(vp == null || a == null || b == null) {
			return(false);
		}
		var cp = this.context;
		double ar = a.get_r(), ag = a.get_g(), ab = a.get_b(), aa = a.get_a(),
			br = b.get_r(), bg = b.get_g(), bb = b.get_b(), ba = b.get_a();
		int xx = vp.get_x(), yy = vp.get_y(), w = vp.get_w(), h = vp.get_h();
		double al = 1.0;
		if(vt != null) {
			al = vt.get_alpha();
		}
		embed "c" {{{
			CGContextRef context = (CGContextRef)cp;
			CGContextSetAlpha(context, (float)al);
		}}}
		if(vt!=null) {
			int tx = x+vp.get_x()+(vp.get_w()/2);
			int ty = y+vp.get_y()+(vp.get_h()/2);
			double rot = vt.get_rotate_angle();
			double scale_x = (double)vt.get_scale_x();
			double scale_y = (double)vt.get_scale_y();
			embed "c" {{{
				CGContextSaveGState(context);
   				CGContextTranslateCTM(context, tx, ty);
   				CGContextRotateCTM(context, DegreesToRadians(rot));
   				CGContextScaleCTM(context, (float)scale_x, (float)scale_y);
   				CGContextTranslateCTM(context, -tx, -ty);
			}}}
		}
		embed "c" {{{
			size_t locationCount = 2;
			CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
			CGFloat locations[] = { 0.0, 1.0 };
			CGFloat colorList[] = {
				(float)ar, (float)ag, (float)ab, (float)aa,
				(float)br, (float)bg, (float)bb, (float)ba
			};
			CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colorList,
				locations, locationCount);
			int _x = x+xx, _y = y+yy;
			CGRect rect = CGRectMake(_x,_y,w,h);
			CGPoint startPoint = CGPointMake(_x,_y);
			CGPoint endPoint = CGPointMake(_x+w,_y+h);
			CGContextSaveGState(context);
			CGContextAddRect(context, rect);
			CGContextClip(context);
			CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
			CGContextRestoreGState(context);
			CGGradientRelease(gradient);
			CGColorSpaceRelease(colorSpace);
		}}}
		if(vt!=null) {
			embed "c" {{{					
				CGContextRestoreGState((CGContextRef)cp);
			}}}
		}
		return(true);
	}

	public bool draw_text(int ax, int y, VgTransform vt, TextLayout text) {
		if(text == null) {
			return(false);
		}
		var x = ax;
		var props = text.get_text_properties();
		if(props != null && props.get_alignment() == 1) {
			x -= (text.get_width() / 2);
		}
		if(text is ImageTextLayout && ((ImageTextLayout)text).is_image_prepared()) {
			return(draw_graphic(x, y, vt, ((ImageTextLayout)text).get_image()));
		}
		if(text is QuartzContextTextLayout) {
			// FIXME: Transform is ignored here
			((QuartzContextTextLayout)text).draw_in_context(context, x, y);
			return(true);
		}
		if(text is ImageTextLayout) {
			return(draw_graphic(x, y, vt, ((ImageTextLayout)text).get_image()));
		}
		return(false);
	}

	public bool draw_graphic(int ax, int ay, VgTransform vt, Image agraphic) {
		if(agraphic == null) {
			return(false);
		}
		var x = ax, y = ay;
		if(agraphic is CodeImage) {
			((CodeImage)agraphic).render(this, x, y, vt);
			return(true);
		}
		if(agraphic is QuartzBitmapImage) {
			var graphic = (QuartzBitmapImage)agraphic;
			var imageref = graphic.get_imageref();
			if(imageref == null) {
				return(false);
			}
			var contextp = this.context;
			embed "c" {{{
				CGContextRef context = (CGContextRef)contextp;
			}}}
			int gw = graphic.get_width(), gh = graphic.get_height();
			double a = 1.0, rot = 0.0, scale_x = 1.0, scale_y = 1.0;
			if(vt != null) {
				a = vt.get_alpha();
				rot = vt.get_rotate_angle();
				scale_x = vt.get_scale_x();
				scale_y = vt.get_scale_y();
			}
			if(a != 1.0) {
				embed "c" {{{
					CGContextSetAlpha(context, a);
				}}}
			}
			if(rot != 0.0) {
				embed "c" {{{
					CGContextSaveGState(context);
				}}}
			}
			if(vt != null && vt.get_flip_horizontal()) {
				// FIXME: Support vertical flipping also; and support the flips also in non-bitmap drawings
				embed "c" {{{
					CGContextTranslateCTM(context, gw, 0.0f);
					CGContextScaleCTM(context, -1.0f, 1.0f);
				}}}
			}
			if(rot != 0.0) {
				Log.debug("Rotation is not supported in the Quartz backend.");
			}
			if(scale_x != 1.0 || scale_y != 1.0) {
				var ngw = (int)(gw * scale_x);
				var ngh = (int)(gh * scale_y);
				x = x + (gw-ngw)/2;
				y = y + (gh-ngh)/2;
				gw = ngw;
				gh = ngh;
			}
			embed "c" {{{
				CGContextDrawImage((CGContextRef)contextp, CGRectMake(x,y,gw,gh), (CGImageRef)imageref);
			}}}
			if(a != 1.0) {
				embed "c" {{{
					CGContextSetAlpha(context, 1.0);
				}}}
			}
			if(rot != 0.0) {
				embed "c" {{{
					CGContextRestoreGState(context);
				}}}
			}
			return(true);
		}
		return(false);
	}

	bool saved = false;

	public bool clip(int x, int y, VgPath vp, VgTransform vt) {
		if(saved == false) {
			var contextp = this.context;
			embed "c" {{{
				CGContextSaveGState((CGContextRef)contextp);
			}}}
			saved = true;
		}
		if(vp != null && vp is VgPathRectangle) {
			var vr = (VgPathRectangle)vp;
			var contextp = this.context;
			int rx = x+vr.get_x(), ry = y+vr.get_y(), rw = vr.get_w(), rh = vr.get_h();
			embed "c" {{{
				CGContextClipToRect((CGContextRef)contextp, CGRectMake(rx, ry, rw, rh));
			}}}
			return(true);
		}
		if(apply_path(x, y, vp, vt) == false) {
			return(false);
		}
		var contextp = this.context;
		embed "c" {{{
			CGContextRef context = (CGContextRef)contextp;
			CGContextClip(context);
		}}}
		return(true);
	}

	public bool clip_clear() {
		if(saved) {
			var contextp = this.context;
			embed "c" {{{
				CGContextRestoreGState((CGContextRef)contextp);
			}}}
			saved = false;
		}
		return(true);
	}

	public Rectangle get_clip() {
		var contextp = this.context;
		int x = 0, y = 0, y2 = 0, x2 = 0;
		embed "c" {{{
			CGContextRef context = (CGContextRef)contextp;
			CGRect rect = CGContextGetClipBoundingBox(context);
			x = rect.origin.x;
			y = rect.origin.y;
			x2 = rect.size.width;
			y2 = rect.size.height;
		}}}
		return(Rectangle.instance(x, y, x2, y2));
	}
}
