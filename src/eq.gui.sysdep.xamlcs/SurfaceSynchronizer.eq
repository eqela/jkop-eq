
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

public class SurfaceSynchronizer : Surface, Size, Position
{
	class RenderableSurfaceSynchronizer : SurfaceSynchronizer, Renderable
	{
		embed {{{
			public override Windows.UI.Xaml.FrameworkElement create_surface_element() {
				return(new XamlCanvasSurface());
			}
		}}}

		public void render(Collection o) {
			embed {{{
				dispatch_delegate(() => {
					var renderable = get_origsurface() as eq.gui.Renderable;
					if(renderable != null) {
						renderable.render(o);
					}
				});
			}}}
		}
	}

	embed {{{
		Windows.UI.Core.CoreDispatcher dispatcher;
	}}}
	property Surface origsurface;
	double posx;
	double posy;
	double szw;
	double szh;
	double scalex;
	double scaley;
	double rangle;
	double alpha;

	embed {{{
		public static SurfaceSynchronizer create(XamlContainerPanel root, eq.gui.SurfaceOptions opts, Windows.UI.Core.CoreDispatcher dispatcher) {
			SurfaceSynchronizer ss = null;
			if(opts.get_surface_type() == eq.gui.SurfaceOptions.SURFACE_TYPE_CONTAINER) {
				ss = new SurfaceSynchronizer();
			}
			else {
				ss = new RenderableSurfaceSynchronizer();
			}
			ss.dispatcher = dispatcher;
			ss.dispatch_delegate(() => {
				ss.initialize_surface(root, opts);
			});
			return(ss);
		}
	}}}

	embed {{{
		public void dispatch_delegate(Windows.UI.Core.DispatchedHandler dh) {
			dispatcher.RunAsync(Windows.UI.Core.CoreDispatcherPriority.Normal, dh);
		}

		public virtual Windows.UI.Xaml.FrameworkElement create_surface_element() {
			return(new XamlPanelSurfaceContainer());
		}

		public void initialize_surface(XamlContainerPanel root, eq.gui.SurfaceOptions opts) {
			Windows.UI.Xaml.FrameworkElement v = create_surface_element();
			int placement = opts.get_placement();
			if(placement == eq.gui.SurfaceOptions.TOP) {
				root.Children.Add(v);
			}
			else if(placement == eq.gui.SurfaceOptions.BOTTOM) {
				root.Children.Insert(0, v);
			}
			else if(placement == eq.gui.SurfaceOptions.ABOVE || placement == eq.gui.SurfaceOptions.BELOW) {
				Windows.UI.Xaml.FrameworkElement rel = null;
				var ss = opts.get_relative() as SurfaceSynchronizer;
				if(ss != null) {
					rel = ss.get_origsurface() as Windows.UI.Xaml.FrameworkElement;
				}
				if(rel != null) {
					var pp = rel.Parent as Windows.UI.Xaml.Controls.Panel;
					if(pp != null) {
						int idx = pp.Children.IndexOf(rel);
						if(idx < 0) {
							root.Children.Add(v);
						}
						if(placement == eq.gui.SurfaceOptions.ABOVE) {
							pp.Children.Insert(idx+1, v);
						}
						else {
							pp.Children.Insert(idx, v);
						}
					}
					else {
						root.Children.Add(v);
					}
				}
			}
			else if(opts.get_placement() == eq.gui.SurfaceOptions.INSIDE) {
				Windows.UI.Xaml.Controls.Panel rel = null;
				var ss = opts.get_relative() as SurfaceSynchronizer;
				if(ss != null) {
					rel = ss.get_origsurface() as Windows.UI.Xaml.Controls.Panel;
				}
				if(rel != null && rel is XamlCanvasSurface == false) {
					rel.Children.Insert(0, v);
				}
				else {
					initialize_surface(root, eq.gui.SurfaceOptions.above(opts.get_relative()));
				}
			}
			else {
				System.Diagnostics.Debug.WriteLine("[ERROR] Unknown surface type encountered.");
			}
			if(v != null) {
				origsurface = (eq.gui.Surface)v;
			}
		}
	}}}

	public void move(double x, double y) {
		embed {{{
			var sd = new Windows.UI.Core.DispatchedHandler(() => {
				origsurface.move(x, y);
				var spos = origsurface as eq.gui.Position;
				if(spos != null) {
					posx = spos.get_x();
					posy = spos.get_y();
				}
			});
			dispatch_delegate(sd);
		}}}
	}

	public void resize(double w, double h) {
		embed {{{
			var sd = new Windows.UI.Core.DispatchedHandler(() => {
				origsurface.resize(w, h);
			});
			dispatch_delegate(sd);
		}}}
		szw = w;
		szh = h;
	}

	public void move_resize(double x, double y, double w, double h) {
		move(x, y);
		resize(w, h);
	}

	public void set_scale(double sx, double sy) {
		embed {{{
			var sd = new Windows.UI.Core.DispatchedHandler(() => {
				origsurface.set_scale(sx, sy);
			});
			dispatch_delegate(sd);
		}}}
		scalex = sx;
		scaley = sy;
	}

	public void set_alpha(double f) {
		embed {{{
			var sd = new Windows.UI.Core.DispatchedHandler(() => {
				origsurface.set_alpha(f);
			});
			dispatch_delegate(sd);
		}}}
		alpha = f;
	}

	public void set_rotation_angle(double a) {
		embed {{{
			var sd = new Windows.UI.Core.DispatchedHandler(() => {
				origsurface.set_rotation_angle(a);
			});
			dispatch_delegate(sd);
		}}}
		rangle = a;
	}

	public double get_scale_x() {
		return(scalex);
	}

	public double get_scale_y() {
		return(scaley);
	}

	public double get_alpha() {
		return(alpha);
	}

	public double get_rotation_angle() {
		return(rangle);
	}

	public double get_x() {
		return(posx);
	}

	public double get_y() {
		return(posy);
	}

	public double get_width() {
		return(szw);
	}

	public double get_height() {
		return(szh);
	}
}