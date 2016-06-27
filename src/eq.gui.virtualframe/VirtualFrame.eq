
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

public class VirtualFrame : Frame, SurfaceContainer, Size
{
	class MySurface : Surface, Size, Position, Renderable, SurfaceContainer
	{
		property double x;
		property double y;
		property double width;
		property double height;
		double scale_x;
		double scale_y;
		double alpha;
		double angle;
		property Collection ops;
		property Collection belows;
		property Collection aboves;
		property Collection children;
		property bool is_container;
		property bool removed = false;

		public void move(double x, double y) {
			this.x = x;
			this.y = y;
		}

		public void resize(double w, double h) {
			this.width = w;
			this.height = h;
		}

		public void move_resize(double x, double y, double w, double h) {
			this.x = x;
			this.y = y;
			this.width = w;
			this.height = h;
		}

		public void set_scale(double sx, double sy) {
			this.scale_x = sx;
			this.scale_y = sy;
		}

		public void set_alpha(double f) {
			this.alpha = f;
		}

		public void set_rotation_angle(double a) {
			this.angle = a;
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
			return(angle);
		}

		public void render(Collection ops) {
			this.ops = ops;
		}

		public Surface add_surface(SurfaceOptions opts) {
			if(opts.get_placement() == SurfaceOptions.INSIDE) {
				var rr = opts.get_relative() as SurfaceContainer;
				if(rr != null) {
					opts.set_placement(SurfaceOptions.BOTTOM);
					opts.set_relative(null);
					return(rr.add_surface(opts));
				}
			}
			var v = new MySurface();
			if(opts.get_surface_type() == SurfaceOptions.SURFACE_TYPE_CONTAINER) {
				v.set_is_container(true);
			}
			if(opts.get_placement() == SurfaceOptions.ABOVE) {
				var rr = opts.get_relative() as MySurface;
				if(rr == null) {
					return(null);
				}
				var aboves = rr.get_aboves();
				if(aboves == null) {
					aboves = LinkedList.create();
					rr.set_aboves(aboves);
				}
				aboves.prepend(v);
			}
			else if(opts.get_placement() == SurfaceOptions.BELOW) {
				var rr = opts.get_relative() as MySurface;
				if(rr == null) {
					return(null);
				}
				var belows = rr.get_belows();
				if(belows == null) {
					belows = LinkedList.create();
					rr.set_belows(belows);
				}
				belows.append(v);
			}
			else if(opts.get_placement() == SurfaceOptions.TOP) {
				if(children == null) {
					children = LinkedList.create();
				}
				children.append(v);
			}
			else if(opts.get_placement() == SurfaceOptions.BOTTOM) {
				if(children == null) {
					children = LinkedList.create();
				}
				children.prepend(v);
			}
			return(v);
		}

		public void remove_surface(Surface ss) {
			var sss = ss as MySurface;
			if(sss != null) {
				sss.set_removed(true);
			}
		}

		void reposition(Object op, double dx, double dy) {
			if(op is ClearOperation) {
				((ClearOperation)op).set_x(((ClearOperation)op).get_x() + dx);
				((ClearOperation)op).set_y(((ClearOperation)op).get_y() + dy);
			}
			if(op is ClipOperation) {
				((ClipOperation)op).set_x(((ClipOperation)op).get_x() + dx);
				((ClipOperation)op).set_y(((ClipOperation)op).get_y() + dy);
			}
			if(op is DrawObjectOperation) {
				((DrawObjectOperation)op).set_x(((DrawObjectOperation)op).get_x() + dx);
				((DrawObjectOperation)op).set_y(((DrawObjectOperation)op).get_y() + dy);
			}
			if(op is FillColorOperation) {
				((FillColorOperation)op).set_x(((FillColorOperation)op).get_x() + dx);
				((FillColorOperation)op).set_y(((FillColorOperation)op).get_y() + dy);
			}
			if(op is FillGradientOperation) {
				((FillGradientOperation)op).set_x(((FillGradientOperation)op).get_x() + dx);
				((FillGradientOperation)op).set_y(((FillGradientOperation)op).get_y() + dy);
			}
			if(op is StrokeOperation) {
				((StrokeOperation)op).set_x(((StrokeOperation)op).get_x() + dx);
				((StrokeOperation)op).set_y(((StrokeOperation)op).get_y() + dy);
			}
		}

		public void add_to_display_list(Collection list, double dx, double dy) {
			if(list == null || removed) {
				return;
			}
			foreach(MySurface o in belows) {
				o.add_to_display_list(list, dx, dy);
			}
			foreach(var op in ops) {
				reposition(op, dx + get_x(), dy + get_y());
				list.add(op);
			}
			double xx, yy;
			if(is_container) {
				xx = get_x();
				yy = get_y();
			}
			foreach(MySurface child in children) {
				child.add_to_display_list(list, dx + xx, dy + yy);
			}
			foreach(MySurface o in aboves) {
				o.add_to_display_list(list, dx, dy);
			}
		}
	}

	property double width;
	property double height;
	property int dpi;
	MySurface root;
	FrameController controller;
	property int frame_type;

	public VirtualFrame() {
		frame_type = Frame.TYPE_DESKTOP;
	}

	public bool has_keyboard() {
		return(false);
	}

	public VirtualFrame initialize(FrameController fc, double width, double height, int dpi) {
		if(fc == null) {
			return(null);
		}
		this.width = width;
		this.height = height;
		this.dpi = dpi;
		root = new MySurface();
		fc.initialize_frame(this);
		fc.on_event(new FrameResizeEvent().set_width(width).set_height(height));
		controller = fc;
		return(this);
	}

	public FrameController get_controller() {
		return(controller);
	}

	public Surface add_surface(SurfaceOptions opts) {
		return(root.add_surface(opts));
	}

	public void remove_surface(Surface ss) {
		root.remove_surface(ss);
	}

	public Collection get_display_list() {
		if(root == null) {
			return(null);
		}
		var v = LinkedList.create();
		root.add_to_display_list(v, 0, 0);
		return(v);
	}
}
