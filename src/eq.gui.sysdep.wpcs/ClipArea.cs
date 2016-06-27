
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

class ClipArea
{
	double x;
	double y;
	eq.gui.vg.VgPath vp;
	eq.gui.vg.VgTransform vt;

	public static ClipArea create(double x, double y, eq.gui.vg.VgPath path, eq.gui.vg.VgTransform vt) {
		if(path == null) {
			return(null);
		}
		var v = new ClipArea();
		v.x = x;
		v.y = y;
		v.vp = path;
		v.vt = vt;
		return(v);
	}
	
	public System.Windows.Media.Geometry get_clip(double nx, double ny) {
		System.Windows.Media.Geometry v = null;
		if(vp is eq.gui.vg.VgPathRectangle) {
			double aw = vp.get_w(), ah = vp.get_h();
			if(aw > 0 && ah > 0) {
				var rect = new System.Windows.Media.RectangleGeometry();
				rect.Rect = new System.Windows.Rect(x+vp.get_x()-nx, y+vp.get_y()-ny, aw, ah);
				v = rect;
			}
		}
		else if(vp is eq.gui.vg.VgPathRoundedRectangle) {
			var vpr = vp as eq.gui.vg.VgPathRoundedRectangle;
			double aw = vpr.get_w(), ah = vpr.get_h(), rd = vpr.get_radius();
			if(aw > 0 && ah > 0 && rd > 0) {
				var rrect = new System.Windows.Media.RectangleGeometry();
				rrect.Rect = new System.Windows.Rect(x+vp.get_x()-nx, y+vp.get_y()-ny, aw, ah);
				rrect.RadiusX = rd;
				rrect.RadiusY = rd;
				v = rrect;
			}
		}
		else if(vp is eq.gui.vg.VgPathCircle) {
			var vpc = vp as eq.gui.vg.VgPathCircle;
			double rd = vpc.get_radius();
			if(rd > 0) {
				var circle = new System.Windows.Media.EllipseGeometry();
				circle.Center = new System.Windows.Point(x+vpc.get_xc()-nx, y+vpc.get_yc()-ny);
				circle.RadiusX = rd;
				circle.RadiusY = rd;
				v = circle;
			}
		}
		else if(vp is eq.gui.vg.VgPathCustom) {
			var cp = vp as eq.gui.vg.VgPathCustom;
			var itr = cp.iterate();
			var pg = new System.Windows.Media.PathGeometry();
			var figure = new System.Windows.Media.PathFigure() {
				StartPoint = new System.Windows.Point(x+cp.get_start_x()-nx, y+cp.get_start_y()-ny)
			};
			while(itr!=null) {
				var vpe = itr.next() as eq.gui.vg.VgPathElement;
				if(vpe == null) {
					break;
				}
				System.Windows.Media.PathSegment segment = null;
				if(vpe.get_operation() == eq.gui.vg.VgPathElement.OP_LINE) {
					segment = new System.Windows.Media.LineSegment() {
						Point = new System.Windows.Point(x+vpe.get_x1()-nx, y+vpe.get_y1()-ny)
					};
				}
				else if(vpe.get_operation() == eq.gui.vg.VgPathElement.OP_CURVE){
					segment = new System.Windows.Media.BezierSegment() {
						Point1 = new System.Windows.Point(x+vpe.get_x1()-nx, y+vpe.get_y1()-ny),
						Point2 = new System.Windows.Point(x+vpe.get_x2()-nx, y+vpe.get_y2()-ny),
						Point3 = new System.Windows.Point(x+vpe.get_x3()-ny, y+vpe.get_y3()-ny)
					};
				}
				else if(vpe.get_operation() == eq.gui.vg.VgPathElement.OP_ARC) {
				}
				else {
					eq.api.Log.eq_api_Log_error((eq.api.Object)eq.api.StringStatic.eq_api_StringStatic_for_strptr("Unknown path element encountered."), null, null);
				}
				if(segment != null) {	
					figure.Segments.Add(segment);
				}
			}
			pg.Figures.Add(figure);
			v = pg;
		}
		if(vt != null) {
			double scx = vt.get_scale_x(), scy = vt.get_scale_y();
			double rot = vt.get_rotate_angle();
			var tg = new System.Windows.Media.TransformGroup();
			if(scx != 1.0 || scy != 1.0) {
				var st = new System.Windows.Media.ScaleTransform() { ScaleX = scx, ScaleY = scy };
				st.CenterX = v.Bounds.Width / 2;
				st.CenterY = v.Bounds.Height / 2;
				tg.Children.Add(st);
			}
			if(rot != 0.0) {
				var rt = new System.Windows.Media.RotateTransform() { Angle = rot};
				rt.CenterX = v.Bounds.Width / 2;
				rt.CenterY = v.Bounds.Height / 2;
				tg.Children.Add(rt);
			}
			if(vt.get_flip_horizontal()) {
				var fht = new System.Windows.Media.ScaleTransform() { ScaleX = -1.0, ScaleY = scy };
				fht.CenterX = v.Bounds.Width / 2;
				tg.Children.Add(fht);
			}
			v.Transform = tg; 
		}
		return(v);
	}
	
	public eq.gui.Rectangle get_clip_bounds() {
		return(eq.gui.RectangleStatic.eq_gui_RectangleStatic_instance((int)x+vp.get_x(), (int)y+vp.get_y(), (int)vp.get_w(), (int)vp.get_h()));
	}
}

