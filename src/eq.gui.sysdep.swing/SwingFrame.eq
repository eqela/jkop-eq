
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

public class SwingFrame : Frame, TitledFrame, ResizableFrame, HidableFrame, ClosableFrame,
      CursorFrame, DesktopWindowFrame, Size, SurfaceContainer, SizeConstrainedFrame
{
	FrameController controller;
	int dpi = 96;

	embed {{{
		java.awt.Window jwindow;
	}}}

	public virtual int determine_dpi() {
		var eqdpi = SystemEnvironment.get_env_var("EQ_DPI");
		if(String.is_empty(eqdpi) == false) {
			var idpi = eqdpi.to_integer();
			Log.debug("DPI set to %d via environment variable EQ_DPI".printf().add(idpi));
			return(idpi);
		}
		int v = 96;
		embed {{{
			int dpi = java.awt.Toolkit.getDefaultToolkit().getScreenResolution();
			if(dpi > 0) {
				v = dpi;
			}
		}}}
		return(v);
	}

	embed {{{
		static int window_count = 0;
		static java.awt.GraphicsDevice device = java.awt.GraphicsEnvironment
			.getLocalGraphicsEnvironment().getScreenDevices()[0];
	}}}

	void _event(Object o) {
		if(controller != null) {
			controller.on_event(o);
		}
	}

	embed {{{
		class SwingFrameMouseListener extends java.awt.event.MouseAdapter
		{
			SwingFrame frame;
			int dpi;

			public SwingFrameMouseListener(SwingFrame frame) {
				this.frame = frame;
				dpi = frame.get_dpi();
			}
			public void mousePressed(java.awt.event.MouseEvent e) {
				eq.gui.PointerPressEvent ppe = new eq.gui.PointerPressEvent();
				ppe.set_type_mouse();
				ppe.set_button(e.getButton());
				ppe.set_x(e.getX());
				ppe.set_y(e.getY());
				frame._event((eq.api.Object)ppe);
			}
			public void mouseReleased(java.awt.event.MouseEvent e) {
				eq.gui.PointerReleaseEvent pre = new eq.gui.PointerReleaseEvent();
				pre.set_type_mouse();
				pre.set_button(e.getButton());
				pre.set_x(e.getX());
				pre.set_y(e.getY());
				frame._event((eq.api.Object)pre);
			}
			public void mouseWheelMoved(java.awt.event.MouseWheelEvent e) {
				if(e.getScrollType() == java.awt.event.MouseWheelEvent.WHEEL_UNIT_SCROLL) {
					int total_scroll = (dpi/96) *  e.getUnitsToScroll();
					int x = e.getX(), y = e.getY();
					if(e.isControlDown()) {
						eq.gui.ZoomEvent ze = new eq.gui.ZoomEvent();
						ze.set_x(x);
						ze.set_y(y);
						if(total_scroll > 0) {
							ze.set_dz(-1);
						}
						else {
							ze.set_dz(1);
						}
						frame._event(ze);
					}
					else {
						eq.gui.ScrollEvent se = new eq.gui.ScrollEvent();
						se.set_x(x);
						se.set_y(y);
						se.set_dy(-total_scroll);
						frame._event(se);
					}
				}
			}
			public void mouseExited(java.awt.event.MouseEvent e) {
				eq.gui.PointerLeaveEvent ple = new eq.gui.PointerLeaveEvent();
				ple.set_type_mouse();
				ple.set_x(e.getX());
				ple.set_y(e.getY());
				frame._event((eq.api.Object)ple);
			}
			public void mouseMoved(java.awt.event.MouseEvent e) {
				eq.gui.PointerMoveEvent pme = new eq.gui.PointerMoveEvent();
				pme.set_type_mouse();
				pme.set_x(e.getX());
				pme.set_y(e.getY());
				frame._event((eq.api.Object)pme);
			}
			public void mouseDragged(java.awt.event.MouseEvent e) {
				eq.gui.PointerMoveEvent pme = new eq.gui.PointerMoveEvent();
				pme.set_type_mouse();
				pme.set_x(e.getX());
				pme.set_y(e.getY());
				frame._event((eq.api.Object)pme);
			}
		}

		class SwingFrameKeyListener extends java.awt.event.KeyAdapter
		{
			SwingFrame frame;

			public SwingFrameKeyListener(SwingFrame frame) {
				this.frame = frame;
			}
			public boolean initialize_key(java.awt.event.KeyEvent awtevent, eq.gui.KeyEvent keyevent) {
				String name = null;
				int keycode = awtevent.getKeyCode();
				char schr = awtevent.getKeyChar();
				if(keycode == java.awt.event.KeyEvent.VK_ENTER) {
					name = "enter";
				}
				else if(keycode == java.awt.event.KeyEvent.VK_BACK_SPACE) {
					name = "backspace";
				}
				else if(keycode == java.awt.event.KeyEvent.VK_TAB) {
					name = "tab";
				}
				else if(keycode == java.awt.event.KeyEvent.VK_ESCAPE) {
					name = "escape";
				}
				else if(keycode == java.awt.event.KeyEvent.VK_SPACE) {
					name = "space";
				}
				else if(keycode == java.awt.event.KeyEvent.VK_LEFT) {
					name = "left";
				}
				else if(keycode == java.awt.event.KeyEvent.VK_RIGHT) {
					name = "right";
				}
				else if(keycode == java.awt.event.KeyEvent.VK_UP) {
					name = "up";
				}
				else if(keycode == java.awt.event.KeyEvent.VK_DOWN) {
					name = "down";
				}
				else if(keycode == java.awt.event.KeyEvent.VK_PAGE_UP) {
					name = "pageup";
				}
				else if(keycode == java.awt.event.KeyEvent.VK_PAGE_DOWN) {
					name = "pagedown";
				}
				boolean v = false;
				eq.api.String kname = null;
				if((int)schr > 31 && (int)schr < 256) {
					keyevent.set_str_char(schr);
					v = true;
				}
				else if(keycode >= 'A' && keycode <= 'Z') {
					int alphachar = keycode;
					boolean caps = java.awt.Toolkit.getDefaultToolkit().getLockingKeyState(java.awt.event.KeyEvent.VK_CAPS_LOCK);
					if((caps == false && awtevent.isShiftDown() == false) || (caps && awtevent.isShiftDown())) {
						alphachar = (alphachar - 'A' + 'a');
					}
					keyevent.set_str_char(alphachar);
					v = true;
				}
				if(name != null) {
					kname = keyevent._S(name);
					v = true;
				}
				if(v) {
					keyevent.set_name(kname);
					keyevent.set_ctrl(awtevent.isControlDown());
					keyevent.set_shift(awtevent.isShiftDown());
					keyevent.set_alt(awtevent.isAltDown());
				}
				return(v);
			}
			public void keyPressed(java.awt.event.KeyEvent e) {
				eq.gui.KeyPressEvent kpe = new eq.gui.KeyPressEvent();
				if(initialize_key(e, kpe)) {
					frame._event(kpe);
				}
			}
			public void keyReleased(java.awt.event.KeyEvent e) {
				eq.gui.KeyReleaseEvent kre = new eq.gui.KeyReleaseEvent();
				if(initialize_key(e, kre)) {
					frame._event(kre);
				}	
			}
		}
	}}}

	public virtual bool do_open_frame(WindowManagerScreen wmscreen, int frametype, Frame parent) {
		var wms = wmscreen as AWTWindowManagerScreen;
		/*
		if(wms == null) {
			var wm = get_window_manager();
			if(wm != null) {
				wms = wm.get_default_screen() as AWTWindowManagerScreen;
			}
		}
		*/
		if(wms != null) {
			Log.error("FIXME: Handle the setting of the display screen");
		}
		if(frametype == CreateFrameOptions.TYPE_SPLASH) {
			embed {{{
				// A window without a frame
				jwindow = new javax.swing.JWindow();
			}}}
		}
		else if(frametype == CreateFrameOptions.TYPE_FULLSCREEN) {
			embed {{{
				javax.swing.JFrame jframe = new javax.swing.JFrame();
				jframe.setExtendedState(javax.swing.JFrame.MAXIMIZED_BOTH);
				jframe.setUndecorated(true);
				jwindow = jframe;
				device.setFullScreenWindow(jwindow);
			}}}
		}
		else {
			if(frametype != CreateFrameOptions.TYPE_NORMAL) {
				Log.warning("Unknown window type encountered: %d. Creating a normal window instead.".printf().add(frametype));
			}
			if(parent != null) {
				SwingFrame f = parent as SwingFrame;
				embed {{{
					java.awt.Window w = null;
					if(f != null) {
						w = f.jwindow;
					}
					jwindow = new javax.swing.JDialog(w, java.awt.Dialog.ModalityType.APPLICATION_MODAL);
					((javax.swing.JDialog)jwindow).setUndecorated(true);
				}}}
			}
			else {
				embed {{{
					javax.swing.JFrame jframe = new javax.swing.JFrame();
					jwindow = jframe;
				}}}
			}
		}
		embed {{{
			if(jwindow != null) {
				if(jwindow instanceof javax.swing.JDialog) {
					((javax.swing.JDialog)jwindow).setDefaultCloseOperation(javax.swing.WindowConstants.DO_NOTHING_ON_CLOSE);
				}
				else if(jwindow instanceof javax.swing.JFrame) {
					((javax.swing.JFrame)jwindow).setDefaultCloseOperation(javax.swing.WindowConstants.DO_NOTHING_ON_CLOSE);					
				}
				jwindow.setLayout(null);
				window_count ++;
				jwindow.addWindowListener(new java.awt.event.WindowAdapter() {
					public void windowClosing(java.awt.event.WindowEvent evt) {
						eq.gui.FrameCloseRequestEvent ce = new eq.gui.FrameCloseRequestEvent();
						_event(ce);
						if(ce.get_accepted()) {
							jwindow.dispose();
						}
					}
					public void windowClosed(java.awt.event.WindowEvent evt) {
						if(controller != null) {
							controller.stop();
							controller.destroy();
							controller = null;
						}
						window_count --;
						if(window_count < 1) {
							System.exit(0);
						}
					}
					public void windowActivated(java.awt.event.WindowEvent evt) {
						jwindow.repaint(0,0,(int)get_width(), (int)get_height());
					}
				});
				jwindow.addComponentListener(new java.awt.event.ComponentAdapter() {
					public void componentResized(java.awt.event.ComponentEvent evt) {
						eq.gui.FrameResizeEvent e = new eq.gui.FrameResizeEvent();
						e.set_width(get_width());
						e.set_height(get_height());
						_event(e);
					}
				});
				java.awt.Container container = get_container_pane();
				SwingFrameKeyListener kl = new SwingFrameKeyListener(this);
				SwingFrameMouseListener ml = new SwingFrameMouseListener(this);
				container.setFocusable(true);
				container.setFocusTraversalKeysEnabled(false);
				container.addKeyListener(kl);
				container.addMouseListener(ml);
				container.addMouseWheelListener(ml);
				container.addMouseMotionListener(ml);
			}
		}}}
		return(true);
	}

	int frametype;

	public int get_frametype() {
		return(frametype);
	}

	public bool initialize(FrameController wa, CreateFrameOptions aopts) {
		if(controller != null || wa == null) {
			return(false);
		}
		Log.debug("Opening a new frame ..");
		controller = wa;
		var opts = aopts;
		if(opts == null && controller != null) {
			opts = controller.get_frame_options();
		}
		if(opts == null) {
			opts = new CreateFrameOptions();
		}
		this.frametype = opts.get_type();
		if(do_open_frame(opts.get_screen(), frametype, opts.get_parent()) == false) {
			Log.error("Failed to open frame.");
			return(false);
		}
		this.dpi = determine_dpi();
		Log.debug("DPI determined as %d".printf().add(dpi));
		controller.initialize_frame(this);
		var minsz = opts.get_minimum_size();
		if(minsz != null) {
			set_minimum_size(minsz.get_width(), minsz.get_height());
		}
		var maxsz = opts.get_maximum_size();
		if(maxsz != null) {
			set_maximum_size(maxsz.get_width(), maxsz.get_height());
		}
		int rw = 0, rh = 0;
		var psz = opts.get_default_size();
		if(psz == null) {
			psz = controller.get_preferred_size();
		}
		if(psz != null) {
	       rw = psz.get_width();
	       rh = psz.get_height();
		}
		if(rw < 1) {
			rw = 640;
		}
		if(rh < 1) {
			rh = 480;
		}
		embed {{{
			java.awt.Dimension dscr = java.awt.Toolkit.getDefaultToolkit().getScreenSize();
			if(rw > dscr.width) {
				rw = dscr.width;
			}
			if(rh > dscr.height) {
				rh = dscr.height;
			}
		}}}
		Log.debug("Initial window size will be %dx%d".printf().add(rw).add(rh));
		if(frametype != CreateFrameOptions.TYPE_FULLSCREEN) {
			resize(rw, rh);
		}
		var pp = opts.get_parent();
		var fstype = CreateFrameOptions.TYPE_FULLSCREEN;
		embed {{{
			java.awt.Point pt = null;
			if(pp != null && pp instanceof SwingFrame) {
				java.awt.Window win = ((SwingFrame)pp).jwindow;
				java.awt.Rectangle rect = win.getBounds();
				pt = win.getLocation();
				pt.translate(rect.width/2-rw/2, rect.height/2-rh/2);
			}
			else if(frametype != fstype) {
				java.awt.GraphicsEnvironment gfxenv = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment();
				pt = gfxenv.getCenterPoint();
				if(pt != null) {
					pt.translate(-rw/2, -rh/2);
				}
			}
			if(pt != null) {
				jwindow.setLocation(pt);
			}
		}}}
		controller.start();
		return(true);
	}

	public int get_frame_type() {
		return(Frame.TYPE_DESKTOP);
	}

	public bool has_keyboard() {
		return(true);
	}

	public FrameController get_controller() {
		return(controller);
	}

	public int get_dpi() {
		return(dpi);
	}

	public void set_icon(Image icon) {
		embed {{{
			if(jwindow == null) {
				return;
			}
			java.awt.Image img = null;
			if(icon != null && icon instanceof AWTImage) {
				img = ((AWTImage)icon).awtimage;
			}
			jwindow.setIconImage(img);
		}}}
	}

	public void set_title(String title) {
		var tt = title;
		if(tt == null) {
			tt = "";
		}
		embed {{{
			if(jwindow != null && jwindow instanceof java.awt.Frame) {
				((java.awt.Frame)jwindow).setTitle(tt.to_strptr());
			}
		}}}
	}

	public void resize(int w, int h) {
		embed {{{
			if(jwindow != null) {
				jwindow.setSize(w, h);
			}
		}}}
	}

	public void hide() {
		embed {{{
			if(jwindow != null) {
				jwindow.setVisible(false);
			}
		}}}
	}

	public void show() {
		embed {{{
			if(jwindow != null) {
				jwindow.setVisible(true);
			}
		}}}
	}

	public void close() {
		embed {{{
			if(jwindow != null) {
				jwindow.dispose();
			}
		}}}
	}

	Cursor _cursor;

	public Cursor get_current_cursor() {
		return(_cursor);
	}

	public void set_current_cursor(Cursor cursor) {
		_cursor = cursor;
		if(cursor == null) {
			embed {{{
				jwindow.setCursor(java.awt.Cursor.getDefaultCursor());
			}}}
			return;
		}
		int type = cursor.get_stock_cursor_id();
		int ct;
		embed {{{
			java.awt.Cursor cs = null;
			if(type == cursor.STOCK_NONE) {
				java.awt.image.BufferedImage cimg = new java.awt.image.BufferedImage(16, 16, java.awt.image.BufferedImage.TYPE_INT_ARGB);
				cs = java.awt.Toolkit.getDefaultToolkit().createCustomCursor(cimg, new java.awt.Point(0,0), "blank");
			}
			else if(type == cursor.STOCK_EDITTEXT) {
				cs = java.awt.Cursor.getPredefinedCursor(java.awt.Cursor.TEXT_CURSOR);
			}
			else if(type == cursor.STOCK_POINT) {
				cs = java.awt.Cursor.getPredefinedCursor(java.awt.Cursor.HAND_CURSOR);				
			}
			else if(type == cursor.STOCK_RESIZE_HORIZONTAL) {
				//FIXME
			}
			else if(type == cursor.STOCK_RESIZE_VERTICAL) {
				//FIXME
			}
			jwindow.setCursor(cs);
		}}}
	}

	embed {{{
		public java.awt.Window get_java_window() {
			return(jwindow);
		}

		java.awt.Container get_container_pane() {
			if(jwindow instanceof javax.swing.JFrame) {
				return(((javax.swing.JFrame)jwindow).getContentPane());
			}
			else if(jwindow instanceof javax.swing.JDialog) {
				return(((javax.swing.JDialog)jwindow).getContentPane());
			}
			else if(jwindow instanceof javax.swing.JWindow) {
				return(((javax.swing.JWindow)jwindow).getContentPane());
			}
			return(null);
		}
	}}}

	public double get_width() {
		double v = 0;
		embed {{{
			if(jwindow != null) {
				java.awt.Container con = get_container_pane();
				java.awt.Dimension sz = con.getSize();
				if(sz != null) {
					v = (double)sz.width;
				}
			}
		}}}
		return(v);
	}

	public double get_height() {
		double v = 0;
		embed {{{
			if(jwindow != null) {
				java.awt.Container con = get_container_pane();
				java.awt.Dimension sz = con.getSize();
				if(sz != null) {
					v = (double)sz.height;
				}
			}
		}}}
		return(v);
	}

	// Components added to a container are tracked in a list. 
	// The order of the list will define the components' front-to-back stacking order within the container. 
	// If no index is specified when adding a component to a container, 
	// it will be added to the end of the list (and hence to the bottom of the stacking order). 

	Surface create_surface_component(SurfaceOptions opts) {
		if(opts == null) {
			return(null);
		}
		Surface ss = opts.get_surface();
		var ctype = SurfaceOptions.SURFACE_TYPE_CONTAINER;
		embed {{{
			if(ss != null && ss instanceof java.awt.Component) {
				return(ss);
			}
			if(opts.get_surface_type() == ctype) {
				return((eq.gui.Surface)new SwingFrameSurface());
			}
			ss = (eq.gui.Surface)new SwingFrameRenderableSurface();
		}}}
		return(ss);
	}

	Surface add_surface_top(SurfaceOptions opts) {
		var v = create_surface_component(opts);
		if(v == null) {
			return(null);
		}
		embed {{{
			jwindow.add((java.awt.Component)v, 0);
		}}}
		return(v);
	}

	Surface add_surface_bottom(SurfaceOptions opts) {
		var v = create_surface_component(opts);
		if(v == null) {
			return(null);
		}
		embed {{{
			jwindow.add((java.awt.Component)v);
		}}}
		return(v);
	}

	embed {{{
		int parent_get_index(java.awt.Container pp, java.awt.Component comp) {
			for(int i = 0; i < pp.getComponentCount(); i++) {
				if(pp.getComponent(i) == comp) {
					return(i);
				}
			}
			return(-1);
		}
	}}}

	Surface add_surface_adjacent(Surface rel, SurfaceOptions opts, int ab) {
		Surface v;
		embed "java" {{{
			if(rel == null || rel instanceof java.awt.Component == false) {
				return(add_surface_bottom(opts));
			}
			java.awt.Component r = (java.awt.Component)rel;
			java.awt.Container pp = r.getParent();
			if(pp == null) {
				return(add_surface_top(opts));
			}
			int zo = parent_get_index(pp, r);
			if(zo < 0) {
				return(add_surface_top(opts));
			}
			v = create_surface_component(opts);
			if(v == null) {
				return(null);
			}
			pp.add((java.awt.Component)v, zo+ab);
		}}}
		return(v);
	}

	Surface add_surface_inside(Surface rel, SurfaceOptions opts) {
		Surface v;
		embed "java" {{{
			if(rel == null || rel instanceof java.awt.Container == false) {
				return(add_surface_adjacent((eq.gui.Surface)rel, opts, 0));
			}
			v = create_surface_component(opts);
			if(v == null) {
				return(null);
			}
			java.awt.Container c = (java.awt.Container)rel;
			c.add((java.awt.Component)v);
		}}}
		return(v);
	}

	public Surface add_surface(SurfaceOptions opts) {
		if(opts.get_placement() == eq.gui.SurfaceOptions.TOP) {
			return(add_surface_top(opts));
		}
		else if(opts.get_placement() == SurfaceOptions.BOTTOM) {
			return(add_surface_bottom(opts));
		}
		else if(opts.get_placement() == SurfaceOptions.ABOVE) {
			return(add_surface_adjacent(opts.get_relative(), opts, 0));
		}
		else if(opts.get_placement() == SurfaceOptions.BELOW) {
			return(add_surface_adjacent(opts.get_relative(), opts, 1));
		}
		else if(opts.get_placement() == SurfaceOptions.INSIDE) {
			return(add_surface_inside(opts.get_relative(), opts));
		}
		return(null);
	}

	public void remove_surface(Surface ss) {
		embed {{{
			if(ss == null || ss instanceof java.awt.Component == false) {
				return;
			}
			java.awt.Component c = (java.awt.Component)ss;
			java.awt.Container pp = c.getParent();
			if(pp == null) {
				return;
			}
			pp.remove(c);
			pp.repaint();
		}}}
	}

	public void set_minimum_size(int w, int h) {
		embed {{{
			if(jwindow != null) {
				jwindow.setMinimumSize(new java.awt.Dimension(w, h));
			}
		}}}
	}

	public void set_maximum_size(int w, int h) {
		embed {{{
			if(jwindow != null) {
				jwindow.setMaximumSize(new java.awt.Dimension(w, h));
			}
		}}}
	}
}
