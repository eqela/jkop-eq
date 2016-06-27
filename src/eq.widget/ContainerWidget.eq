
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

public class ContainerWidget : Widget
{
	LinkedList children;
	bool in_layout = false;
	bool do_layout = false;
	bool _initializing_layout = false;
	property bool auto_start_children = true;
	property bool remove_children_on_cleanup = true;
	property Color configured_draw_color;

	public ContainerWidget() {
		children = LinkedList.create();
	}

	public ContainerWidget set_draw_color(Color color) {
		configured_draw_color = color;
		return(this);
	}

	public int count() {
		return(children.count());
	}

	public int count_enabled() {
		int v = 0;
		foreach(Widget w in iterate_children()) {
			if(w.is_enabled()) {
				v++;
			}
		}
		return(v);
	}

	public Widget get_first_child() {
		return(get_child(0));
	}

	public Widget get_last_child() {
		if(children == null) {
			return(null);
		}
		return(children.get_last() as Widget);
	}

	public Widget get_child(int n) {
		return(children.get_index(n) as Widget);
	}

	public Iterator iterate_children(int n = 0) {
		return(children.iterate_from_index(n));
	}

	public Iterator iterate_children_reverse() {
		return(children.iterate_reverse());
	}

	public bool move_child_up(Widget child) {
		var nn = children.get_first_node();
		while(nn != null) {
			if(nn.value == child) {
				var prev = nn.prev;
				if(prev != null) {
					nn.value = prev.value;
					prev.value = child;
					layout();
					return(true);
				}
				break;
			}
			nn = nn.next;
		}
		return(false);
	}

	public bool move_child_down(Widget child) {
		var nn = children.get_first_node();
		while(nn != null) {
			if(nn.value == child) {
				var next = nn.next;
				if(next != null) {
					nn.value = next.value;
					next.value = child;
					layout();
					return(true);
				}
				break;
			}
			nn = nn.next;
		}
		return(false);
	}

	public void make_child_first(Widget child) {
		if(child == null) {
			return;
		}
		var enabled = child.is_enabled();
		if(enabled) {
			child.set_enabled(false);
		}
		children.remove(child);
		children.prepend(child);
		if(enabled) {
			child.set_enabled(true);
		}
	}

	public virtual void prepend(Widget child) {
		if(this == child) {
			Log.warning("Tried to add a widget to itself!");
			return;
		}
		if(child != null) {
			children.prepend(child);
			child.set_parent(this);
			child.set_alpha_multiplier(get_alpha_multiplier() * get_alpha());
			on_child_added(child);
		}
	}

	public virtual void insert(Widget child, int n) {
		if(this == child) {
			Log.warning("Tried to add a widget to itself!");
			return;
		}
		if(child != null) {
			children.insert(child, n);
			child.set_parent(this);
			child.set_alpha_multiplier(get_alpha_multiplier() * get_alpha());
			on_child_added(child);
		}
	}

	public virtual ContainerWidget add(Widget child) {
		if(this == child) {
			Log.warning("Tried to add a widget to itself!");
			return(this);
		}
		if(child != null) {
			children.add(child);
			child.set_parent(this);
			child.set_alpha_multiplier(get_alpha_multiplier() * get_alpha());
			on_child_added(child);
		}
		return(this);
	}

	public void remove_first_child() {
		var fn = children.get_first_node();
		if(fn == null) {
			return;
		}
		var ww = fn.get_node_value() as Widget;
		if(ww != null) {
			ww.set_parent(null);
		}
		children.remove_node(fn);
		on_child_removed(ww);
	}

	public void remove_last_child() {
		var fn = children.get_last_node();
		if(fn == null) {
			return;
		}
		var ww = fn.get_node_value() as Widget;
		if(ww != null) {
			ww.set_parent(null);
		}
		children.remove_node(fn);
		on_child_removed(ww);
	}

	public ContainerWidget remove(Widget child, bool complete = true) {
		if(child != null) {
			if(complete) {
				child.set_parent(null);
			}
			children.remove(child);
			on_child_removed(child);
		}
		return(this);
	}

	public bool remove_index(int n, bool complete = true) {
		var node = children.get_node(n);
		if(node != null) {
			var ww = node.get_node_value() as Widget;
			if(ww != null) {
				if(complete) {
					ww.set_parent(null);
				}
				on_child_removed(ww);
			}
		}
		return(children.remove_node(node));
	}

	public virtual void on_children_removed() {
	}

	public void remove_children() {
		var il = in_layout;
		in_layout = true;
		while(children.count() > 0) {
			var c0 = children.get_index(0) as Widget;
			if(c0 == null) {
				break;
			}
			children.remove(c0);
			c0.set_parent(null);
		}
		in_layout = il;
		on_children_removed();
	}

	public override void release_focus() {
		var it = iterate_children();
		Widget c;
		while(it != null && (c = it.next() as Widget) != null) {
			c.release_focus();
		}
		base.release_focus();
	}

	public Widget get_default_focus_widget() {
		foreach(Widget c in iterate_children_reverse()) {
			if(c.is_enabled() == false) {
				continue;
			}
			var r = c.get_default_focus_widget();
			if(r != null) {
				return(r);
			}
		}
		return(null);
	}

	public override void cleanup() {
		base.cleanup();
		if(remove_children_on_cleanup) {
			remove_children();
		}
	}

	public virtual void on_container_resize() {
		layout();
	}

	public override void on_resize() {
		base.on_resize();
		on_container_resize();
	}

	public double get_child_relative_x(double x) {
		if(this is ClipperWidget) {
			return(x);
		}
		return(get_x() + x);
	}

	public double get_child_relative_y(double y) {
		if(this is ClipperWidget) {
			return(y);
		}
		return(get_y() + y);
	}

	public void on_rotate() {
		base.on_rotate();
		// FIXME: We should set the rotation point to be consistent
		// (currently all children will just rotate around themselves
		// so this really only works for layers
		foreach(Widget w in iterate_children()) {
			w.set_rotation(get_rotation());
		}
	}

	public void on_alpha_change() {
		base.on_alpha_change();
		var aa = get_alpha_multiplier() * get_alpha();
		foreach(Widget w in iterate_children()) {
			w.set_alpha_multiplier(aa);
		}
	}

	public void on_move_diff(double diffx, double diffy) {
		base.on_move_diff(diffx, diffy);
		if(this is ClipperWidget == false) {
			foreach(Widget w in iterate_children()) {
				w.move(w.get_x()+diffx, w.get_y()+diffy);
			}
		}
	}

	public override Widget get_hover_widget(int x, int y) {
		Widget v = null;
		foreach(Widget c in iterate_children_reverse()) {
			if(c.is_enabled() == false) {
				continue;
			}
			if(x >= c.get_x() && x < c.get_x() + c.get_width() &&
				y >= c.get_y() && y < c.get_y() + c.get_height()) {
				v = c.get_hover_widget(x, y);
				if(v != null) {
					break;
				}
			}
		}
		return(v);
	}

	private bool is_inside_widget(int x, int y, Widget c) {
		return(x >= c.get_x() && x < c.get_x() + c.get_width() && y >= c.get_y() && y < c.get_y() + c.get_height());
	}

	public override bool on_pointer_press(int x, int y, int button, int id) {
		foreach(Widget c in iterate_children_reverse()) {
			if(c.is_enabled() == false) {
				continue;
			}
			if(is_inside_widget(x, y, c) && c.on_pointer_press(x, y, button, id)) {
				return(true);
			}
		}
		return(base.on_pointer_press(x, y, button, id));
	}

	public override bool on_pointer_release(int x, int y, int button, int id) {
		foreach(Widget c in iterate_children_reverse()) {
			if(c.is_enabled() == false) {
				continue;
			}
			if(is_inside_widget(x, y, c) && c.on_pointer_release(x, y, button, id)) {
				return(true);
			}
		}
		return(base.on_pointer_release(x, y, button, id));
	}

	public override bool on_pointer_cancel(int x, int y, int button, int id) {
		foreach(Widget c in iterate_children_reverse()) {
			if(c.is_enabled() == false) {
				continue;
			}
			if(is_inside_widget(x, y, c) && c.on_pointer_cancel(x, y, button, id)) {
				return(true);
			}
		}
		return(base.on_pointer_cancel(x, y, button, id));
	}

	public override bool on_pointer_drag(int x, int y, int dx, int dy, int button, bool drop, int id) {
		foreach(Widget c in iterate_children_reverse()) {
			if(c.is_enabled() == false) {
				continue;
			}
			if(is_inside_widget(x, y, c) && c.on_pointer_drag(x, y, dx, dy, button, drop, id)) {
				return(true);
			}
		}
		return(base.on_pointer_drag(x, y, dx, dy, button, drop, id));
	}

	public override bool on_pointer_move(int x, int y, int id) {
		foreach(Widget c in iterate_children_reverse()) {
			if(c.is_enabled() == false) {
				continue;
			}
			if(is_inside_widget(x, y, c) && c.on_pointer_move(x, y, id)) {
				return(true);
			}
		}
		return(base.on_pointer_move(x, y, id));
	}

	public override bool on_context(int x, int y) {
		foreach(Widget c in iterate_children_reverse()) {
			if(c.is_enabled() == false) {
				continue;
			}
			if(is_inside_widget(x, y, c) && c.on_context(x, y)) {
				return(true);
			}
		}
		return(base.on_context(x, y));
	}

	public override bool on_context_drag(int x, int y, int dx, int dy, bool drop, int id) {
		foreach(Widget c in iterate_children_reverse()) {
			if(c.is_enabled() == false) {
				continue;
			}
			if(is_inside_widget(x, y, c) && c.on_context_drag(x, y, dx, dy, drop, id)) {
				return(true);
			}
		}
		return(base.on_context_drag(x, y, dx, dy, drop, id));
	}

	public override bool on_scroll(int x, int y, int dx, int dy) {
		foreach(Widget c in iterate_children_reverse()) {
			if(c.is_enabled() == false) {
				continue;
			}
			if(is_inside_widget(x, y, c) && c.on_scroll(x, y, dx, dy)) {
				return(true);
			}
		}
		return(base.on_scroll(x, y, dx, dy));
	}

	public override bool on_zoom(int x, int y, int dz) {
		foreach(Widget c in iterate_children_reverse()) {
			if(c.is_enabled() == false) {
				continue;
			}
			if(is_inside_widget(x, y, c) && c.on_zoom(x, y, dz)) {
				return(true);
			}
		}
		return(base.on_zoom(x, y, dz));
	}

	public override bool on_key_press(KeyEvent e) {
		foreach(Widget c in iterate_children_reverse()) {
			if(c.is_enabled() == false) {
				continue;
			}
			if(c.on_key_press(e)) {
				return(true);
			}
		}
		return(base.on_key_press(e));
	}

	public override bool on_key_release(KeyEvent e) {
		foreach(Widget c in iterate_children_reverse()) {
			if(c.is_enabled() == false) {
				continue;
			}
			if(c.on_key_release(e)) {
				return(true);
			}
		}
		return(base.on_key_release(e));
	}

	public override void initialize() {
		base.initialize();
		foreach(Widget c in iterate_children()) {
			if(c.is_enabled() == false) {
				if(Widget.initialize_disabled_widgets && c.get_initialize_if_disabled()) {
				}
				else {
					continue;
				}
			}
			c.execute_initialize();
		}
	}

	public override void start() {
		base.start();
		if(auto_start_children) {
			foreach(Widget c in iterate_children()) {
				if(c.is_enabled() == false) {
					continue;
				}
				if(c.is_started() == false) {
					c.start();
				}
			}
		}
	}

	public override void stop() {
		base.stop();
		foreach(Widget c in iterate_children()) {
			if(c.is_enabled() == false) {
				continue;
			}
			if(c.is_started()) {
				c.stop();
			}
		}
	}

	public void layout() {
		if(is_initialized() == false) {
			return;
		}
		if(is_initializing()) {
			_initializing_layout = true;
			return;
		}
		if(in_layout) {
			do_layout = true;
			return;
		}
		int n = 0;
		do_layout = true;
		while(do_layout) {
			in_layout = true;
			do_layout = false;
			arrange_children();
			in_layout = false;
			n++;
			if(n > 10) {
				Log.error("Layout loop exceeds 10 rounds. Aborting.");
				break;
			}
		}
	}

	public virtual void on_child_added(Widget child) {
		layout();
	}

	public virtual void on_child_removed(Widget child) {
		layout();
	}

	public virtual void on_new_child_size_params(Widget w) {
		layout();
	}

	public void on_initialized() {
		base.on_initialized();
		if(_initializing_layout) {
			layout();
			_initializing_layout = false;
		}
	}

	public virtual void arrange_children() {
	}

	public void on_animation_update() {
		base.on_animation_update();
		layout();
	}
}
