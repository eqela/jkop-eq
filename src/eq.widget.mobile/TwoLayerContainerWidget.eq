
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

public class TwoLayerContainerWidget : ContainerWidget, EventReceiver
{
	property Widget background;
	property Widget foreground;
	bool background_shown;
	property String foreground_reserved_space;

	public TwoLayerContainerWidget() {
		foreground_reserved_space = "8mm";
	}

	int get_background_required_width() {
		int max = get_width() - px(foreground_reserved_space);
		int v = max;
		if(background != null) {
			var wr = background.get_width_request();
			if(wr > 0 && wr < v) {
				v = wr;
			}
		}
		if(v > max) {
			v = max;
		}
		return(v);
	}

	double get_foreground_moved_pos() {
		return(get_x() - get_background_required_width());
	}

	public void initialize() {
		base.initialize();
		background_shown = false;
		if(background != null) {
			add(background);
			background.set_enabled(false);
		}
		if(foreground != null) {
			add(foreground);
			set_size_request(foreground.get_width_request(), foreground.get_height_request());
		}
	}

	public void arrange_children() {
		var sx = get_x();
		var sy = get_y();
		var sw = get_width();
		var sh = get_height();
		if(background != null) {
			var bwr = get_background_required_width();
			background.resize(bwr, sh);
			background.move(sx + (sw - bwr), sy);
		}
		if(foreground != null) {
			foreground.resize(sw, sh);
			if(background_shown) {
				foreground.move(get_foreground_moved_pos(), sy);
			}
			else {
				foreground.move(sx, sy);
			}
		}
	}

	public void show_background() {
		if(background_shown) {
			return;
		}
		if(background != null) {
			background.set_enabled(true);
		}
		if(foreground != null) {
			foreground.move(get_foreground_moved_pos(), foreground.get_y(), 300000);
		}
		background_shown = true;
	}

	class HideBackgroundListener : AnimationListener
	{
		property TwoLayerContainerWidget widget;
		public void on_animation_listener_end(bool aborted) {
			widget.on_background_hidden();
		}
	}

	public void on_background_hidden() {
		if(background != null) {
			background.set_enabled(false);
		}
	}

	public void hide_background() {
		if(background_shown == false) {
			return;
		}
		if(foreground != null) {
			foreground.move(get_x(), get_y(), 300000,
				new HideBackgroundListener().set_widget(this));
		}
		else if(background != null) {
			background.set_enabled(false);
			background_shown = false;
		}
		background_shown = false;
	}

	public void toggle_background() {
		if(background_shown) {
			hide_background();
		}
		else {
			show_background();
		}
	}

	public void on_event(Object o) {
		if(o != null && o is ToggleBackgroundEvent) {
			toggle_background();
			return;
		}
		forward_event(o);
	}

	void on_swipe_left() {
		if(background_shown == false) {
			show_background();
		}
	}

	void on_swipe_right() {
		if(background_shown) {
			hide_background();
		}
	}
}
