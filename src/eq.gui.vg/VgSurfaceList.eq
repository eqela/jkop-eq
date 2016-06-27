
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

public class VgSurfaceList
{
	property VgSurface parent;
	VgSurface child;

	public void set_child(VgSurface c) {
		if(child != null && c == null) {
			child.set_container(null);
		}
		child = c;
		if(child != null) {
			child.set_container(this);
		}
	}

	public VgSurface get_child() {
		return(child);
	}

	VgPathRectangle play_clips(VgContext context, Stack clips) {
		int cx1,cy1,cx2,cy2;
		context.clip_clear();
		foreach(VgPathRectangle r in clips) {
			context.clip(0, 0, r, null);
			if(cx1 < 0 || r.get_x() < cx1) {
				cx1 = r.get_x();
			}
			if(cy1 < 0 || r.get_y() < cy1) {
				cy1 = r.get_y();
			}
			if(cx2 < 0 || r.get_x()+r.get_w() > cx2) {
				cx2 = r.get_x()+r.get_w();
			}
			if(cy2 < 0 || r.get_y()+r.get_h() > cy2) {
				cy2 = r.get_y()+r.get_h();
			}
		}
		return(VgPathRectangle.create(cx1,cy1,cx2-cx1,cy2-cy1));
	}

	public void draw(VgContext context, int x, int y, int w, int h, Stack clips) {
		var ss = child;
		while(ss != null) {
			var ssx = ss.get_x(), ssy = ss.get_y(), ssw = ss.get_width(), ssh = ss.get_height();
			var da = ss.get_dirty_area();
			if(da != null) {
				var dx = da.get_x(), dy = da.get_y(), dw = da.get_width(), dh = da.get_height();
				if(dx+dw < x || dy+dh < y || dx >= x+w || dy >= y+h) {
					ss = ss.get_next();
					continue;
				}
			}
			else if(ssx+ssw < x || ssy+ssh < y || ssx >= x+w || ssy >= y+h) {
				ss = ss.get_next();
				continue;
			}
			ss.draw_in_context(context, ssx, ssy);
			var cc = ss.get_child();
			if(cc != null) {
				clips.push(VgPathRectangle.create(ss.get_x(), ss.get_y(), ss.get_width(), ss.get_height()));
				var rr = play_clips(context, clips);
				cc.draw(context, rr.get_x(), rr.get_y(), rr.get_w(), rr.get_h(), clips);
				clips.pop();
				play_clips(context, clips);
			}
			ss = ss.get_next();
		}
	}

	public Surface add_surface_top(VgSurface v) {
		if(v == null) {
			return(null);
		}
		if(child == null) {
			set_child(v);
			v.set_next(null);
			v.set_prev(this);
		}
		else {
			var ss = child;
			while(ss.get_next() != null) {
				ss = ss.get_next();
			}
			ss.set_next(v);
			v.set_prev(ss);
			v.set_next(null);
		}
		return(v);
	}

	public Surface add_surface_bottom(VgSurface v) {
		if(v == null) {
			return(null);
		}
		if(child != null) {
			child.set_prev(v);
		}
		v.set_next(child);
		v.set_prev(this);
		set_child(v);
		return(v);
	}

	public Surface add_surface_above(VgSurface ssv, VgSurface v) {
		if(v == null) {
			return(null);
		}
		if(ssv == null) {
			return(add_surface_top(v));
		}
		var next = ssv.get_next();
		v.set_next(next);
		if(next != null) {
			next.set_prev(v);
		}
		v.set_prev(ssv);
		ssv.set_next(v);
		v.set_container(ssv.get_container());
		return(v);
	}

	public Surface add_surface_below(VgSurface ssv, VgSurface v) {
		if(v == null) {
			return(null);
		}
		if(ssv == null) {
			return(add_surface_bottom(v));
		}
		var prev = ssv.get_prev();
		v.set_prev(prev);
		if(prev != null) {
			if(prev is VgSurface) {
				((VgSurface)prev).set_next(v);
			}
		}
		v.set_next(ssv);
		ssv.set_prev(v);
		if(v.get_prev() is VgSurfaceList) {
			((VgSurfaceList)v.get_prev()).set_child(v);
		}
		v.set_container(ssv.get_container());
		return(v);
	}

	public Surface add_surface_inside(VgSurface ssv, VgSurface v) {
		if(v == null) {
			return(null);
		}
		if(ssv == null) {
			return(add_surface_above(ssv, v));
		}
		var cc = ssv.get_child();
		if(cc == null) {
			cc = new VgSurfaceList();
			ssv.set_child(cc);
		}
		return(cc.add_surface_bottom(v));
	}

	public void remove_surface(VgSurface ssv) {
		if(ssv == null) {
			return;
		}
		ssv.invalidate_all();
		var ssvc = ssv.get_container();
		if(ssvc != null) {
			var ssvp = ssvc.get_parent();
			if(ssvp != null) {
				ssvp.invalidate_all();
			}
			var ssvch = ssvc.get_child();
			if(ssvch != null) {
				ssvch.invalidate_all();
			}
		}
		ssv.set_parent(null);
		var prev = ssv.get_prev();
		var next = ssv.get_next();
		if(prev is VgSurface) {
			((VgSurface)prev).set_next(next);
		}
		else if(prev is VgSurfaceList) {
			((VgSurfaceList)prev).set_child(next);
		}
		if(next != null && next is VgSurface) {
			((VgSurface)next).set_prev(prev);
		}
		var cc = ssv.get_child();
		if(cc != null) {
			cc.clear_surface();
		}
		ssv.set_next(null);
		ssv.set_prev(null);
		ssv.set_child(null);
	}

	public void clear_surface() {
		while(child != null) {
			remove_surface(child);
		}
	}
}
