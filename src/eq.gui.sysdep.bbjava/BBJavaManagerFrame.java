
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

package eq.gui.sysdep.bbjava;

import net.rim.device.api.ui.*;
import net.rim.device.api.ui.component.*;
import net.rim.device.api.ui.container.*;
import net.rim.device.api.system.Display;

class BBJavaManagerFrame extends Manager implements Invalidatable, eq.gui.ClosableFrame, eq.gui.CapabilityFrame, eq.gui.Frame, eq.gui.SurfaceContainer, eq.gui.Size
{	
	eq.gui.FrameController controller;
	eq.gui.Size preferred_size;

	public BBJavaManagerFrame() {
		super(0);
	}

	public BBJavaManagerFrame(long s) {
		super(s);
	}

	public int get_frame_type() {
		return(eq.gui.FrameStatic.TYPE_PHONE);
	}

	public boolean has_keyboard() {
		return(false);
	}

	public void initialize(eq.gui.FrameController fc, eq.gui.CreateFrameOptions opts) {	
		controller = fc;
		controller.initialize_frame(this);
		if(opts != null && opts.get_parent() instanceof BBJavaManagerFrame) {
			BBJavaManagerFrame parent_frame = (BBJavaManagerFrame)opts.get_parent();
			if(parent_frame!=null) {
				eq.gui.Size sz = controller.get_preferred_size();
				int w = 320, h = 240;
				if(sz != null) {
					w = (int)sz.get_width();
					h = (int)sz.get_height();
				}
				if(w > parent_frame.get_width()) {
					w = (int)parent_frame.get_width();
				}
				if(h > parent_frame.get_height()) {
					h = (int)parent_frame.get_height();
				}
				set_preferred_size(w, h);
			}
		}
		System.out.println("Blackberry Frame has been initialized. " + getPreferredWidth() + "x" + getPreferredHeight() + " px");
	}

	public void set_preferred_size(int w, int h) {
		preferred_size = eq.gui.SizeStatic.eq_gui_SizeStatic_instance(w, h);
	}

	public int getPreferredWidth() {
		if(preferred_size!=null) {
			return((int)preferred_size.get_width());
		}
		return(Display.getWidth());
	}

	public int getPreferredHeight() {
		if(preferred_size!=null) {
			return((int)preferred_size.get_height());
		}
		return(Display.getHeight());
	}

	public void sublayout(int aw, int ah) {
		int w = aw, h = ah;
		int vw = getPreferredWidth(), vh = getPreferredHeight();
		if(w > vw && vw > 0) {
			w = vw;
		}
		if(h > vh && vh > 0) {
			h = vh;
		}
		setExtent(w, h);
		int c = getFieldCount();
		for(int i = 0; i < c; i++) {
			Field wf = getField(i);
			if(wf != null) {
				int pw = wf.getPreferredWidth(), ph = wf.getPreferredHeight();
				layoutChild(wf, pw, ph);
			}
		}
		eq.gui.FrameResizeEvent fre = new eq.gui.FrameResizeEvent();
		fre.set_width(w);
		fre.set_height(h);
		_event(fre);
		invalidate();
	}

	public void close() {
		if(controller != null) {
			controller.stop();
			controller.destroy();
			controller = null;
		}
		Manager manager = getScreen();
		if(manager instanceof MyPopupScreen) {
			((MyPopupScreen)manager).close();
		}	
	}

	public void _invalidate(int x, int y, int w, int h) {
		invalidate(x, y, w, h);
	}

	public eq.gui.FrameController get_controller() {
		return(controller);
	}

	public void on_start() {
		if(controller != null) {
			controller.start();
		}
	}

	public void on_stop() {
		if(controller != null) {
			controller.stop();
		}	
	}

	boolean _event(eq.api.Object o) {
		if(controller != null) {
			return(controller.on_event(o));
		}
		return(false);
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

	public int get_dpi() {
		double dpi = (Display.getVerticalResolution() / 39.370078740157);
		return((int)dpi);
	}

	public double get_width() {
		return(getWidth());
	}

	public double get_height() {
		return(getHeight());
	}

	eq.gui.Surface create_surface(eq.gui.SurfaceOptions opts) {
		if(opts == null) {
			return(null);
		}
		eq.gui.Surface surf = opts.get_surface();
		if(surf != null && surf instanceof Field) {
			return(surf);
		}
		if(opts.get_surface_type() == eq.gui.SurfaceOptions.SURFACE_TYPE_CONTAINER) {
			return(new ContainerFieldSurface());
		}
		return(new FieldSurface());
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

	Manager get_parent_manager(Field field) {
		if(field == null) {
			return(null);
		}
		Manager v = field.getManager();
		if(v == null) {
			return(null);
		}
		if(v instanceof Manager == false) {
			return(null);
		}
		return(v);
	}

	public void remove_surface(eq.gui.Surface ss) {
		if(ss == null) {
			return;
		}
		if(ss instanceof Field == false) {
			return;
		}
		Manager mp = get_parent_manager((Field)ss);
		if(mp != null) {
			mp.delete((Field)ss);
			mp.invalidate();
		}
	}

	public eq.gui.Surface add_surface_top(eq.gui.SurfaceOptions opts) {
		eq.gui.Surface surf = create_surface(opts);
		if(surf == null) {
			return(null);
		}
		add((Field)surf);
		invalidate();
		return(surf);
	}
	
	public eq.gui.Surface add_surface_bottom(eq.gui.SurfaceOptions opts) {
		eq.gui.Surface surf = create_surface(opts);
		if(surf == null) {
			return(null);
		}
		insert((Field)surf, 0);
		invalidate();
		return(surf);
	}

	public eq.gui.Surface add_surface_above(eq.gui.Surface ss, eq.gui.SurfaceOptions opts) {
		if(ss == null || ss instanceof Field == false) {
			return(add_surface_top(opts));
		}
		Manager mp = get_parent_manager((Field)ss);
		if(mp == null) {
			return(add_surface_top(opts));
		}
		int ssi = ((Field)ss).getIndex();
		if(ssi < 0) {
			return(add_surface_top(opts));
		}
		eq.gui.Surface surf = create_surface(opts);
		if(surf == null) {
			return(null);
		}
		mp.insert((Field)surf, ssi+1);
		mp.invalidate();
		return(surf);
	}

	public eq.gui.Surface add_surface_below(eq.gui.Surface ss, eq.gui.SurfaceOptions opts) {
		if(ss == null || ss instanceof Field == false) {
			return(add_surface_top(opts));
		}
		Manager mp = get_parent_manager((Field)ss);
		if(mp == null) {
			return(add_surface_top(opts));
		}
		int ssi = ((Field)ss).getIndex();
		if(ssi < 0) {
			return(add_surface_top(opts));
		}
		eq.gui.Surface surf = create_surface(opts);
		if(surf == null) {
			return(null);
		}
		mp.insert((Field)surf, ssi);
		mp.invalidate();
		return(surf);
	}

	public eq.gui.Surface add_surface_inside(eq.gui.Surface ss, eq.gui.SurfaceOptions opts) {
		if(ss == null || ss instanceof Manager == false) {
			System.out.println("Attempted to add a surface inside a non-container surface. Adding above instead.");
			return(add_surface_above(ss, opts));
		}
		eq.gui.Surface surf = create_surface(opts);
		if(surf == null) {
			return(null);
		}
		((Manager)ss).insert((Field)surf, 0);
		((Manager)ss).invalidate();
		return(surf);
	}
}
