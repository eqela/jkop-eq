
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

public class ClockWidget : LayerWidget, TimerHandler
{
	LabelWidget label;
	BackgroundTask timer;
	bool narrow_mode = false;

	public void initialize() {
		base.initialize();
		var ll = LayerWidget.instance();
		ll.add(CanvasWidget.for_color(Color.instance("#FFFFFF20")).set_outline_color(Color.instance("#FFFFFF40")).set_rounded(true));
		ll.add(LayerWidget.instance().set_margin(px("1mm")).add(label = LabelWidget.instance()).set_minimum_width_request(px("17mm")));
		label.set_font(Theme.font().modify("bold color=white shadow-color=black"));
		add(AlignWidget.instance().add(ll));
	}

	public void set_narrow_mode(bool nm) {
		narrow_mode = nm;
		update();
	}

	public void cleanup() {
		base.cleanup();
		label = null;
	}

	void update() {
		if(label == null) {
			return;
		}
		if(narrow_mode) {
			label.set_text(DateTime.for_now().to_string_time(true, true, false));
		}
		else {
			label.set_text(DateTime.for_now().to_string_time(true, true, false));
		}
	}

	public void start() {
		base.start();
		timer = start_timer(60 * 1000000, this, null);
		update();
	}

	public void stop() {
		base.stop();
		if(timer != null) {
			timer.abort();
			timer = null;
		}
	}

	public bool on_timer(Object arg) {
		update();
		return(true);
	}
}
