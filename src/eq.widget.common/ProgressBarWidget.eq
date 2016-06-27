
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

public class ProgressBarWidget : LayerWidget
{
	public static ProgressBarWidget instance() {
		return(new ProgressBarWidget());
	}

	LabelWidget label;
	String text;
	Color color;
	int value = 0;
	int max = 0;
	bool draw_border = true;

	public ProgressBarWidget set_draw_border(bool v) {
		draw_border = v;
		update_view();
		return(this);
	}

	public bool get_draw_border() {
		return(draw_border);
	}

	public ProgressBarWidget set_text(String text) {
		this.text = text;
		if(label != null) {
			label.set_text(text);
		}
		return(this);
	}

	public String get_text() {
		return(text);
	}

	public ProgressBarWidget set_color(Color color) {
		this.color = color;
		update_view();
		return(this);
	}

	public Color get_color() {
		return(color);
	}

	public ProgressBarWidget set_value(int value) {
		this.value = value;
		update_view();
		return(this);
	}

	public int get_value() {
		return(value);
	}

	public ProgressBarWidget set_max(int max) {
		this.max = max;
		update_view();
		return(this);
	}

	public int get_max() {
		return(max);
	}

	public void initialize() {
		base.initialize();
		if(color == null) {
			color = Theme.get_highlight_color();
		}
		set_width_request(px("65mm"));
		if(String.is_empty(text)) {
			text = " ";
		}
		add(label = LabelWidget.for_string(text));
		set_margin(px("1mm"));
	}

	public void cleanup() {
		base.initialize();
		label = null;
	}

	public Collection render() {
		var v = LinkedList.create();
		if(draw_border) {
			v.add(new StrokeOperation().set_x(0).set_y(0).set_color(color)
				.set_shape(RectangleShape.create(0, 0, get_width(), get_height()))
				.set_width(px("500um")));
		}
		if(max > 0) {
			v.add(new FillColorOperation().set_x(0).set_y(0).set_color(color)
				.set_shape(RectangleShape.create(0, 0, ((double)value / (double)max) * get_width(), get_height())));
		}
		return(v);
	}
}
