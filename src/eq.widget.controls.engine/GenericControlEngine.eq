
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

public class GenericControlEngine : ControlEngine
{
	public NumberSelectorControl create_number_selector_control() {
		return(new NumberSelectorControlWidget());
	}

	public TabbedViewControl create_tabbed_view_control() {
		return(new TabbedViewControlWidget());
	}

	public ButtonControl create_button_control() {
		return(new ButtonControlWidget());
	}

	public LabelControl create_label_control() {
		return(new LabelControlWidget());
	}

	public SolidColorControl create_solid_color_control() {
		return(new SolidColorControlWidget());
	}

	public TextInputControl create_text_input_control() {
		return(new TextInputControlWidget());
	}

	public TextAreaControl create_text_area_control() {
		return(null); // FIXME
	}

	public ScrollerControl create_horizontal_scroller_control(Widget widget) {
		return(HScrollerWidget.for_widget(widget));
	}

	public ScrollerControl create_vertical_scroller_control(Widget widget) {
		return(VScrollerWidget.for_widget(widget));
	}

	public ScrollerControl create_horizontal_vertical_scroller_control(Widget widget) {
		return(ScrollerWidget.for_widget(widget));
	}
}
