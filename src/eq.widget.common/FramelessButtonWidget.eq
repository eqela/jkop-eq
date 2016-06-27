
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

public class FramelessButtonWidget : ButtonWidget
{
	public static FramelessButtonWidget instance() {
		return(new FramelessButtonWidget());
	}

	public static FramelessButtonWidget create(Image image, String text) {
		return((FramelessButtonWidget)new FramelessButtonWidget().set_icon(image).set_text(text));
	}

	public static FramelessButtonWidget for_image(Image image) {
		return((FramelessButtonWidget)new FramelessButtonWidget().set_icon(image));
	}

	public static FramelessButtonWidget for_text(String text) {
		return((FramelessButtonWidget)new FramelessButtonWidget().set_text(text));
	}

	public static FramelessButtonWidget for_widget(Widget widget) {
		return((FramelessButtonWidget)new FramelessButtonWidget().set_custom_display_widget(widget));
	}

	public static FramelessButtonWidget for_action_item(ActionItem ai) {
		return((FramelessButtonWidget)new FramelessButtonWidget().set_action_item(ai));
	}

	public FramelessButtonWidget() {
		set_draw_frame(false);
		set_draw_outline(false);
		set_rounded(false);
		set_color(Theme.get_base_color().set_a(0.75));
		set_internal_margin("500um");
	}

	public FramelessButtonWidget make_bold() {
		set_font(Theme.font().modify("bold"));
		return(this);
	}
}
