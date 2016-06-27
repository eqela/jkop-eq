
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
 
class KeypadTypist extends eq.api.Object implements eq.os.task.TimerHandler
{
	final char[] KEYS_1 = {'.', ',', '?', '-', '_', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '1'};
	final char[] KEYS_2 = {'a', 'b', 'c', 'A', 'B', 'C', '2'};
	final char[] KEYS_3 = {'d', 'e', 'f', 'D', 'E', 'F', '3'};
	final char[] KEYS_4 = {'g', 'h', 'i', 'G', 'H', 'I', '4'};
	final char[] KEYS_5 = {'j', 'k', 'l', 'J', 'K', 'L', '5'};
	final char[] KEYS_6 = {'m', 'n', 'o', 'M', 'N', 'O', '6'};
	final char[] KEYS_7 = {'p', 'q', 'r', 's', 'P', 'Q', 'R', 'S', '7'};
	final char[] KEYS_8 = {'t', 'u', 'v', 'T', 'U', 'V', '8'};
	final char[] KEYS_9 = {'w', 'x', 'y', 'z', 'W', 'X', 'Y', 'Z', '9'};
	final char[] KEYS_0 = {' ', '\n', '0'};
	eq.os.task.BackgroundTaskManager btm = null;
	eq.os.task.BackgroundTask press_timer = null;
	Canvas canvas;
	eq.api.String integer_input = null;
	char current_char = 0;
	int curr_key = 0;
	int curr_idx = 0;
	boolean is_typing = false;

	public KeypadTypist(Canvas c) {
		canvas = c;
		btm = eq.gui.GUIStatic.engine.get_background_task_manager();
	}
	
	eq.api.String eqstr(String str) {
		return(eq.api.StringStatic.eq_api_StringStatic_for_strptr(str));
	}
	
	boolean _event(eq.api.Object o, eq.gui.KeyEvent e) {
		if(o instanceof eq.gui.FrameController) {
			return(((eq.gui.FrameController)o).on_event(e));
		}
		return(false);
	}

	public boolean on_key_press(int keycode, eq.gui.FrameController e) {
		char[] chars = get_chars(keycode);
		if(chars == null) {
			boolean v = is_typing && java.lang.Math.abs(keycode) != 8;
			reset_typist(false);
			return(v);
		}
		if(curr_key != keycode) {
			curr_key = keycode;
			reset_typist(false);
		}
		if(curr_idx >= chars.length) {
			curr_idx = 0;
		}
		if(is_typing) {
			_event((eq.api.Object)e, new eq.gui.KeyPressEvent()
				.set_name(eqstr("backspace"))
			);
			if(press_timer != null) {
				press_timer.abort();
			}
		}
		boolean v = _event((eq.api.Object)e, new eq.gui.KeyPressEvent()
			.set_str(eqstr(new java.lang.Character(chars[curr_idx]).toString())));
		integer_input = eqstr(canvas.getKeyName(keycode));
		if(v) {
			curr_idx++;
			is_typing = true;
		}
		else {
			curr_idx = 0;
		}
		press_timer = btm.start_timer(1500000, (eq.os.task.TimerHandler)this, (eq.api.Object)e);
		return(v);
	}
	
	public boolean on_key_release() {
		if(integer_input != null) {
			integer_input = null;
			return(true);
		}
		return(false);
	}

	public boolean on_timer(eq.api.Object o) {
		if(integer_input != null) {
			_event(o, new eq.gui.KeyPressEvent()
				.set_name(eqstr("backspace"))
			);
			_event(o, new eq.gui.KeyPressEvent()
				.set_str(integer_input)
			);
		}
		reset_typist(true);
		return(false);
	}

	public void reset_typist(boolean is_request_from_timer) {
		if(is_request_from_timer == false && press_timer != null) {
			press_timer.abort();
		}
		curr_idx = 0;
		is_typing = false;
		integer_input = null;
	}

	private char[] get_chars(int keycode) {
		if(keycode == Canvas.KEY_NUM1) {
			return(KEYS_1);
		}
		else if(keycode == Canvas.KEY_NUM2) {
			return(KEYS_2);
		}
		else if(keycode == Canvas.KEY_NUM3) {
			return(KEYS_3);
		}
		else if(keycode == Canvas.KEY_NUM4) {
			return(KEYS_4);
		}
		else if(keycode == Canvas.KEY_NUM5) {
			return(KEYS_5);
		}
		else if(keycode == Canvas.KEY_NUM6) {
			return(KEYS_6);
		}
		else if(keycode == Canvas.KEY_NUM7) {
			return(KEYS_7);
		}
		else if(keycode == Canvas.KEY_NUM8) {
			return(KEYS_8);
		}
		else if(keycode == Canvas.KEY_NUM9) {
			return(KEYS_9);
		}
		else if(keycode == Canvas.KEY_NUM0) {
			return(KEYS_0);
		}
		return(null);
	}
}
