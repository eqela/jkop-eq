
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

import eq.gui.*;
import net.rim.device.api.ui.TouchEvent;
import net.rim.device.api.system.KeypadListener;

class ScreenEventHelper
{
	BBJavaManagerFrame frame;
	public ScreenEventHelper(BBJavaManagerFrame frame) {
		this.frame = frame;
	}

	eq.api.String eqstr(java.lang.String s) {
		if(s == null) {
			return(null);
		}
		return(eq.api.StringStatic.eq_api_StringStatic_for_strptr(s));
	}

	public void add_key_event(eq.gui.KeyEvent e, int status, char c) {
		eq.api.String key_string = eqstr(String.valueOf(c));
		java.lang.String keyName = null;
		if(c == net.rim.device.api.system.Characters.ENTER) {
			keyName = "enter";
			key_string = null;
		}
		else if(c == net.rim.device.api.system.Characters.TAB) {
			keyName = "tab";
			key_string = null;
		}
		else if(c == net.rim.device.api.system.Characters.BACKSPACE) {
			keyName = "backspace";
			key_string = null;
		}
		else if(c == net.rim.device.api.system.Characters.ESCAPE) {
			keyName = "back";
			key_string = null;
		}
		boolean altpressed = false;
		boolean shiftpressed = false;
		if((status & KeypadListener.STATUS_SHIFT) == KeypadListener.STATUS_SHIFT) {
			shiftpressed = true;
		}
		if((status & KeypadListener.STATUS_ALT) == KeypadListener.STATUS_ALT) {
		}
		e.set_alt(altpressed);
		e.set_shift(shiftpressed);
		e.set_name(eqstr(keyName));
		e.set_str(key_string);
	}

	public boolean key_char(char c, int status, int time) {
		boolean v;
		KeyReleaseEvent kre = new KeyReleaseEvent();
		add_key_event(kre, status, c);
		KeyPressEvent kpe = new KeyPressEvent();
		add_key_event(kpe, status, c);
		v = frame._event(kpe);
		if(v == false) {
			v = frame._event(kre);
		}
		return(v);
	}

	public void navigation_click(int s, int t) {
		if(((s & KeypadListener.STATUS_TRACKWHEEL) == KeypadListener.STATUS_TRACKWHEEL) ||
			((s & KeypadListener.STATUS_FOUR_WAY) == KeypadListener.STATUS_FOUR_WAY)) {
			KeyPressEvent kpe = new KeyPressEvent();
			kpe.set_name(eqstr("enter"));
			frame._event(kpe);
		}
	}

	public void navigation_unclick(int s, int t) {
		if(((s & KeypadListener.STATUS_TRACKWHEEL) == KeypadListener.STATUS_TRACKWHEEL) ||
			((s & KeypadListener.STATUS_FOUR_WAY) == KeypadListener.STATUS_FOUR_WAY)) {
			KeyReleaseEvent kre = new KeyReleaseEvent();
			kre.set_name(eqstr("enter"));
			frame._event(kre);
		}
	}

	boolean send_navigation(boolean is_press, String direction) {
		KeyEvent ke = null;
		if(is_press) {
			ke = new KeyPressEvent();
		}
		else {
			ke = new KeyReleaseEvent();
		}
		ke.set_name(eqstr(direction));
		return(frame._event(ke));
	}

	public boolean navigation_movement(int dx, int dy, int status, int time) {
		String keyName = null;
		if(dx > 0 && dy == 0) {
			keyName = "right";
		}
		else if(dx < 0 && dy == 0) {
			keyName = "left";
		}
		else if(dy > 0 && dx == 0) {
			keyName = "down";
		}
		else if(dy < 0 && dx == 0) {
			keyName = "up";
		}
		if(send_navigation(true, keyName) == false && ("up".equals(keyName) || "down".equals(keyName))) {
			keyName = "focus_next";
			if("up".equals(keyName)) {
				keyName = "focus_previous";
			}
			send_navigation(false, keyName);
		}
		else {
			return(send_navigation(false, keyName));
		}
		return(false);
	}

	public boolean touch_event(TouchEvent message) {
		int eventCode = message.getEvent();
		boolean v = false;
		for(int i = 1; i < 3; i++) {
			int x = message.getX(i);
			int y = message.getY(i);
			if(x < 1 || y < 1) {
				continue;
			}
			if(eventCode == TouchEvent.DOWN) {
				PointerPressEvent ppe = new PointerPressEvent();
				ppe.set_button(1);
				ppe.set_id(i);
				ppe.set_x(x);
				ppe.set_y(y);
				ppe.set_pointer_type(PointerEvent.TOUCH);
				v = frame._event(ppe);
			 }
			 else if(eventCode == TouchEvent.UP) {
				PointerReleaseEvent pre = new PointerReleaseEvent();
				pre.set_button(1);
				pre.set_id(i);
				pre.set_x(x);
				pre.set_y(y);
				pre.set_pointer_type(PointerEvent.TOUCH);
				frame._event(pre);
				PointerLeaveEvent ple = new PointerLeaveEvent();
				ple.set_id(i);
				ple.set_x(x);
				ple.set_y(y);
				ple.set_pointer_type(PointerEvent.TOUCH);
				v = frame._event(ple);
			 }
			 else if(eventCode == TouchEvent.MOVE) {
				PointerMoveEvent pme = new PointerMoveEvent();
				pme.set_id(i);
				pme.set_x(x);
				pme.set_y(y);
				pme.set_pointer_type(PointerEvent.TOUCH);
				v = frame._event(pme);
			 }
		}
		return(v);
	}

	public boolean on_close() {
		eq.gui.KeyPressEvent kpe = new eq.gui.KeyPressEvent();
		kpe.set_name(eqstr("back"));
		return(frame._event(kpe));
	}
}
