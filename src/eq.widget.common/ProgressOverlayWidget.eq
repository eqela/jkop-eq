
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

public class ProgressOverlayWidget : LayerWidget
{
	public static ProgressOverlayWidget show(LayerWidget parent, String msg) {
		if(parent == null) {
			return(null);
		}
		var ww = ProgressOverlayWidget.for_message(msg);
		parent.add(ww);
		return(ww);
	}

	public static ProgressOverlayWidget hide(ProgressOverlayWidget ww) {
		if(ww == null) {
			return(null);
		}
		ww.dismiss_widget();
		return(null);
	}

	public static ProgressOverlayWidget for_message(String msg) {
		return(new ProgressOverlayWidget().set_display_text(msg));
	}

	String display_text;
	property Color background_color;
	property Color foreground_color;
	Widget canvas;
	Widget label;
	LabelWidget display_text_label;

	public ProgressOverlayWidget() {
		display_text = "Processing ..";
		background_color = Color.instance("#000000");
		foreground_color = Color.instance("#FFFFFF");
	}

	public ProgressOverlayWidget set_display_text(String dt) {
		display_text = dt;
		if(display_text_label != null) {
			display_text_label.set_text(dt);
		}
		return(this);
	}

	public String get_display_text() {
		return(display_text);
	}

	public void initialize() {
		base.initialize();
		set_draw_color(foreground_color);
		canvas = CanvasWidget.for_color(background_color);
		label = LayerWidget.instance().set_margin(px("2mm")).add(display_text_label = LabelWidget.for_string(display_text));
		set_alpha(0.0);
		label.set_align_x(0.0);
		label.set_align_y(-1.0);
		add(canvas);
		add(new AlignWidget().add(new WaitAnimationWidget().set_background_color(Theme.get_base_color())
			.set_size_request_override(px("30mm"), px("30mm"))));
		add(new AlignWidget().add(label));
	}

	public void first_start() {
		base.first_start();
		set_alpha(1.0, 750000);
		label.set_align_y(0.0, 750000);
	}

	public void cleanup() {
		base.cleanup();
		canvas = null;
		label = null;
		display_text_label = null;
	}

	public void dismiss_widget() {
		if(canvas == null || label == null) {
			base.dismiss_widget();
			return;
		}
		label.set_align_y(1.0, 750000);
		canvas = null;
		label = null;
		set_alpha(0.0, 750000, new WidgetDismisserAnimationListener().set_widget(this));
	}

	public bool on_pointer_press(int x, int y, int button, int id) {
		return(true);
	}

	public bool on_pointer_release(int x, int y, int button, int id) {
		return(true);
	}

	public bool on_pointer_move(int x, int y, int id) {
		return(true);
	}

	public bool on_pointer_cancel(int x, int y, int button, int id) {
		return(true);
	}

	public bool on_pointer_drag(int x, int y, int dx, int dy, int button, bool drop, int id) {
		return(true);
	}

	public bool on_context(int x, int y) {
		return(true);
	}

	public bool on_context_drag(int x, int y, int dx, int dy, bool drop, int id) {
		return(true);
	}

	public bool on_scroll(int x, int y, int dx, int dy) {
		return(true);
	}

	public bool on_zoom(int x, int y, int dz) {
		return(true);
	}
}
