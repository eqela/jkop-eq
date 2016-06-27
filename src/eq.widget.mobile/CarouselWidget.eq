
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

public class CarouselWidget : ClipperContainerWidget, AnimationListener
{
	public static CarouselWidget instance() {
		return(new CarouselWidget());
	}

	property bool infinite_pages = false;
	Array pages;
	int current_page;
	Widget disp_previous;
	Widget disp_current;
	Widget disp_next;
	property bool retain_pages = false;
	Animation animation;
	bool dragging = false;

	public CarouselWidget() {
		set_auto_start_children(false);
	}

	public int get_current_page() {
		return(current_page);
	}

	public void on_surface_removed() {
		base.on_surface_removed();
		remove_children();
	}

	public void on_surface_created(Surface surface) {
		base.on_surface_created(surface);
		change_page(0, 0);
	}

	public virtual CarouselWidget add_page(Widget page, int margin = 0) {
		if(page == null) {
			return(this);
		}
		if(pages == null) {
			pages = Array.create();
		}
		var pp = page;
		if(margin > 0) {
			pp = LayerWidget.for_widget(page, margin).set_remove_children_on_cleanup(false);
		}
		pages.append(pp);
		return(this);
	}

	public virtual int get_page_count() {
		if(pages == null) {
			return(0);
		}
		return(pages.count());
	}

	public virtual Widget get_page(int n) {
		if(pages == null) {
			return(null);
		}
		return(pages.get(n) as Widget);
	}

	public virtual void on_page_changed() {
		if(disp_previous == null) {
			disp_previous = get_page(current_page-1);
			if(disp_previous != null) {
				if(disp_previous.is_initialized() == false) {
					add(disp_previous);
				}
				disp_previous.move(-get_width(), 0);
			}
		}
		if(disp_next == null) {
			disp_next = get_page(current_page+1);
			if(disp_next != null) {
				if(disp_next.is_initialized() == false) {
					add(disp_next);
				}
				disp_next.move(get_width(),0);
			}
		}
		if(disp_previous != null && disp_previous.is_started()) {
			disp_previous.stop();
		}
		if(disp_next != null && disp_next.is_started()) {
			disp_next.stop();
		}
		if(disp_current != null && disp_current.is_started() == false && is_started()) {
			disp_current.start();
		}
	}

	public bool change_to_page(int n) {
		if(infinite_pages == false) {
			if(n < 0 || n >= get_page_count()) {
				return(false);
			}
		}
		while(n != current_page) {
			var first = current_page;
			if(current_page < n) {
				change_page(1, 0);
			}
			else if(current_page > n) {
				change_page(-1, 0);
			}
			if(first == current_page) {
				break;
			}
		}
		if(current_page == n) {
			return(true);
		}
		return(false);
	}

	public bool change_page(int direction, int duration) {
		if(animation != null) {
			return(false);
		}
		int n = current_page + direction;
		if(infinite_pages == false) {
			if(n < 0 || n >= get_page_count()) {
				return(false);
			}
		}
		var w = get_width();
		// move towards the left: previous is now current
		if(direction < 0) {
			if(disp_next != null) {
				if(retain_pages == false) {
					remove(disp_next);
				}
				else {
					disp_next.resize(0,0);
				}
			}
			disp_next = disp_current;
			disp_current = disp_previous;
			disp_previous = null;
		}
		// move towards the right: next is now current
		else if(direction > 0) {
			if(disp_previous != null) {
				if(retain_pages == false) {
					remove(disp_previous);
				}
				else {
					disp_previous.resize(0,0);
				}
			}
			disp_previous = disp_current;
			disp_current = disp_next;
			disp_next = null;
		}
		// change to the current page (effectively update things)
		else if(direction == 0) {
			if(disp_previous != null && disp_previous.is_initialized() == false) {
				add(disp_previous);
			}
			if(disp_next != null && disp_next.is_initialized() == false) {
				add(disp_next);
			}
			if(disp_current != null && disp_current.is_initialized() == false) {
				add(disp_current);
			}
		}
		update_widget_positions(0, 0, duration);
		if(current_page != n) {
			current_page = n;
			if(duration < 1) {
				on_page_changed();
			}
		}
		return(true);
	}

	public void on_animation_listener_end(bool aborted) {
		animation = null;
		on_page_changed();
	}

	void update_widget_positions(int adjustx, int adjusty, int aduration) {
		var duration = aduration;
		if(animation != null) {
			animation.stop();
			animation = null;
		}
		var w = get_width(), h = get_height();
		if(duration > 0) {
			animation = new Animation().set_duration(duration);
			animation.add_listener(this);
		}
		if(disp_previous != null) {
			disp_previous.resize(w,h);
			if(animation != null) {
				animation.add_item(LinearAnimationItem.for_double(disp_previous.get_xvalue(), adjustx-w));
				animation.add_item(LinearAnimationItem.for_double(disp_previous.get_yvalue(), adjusty));
				animation.add_target(disp_previous);
			}
			else {
				disp_previous.move(adjustx-w, adjusty, duration);
			}
		}
		if(disp_current != null) {
			disp_current.resize(w,h);
			if(animation != null) {
				animation.add_item(LinearAnimationItem.for_double(disp_current.get_xvalue(), adjustx));
				animation.add_item(LinearAnimationItem.for_double(disp_current.get_yvalue(), adjusty));
				animation.add_target(disp_current);
			}
			else {
				disp_current.move(adjustx,adjusty, duration, this);
			}
		}
		if(disp_next != null) {
			disp_next.resize(w,h);
			if(animation != null) {
				animation.add_item(LinearAnimationItem.for_double(disp_next.get_xvalue(), adjustx+w));
				animation.add_item(LinearAnimationItem.for_double(disp_next.get_yvalue(), adjusty));
				animation.add_target(disp_next);
			}
			else {
				disp_next.move(adjustx+w,adjusty, duration);
			}
		}
		if(animation != null) {
			start_animation(animation);
		}
	}

	public void on_resize() {
		base.on_resize();
		update_widget_positions(0, 0, 0);
	}

	public void initialize() {
		base.initialize();
		current_page = 0;
		disp_previous = get_page(-1);
		disp_current = get_page(0);
		if(disp_previous != null) {
			add(disp_previous);
		}
		if(disp_current != null) {
			add(disp_current);
		}
		disp_next = get_page(1);
		if(disp_next != null) {
			add(disp_next);
		}
	}

	public void start() {
		base.start();
		if(disp_current != null && disp_current.is_started() == false) {
			disp_current.start();
		}
	}

	public void cleanup() {
		base.cleanup();
		disp_previous = null;
		disp_current = null;
		disp_next = null;
	}

	public bool on_pointer_drag(int x, int y, int dx, int dy, int button, bool drop, int id) {
		if(animation != null) {
			return(false);
		}
		var ydiff = Math.abs(dy);
		var xdiff = Math.abs(dx);
		if(dragging == false && xdiff > 20 && xdiff > 3*ydiff) {
			dragging = true;
		}
		if(dragging) {
			update_widget_positions(dx, 0, 0);
		}
		else {
			return(base.on_pointer_drag(x,y,dx,dy,button,drop,id));
		}
		if(drop) {
			if(xdiff >= get_width() / 3) {
				bool r = false;
				if(dx < 0) {
					r = change_page(1, 100000);
				}
				else if(dx > 0) {
					r = change_page(-1, 100000);
				}
				if(r == false) {
					update_widget_positions(0,0,100000);
				}
			}
			else {
				update_widget_positions(0,0,100000);
			}
			dragging = false;
		}
		return(true);
	}

	public bool on_key_press(KeyEvent e) {
		if(e.has_name("left")) {
			change_page(-1, 250000);
			return(true);
		}
		if(e.has_name("right")) {
			change_page(1, 250000);
			return(true);
		}
		return(base.on_key_press(e));
	}
}
