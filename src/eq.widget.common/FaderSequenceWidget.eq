
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

public class FaderSequenceWidget : ChangerWidget, TimerHandler
{
	public static FaderSequenceWidget for_content(Array content, int delay = -1) {
		var v = new FaderSequenceWidget().set_content(content);
		if(delay > 0) {
			v.set_delay(delay);
		}
		return(v);
	}

	property int delay = 5 * 1000000;
	property String image_mode;
	BackgroundTask timer;
	Array content;
	int current;

	public FaderSequenceWidget() {
		image_mode = "fill";
	}

	public FaderSequenceWidget set_content(Array content) {
		this.content = content;
		current = -1;
		return(this);
	}

	Widget widget_for_content_item(Object o) {
		if(o is Image) {
			return(ImageWidget.for_image((Image)o).set_mode(image_mode));
		}
		if(o is Collection) {
			var image = ((Collection)o).get(0) as Image;
			var text = String.as_string(((Collection)o).get(1));
			var v = LayerWidget.instance();
			if(image != null) {
				v.add(ImageWidget.for_image(image).set_mode(image_mode));
			}
			if(String.is_empty(text) == false) {
				v.add(LayerWidget.instance().set_margin(px("2mm"))
					.add(LabelWidget.for_string(text).set_font(Font.instance("4mm italic color=white shadow-color=black")).set_wrap(true)));
			}
			return(v);
		}
		return(null);
	}

	void show_next() {
		if(content == null || content.count() < 1) {
			return;
		}
		var n = current+1;
		if(n >= content.count()) {
			n = 0;
		}
		current = n;
		replace_with(widget_for_content_item(content.get(n)), ChangerWidget.EFFECT_CROSSFADE);
	}

	public bool on_timer(Object o) {
		show_next();
		return(true);
	}

	public void start() {
		base.start();
		timer = start_timer(delay, this, null);
		show_next();
	}

	public void stop() {
		base.stop();
		if(timer != null) {
			timer.abort();
			timer = null;
		}
	}
}
