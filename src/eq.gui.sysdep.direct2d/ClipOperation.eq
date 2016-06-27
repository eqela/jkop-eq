
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

class ClipOperation
{
	embed "c++" {{{
		#include <d2d1.h>
	}}}

	Stack clip_stack;
	ptr target;
	ptr factory;

	public static ClipOperation create(ptr target, ptr factory) {
		var v = new ClipOperation();
		v.clip_stack = Stack.create();
		v.target = target;
		v.factory = factory;
		return(v);
	}

	public bool push_clip(int x, int y, VgPath vp, VgTransform vt) {
		if(vp is VgPathRectangle) {
			return(push_aligned_axis(x, y, (VgPathRectangle)vp, vt));
		}
		else {
			return(push_geometry_layer(x, y, vp, vt));
		}
		return(false);
	}

	public bool pop_clip() {
		var vp = clip_stack.pop();
		if(vp == null) {
			return(false);
		}
		ptr target = this.target;
		if(vp is VgPathRectangle) {
			embed "c++" {{{
				((ID2D1RenderTarget*)target)->PopAxisAlignedClip();
			}}}
		}
		else {
			embed "c++" {{{
				((ID2D1RenderTarget*)target)->PopLayer();
			}}}
		}
		return(true);
	}

	public bool clear() {
		while(pop_clip()) {}
		return(false);
	}

	bool push_aligned_axis(int x, int y, VgPathRectangle vp, VgTransform vt) {
		bool v = false;
		ptr target = this.target;
		int ax = x + vp.get_x(), ay = y + vp.get_y();
		int width = vp.get_w(), height = vp.get_h();
		embed "c++" {{{
			((ID2D1RenderTarget*)target)->SetTransform(D2D1::Matrix3x2F::Identity());
			((ID2D1RenderTarget*)target)->PushAxisAlignedClip(
				D2D1::RectF(ax, ay, ax+width, ay+height),
				D2D1_ANTIALIAS_MODE_PER_PRIMITIVE
			);
			v = 1;
		}}}
		if(v) {
			clip_stack.push(vp);
		}
		return(v);
	}

	bool push_geometry_layer(int x, int y, VgPath vp, VgTransform vt) {
		bool v = false;
		ptr geometry = null;
		ptr target = this.target;
		ptr factory = this.factory;
		if(vp is VgPathRoundedRectangle) {
			int ax = x + vp.get_x(), ay = y + vp.get_y();
			int width = vp.get_w(), height = vp.get_h();
			int radius = ((VgPathRoundedRectangle)vp).get_radius();
			embed "c++" {{{
				((ID2D1Factory*)factory)->CreateRoundedRectangleGeometry(D2D1::RoundedRect(
					D2D1::RectF(ax, ay, ax+width, ay+height), radius, radius),
					(ID2D1RoundedRectangleGeometry**)&geometry
				);
			}}}
		}
		else if(vp is VgPathCircle) {
			var vpc = (VgPathCircle)vp;
			int xc = x+vpc.get_xc(), yc = y+vpc.get_yc();
			int radius = vpc.get_radius();
			embed "c++" {{{
				((ID2D1Factory*)factory)->CreateEllipseGeometry(
					D2D1::Ellipse(D2D1::Point2F(xc, yc), radius, radius),
					(ID2D1EllipseGeometry**)&geometry
				);
			}}}
		}
		else if(vp is VgPathCustom) {
			var custom = (VgPathCustom)vp;
			int sx = custom.get_start_x()+x, sy = custom.get_start_y()+y;
			embed "c++" {{{
				ID2D1GeometrySink* sink;
				((ID2D1Factory*)factory)->CreatePathGeometry((ID2D1PathGeometry**)&geometry);
				((ID2D1PathGeometry*)geometry)->Open(&sink);
				sink->BeginFigure(D2D1::Point2F(sx, sy), D2D1_FIGURE_BEGIN_FILLED);
			}}}
			foreach(VgPathElement e in custom.iterate()) {
				if(e.get_operation() == VgPathElement.OP_LINE) {
					int x1 = x+e.get_x1(), y1 = y+e.get_y1();
					embed "c++" {{{
						sink->AddLine(D2D1::Point2F(x1, y1));
					}}}
				}
				else if(e.get_operation() == VgPathElement.OP_CURVE) {
					int x1 = x+e.get_x1(), y1 = y+e.get_y1();
					int x2 = x+e.get_x2(), y2 = y+e.get_y2();
					int x3 = x+e.get_x3(), y3 = y+e.get_y3();
					embed "c++" {{{
						sink->AddBezier(D2D1::BezierSegment(
							D2D1::Point2F(x1, y1),
							D2D1::Point2F(x2, y2),
							D2D1::Point2F(x3, y3)
						));
					}}}
				}
				else if(e.get_operation() == VgPathElement.OP_ARC) {
					int x1 = x+e.get_x1(), y1 = y+e.get_y1();
					double sangle = e.get_angle1(), tangle = e.get_angle2();
					int radius = e.get_radius();
					double inix = (Math.cos(sangle) * radius) + x1;
					double iniy = (Math.sin(sangle) * radius) + y1;
					double termix = (Math.cos(tangle) * radius) + x1;
					double termiy = (Math.sin(tangle) * radius) + y1;
					double a1 = (sangle/MathConstant.M_PI*180), a2 = (tangle/MathConstant.M_PI*180);
					embed "c++" {{{
						sink->AddLine(D2D1::Point2F(inix, iniy));
						sink->AddArc(D2D1::ArcSegment(
							D2D1::Point2F(termix, termiy),
							D2D1::SizeF(radius, radius),
							tangle,
							D2D1_SWEEP_DIRECTION_CLOCKWISE,
							D2D1_ARC_SIZE_SMALL
						));
					}}}
				}
				else {
					Log.error("Invalid custom path operation");
				}
			}
			embed "c++" {{{
				sink->EndFigure(D2D1_FIGURE_END_OPEN);
				sink->Close();
				sink->Release();
			}}}
		}
		embed "c++" {{{
			if(geometry) {
				((ID2D1RenderTarget*)target)->SetTransform(D2D1::Matrix3x2F::Identity());
				ID2D1Layer* layer;
				((ID2D1RenderTarget*)target)->CreateLayer(NULL, &layer);
				((ID2D1RenderTarget*)target)->PushLayer(D2D1::LayerParameters(D2D1::InfiniteRect(), (ID2D1Geometry*)geometry), layer);
				((ID2D1Geometry*)geometry)->Release();
				layer->Release();
				v = 1;
			}
		}}}
		if(v) {
			clip_stack.push(vp);
		}
		return(v);
	}
}
