
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

public class DynamicImageWidget : ChangerWidget, EventReceiver
{
	public static DynamicImageWidget instance() {
		return(new DynamicImageWidget());
	}

	public static DynamicImageWidget for_provider(DynamicImageProvider provider) {
		return(new DynamicImageWidget().set_provider(provider));
	}

	DynamicImageProvider provider;
	BackgroundTask op;
	property String image_width;
	property String image_height;
	property String image_mode;
	property String broken_image_name;
	Image image;

	public DynamicImageWidget() {
		image_width = "20mm";
		image_height = "20mm";
		image_mode = "fit";
		broken_image_name = "image_not_found";
	}

	public Image get_image() {
		return(image);
	}

	public DynamicImageWidget set_provider(DynamicImageProvider provider) {
		this.provider = provider;
		this.image = null;
		if(is_initialized()) {
			update_image();
		}
		return(this);
	}

	public void initialize() {
		base.initialize();
		if(String.is_empty(image_width) == false && String.is_empty(image_height) == false) {
			set_size_request_override(px(image_width), px(image_height));
		}
		if(image == null) {
			update_image();
		}
	}

	public void stop() {
		base.stop();
		abort_update();
	}

	void abort_update() {
		if(op != null) {
			op.abort();
			op = null;
		}
		var waw = get_active_widget() as WaitAnimationWidget;
		if(waw != null) {
			replace_with(new Widget(), ChangerWidget.EFFECT_CROSSFADE);
		}
	}

	void set_broken_image() {
		var bi = IconCache.get(broken_image_name);
		if(bi != null) {
			replace_with(ImageWidget.for_image(bi), ChangerWidget.EFFECT_CROSSFADE);
		}
		else {
			replace_with(CanvasWidget.for_colors(Color.instance("#404040"), Color.instance("#808080"))
				.set_outline_color(Color.instance("#000000")).set_outline_width("600um"), ChangerWidget.EFFECT_CROSSFADE);
		}
	}

	public void update_image() {
		abort_update();
		if(provider == null) {
			set_broken_image();
		}
		else {
			replace_with(WaitAnimationWidget.instance(), ChangerWidget.EFFECT_CROSSFADE);
			op = provider.get(this, this);
		}
	}

	public void on_event(Object o) {
		if(o != null && o is DynamicImageResult) {
			op = null;
			var we = (DynamicImageResult)o;
			image = we.get_image();
			if(image == null) {
				set_broken_image();
			}
			else {
				replace_with(ImageWidget.for_image(image).set_mode(image_mode), ChangerWidget.EFFECT_CROSSFADE);
			}
			return;
		}
		forward_event(o);
	}
}
