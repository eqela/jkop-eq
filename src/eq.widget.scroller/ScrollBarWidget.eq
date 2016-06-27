
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

public class ScrollBarWidget : Widget
{
	property bool horizontal = false;
	property bool always_show = false;
	int pos;
	int sz;
	int maxsz;

	public void initialize() {
		base.initialize();
		if(horizontal) {
			set_height_request(px("1mm"));
		}
		else {
			set_width_request(px("1mm"));
		}
	}

	public void start() {
		base.start();
		set_alpha(0.75);
		on_changed();
	}

	BackgroundTask change_timer;

	public void stop() {
		base.stop();
		if(change_timer != null) {
			change_timer.abort();
			change_timer = null;
		}
	}

	public void cleanup() {
		base.cleanup();
		if(change_timer != null) {
			change_timer.abort();
			change_timer = null;
		}
	}

	class MyChangeTimerHandler : TimerHandler
	{
		property ScrollBarWidget widget;
		public bool on_timer(Object arg) {
			widget.set_alpha(0.0, 500000);
			return(false);
		}
	}

	void on_changed() {
		if(always_show) {
			return;
		}
		if(change_timer != null) {
			change_timer.abort();
			change_timer = null;
		}
		set_alpha(0.75);
		change_timer = start_timer(1000000, new MyChangeTimerHandler().set_widget(this), null);
	}

	public void update(int pos, int sz, int maxsz) {
		this.pos = pos;
		this.sz = sz;
		this.maxsz = maxsz;
		update_view();
		on_changed();
	}

	public Collection render() {
		if(sz >= maxsz) {
			return(LinkedList.create());
		}
		var v = LinkedList.create();
		var cc = Theme.get_highlight_color();
		if(horizontal) {
			int bw = get_width() * sz / maxsz;
			int bx = get_width() * pos / maxsz;
			v.add(new FillColorOperation().set_x(bx).set_y(0)
				.set_shape(RoundedRectangleShape.create(0, 0, bw, get_height(), get_height()/2))
				.set_color(cc));
		}
		else {
			int bw = get_height() * sz / maxsz;
			int bx = get_height() * pos / maxsz;
			v.add(new FillColorOperation().set_x(0).set_y(bx)
				.set_shape(RoundedRectangleShape.create(0, 0, get_width(), bw, get_width()/2))
				.set_color(cc));
		}
		return(v);
	}
}
