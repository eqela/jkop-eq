
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

class PopupContainerWidget : LayerWidget
{
	property bool modal = true;
	property Widget next_to_focus;

	public Widget get_default_focus_widget() {
		var v = base.get_default_focus_widget();
		if(v == null) {
			v = this;
		}
		return(v);
	}

	public Widget get_hover_widget(int x, int y) {
		var v = base.get_hover_widget(x, y);
		if(v == null) {
			v = this;
		}
		return(v);
	}

	public bool on_pointer_press(int x, int y, int button, int id) {
		var r = base.on_pointer_press(x,y,button,id);
		// Simulate here the functionality of WidgetEngine:
		// If no one handles the event, we use it to effectively
		// close the virtual keyboard
		if(r == false) {
			var e = get_engine();
			if(e != null) {
				e.reset_focus(true);
			}
		}
		if(modal == false) {
			Widget c;
			var cc = get_child(0) as ContainerWidget;
			if(cc != null) {
				c = cc.get_child(0);
			}
			if(c != null) {
				if(x >= c.get_x() && x < c.get_x() + c.get_width() &&
					y >= c.get_y() && y < c.get_y() + c.get_height()) {
				}
				else {
					Popup.close(this);
				}
			}
		}
		return(true);
	}

	public bool on_pointer_release(int x, int y, int button, int id) {
		base.on_pointer_release(x,y,button,id);
		return(true);
	}

	public bool on_pointer_cancel(int x, int y, int button, int id) {
		base.on_pointer_cancel(x,y,button,id);
		return(true);
	}

	public bool on_pointer_drag(int x, int y, int dx, int dy, int button, bool drop, int id) {
		base.on_pointer_drag(x,y,dx,dy,button,drop,id);
		return(true);
	}

	public bool on_pointer_move(int x, int y, int id) {
		base.on_pointer_move(x,y,id);
		return(true);
	}

	public bool on_context(int x, int y) {
		base.on_context(x,y);
		return(true);
	}

	public bool on_context_drag(int x, int y, int dx, int dy, bool drop, int id) {
		base.on_context_drag(x,y,dx,dy,drop,id);
		return(true);
	}

	public bool on_scroll(int x, int y, int dx, int dy) {
		base.on_scroll(x,y,dx,dy);
		return(true);
	}

	public bool on_zoom(int x, int y, int dz) {
		base.on_zoom(x,y,dz);
		return(true);
	}

	public bool on_key_press(KeyEvent e) {
		var v = base.on_key_press(e);
		if(v == false) {
			var ee = get_engine();
			if(ee != null) {
				ee.on_unhandled_key_press(e);
			}
		}
		return(true);
	}

	public bool on_key_release(KeyEvent e) {
		var v = base.on_key_release(e);
		if(v == false) {
			var ee = get_engine();
			if(ee != null) {
				ee.on_unhandled_key_release(e);
			}
		}
		return(true);
	}
}

