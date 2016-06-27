
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

#public @class : XamlContainerPanel, XamlFrame, Frame, SurfaceContainer, ClosableFrame, TitledFrame, HidableFrame
	@imports eq.api
	@imports eq.gui
{
	@lang "cs" {{{
		FrameController controller;
		Windows.UI.Core.CoreDispatcher dispatcher;
		int dpi = -1;
		bool initialized = false;
		System.Collections.Generic.Dictionary<Windows.System.VirtualKey, char> keytable;
		Windows.System.VirtualKey current_key = 0;
		eq.gui.Size default_size;
		int create_frame_type;
		bool force_fullscreen = true;
		bool input_enabled = false;
		Windows.UI.ViewManagement.ApplicationView myview;
		Windows.UI.Core.CoreWindow mywindow;		

		public XamlPanelFrame() {
			mywindow = Windows.UI.Core.CoreWindow.GetForCurrentThread();
			myview = Windows.UI.ViewManagement.ApplicationView.GetForCurrentView();
			keytable = new System.Collections.Generic.Dictionary<Windows.System.VirtualKey, char>();
			dispatcher = mywindow.Dispatcher;
			Loaded += on_loaded;
			Unloaded += on_unloaded;
			if(GuiEngine.root_panel == null) {
				GuiEngine.root_panel = this;
			}
		}

		public static XamlPanelFrame find_current_panel_frame() {
			var rootframe = Windows.UI.Xaml.Window.Current.Content as Windows.UI.Xaml.Controls.Frame;
			if(rootframe == null) {
				return(null);
			}
			var mainpage = rootframe.Content as Windows.UI.Xaml.Controls.Page;
			if(mainpage == null) {
				return(null);
			}
			return(mainpage.Content as XamlPanelFrame);
		}

		public void set_force_fullscreen(bool v) {
			this.force_fullscreen = v;
		}

		public void show() {
			dispatcher.RunAsync(Windows.UI.Core.CoreDispatcherPriority.Normal, () => {
				if(mywindow != null) {
					mywindow.Activate();
				}
			});
		}

		public void hide() {
		}

		public void enable_inputs() {
			if(input_enabled == false) {
				PointerPressed += on_pointer_press;
				PointerReleased += on_pointer_release;
				PointerWheelChanged += on_pointer_wheel;
				PointerMoved += on_pointer_move;
				Windows.UI.Xaml.Window.Current.CoreWindow.KeyDown += on_key_press;
				Windows.UI.Xaml.Window.Current.CoreWindow.KeyUp += on_key_release;
				Windows.UI.Xaml.Window.Current.CoreWindow.CharacterReceived += CharReceived;
				input_enabled = true;
			}
		}

		public void disable_inputs() {
			if(input_enabled) {
				PointerPressed -= on_pointer_press;
				PointerReleased -= on_pointer_release;
				PointerMoved -= on_pointer_move;
				Windows.UI.Xaml.Window.Current.CoreWindow.KeyDown -= on_key_press;
				Windows.UI.Xaml.Window.Current.CoreWindow.KeyUp -= on_key_release;
				Windows.UI.Xaml.Window.Current.CoreWindow.CharacterReceived -= CharReceived;
				input_enabled = false;
			}
		}

		protected void CharReceived(Windows.UI.Core.CoreWindow sender, Windows.UI.Core.CharacterReceivedEventArgs args) {
			var ks = args.KeyCode;
			KeyEvent ke = new KeyPressEvent();
			if(current_key == 0) {
				ke.set_str(eq.api.CString.for_strptr(new System.String((char)ks, 1)));
				set_key_event_state(ke);
				_event(ke);
			}
			else {
				keytable[current_key] = (char)ks;
			}
		}

		public void set_default_size(double width, double height) {
			default_size = eq.gui.CSize.instance(width, height);
		}

		void _event(eq.api.Object o) {
			if(initialized && controller != null && o != null) {
				controller.on_event(o);
			}
		}

		eq.api.String to_eqstr(string input) {
			return(eq.api.CString.for_strptr(input));
		}

		bool vk_set_as_alpha(KeyEvent e, Windows.System.VirtualKey vk) {
			char ch = (char)vk;
			if(ch < 'A' || ch > 'Z') {
				return(false);
			}
			var caps_state = Windows.UI.Xaml.Window.Current.CoreWindow.GetKeyState(Windows.System.VirtualKey.CapitalLock);
			bool capslock_uppercase = caps_state == Windows.UI.Core.CoreVirtualKeyStates.Locked && e.get_shift() == false;
			bool no_capslock_uppercase = caps_state != Windows.UI.Core.CoreVirtualKeyStates.Locked && e.get_shift();
			if(capslock_uppercase == false &&  no_capslock_uppercase == false) {
				ch = (char)(ch - 'A' + 'a');
			}
			e.set_str(to_eqstr(new System.String(ch, 1)));
			return(true);
		}

		protected void on_key_press(Windows.UI.Core.CoreWindow sender, Windows.UI.Core.KeyEventArgs e) {
			var ks = e.VirtualKey;
			KeyEvent ke = new KeyPressEvent();
			set_key_event_properties(ke, (uint)ks);
			set_key_event_state(ke);
			if(ke.get_name() != null || vk_set_as_alpha(ke, ks)) {
				current_key = ks;
				_event(ke);	
			}
		}

		protected void on_key_release(Windows.UI.Core.CoreWindow sender, Windows.UI.Core.KeyEventArgs e) {
			var key = e.VirtualKey;
			KeyEvent kre = new KeyReleaseEvent();
			set_key_event_properties(kre, (uint)key);
			set_key_event_state(kre);
			if(keytable.ContainsKey(key)) {
				var kstr = new System.String((char)keytable[key], 1);
				kre.set_str(to_eqstr(kstr));
				keytable[key] = '\0';
			}
			_event(kre);
			current_key = 0;
		}

		void set_key_event_state(KeyEvent e) {
			var ctrl_state = Windows.UI.Xaml.Window.Current.CoreWindow.GetKeyState(Windows.System.VirtualKey.Control);
			if((ctrl_state & Windows.UI.Core.CoreVirtualKeyStates.Down) == Windows.UI.Core.CoreVirtualKeyStates.Down) {
				e.set_ctrl(true);
			}
			var shift_state = Windows.UI.Xaml.Window.Current.CoreWindow.GetKeyState(Windows.System.VirtualKey.Shift);
			if((shift_state & Windows.UI.Core.CoreVirtualKeyStates.Down) == Windows.UI.Core.CoreVirtualKeyStates.Down) {
				e.set_shift(true);
			}
		}

		void set_key_event_properties(KeyEvent e, uint vk) {
			string kstr = new System.String((char)vk, 1);
			if(vk == (int)Windows.System.VirtualKey.Back) { //FIXME: backspace gives this VK, this instead.
				e.set_name(to_eqstr("backspace"));
				kstr = null;
			}
			else if(vk == (int)Windows.System.VirtualKey.Escape) {
				e.set_name(to_eqstr("escape"));
				kstr = null;
			}
			else if(vk == (int)Windows.System.VirtualKey.Space) {
				e.set_name(to_eqstr("space"));
				kstr = " ";
			}
			else if(vk == (int)Windows.System.VirtualKey.Tab) {
				e.set_name(to_eqstr("tab"));
				kstr = null;
			}
			else if(vk == (int)Windows.System.VirtualKey.Space) {
				e.set_name(to_eqstr("space"));
				kstr = null;
			}
			else if(vk == (int)Windows.System.VirtualKey.Enter) {
				e.set_name(to_eqstr("enter"));
				kstr = null;
			}
			else if(vk == (int)Windows.System.VirtualKey.Delete) {
				e.set_name(to_eqstr("delete"));
				kstr = null;
			}
			else if(vk == (int)Windows.System.VirtualKey.Up) {
				e.set_name(to_eqstr("up"));
				kstr = null;
			}
			else if(vk == (int)Windows.System.VirtualKey.Down) {
				e.set_name(to_eqstr("down"));
				kstr = null;
			}
			else if(vk == (int)Windows.System.VirtualKey.Left) {
				e.set_name(to_eqstr("left"));
				kstr = null;
			}
			else if(vk == (int)Windows.System.VirtualKey.Right) {
				e.set_name(to_eqstr("right"));
				kstr = null;
			}
			else if(vk == (int)Windows.System.VirtualKey.Home) {
				e.set_name(to_eqstr("home"));
				kstr = null;
			}
			else if(vk == (int)Windows.System.VirtualKey.End) {
				e.set_name(to_eqstr("end"));
				kstr = null;
			}
			else if(vk == (int)Windows.System.VirtualKey.PageUp) {
				e.set_name(to_eqstr("pageup"));
				kstr = null;
			}
			else if(vk == (int)Windows.System.VirtualKey.PageDown) {
				e.set_name(to_eqstr("pagedown"));
				kstr = null;
			}
			if(kstr != null) {
				e.set_str(to_eqstr(kstr));
			}
		}

		protected void on_pointer_wheel(object sender, Windows.UI.Xaml.Input.PointerRoutedEventArgs e) {
			var pp = e.GetCurrentPoint((XamlPanelFrame)sender);
			var ppp = pp.Properties;
			var md = ppp.MouseWheelDelta;
			int x = (int)pp.Position.X, y = (int)pp.Position.Y;
			if((e.KeyModifiers & Windows.System.VirtualKeyModifiers.Control) != 0) {
				eq.gui.ZoomEvent ze = new eq.gui.ZoomEvent();
				ze.set_x(x);
				ze.set_y(y);
				if(md > 0) {
					ze.set_dz(1);
				}
				else {
					ze.set_dz(-1);
				}
				_event(ze);
			}
			else {
				eq.gui.ScrollEvent se = new eq.gui.ScrollEvent();
				se.set_x(x);
				se.set_y(y);
				se.set_dy(md);
				_event(se);
			}
		}

		protected void on_pointer_press(object sender, Windows.UI.Xaml.Input.PointerRoutedEventArgs e) {
			var pts = e.GetCurrentPoint((XamlPanelFrame)sender);
			var ppe = new PointerPressEvent();
			ppe.set_pointer_type(PointerEvent.MOUSE);
			ppe.set_id((int)pts.PointerId);
			ppe.set_x((int)pts.Position.X);
			ppe.set_y((int)pts.Position.Y);
			int button = 1;
			if(pts.Properties.IsMiddleButtonPressed) {
				button = 2;
			}
			else if(pts.Properties.IsRightButtonPressed) {
				button = 3;
			}
			ppe.set_button(button);
			_event(ppe);
		}

		protected void on_pointer_release(object sender, Windows.UI.Xaml.Input.PointerRoutedEventArgs e) {
			var pts = e.GetCurrentPoint((XamlPanelFrame)sender);
			var pre = new PointerReleaseEvent();
			pre.set_pointer_type(PointerEvent.MOUSE);
			pre.set_id((int)pts.PointerId);
			pre.set_x((int)pts.Position.X);
			pre.set_y((int)pts.Position.Y);
			int button = 1;
			if(pts.Properties.IsMiddleButtonPressed) {
				button = 2;
			}
			else if(pts.Properties.IsRightButtonPressed) {
				button = 3;
			}
			pre.set_button(button);
			_event(pre);
		}

		protected void on_pointer_move(object sender, Windows.UI.Xaml.Input.PointerRoutedEventArgs e) {
			var pts = e.GetCurrentPoint((XamlPanelFrame)sender);
			var pme = new PointerMoveEvent();
			pme.set_pointer_type(PointerEvent.MOUSE);
			pme.set_id((int)pts.PointerId);
			pme.set_x((int)pts.Position.X);
			pme.set_y((int)pts.Position.Y);
			_event(pme);
		}

		public virtual void on_window_resized(object o, Windows.UI.Core.WindowSizeChangedEventArgs e) {
		}

		void on_view_consolidated(Windows.UI.ViewManagement.ApplicationView sender, Windows.UI.ViewManagement.ApplicationViewConsolidatedEventArgs e) {
			close();
		}

		protected void on_size_changed(object o, Windows.UI.Xaml.SizeChangedEventArgs e) {
			var sz = e.NewSize;
			if(controller != null) {
				var fre = new FrameResizeEvent();
				fre.set_width(sz.Width);
				fre.set_height(sz.Height);
				controller.on_event(fre);
			}
		}

		public void set_main_object(eq.api.Object main, eq.gui.CreateFrameOptions aopts = null) {
			if(main is FrameController) {
				controller = (FrameController)main;
			}
			var opts = aopts;
			if(opts == null && controller != null) {
				opts = controller.get_frame_options();
			}
			if(opts == null) {
				opts = new eq.gui.CreateFrameOptions();
			}
			var type = opts.get_type();
			var resizable = opts.get_resizable();
			var screen = opts.get_screen();
			var minimum_size = opts.get_minimum_size();
			if(minimum_size != null) {
				MinWidth = minimum_size.get_width();
				MinHeight = minimum_size.get_height();
			}
			var maximum_size = opts.get_maximum_size();
			if(maximum_size != null) {
				MaxWidth = maximum_size.get_width();
				MaxHeight = maximum_size.get_height();
			}
			var default_size = opts.get_default_size();
			if(default_size != null) {
				set_default_size(default_size.get_width(), default_size.get_height());
			}
			create_frame_type = type;
		}

		public virtual void on_unloaded(object sender, Windows.UI.Xaml.RoutedEventArgs e) {
			disable_inputs();
			SizeChanged -= on_size_changed;
			Windows.UI.Xaml.Window.Current.SizeChanged -= on_window_resized;
		}

		public virtual void on_loaded(object sender, Windows.UI.Xaml.RoutedEventArgs e) {
			if(controller != null) {
				controller.initialize_frame(this);
				initialized = true;
				if(force_fullscreen == false) {
					var ds = default_size;
					if(ds == null) {
						ds = controller.get_preferred_size();
					}
					Width = ds.get_width();
					Height = ds.get_height();
				}
				UpdateLayout();
				controller.start();
				{
					var fre = new FrameResizeEvent();
					fre.set_width(ActualWidth);
					fre.set_height(ActualHeight);
					controller.on_event(fre);
				}
			}
			SizeChanged += on_size_changed;
			Windows.UI.ViewManagement.ApplicationView.GetForCurrentView().Consolidated += on_view_consolidated;
			Windows.UI.Xaml.Window.Current.SizeChanged += on_window_resized;
			enable_inputs();
			Loaded -= on_loaded;
		}

		public int get_frame_type() {
			return(0); //FIXME how about Surface tablets?
		}

		public void set_title(eq.api.String title) {
			if(title != null) {
				myview.Title = title.to_strptr();
			}
		}

		public virtual void close() {
			initialized = false;
			if(controller != null) {
				controller.stop();
				controller.destroy();
				controller = null;
			}
		}

		public void set_icon(Image icon) {
			//FIXME
		}

		public bool has_keyboard() {
			return(true); //FIXME how bout for Surface tablets?
		}

		public FrameController get_controller() {
			return(controller);		
		}

		public int get_dpi() {
			if(dpi < 0) {
				var di = Windows.Graphics.Display.DisplayInformation.GetForCurrentView();
				dpi =(int)(di.LogicalDpi);
			}
			return(dpi);
		}

		public Surface add_surface(SurfaceOptions opts) {
			if(opts == null) {
				return(null);
			}
			return(SurfaceSynchronizer.create(this, opts, dispatcher));
		}

		public void remove_surface(Surface surf) {
			if(initialized == false) {
				return;
			}
			dispatcher.RunAsync(Windows.UI.Core.CoreDispatcherPriority.Normal, () => {
				Windows.UI.Xaml.FrameworkElement element = null;
				var ss = surf as SurfaceSynchronizer;
				if(ss != null) {
					element = ss.get_origsurface() as Windows.UI.Xaml.FrameworkElement;
				}
				else {
					element = surf as Windows.UI.Xaml.FrameworkElement;
				}
				if(element != null) {
					try {
						var pp = element.Parent as Windows.UI.Xaml.Controls.Panel;
						if(pp != null) {
							pp.Children.Remove(element);
						}
					}
					catch(System.Runtime.InteropServices.InvalidComObjectException e) {
						//This is still called after the widget is destroyed, even if the Panel is already destroyed
					}
				}
			});
		}
	}}}
}