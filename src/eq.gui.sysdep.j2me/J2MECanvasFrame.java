
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

package eq.gui.sysdep.j2me;

import javax.microedition.lcdui.Canvas;
import javax.microedition.lcdui.Graphics;

public class J2MECanvasFrame extends Canvas implements eq.gui.ClosableFrame, eq.gui.CapabilityFrame, eq.gui.vg.VgFrame, eq.gui.Frame, eq.gui.Size, eq.gui.SurfaceContainer
{
	J2MECanvasFrame parent_frame;
	eq.gui.vg.VgSurfaceList surfaces;
	eq.gui.FrameController engine;
	KeypadTypist typist;

	public J2MECanvasFrame() {
		surfaces = new eq.gui.vg.VgSurfaceList();
		if("1".equals(getKeyName('1'))) {
			typist = new KeypadTypist(this);
		}
	}
	
	public int get_frame_type() {
		return(eq.gui.FrameStatic.TYPE_PHONE);
	}

	public boolean has_keyboard() {
		return(false);
	}

	public void paint(Graphics g) {
		J2MEGraphicsVgContext ctx = new J2MEGraphicsVgContext(g, getWidth(), getHeight());
		eq.gui.vg.VgPathRectangle rr = eq.gui.vg.VgPathRectangle.eq_gui_vg_VgPathRectangle_create(0, 0, getWidth(), getHeight()); 
		eq.api.Stack clips = eq.api.Stack.eq_api_Stack_create();
		clips.push((eq.api.Object)rr);
		surfaces.draw((eq.gui.vg.VgContext)ctx, 0, 0, getWidth(), getHeight(), clips);
	}

	public J2MECanvasFrame set_frame_controller(eq.gui.FrameController fc) {
		this.engine = fc;
		return(this);
	}

	public void close() {
		if(engine!=null) {
			engine.stop();
			engine.destroy();
		}
		if(parent_frame != null) {
			javax.microedition.lcdui.Display disp = J2MEDisplay.get_display();
			if(disp!=null) {
				disp.setCurrent(parent_frame);
			}
		}
	}

	public void set_parent_frame(J2MECanvasFrame parent) {
		this.parent_frame = parent;
	}
	
	public eq.api.Object create_main_object() {
		return((eq.api.Object)engine);
	}
	
	public void initialize_frame() {
		eq.api.Object main = create_main_object();
		if(main instanceof eq.gui.FrameController == false) {
			return;
		}
		this.engine = (eq.gui.FrameController)main;
		eq.gui.CreateFrameOptions opts = this.engine.get_frame_options();
		if(opts != null && opts.get_type() == eq.gui.CreateFrameOptions.TYPE_FULLSCREEN) {
			setFullScreenMode(true);
		}
		this.engine.initialize_frame((eq.gui.Frame)this);
	}
	
	void _event(eq.api.Object o) {
		if(engine != null) {
			engine.on_event(o);
		}
	}

	public eq.gui.FrameController get_controller() {
		return(engine);
	}
	
	public boolean is_capability_supported(eq.api.String cap) {
		if(cap == null) {
			return(true);
		}
		String str = cap.to_strptr();
		if(str == null) {
			return(true);
		}
		if(str.equals("alpha")) {
			return(false);
		}
		if(str.equals("rotation")) {
			return(false);
		}
		return(true);
	}
	
	public void start() {
		engine.start();
	}
	
	public void pause() {
		engine.stop();
	}
	
	public void sizeChanged(int w, int h) {
		eq.gui.FrameResizeEvent fre = new eq.gui.FrameResizeEvent();
		fre.set_width(w);
		fre.set_height(h);
		_event(fre);
	}
	
	public void pointerPressed(int x, int y) {
		eq.gui.PointerPressEvent ppe = new eq.gui.PointerPressEvent();
		ppe.set_button(1);
		ppe.set_x(x);
		ppe.set_y(y);
		ppe.set_pointer_type(eq.gui.PointerEvent.TOUCH);
		_event(ppe);
	}
	
	public void pointerReleased(int x, int y) {
		eq.gui.PointerReleaseEvent pre = new eq.gui.PointerReleaseEvent();
		pre.set_button(1);
		pre.set_x(x);
		pre.set_y(y);
		pre.set_pointer_type(eq.gui.PointerEvent.TOUCH);
		eq.gui.PointerLeaveEvent ple = new eq.gui.PointerLeaveEvent();
		ple.set_id(1);
		ple.set_x(x);
		ple.set_y(y);
		ple.set_pointer_type(eq.gui.PointerEvent.TOUCH);
		_event(ple);
		_event(pre);
	}
	
	public void pointerDragged(int x, int y) {
		eq.gui.PointerMoveEvent pme = new eq.gui.PointerMoveEvent();
		pme.set_x(x);
		pme.set_y(y);
		pme.set_pointer_type(eq.gui.PointerEvent.TOUCH);
		_event(pme);
	}

	private eq.api.String eqstr(java.lang.String s) {
		return(eq.api.StringStatic.eq_api_StringStatic_for_strptr(s));
	}

	eq.gui.KeyEvent key_event(int keyCode, eq.gui.KeyEvent e) {
		String keyName = null;
		String strKeyCode = getKeyName(keyCode);
		eq.api.String keyStr = eqstr(new java.lang.Character((char)keyCode).toString());
		if(keyCode == -6) {
			keyName = "tab";
			keyStr = null;
		}
		else if(keyCode == -7) {
			keyName = "back";
			keyStr = null;
		}
		else if(keyCode == -8 || keyCode == 8) {
			keyName = "backspace";
			keyStr = null;
		}
		else if(keyCode == -5 ||"ENTER".equals(strKeyCode) || "SELECT".equals(strKeyCode)) {
			keyName = "enter";
			keyStr = null;
		}
		else if(keyCode == -4) {
			keyName = "right";
			keyStr = null;
		}
		else if(keyCode == -3) {
			keyName = "left";
			keyStr = null;
		}
		else if(keyCode == -1) {
			keyName = "up";
			keyStr = null;
		}
		else if(keyCode == -2) {
			keyName = "down";
			keyStr = null;
		}
		return(e.set_name(keyName != null ? eqstr(keyName) : null)
			.set_str(keyStr)
			.set_shift(false)
		);
	}
	
	public void keyPressed(int keycode) {
		eq.gui.KeyPressEvent e = new eq.gui.KeyPressEvent();
		boolean typed = false;
		key_event(keycode, e);
		if(typist != null && e.get_name() == null) {
			if(typist.on_key_press(keycode, engine)) {
				typed = true;
			}
		}
		if(typed == false) { 
			_event(e);
		}
	}

	public void keyReleased(int keycode) {
		eq.gui.KeyReleaseEvent e = new eq.gui.KeyReleaseEvent();
		boolean typed = false;
		key_event(keycode, e);
		if(typist != null && e.get_name() == null) {
			typist.on_key_release();
			typed = true;
		}
		if(typed == false) {
			_event(e);
		}
	}

	public eq.gui.vg.VgSurface create_surface(eq.gui.SurfaceOptions opts) {
		eq.gui.vg.VgSurface v = new eq.gui.vg.VgSurface().set_cached(false);
		v.set_parent((eq.gui.vg.VgFrame)this);
		return(v);
	}

	public eq.gui.Surface add_surface(eq.gui.SurfaceOptions opts) {
		if(opts == null) {
			return(null);
		}
		eq.gui.vg.VgSurface v = create_surface(opts);
		if(v == null) {
			return(null);
		}
		if(opts.get_placement() == eq.gui.SurfaceOptions.TOP) {
			return(surfaces.add_surface_top(v));
		}
		else if(opts.get_placement() == eq.gui.SurfaceOptions.BOTTOM) {
			return(surfaces.add_surface_bottom(v));
		}
		else if(opts.get_placement() == eq.gui.SurfaceOptions.ABOVE) {
			eq.gui.Surface surf = opts.get_relative();
			if(surf instanceof eq.gui.vg.VgSurface) {
				return(surfaces.add_surface_above((eq.gui.vg.VgSurface)surf, v));
			}
		}
		else if(opts.get_placement() == eq.gui.SurfaceOptions.BELOW) {
			eq.gui.Surface surf = opts.get_relative();
			if(surf instanceof eq.gui.vg.VgSurface) {
				return(surfaces.add_surface_below((eq.gui.vg.VgSurface)surf, v));
			}
		}
		else if(opts.get_placement() == eq.gui.SurfaceOptions.INSIDE) {
			eq.gui.Surface surf = opts.get_relative();
			if(surf instanceof eq.gui.vg.VgSurface) {
				return(surfaces.add_surface_inside((eq.gui.vg.VgSurface)surf, v));
			}
		}
		return(null);
	}
	
	public void invalidate(int x, int y, int w, int h) {
		repaint(x, y, w, h);
	}
	
	public int get_dpi() {
		return(96);
	}
	
	public double get_width() {	
		return((double)getWidth());
	}

	public double get_height() {	
		return((double)getHeight());
	}

	public void remove_surface(eq.gui.Surface ss) {
		if(ss instanceof eq.gui.vg.VgSurface) {
			surfaces.remove_surface((eq.gui.vg.VgSurface)ss);
		}
	}
}
