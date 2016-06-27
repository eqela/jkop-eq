
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

public class VgSurface : Surface, Size, Position, VgRenderable, Renderable
{
	property VgFrame parent;
	double x;
	double y;
	double w;
	double h;
	double scale_x = 1.0;
	double scale_y = 1.0;
	double alpha = 1.0;
	double rotation = 0.0;
	Collection ops;
	VgRenderableImage bitmap;
	property VgSurface next;
	property Object prev;
	property bool cached = true;
	VgSurfaceList child;
	property VgSurfaceList container;
	Rectangle dirty_area;

	public VgSurface set_child(VgSurfaceList c) {
		if(child != null && c == null) {
			child.set_parent(null);
		}
		child = c;
		if(child != null) {
			child.set_parent(this);
		}
		return(this);
	}

	public VgSurfaceList get_child() {
		return(child);
	}

	public void draw_in_context(VgContext context, int ssx, int ssy) {
		if(cached) {
			if(bitmap != null) {
				context.draw_graphic(ssx, ssy, get_draw_transform(), bitmap);
			}
			else {
			}
		}
		else {
			VgRenderer.render_to_vg_context(ops, context, ssx, ssy);
		}
	}

	public void render(Collection ops) {
		this.ops = ops;
		if(cached) {
			update_bitmap();
		}
		invalidate_all();
	}

	public VgTransform get_draw_transform() {
		return(new VgTransform()
			.set_scale_x(scale_x).set_scale_y(scale_y)
			.set_alpha(alpha).set_rotate_angle(rotation)
		);
	}

	public Rectangle get_dirty_area() {
		if(dirty_area!=null) {
			var x = dirty_area.get_x()+get_x();
			var y = dirty_area.get_y()+get_y();
			return(Rectangle.instance((int)x, (int)y, (int)dirty_area.get_width(), (int)dirty_area.get_height()));
		}
		return(null);
	}

	public void invalidate(int x, int y, int w, int h) {
		if(parent == null) {
			return;
		}
		parent.invalidate(get_x()+x, get_y()+y, w, h);
	}

	public void invalidate_all() {
		if(dirty_area!=null && parent != null) {
			invalidate(dirty_area.get_x(),dirty_area.get_y(),dirty_area.get_width(),dirty_area.get_height());
		}
		else {
			invalidate(0, 0, get_width(), get_height());
		}
	}

	public double get_container_x() {
		if(container != null) {
			var p = container.get_parent();
			if(p!=null) {
				return(p.get_x());
			}
		}
		return(0.0);
	}

	public double get_container_y() {
		if(container != null) {
			var p = container.get_parent();
			if(p!=null) {
				return(p.get_y());
			}
		}
		return(0.0);
	}

	public double get_x() {
		return(x + get_container_x());
	}

	public double get_y() {
		return(y + get_container_y());
	}

	public double get_width() {
		return(w);
	}

	public double get_height() {
		return(h);
	}

	public void move(double x, double y) {
		if(this.x == x && this.y == y) {
			return;
		}
		invalidate_all();
		this.x = x;
		this.y = y;
		invalidate_all();
	}

	public void update_bitmap() {
		if(get_width() < 1 || get_height() < 1) {
			return;
		}
		if(bitmap == null || bitmap.get_width() != get_width() || bitmap.get_height() != get_height()) {
			bitmap = VgRenderableImage.create(get_width(), get_height());
		}
		if(bitmap == null) {
			Log.debug("update_bitmap: VgRenderableImage is null");
			return;
		}
		var ctx = bitmap.get_vg_context();
		if(ctx == null) {
			return;
		}
		ctx.clear(0, 0, VgPathRectangle.create(0, 0, bitmap.get_width(), bitmap.get_height()), null);
		VgRenderer.render_to_vg_context(ops, ctx);
	}

	public void resize(double w, double h) {
		if(get_width() == w && get_height() == h) {
			return;
		}
		invalidate_all();
		this.w = w;
		this.h = h;
		if(dirty_area!=null) {
			var ll = w;
			if(h > ll) {
				ll = h;
			}
			var w2 = ll/2;
			dirty_area = Rectangle.instance((int)-w2, (int)-w2, (int)(2*ll), (int)(2*ll));
		}
		invalidate_all();
	}

	public void move_resize(double x, double y, double w, double h) {
		move(x, y);
		resize(w, h);
	}

	public void set_scale(double sx, double sy) {
		if(scale_x == sx && scale_y == sy) {
			return;
		}
		scale_x = sx;
		scale_y = sy;
		invalidate_all();
	}

	public void set_alpha(double a) {
		if(alpha == a) {
			return;
		}
		alpha = a;
		invalidate_all();
	}

	public void set_rotation_angle(double a) {
		if(rotation == a) {
			return;
		}
		rotation = a;
		// FIXME: This invalidation is too much; we would only need to the extent
		// of the current rotation
		var ll = get_width();
		if(get_height() > ll) {
			ll = get_height();
		}
		var w2 = ll/2;
		invalidate_all();
		dirty_area = Rectangle.instance((int)-w2, (int)-w2, (int)(2*ll), (int)(2*ll));
		invalidate_all();
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
		return(rotation);
	}

	public VgContext get_vg_context() {
		if(bitmap == null) {
			return(null);
		}
		return(bitmap.get_vg_context());
	}
}
