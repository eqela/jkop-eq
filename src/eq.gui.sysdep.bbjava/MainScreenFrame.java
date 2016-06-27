
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
import net.rim.device.api.ui.container.*;
import net.rim.device.api.ui.decor.*;
import net.rim.device.api.ui.component.*;
import net.rim.device.api.system.*;

public class MainScreenFrame extends MainScreen
{
	public eq.api.Object main_object;
	MainScreenFrame parent_frame;
	BBJavaManagerFrame mymanager;
	String fixed_orientation;
	ScreenEventHelper helper;
	int width;
	int height;

	public eq.api.Object get_main_object() {
		return(null);
	}

	public void on_load_screen() {
		eq.api.Object main = get_main_object();
		if(main != null && main instanceof eq.gui.FrameController == false) {
			return;
		}
		mymanager = new BBJavaManagerFrame();
		helper = new ScreenEventHelper(mymanager);
		add(mymanager);
		resize_screen(0, 0);
		if(fixed_orientation != null) {
			mymanager.set_preferred_size(width, height);
		}
		mymanager.initialize((eq.gui.FrameController)main, null);
	}

	public void set_fixed_orientation(String orientation) {
		this.fixed_orientation = orientation;
	}

	eq.api.String eqstr(java.lang.String s) {
		if(s == null) {
			return(null);
		}
		return(eq.api.StringStatic.eq_api_StringStatic_for_strptr(s));
	}

	protected boolean onSavePrompt() {
		return(true);
    }

	protected boolean keyChar(char c, int status, int time) {
		helper.key_char(c, status, time);
		return(super.keyChar(c, status, time));
	}
	
	protected boolean navigationClick(int s, int t) {
		helper.navigation_click(s, t);
		return(super.navigationClick(s, t));
	}

	protected boolean navigationUnclick(int s, int t) {
		helper.navigation_unclick(s, t);
		return(super.navigationUnclick(s, t));
	}

	protected boolean navigationMovement(int dx, int dy, int status, int time) {
		if(helper.navigation_movement(dx, dy, status, time)) {
			return(true);
		}
		return(super.navigationMovement(dx, dy, status, time));
	}

	protected boolean touchEvent(TouchEvent message) {
		if(helper.touch_event(message)) {
			return(true);
		}
		return(super.touchEvent(message));
	}

	public void resize_screen(int aw, int ah) {
		int ow = aw, oh = ah;
		boolean is_sublayout = false;
		if(ow == 0 || oh == 0) {
			ow = (int)Display.getWidth();
			oh = (int)Display.getHeight();
		}
		else {
			is_sublayout = true;
		}
		int w = ow, h = oh;
		if(Display.getOrientation() == Display.ORIENTATION_LANDSCAPE || "landscape".equals(fixed_orientation)) {
			if(w < h) {
				w = oh;
				h = ow;
			}
		}
		else if(Display.getOrientation() == Display.ORIENTATION_PORTRAIT || "portrait".equals(fixed_orientation)) {
			if(h < w) {
				w = oh;
				h = ow;
			}
		}
		if(is_sublayout) {
			super.sublayout(w, h);
		}
		if(width == 0 && height == 0) {
			width = w;
			height = h;
		}
		else {
			mymanager.sublayout(w, h);
		}
	}

	public void on_activate() {
		if(mymanager != null) {
			mymanager.on_start();
			resize_screen(0, 0);
		}
	}

	public void on_deactivate() {
		if(mymanager != null) {
			mymanager.on_stop();
		}
	}

	protected void sublayout(int ow, int oh) {
		resize_screen(ow, oh);
	}

	public boolean onClose() {
		if(helper.on_close()) {
			return(false);
		}
		return(super.onClose());
	}
}
