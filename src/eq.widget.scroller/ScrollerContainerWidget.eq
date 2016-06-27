
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

public class ScrollerContainerWidget : ContainerWidget, ScrollableWidget, ClipperWidget
{
	class ScrollTimer : TimerHandler
	{
		public bool on_timer(Object arg) {
			if (arg is ScrollerContainerWidget) {
				((ScrollerContainerWidget)arg).tick();
			}
			return(true);
		}
	}

	int current_y = 0;
	int current_x = 0;
	int last_dx = 0;
	int last_dy = 0;
	int largest_child_w;
	int largest_child_h;
	property bool horizontal = true;
	property bool vertical = true;
	property Color scroll_color = null;
	property bool enable_keyboard_control = true;
	property bool enable_kinetic_scrolling = true;
	property double max_velocity = 150.0;
	BackgroundTask timer;
	TimeVal kinetic_started;
	int point_a = 0;
	double velocity = 0.0;
	int distance = 0;

	public override bool get_always_has_surface() {
		return(true);
	}

	public void copy_settings_from(ScrollerContainerWidget scw) {
		if(scw == null) {
			return;
		}
		horizontal = scw.get_horizontal();
		vertical = scw.get_vertical();
		scroll_color = scw.get_scroll_color();
		enable_keyboard_control = scw.get_enable_keyboard_control();
		enable_kinetic_scrolling = scw.get_enable_kinetic_scrolling();
		max_velocity = scw.get_max_velocity();
	}

	public void on_changed() {
		var pp = get_parent() as ScrollerWidget;
		if(pp != null) {
			pp.on_changed(-current_x, -current_y, get_width(), get_height(), largest_child_w, largest_child_h);
		}
	}

	bool is_in(int x, int y, int bx, int by, int bw, int bh) {
		return(x >= bx && x < bx+bw && y >= by && y < by+bh);
	}

	public void scroll_to(int ax, int ay, int w, int h) {
		var x = ax - current_x;
		var y = ay - current_y;
		if(w > get_width() || h > get_height()) {
			if((current_y+y >= 0 || current_y+y+h<=get_height()) && (current_x+x>=0 || current_x+x+w<=get_width())) {
				return;
			}
			if(w >= get_width() && h >= get_height()) {
				int vx = -current_x, vy = -current_y, vw = get_width(), vh = get_height();
				if(vx < 0) {
					vw -= vx;
					vx = 0;
				}
				if(vy < 0) {
					vh -= vy;
					vy = 0;
				}
				if(vw < 0) {
					vw = 0;
				}
				if(vh < 0) {
					vh = 0;
				}
				int vx2 = vx+vw, vy2 = vy+vh, x2 = x+w, y2 = y+h;
				if(is_in(x, y, vx, vy, vw, vh) || is_in(x+w, y, vx, vy, vw, vh) || is_in(x, y+h, vx, vy, vw, vh) || is_in(x+w, y+h, vx, vy, vw, vh) ||
					is_in(vx, vy, x, y, w, h) || is_in(vx+vw, vy, x, y, w, h) || is_in(vx, vy+vh, x, y, w, h) || is_in(vx+vw, vy+vh, x, y, w, h)) {
					return;
				}
			}
		}
		bool change = false;
		if(vertical) {
			// if we need to scroll up (the rectangle to view is above the viewport)
			if(ay < 0) {
				current_y = current_y - ay;
				change = true;
			}
			// if we need to scroll down (the rectangle to view is below the viewport)
			if(ay + h > (int)get_height()) {
				current_y = current_y - ((ay + h) - (int)get_height());
				change = true;
			}
		}
		if(horizontal) {
			if(ax < 0) {
				current_x = current_x - ax;
				change = true;
			}
			if(ax + w > (int)get_width()) {
				current_x = current_x - ((ax + w) - (int)get_width());
				change = true;
			}
		}
		if(change) {
			arrange_children();
			on_changed();
		}
	}

	public bool is_at_bottom() {
		return(current_y == get_height() - largest_child_h);
	}

	public void scroll_to_bottom() {
		int ncy = get_height() - largest_child_h;
		if(ncy != current_y) {
			current_y = ncy;
			arrange_children();
			on_changed();
		}
	}

	public void scroll_to_top() {
		if(current_y != 0) {
			current_y = 0;
			arrange_children();
			on_changed();
		}
	}

	void adjust_overscroll() {
		if(current_x < get_width() - get_width_request()) {
			current_x = get_width() - get_width_request();
		}
		if(current_y < get_height() - get_height_request()) {
			current_y = get_height() - get_height_request();
		}
		if(current_x > 0) {
			current_x = 0;
		}
		if(current_y > 0) {
			current_y = 0;
		}
		if(horizontal == false) {
			current_x = 0;
		}
		if(vertical == false) {
			current_y = 0;
		}
	}

	void _do_scroll(int dx, int dy, bool force) {
		if(dx == 0 && dy == 0 && force == false) {
			return;
		}
		current_x += dx;
		current_y += dy;
		adjust_overscroll();
		arrange_children();
		on_changed();
	}

	public void scroll(int dx, int dy) {
		if(dx == 0 && dy == 0) {
			return;
		}
		_do_scroll(dx, dy, false);
	}

	public void on_resize() {
		base.on_resize();
		foreach(Widget c in iterate_children()) {
			c.set_resize_dirty(true);
		}
		_do_scroll(0, 0, true);
	}

	public void tick() {
		velocity *= 0.95;
		if(velocity < 1.0 && velocity > -1.0) {
			end_kinetic_scrolling();
			return;
		}
		if(vertical) {
			var orig = current_y;
			current_y += velocity;
			if(current_y > 0) {
				current_y = 0;
				end_kinetic_scrolling();
			}
			else if(current_y < get_height() - get_height_request()) {
				current_y = get_height() - get_height_request();
				end_kinetic_scrolling();
			}
			if(current_y == orig) {
				return;
			}
		}
		else if(horizontal) {
			var orig = current_x;
			current_x += velocity;
			if(current_x > 0) {
				current_x = 0;
				end_kinetic_scrolling();
			}
			else if(current_x < get_width() - get_width_request()) {
				current_x = get_width() - get_width_request();
				end_kinetic_scrolling();
			}
			if(current_x == orig) {
				return;
			}
		}
		adjust_overscroll();
		arrange_children();
		on_changed();
	}

	void end_kinetic_scrolling() {
		if(timer != null) {
			timer.abort();
			timer = null;
		}
		point_a = 0;
		velocity = 0.0;
		distance = 0;
	}

	public override bool on_pointer_drag(int xx, int yy, int odx, int ody, int button, bool drop, int id) {
		if(base.on_pointer_drag((int)(xx - get_x()), (int)(yy - get_y()), odx, ody, button, drop, id)) {
			if(drop) {
				last_dx = 0;
				last_dy = 0;
			}
			return(true);
		}
		bool v = false;
		var x = xx - (int)get_x();
		var y = yy - (int)get_y();
		int dx = odx - last_dx;
		int dy = ody - last_dy;
		int temp_b = 0;
		if(horizontal && vertical) {
			scroll(dx, dy);
			v = true;
		}
		else if(horizontal) {
			if(dx != 0) {
				if(point_a == 0) {
					set_initial_position(odx);
				}
				temp_b = odx;
				scroll(dx, 0);
				v = true;
			}
		}
		else if(vertical) {
			if(dy != 0) {
				if(point_a == 0) {
					set_initial_position(ody);
				}
				temp_b = ody;
				scroll(0, dy);
				v = true;
			}
		}
		if(last_dx == 0 && last_dy == 0) {
			on_pointer_cancel(x, y, button, id);
		}
		if(drop) {
			if(enable_kinetic_scrolling && ((vertical && last_dy != 0) || (horizontal && last_dx != 0))) {
				int diff = 0;
				if(vertical) {
					diff = last_dy - point_a;
				}
				else if(horizontal) {
					diff = last_dx - point_a;
				}
				var mm = px("2mm");
				if(diff > mm || diff < 0-mm) {
					var time_ended = SystemClock.timeval();
					int time = TimeVal.diff(time_ended, kinetic_started);
					if(time > 0) {
						velocity = (diff * 20000) / time;
					}
					if(velocity > max_velocity) {
						velocity = max_velocity;
					}
					else if(velocity < 0-max_velocity) {
						velocity = 0-max_velocity;
					}
					if(timer != null) {
						timer.abort();
					}
					timer = start_timer(1000000/120, new ScrollTimer(), this);
				}
			}
			last_dx = 0;
			last_dy = 0;
		}
		else {
			int prev_d = Math.abs(temp_b - point_a);
			if(distance > prev_d) {
				set_initial_position(temp_b);
				prev_d = Math.abs(temp_b - point_a);
			}
			distance = prev_d;
			last_dx = odx;
			last_dy = ody;
		}
		return(true);
	}

	void set_initial_position(int a) {
		point_a = a;
		velocity = 0.0;
		distance = 0;
		kinetic_started = SystemClock.timeval();
	}

	public override bool on_scroll(int xx, int yy, int dx, int dy) {
		if(base.on_scroll((int)(xx - get_x()), (int)(yy - get_y()), dx, dy)) {
			return(true);
		}
		var ocx = current_x, ocy = current_y;
		if(horizontal && vertical) {
			scroll(dx, dy);
		}
		else if(horizontal) {
			if(vertical == false && dx == 0 && dy != 0) {
				// HACK: Allows mouse wheels to scroll horizontal scrollers
				scroll(dy, 0);
			}
			else {
				scroll(dx, 0);
			}
		}
		else if(vertical) {
			scroll(0, dy);
		}
		return(ocx != current_x || ocy != current_y);
	}

	public override bool on_key_press(KeyEvent e) {
		if(enable_keyboard_control == false) {
			return(base.on_key_press(e));
		}
		if(e == null || e.get_ctrl() || e.get_command()) {
			return(base.on_key_press(e));
		}
		var name = e.get_name();
		var str = e.get_str();
		bool v = false;
		if(vertical) {
			if("up".equals(name)) {
				scroll(0, px("5mm"));
				v = true;
			}
			else if("down".equals(name)) {
				scroll(0, -px("5mm"));
				v = true;
			}
		}
		if(horizontal) {
			if("left".equals(name)) {
				scroll(px("5mm"), 0);
				v = true;
			}
			else if("right".equals(name)) {
				scroll(-px("5mm"), 0);
				v = true;
			}
		}
		if(v == false) {
			return(base.on_key_press(e));
		}
		return(v);
	}

	private int get_child_width(Widget child) {
		int v = get_width();
		if(horizontal) {
			v = child.get_width_request();
		}
		if(v < get_width()) {
			v = get_width();
		}
		return(v);
	}

	private int get_child_height(Widget child) {
		int v = get_height();
		if(vertical) {
			v = child.get_height_request();
		}
		if(v < get_height()) {
			v = get_height();
		}
		return(v);
	}

	public override void on_child_added(Widget child) {
		base.on_child_added(child);
		if(is_initialized() && child != null && get_width() > 0 && get_height() > 0) {
			child.resize(get_child_width(child), get_child_height(child));
			child.move(current_x, current_y);
			update_size_request();
			on_changed();
		}
	}

	public override void on_child_removed(Widget child) {
		base.on_child_removed(child);
		if(is_initialized()) {
			update_size_request();
			on_changed();
		}
	}

	public override void on_new_child_size_params(Widget child) {
		base.on_new_child_size_params(child);
		if(is_initialized() && child != null && get_width() > 0 && get_height() > 0) {
			child.resize(get_child_width(child), get_child_height(child));
			child.move(current_x, current_y);
			adjust_overscroll();
			arrange_children();
			on_changed();
		}
		update_size_request();
	}

	public void on_move_diff(double diffx, double diffy) {
	}

	public override void arrange_children() {
		if(is_initialized() == false || get_width() < 1 || get_height() < 1) {
			foreach(Widget c in iterate_children()) {
				c.resize(0,0);
				c.move(get_x(), get_y());
			}
			return;
		}
		largest_child_w = 0;
		largest_child_h = 0;
		foreach(Widget c in iterate_children()) {
			int cw = get_child_width(c);
			int ch = get_child_height(c);
			c.resize(cw, ch);
			c.move(current_x, current_y);
			if(cw > largest_child_w) {
				largest_child_w = cw;
			}
			if(ch > largest_child_h) {
				largest_child_h = ch;
			}
		}
	}

	private void update_size_request() {
		int rw = 0, rh = 0;
		foreach(Widget c in iterate_children()) {
			var cwr = c.get_width_request();
			var chr = c.get_height_request();
			if(cwr > rw) {
				rw = cwr;
			}
			if(chr > rh) {
				rh = chr;
			}
		}
		set_size_request(rw, rh);
	}

	public void on_widget_initialized() {
		base.on_widget_initialized();
		set_surface_content(LinkedList.create());
	}

	public void do_update_view() {
	}

	public Collection render() {
		return(LinkedList.create());
	}

	public override void initialize() {
		current_y = 0;
		base.initialize();
		update_size_request();
		on_changed();
	}

	public bool is_surface_container() {
		return(true);
	}

	public void start() {
		base.start();
		_do_scroll(0, -1, true);
		_do_scroll(0, 1, true);
	}

	public void stop() {
		base.stop();
		end_kinetic_scrolling();
	}

	public Widget get_hover_widget(int x, int y) {
		return(base.get_hover_widget((int)(x - get_x()), (int)(y - get_y())));
	}

	public bool on_pointer_press(int x, int y, int button, int id) {
		end_kinetic_scrolling();
		last_dx = 0;
		last_dy = 0;
		return(base.on_pointer_press((int)(x - get_x()), (int)(y - get_y()), button, id));
	}

	public bool on_pointer_release(int x, int y, int button, int id) {
		return(base.on_pointer_release((int)(x - get_x()), (int)(y - get_y()), button, id));
	}

	public bool on_pointer_cancel(int x, int y, int button, int id) {
		return(base.on_pointer_cancel((int)(x - get_x()), (int)(y - get_y()), button, id));
	}

	public bool on_pointer_move(int x, int y, int id) {
		return(base.on_pointer_move((int)(x - get_x()), (int)(y - get_y()), id));
	}

	public bool on_context(int x, int y) {
		return(base.on_context((int)(x - get_x()), (int)(y - get_y())));
	}

	public bool on_context_drag(int x, int y, int dx, int dy, bool drop, int id) {
		return(base.on_context_drag((int)(x - get_x()), (int)(y - get_y()), dx, dy, drop, id));
	}

	public bool on_zoom(int x, int y, int dz) {
		return(base.on_zoom((int)(x - get_x()), (int)(y - get_y()), dz));
	}
}

