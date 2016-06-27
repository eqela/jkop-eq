
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

public class FormButtonWidget : ButtonWidget
{
	property String title;
	property String label;

	public FormButtonWidget() {
		set_color(Color.instance("#AAAAAA80"));
	}

	public void initialize() {
		base.initialize();
		var lw = BoxWidget.vertical();
		lw.set_margin(px("2mm"));
		lw.set_spacing(px("1mm"));
		if(String.is_empty(title) == false) {
			lw.add(LabelWidget.for_string(title).set_font(Theme.font().modify("bold")).set_wrap(true).set_text_align(LabelWidget.LEFT));
		}
		if(String.is_empty(label) == false) {
			lw.add(LabelWidget.for_string(label).set_wrap(true).set_text_align(LabelWidget.LEFT));
		}
		add(lw);
	}
}
