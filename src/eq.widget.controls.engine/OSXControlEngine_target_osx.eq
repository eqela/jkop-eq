
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

public class OSXControlEngine : ControlEngine
{
	public NumberSelectorControl create_number_selector_control() {
		return(new NumberSelectorControlWidget());
	}

	public TabbedViewControl create_tabbed_view_control() {
		return(new OSXTabbedViewControl());
	}

	public ButtonControl create_button_control() {
		return(new OSXButtonControl());
	}

	public LabelControl create_label_control() {
		return(new OSXLabelControl());
	}

	public SolidColorControl create_solid_color_control() {
		return(new OSXSolidColorControl());
	}

	public TextInputControl create_text_input_control() {
		return(new OSXTextInputControl());
	}

	public TextAreaControl create_text_area_control() {
		return(new OSXTextAreaControl());
	}

	public ScrollerControl create_horizontal_scroller_control(Widget widget) {
		var v = new OSXScrollerControl();
		v.set_horizontal(true);
		v.set_vertical(false);
		v.set_widget(widget);
		return(v);
	}

	public ScrollerControl create_vertical_scroller_control(Widget widget) {
		var v = new OSXScrollerControl();
		v.set_horizontal(false);
		v.set_vertical(true);
		v.set_widget(widget);
		return(v);
	}

	public ScrollerControl create_horizontal_vertical_scroller_control(Widget widget) {
		var v = new OSXScrollerControl();
		v.set_horizontal(true);
		v.set_vertical(true);
		v.set_widget(widget);
		return(v);
	}
}
