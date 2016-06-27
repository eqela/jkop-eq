
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

public class ImageButtonWidget : ClickWidget
{
	public static ImageButtonWidget instance(Image image, String text, Object event) {
		var v = new ImageButtonWidget().set_image(image).set_text(text);
		v.set_event(event);
		return(v);
	}

	property Image image;
	property String text;
	property Font font;
	property String image_mode;
	CanvasWidget canvas;

	public ImageButtonWidget() {
		font = Font.instance("5mm color=white outline-color=black");
		image_mode = "fill";
	}

	public void initialize() {
		base.initialize();
		if(image != null) {
			add(ImageWidget.for_image(image).set_mode(image_mode));
		}
		if(String.is_empty(text) == false) {
			add(LabelWidget.for_string(text).set_font(font));
		}
		set_height_request_override(px("30mm"));
	}

	public void on_changed() {
		if(get_pressed()) {
			if(canvas == null) {
				add(canvas = CanvasWidget.for_color(Color.instance("#00000070")));
			}
		}
		else {
			if(canvas != null) {
				remove(canvas);
				canvas = null;
			}
		}
	}
}
