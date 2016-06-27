
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

public class EventConsumerLayerWidget : LayerWidget
{
	public static EventConsumerLayerWidget for_widget(Widget widget) {
		return(new EventConsumerLayerWidget().set_consumer_child_widget(widget));
	}

	property bool consume_pointer_events = true;
	property bool consume_key_events = true;
	property bool consume_tab_key_events = true;
	property Widget consumer_child_widget;

	public override void initialize() {
		base.initialize();
		if(consumer_child_widget != null) {
			add(consumer_child_widget);
		}
	}

	public override Widget get_hover_widget(int x, int y) {
		var v = base.get_hover_widget(x,y);
		if(v != null) {
			return(v);
		}
		if(consume_pointer_events) {
			return(this);
		}
		return(null);
	}

	public override bool on_pointer_press(int x, int y, int button, int id) {
		if(base.on_pointer_press(x, y, button, id)) {
			return(true);
		}
		return(consume_pointer_events);
	}

	public override bool on_pointer_release(int x, int y, int button, int id) {
		if(base.on_pointer_release(x, y, button, id)) {
			return(true);
		}
		return(consume_pointer_events);
	}

	public override bool on_pointer_move(int x, int y, int id) {
		if(base.on_pointer_move(x, y, id)) {
			return(true);
		}
		return(consume_pointer_events);
	}

	public override bool on_pointer_cancel(int x, int y, int button, int id) {
		if(base.on_pointer_cancel(x, y, button, id)) {
			return(true);
		}
		return(consume_pointer_events);
	}

	public override bool on_pointer_drag(int x, int y, int dx, int dy, int button, bool drop, int id) {
		if(base.on_pointer_drag(x, y, dx, dy, button, drop, id)) {
			return(true);
		}
		return(consume_pointer_events);
	}

	public override bool on_context(int x, int y) {
		if(base.on_context(x, y)) {
			return(true);
		}
		return(consume_pointer_events);
	}

	public override bool on_context_drag(int x, int y, int dx, int dy, bool drop, int id) {
		if(base.on_context_drag(x, y, dx, dy, drop, id)) {
			return(true);
		}
		return(consume_pointer_events);
	}

	public override bool on_scroll(int x, int y, int dx, int dy) {
		if(base.on_scroll(x, y, dx, dy)) {
			return(true);
		}
		return(consume_pointer_events);
	}

	public override bool on_zoom(int x, int y, int dz) {
		if(base.on_zoom(x, y, dz)) {
			return(true);
		}
		return(consume_pointer_events);
	}

	public override bool on_key_press(KeyEvent e) {
		if(base.on_key_press(e)) {
			return(true);
		}
		if(consume_tab_key_events == false && e != null && "tab".equals(e.get_name())) {
			return(false);
		}
		return(consume_key_events);
	}

	public override bool on_key_release(KeyEvent e) {
		if(base.on_key_release(e)) {
			return(true);
		}
		if(consume_tab_key_events == false && e != null && "tab".equals(e.get_name())) {
			return(false);
		}
		return(consume_key_events);
	}

	public override bool on_key_event(KeyEvent e) {
		if(base.on_key_event(e)) {
			return(true);
		}
		if(consume_tab_key_events == false && e != null && "tab".equals(e.get_name())) {
			return(false);
		}
		return(consume_key_events);
	}
}
