
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

namespace eq.gui.sysdep.wpcs
{
	using System;
	using System.Windows;
	using System.Windows.Controls;
	using System.Windows.Input;
	using System.Windows.Controls.Primitives;
	
	public class FramePanel : Canvas, eq.gui.Frame, eq.gui.SurfaceContainer, eq.gui.Size, eq.gui.ClosableFrame
	{
		public class MyCanvas : Canvas {
			private FramePanel mycanvas;
			public MyCanvas(FramePanel panel) {
				mycanvas = panel;	
			}
		}

		eq.api.Object main_object;
		eq.gui.FrameController controller;
		MyCanvas mycanvas = null;
		int dpi = -1;
		UIElement bottomelement = null;
		bool input_enabled = true;

		public FramePanel() {
			Touch.FrameReported += on_touch_event;
			Loaded += on_loaded_custom;
			GuiEngine.rootframe = (Canvas)this;
		}

		public int get_frame_type() {
			return(eq.gui.FrameStatic.TYPE_PHONE);
		}

		public bool has_keyboard() {
			return(false);
		}

		public virtual eq.api.Object create_main_object() {
			return(main_object);
		}

		public void on_loaded_custom(object src, System.Windows.RoutedEventArgs e) {
			var main = create_main_object();
			if(main is eq.gui.FrameController == false) {
				return;
			}
			this.controller = (eq.gui.FrameController)main;
			/*if(eq.api.StringStatic.eq_api_StringStatic_for_strptr("fullscreen").equals((eq.api.Object)this.controller.get_preferred_type())) {
				Microsoft.Phone.Shell.SystemTray.IsVisible = false;
			}*/
			mycanvas = new MyCanvas(this) { Width = ActualWidth, Height = ActualHeight };
			Children.Add(mycanvas);
			controller.initialize_frame(this);
			var pp = this.Parent as FramePanel;
			while(pp != null) {
				var px = pp.Parent as FramePanel;
				if(px != null) {
					pp = px;
					continue;
				}
				break;
			}
			var parent = pp;
			if(parent != null) {
				parent.set_input_enabled(false);
				double width = 480, height = 270;
				var sz = this.controller.get_preferred_size();
				if(sz!=null) {
					width = sz.get_width();
					height = sz.get_height();
				}
				if(width > parent.get_width()) {
					width = parent.get_width();
				}
				if(height > parent.get_height()) {
					height = parent.get_height();
				}
				double pw = parent.get_width(), ph = parent.get_height();
				Canvas.SetLeft(this, pw/2-width/2);
				Canvas.SetTop(this, ph/2-height/2);
				this.Width = width;
				this.Height = height;
				mycanvas.Width = width;
				mycanvas.Height = height;
			}
			var fre = new eq.gui.FrameResizeEvent();
			fre.set_width(mycanvas.Width);
			fre.set_height(mycanvas.Height);
			_event(fre);
			on_activate();
			Loaded -= on_loaded_custom;
			LayoutUpdated += on_layout_changed;
			do_add_bottom_element();
		}

		public FramePanel set_main_object(eq.api.Object o) {
			main_object = o;
			return(this);
		}

		public void set_bottom_element(UIElement element) {
			if(bottomelement != null) {
				Children.Remove(bottomelement);
				bottomelement = null;
			}
			bottomelement = element;
			if(mycanvas == null) {
				return;
			}
			do_add_bottom_element();
		}

		void do_add_bottom_element() {
			if(bottomelement != null) {
				Children.Add(bottomelement);
				Canvas.SetLeft(bottomelement, 0);
				Canvas.SetTop(bottomelement, 200);
			}
		}

		public void on_activate() {
			if(controller != null) {
				controller.start();
			}
		}
		
		public void on_deactivate() {
			if(controller != null) {
				controller.stop();
			}
		}
		
		public void set_input_enabled(bool v) {
			input_enabled = v;
		}

		public void close() {
			var parent = this.Parent as FramePanel;
			if(parent!=null) {
				set_input_enabled(false);
				parent.Children.Remove(this);
				if(parent != null) {
					parent.set_input_enabled(true);
				}
			}
		}

		public eq.gui.FrameController get_controller() {
			return(controller);
		}

		public double get_width() {
			// FIXME: This is wrong if a bottom element has been added
			if(mycanvas!=null) {
				return(mycanvas.Width);
			}
			return(0);
		}
		
		public double get_height() {
			// FIXME: This is wrong if a bottom element has been added
			if(mycanvas!=null) {
				return(mycanvas.Height);
			}
			return(0);
		}

		public int get_dpi() {
			if(dpi < 0) {
				dpi = (int)(Windows.Graphics.Display.DisplayProperties.LogicalDpi * 1.5);
			}
			return(dpi);
		}

		Canvas create_surface(eq.gui.SurfaceOptions opts) {
			if(opts == null) {
				return(null);
			}
			eq.gui.Surface ss = opts.get_surface();
			if(ss != null && ss is Canvas) {
				return((Canvas)ss);
			}
			if(opts.get_surface_type() == eq.gui.SurfaceOptions.SURFACE_TYPE_CONTAINER) {
				return(new ContainerSurfaceCanvas() { Background = null });
			}
			return(new SurfaceCanvas());
		}

		public eq.gui.Surface add_surface(eq.gui.SurfaceOptions opts) {
			if(opts.get_placement() == eq.gui.SurfaceOptions.TOP) {
				return(add_surface_top(opts));
			}
			else if(opts.get_placement() == eq.gui.SurfaceOptions.BOTTOM) {
				return(add_surface_bottom(opts));
			}
			else if(opts.get_placement() == eq.gui.SurfaceOptions.ABOVE) {
				return(add_surface_above(opts.get_relative(), opts));
			}
			else if(opts.get_placement() == eq.gui.SurfaceOptions.BELOW) {
				return(add_surface_below(opts.get_relative(), opts));
			}
			else if(opts.get_placement() == eq.gui.SurfaceOptions.INSIDE) {
				return(add_surface_inside(opts.get_relative(), opts));
			}
			return(null);
		}
		
		public void remove_surface(eq.gui.Surface ss) {
			if(ss is Canvas == false) {
				return;
			}
			var cp = get_parent_canvas((Canvas)ss);
			if(cp != null) {
				cp.Children.Remove((UIElement)ss);
			}
		}

		public eq.gui.Surface add_surface_top(eq.gui.SurfaceOptions opts) {
			var surf = create_surface(opts);
			if(surf == null) {
				return(null);
			}
			mycanvas.Children.Add((UIElement)surf);
			return((eq.gui.Surface)surf);
		}
		
		public eq.gui.Surface add_surface_bottom(eq.gui.SurfaceOptions opts) {
			var surf = create_surface(opts);
			if(surf == null) {
				return(null);
			}
			mycanvas.Children.Insert(0, surf);
			return((eq.gui.Surface)surf);
		}

		public eq.gui.Surface add_surface_above(eq.gui.Surface ss, eq.gui.SurfaceOptions opts) {
			if(ss == null || ss is Canvas == false) {
				return(add_surface_top(opts));
			}
			var vg = get_parent_canvas((Canvas)ss);
			if(vg == null) {
				return(add_surface_top(opts));
			}
			int ssi = ((Canvas)vg).Children.IndexOf((UIElement)ss);
			if(ssi < 0) {
				return(add_surface_top(opts));
			}
			var surf = create_surface(opts);
			if(surf == null) {
				return(null);
			}
			vg.Children.Insert(ssi+1, surf);
			return((eq.gui.Surface)surf);
		}

		public eq.gui.Surface add_surface_below(eq.gui.Surface ss, eq.gui.SurfaceOptions opts) {
			if(ss == null || ss is Canvas == false) {
				return(add_surface_top(opts));
			}
			var vg = get_parent_canvas((Canvas)ss);
			if(vg == null) {
				return(add_surface_top(opts));
			}
			int ssi = ((Canvas)vg).Children.IndexOf((Canvas)ss);
			if(ssi < 0) {
				return(add_surface_top(opts));
			}
			var surf = create_surface(opts);
			if(surf == null) {
				return(null);
			}
			vg.Children.Insert(ssi,surf);
			return((eq.gui.Surface)surf);
		}

		public eq.gui.Surface add_surface_inside(eq.gui.Surface ss, eq.gui.SurfaceOptions opts) {
			if(ss == null || ss is Canvas == false || ss is SurfaceCanvas) {
				System.Diagnostics.Debug.WriteLine("Attempted to add a surface inside a non-container surface. Adding above instead.");
				return(add_surface_above(ss, opts));
			}
			var canvas = create_surface(opts);
			if(canvas == null) {
				return(null);
			}
			((Canvas)ss).Children.Insert(0, canvas);
			return((eq.gui.Surface)canvas);
		}
	
		public Canvas get_parent_canvas(Canvas cc) {
			if(cc == null) {
				return(null);
			}
			var cp = cc.Parent;
			if(cp is Canvas == false) {
				return(null);
			}
			return((Canvas)cp);
		}

		bool _event(eq.api.Object e) {
			if(controller != null) {
				return(controller.on_event(e));
			}
			return(false);
		}

		public void on_size_changed(double w, double h) {
			mycanvas.Width = w;
			mycanvas.Height = h;
			foreach(var fp in this.Children) {
				if(fp is FramePanel) {
					((FramePanel)fp).update_popup_position(w, h);
				}
			}
			var fre = new eq.gui.FrameResizeEvent();
			fre.set_width(w);
			fre.set_height(h);
			_event(fre);
		}
		
		void update_popup_position(double pw, double ph) {
			Canvas.SetLeft(this, pw/2-get_width()/2);
			Canvas.SetTop(this, ph/2-get_height()/2);
		}
		
		public void on_layout_changed(object s, EventArgs e) {
			mycanvas.Width = ActualWidth;
			mycanvas.Height = ActualHeight;
			var fre = new eq.gui.FrameResizeEvent();
			fre.set_width(get_width());
			fre.set_height(get_height());
			_event(fre);
		}

		public bool on_back_pressed() {
			int count = this.Children.Count;
			for(int i = 0; i < count; i++) {
				var fp = this.Children[i];
				if(fp is FramePanel) {
					if(((FramePanel)fp).on_back_pressed()) {
						return(true);
					}
				}
			}
			var kpe = new eq.gui.KeyPressEvent();
			kpe.set_name(eq.api.StringStatic.eq_api_StringStatic_for_strptr("back"));
			bool v = _event(kpe);
			var kre = new eq.gui.KeyReleaseEvent();
			kre.set_name(eq.api.StringStatic.eq_api_StringStatic_for_strptr("back"));
			if(v == false) {
				v = _event(kre);
			}
			return(v);
		}

		public void on_touch_event(object sender, TouchFrameEventArgs args) {
			if(input_enabled == false){
				return;
			}
			var tps = args.GetTouchPoints(this);
			foreach(var tp in tps) {
			var ta = tp.Action;
			int x = (int)tp.Position.X, y = (int)tp.Position.Y;
			int id = tp.TouchDevice.Id;
			if(ta == TouchAction.Down) {
				var ppe = new eq.gui.PointerPressEvent();
				ppe.set_button(1);
				ppe.set_id(id);
				ppe.set_x(x);
				ppe.set_y(y);
				ppe.set_pointer_type(eq.gui.PointerEvent.TOUCH);
				_event(ppe);
			}
			else if(ta == TouchAction.Up) {
				var pre = new eq.gui.PointerReleaseEvent();
				pre.set_button(1);
				pre.set_id(id);
				pre.set_x(x);
				pre.set_y(y);
				pre.set_pointer_type(eq.gui.PointerEvent.TOUCH);
				_event(pre);
				var ple = new eq.gui.PointerLeaveEvent();
				ple.set_id(id);
				ple.set_x(x);
				ple.set_y(y);
				ple.set_pointer_type(eq.gui.PointerEvent.TOUCH);
				_event(ple);
			}
			else if(ta == TouchAction.Move) {
				var pme = new eq.gui.PointerMoveEvent();
				pme.set_id(id);
				pme.set_x(x);
				pme.set_y(y);
				pme.set_pointer_type(eq.gui.PointerEvent.TOUCH);
				_event(pme);
			}
			}
		}
	}
}
