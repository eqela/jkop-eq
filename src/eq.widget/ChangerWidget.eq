
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

public class ChangerWidget : LayerWidget, ClipperWidget
{
	static int default_switch_duration = 300000;
	public static int EFFECT_NONE = 0;
	public static int EFFECT_CROSSFADE = 1;
	public static int EFFECT_SCROLL_LEFT = 2;
	public static int EFFECT_SCROLL_RIGHT = 3;
	public static int EFFECT_SCROLL_UP = 4;
	public static int EFFECT_SCROLL_DOWN = 5;
	public static int EFFECT_COVERSCROLL_LEFT = 6;
	public static int EFFECT_COVERSCROLL_RIGHT = 7;

	public static int get_default_switch_duration() {
		return(default_switch_duration);
	}

	public static void set_default_switch_duration(int x) {
		default_switch_duration = x;
	}

	public static ChangerWidget instance() {
		return(new ChangerWidget());
	}

	property int switch_duration;
	property bool disable_animation = false;
	Widget active_widget;
	int being_removed;

	public ChangerWidget() {
		switch_duration = default_switch_duration;
		being_removed = 0;
	}

	public override bool get_always_has_surface() {
		return(true);
	}

	public bool is_surface_container() {
		return(true);
	}

	public int get_changer_widget_count() {
		return(count() - being_removed);
	}

	public Widget get_active_widget() {
		return(active_widget);
	}

	class RemoverListener : AnimationListener {
		property ChangerWidget changer;
		property Widget oldchild;
		public void on_animation_listener_end(bool aborted) {
			changer.on_remove_complete();
			changer.remove_changer(oldchild);
		}
	}

	public bool replace_with(Widget newchild, int effect = 0) {
		if(newchild != null) {
			if(newchild.is_initialized() == false) {
				add_changer(newchild, false, EFFECT_NONE);
			}
		}
		being_removed ++;
		return(activate(newchild, effect, new RemoverListener().set_changer(this).set_oldchild(active_widget)));
	}

	public void on_remove_complete() {
		being_removed --;
	}

	public bool remove_changer(Widget child) {
		if(child == null) {
			return(false);
		}
		remove(child);
		if(active_widget == child) {
			active_widget = null;
		}
		return(true);
	}

	public override void on_new_child_size_params(Widget w) {
		if(w != active_widget) {
			return;
		}
		base.on_new_child_size_params(w);
	}

	public ChangerWidget add_changer(Widget child, bool active = false, int effect = 0) {
		if(child == null) {
			return(this);
		}
		if(child.is_initialized() == false) {
			child.set_enabled(false);
			child.set_alpha(0.0);
			add(child);
		}
		if(active) {
			activate(child, effect);
		}
		return(this);
	}

	class WidgetDisabler : AnimationListener
	{
		property Widget widget;
		public void on_animation_listener_end(bool aborted) {
			if(aborted == false) {
				widget.set_enabled(false);
			}
		}
	}

	public bool activate(Widget child, int effect = 0, AnimationListener listener = null) {
		if(active_widget == child) {
			return(false);
		}
		var ef = effect;
		if(disable_animation) {
			ef = EFFECT_NONE;
		}
		// 1. removal of the old active widget
		if(active_widget != null) {
			var ll = new WidgetDisabler().set_widget(active_widget);
			if(ef == EFFECT_CROSSFADE) {
				active_widget.set_alpha(0.0, switch_duration, ll);
			}
			else if(ef == EFFECT_SCROLL_LEFT) {
				active_widget.move(0 - active_widget.get_width(), active_widget.get_y(), switch_duration, ll);
			}
			else if(ef == EFFECT_SCROLL_RIGHT) {
				active_widget.move(0 + active_widget.get_width(), active_widget.get_y(), switch_duration, ll);
			}
			else if(ef == EFFECT_SCROLL_UP) {
				active_widget.move(active_widget.get_x(), 0 - active_widget.get_height(), switch_duration, ll);
			}
			else if(ef == EFFECT_SCROLL_DOWN) {
				active_widget.move(active_widget.get_x(), 0 + active_widget.get_height(), switch_duration, ll);
			}
			else if(ef == EFFECT_COVERSCROLL_LEFT || ef == EFFECT_COVERSCROLL_RIGHT) {
				active_widget.set_alpha(0.0, switch_duration, ll);
			}
			else { // EFFECT_NONE
				active_widget.set_alpha(0.0);
				active_widget.set_enabled(false);
			}
			active_widget = null;
		}
		// 2. addition of the new active widget
		if(child != null) {
			child.set_enabled(true);
			arrange_child(child);
			var dur = switch_duration;
			if(ef == EFFECT_CROSSFADE) {
				child.move(0,0);
				child.set_alpha(0.0);
				child.set_alpha(1.0, dur, listener);
			}
			else if(ef == EFFECT_SCROLL_LEFT || ef == EFFECT_COVERSCROLL_LEFT) {
				child.move(0 + child.get_width(), 0);
				child.set_alpha(1.0);
				child.move(0,0,dur,listener);
			}
			else if(ef == EFFECT_SCROLL_RIGHT || ef == EFFECT_COVERSCROLL_RIGHT) {
				child.move(0-child.get_width(), 0);
				child.set_alpha(1.0);
				child.move(0,0,dur,listener);
			}
			else if(ef == EFFECT_SCROLL_UP) {
				child.move(0, 0 + child.get_height());
				child.set_alpha(1.0);
				child.move(0,0,dur,listener);
			}
			else if(ef == EFFECT_SCROLL_DOWN) {
				child.move(0, 0-child.get_height());
				child.set_alpha(1.0);
				child.move(0,0,dur,listener);
			}
			else { // EFFECT_NONE
				child.set_alpha(1.0, 0, listener);
			}
			active_widget = child;
		}
		return(true);
	}

	public void arrange_child(Widget c) {
		if(c == null) {
			return;
		}
		c.resize(get_width()-get_margin_left()-get_margin_right(), get_height()-get_margin_top()-get_margin_bottom());
	}
	public Widget get_hover_widget(int x, int y) {
		if(active_widget == null) {
			return(null);
		}
		return(active_widget.get_hover_widget((int)(x - get_x()), (int)(y - get_y())));
	}

	public bool on_pointer_press(int x, int y, int button, int id) {
		if(active_widget == null) {
			return(false);
		}
		return(active_widget.on_pointer_press((int)(x - get_x()), (int)(y - get_y()),button,id));
	}

	public bool on_pointer_release(int x, int y, int button, int id) {
		if(active_widget == null) {
			return(false);
		}
		return(active_widget.on_pointer_release((int)(x - get_x()), (int)(y - get_y()),button,id));
	}

	public bool on_pointer_cancel(int x, int y, int button, int id) {
		if(active_widget == null) {
			return(false);
		}
		return(active_widget.on_pointer_cancel((int)(x - get_x()), (int)(y - get_y()),button,id));
	}

	public bool on_pointer_drag(int x, int y, int dx, int dy, int button, bool drop, int id) {
		if(active_widget == null) {
			return(false);
		}
		return(active_widget.on_pointer_drag((int)(x - get_x()), (int)(y - get_y()),dx,dy,button,drop,id));
	}

	public bool on_pointer_move(int x, int y, int id) {
		if(active_widget == null) {
			return(false);
		}
		return(active_widget.on_pointer_move((int)(x - get_x()), (int)(y - get_y()),id));
	}

	public bool on_context(int x, int y) {
		if(active_widget == null) {
			return(false);
		}
		return(active_widget.on_context((int)(x - get_x()), (int)(y - get_y())));
	}

	public bool on_context_drag(int x, int y, int dx, int dy, bool drop, int id) {
		if(active_widget == null) {
			return(false);
		}
		return(active_widget.on_context_drag((int)(x - get_x()), (int)(y - get_y()),dx,dy,drop,id));
	}

	public bool on_scroll(int x, int y, int dx, int dy) {
		if(active_widget == null) {
			return(false);
		}
		return(active_widget.on_scroll((int)(x - get_x()), (int)(y - get_y()),dx,dy));
	}

	public bool on_zoom(int x, int y, int dz) {
		if(active_widget == null) {
			return(false);
		}
		return(active_widget.on_zoom((int)(x - get_x()), (int)(y - get_y()),dz));
	}

	public bool on_key_press(KeyEvent e) {
		if(active_widget == null) {
			return(false);
		}
		return(active_widget.on_key_press(e));
	}

	public bool on_key_release(KeyEvent e) {
		if(active_widget == null) {
			return(false);
		}
		return(active_widget.on_key_release(e));
	}
}
