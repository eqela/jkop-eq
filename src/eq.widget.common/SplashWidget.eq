
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

public class SplashWidget : LayerWidget
{
	class TextInfo
	{
		property String text;
		property Font font;
	}

	property Widget next;
	Collection objects;
	BoxWidget box;
	property bool fade_in = true;
	property bool fade_out = true;
	property int splash_delay = 3000000;
	property int logo_delay;
	property int transition_delay = 500000;
	property String max_logo_width;
	int max_logo_width_px;
	property Color background_color;
	property Image background_image;
	property bool show_powered_by_eqela = true;

	public SplashWidget() {
		objects = LinkedList.create();
		max_logo_width = "70mm";
		background_color = Color.instance("black");
	}

	public SplashWidget add_image(Image img) {
		if(img != null) {
			objects.add(img);
		}
		return(this);
	}

	public SplashWidget add_widget(Widget w) {
		if(w != null) {
			objects.add(w);
		}
		return(this);
	}

	public SplashWidget add_text(String text, Font font = null) {
		objects.add(new TextInfo().set_text(text).set_font(font));
		return(this);
	}

	public void on_resize() {
		base.on_resize();
		if(box == null) {
			return;
		}
		var niw = (int)(2 * get_width()) / 3;
		if(max_logo_width_px > 0 && niw > max_logo_width_px) {
			niw = max_logo_width_px;
		}
		foreach(ImageWidget iw in box.iterate_children()) {
			iw.set_image_width(niw);
		}
	}

	public void initialize() {
		base.initialize();
		if(max_logo_width != null) {
			max_logo_width_px = px(max_logo_width);
		}
		else {
			max_logo_width_px = -1;
		}
		set_size_request_override(px("170mm"), px("120mm"));
		if(background_image != null) {
			add(ImageWidget.for_image(background_image));
		}
		if(background_color != null) {
			add(CanvasWidget.for_color(background_color));
		}
		set_draw_color(Color.instance("white"));
		var vb = VBoxWidget.instance().set_spacing(px("1mm"));
		foreach(var o in objects) {
			if(o is Image) {
				var iw = ImageWidget.for_image((Image)o).set_mode("fit");
				iw.set_alpha(0.0);
				vb.add(iw);
			}
			else if(o is Widget) {
				add((Widget)o);
			}
			else if(o is TextInfo) {
				var ti = (TextInfo)o;
				vb.add(LabelWidget.for_string(ti.get_text()).set_font(ti.get_font()).set_wrap(true));
			}
		}
		add(AlignWidget.instance().add(vb));
		if(show_powered_by_eqela) {
			add(AlignWidget.instance().add_align(1, 1, ImageWidget.for_image(IconCache.get("poweredbyeqela")).set_mode("fit")
				.set_image_height(px("6mm"))));
		}
		box = vb;
	}

	public void cleanup() {
		base.cleanup();
		box = null;
	}

	public void start() {
		base.start();
		start_delay_timer(splash_delay);
		foreach(ImageWidget iw in box.iterate_children()) {
			iw.set_alpha(1.0, transition_delay);
		}
	}

	public void on_delay_timer(Object arg) {
		switch_to_next();
	}

	void switch_to_next() {
		if(box != null) {
			foreach(ImageWidget iw in box.iterate_children()) {
				iw.set_scale(1.0);
			}
		}
		var pp = get_parent() as ContainerWidget;
		if(pp != null && next != null) {
			if(fade_in) {
				next.set_alpha(0.0);
				pp.add(next);
				next.set_alpha(1.0, transition_delay);
			}
			else {
				pp.add(next);
			}
		}
		if(fade_out) {
			set_alpha(0.0, transition_delay, new WidgetDismisserAnimationListener().set_widget(this));
		}
		else {
			dismiss_widget();
		}
	}
}
