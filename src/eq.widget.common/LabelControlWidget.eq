
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

public class LabelControlWidget : LayerWidget, LabelControl
{
	String text;
	LabelWidget label;
	int align;
	bool bold = false;
	Color color;

	public void initialize() {
		base.initialize();
		add(label = LabelWidget.instance());
		update_label();
	}

	public void cleanup() {
		base.cleanup();
		label = null;
	}

	void update_label() {
		if(label != null) {
			label.set_text(text);
			if(align == Alignment.LEFT) {
				label.set_text_align(LabelWidget.LEFT);
			}
			else if(align == Alignment.CENTER) {
				label.set_text_align(LabelWidget.CENTER);
			}
			else if(align == Alignment.RIGHT) {
				label.set_text_align(LabelWidget.RIGHT);
			}
			label.set_color(color);
			if(bold) {
				label.set_font(Theme.font().modify("bold"));
			}
			else {
				label.set_font(Theme.font());
			}
		}
	}

	public LabelControl set_text(String text) {
		this.text = text;
		update_label();
		return(this);
	}

	public LabelControl set_text_align(int align) {
		this.align = align;
		update_label();
		return(this);
	}

	public LabelControl set_font_bold(bool value) {
		this.bold = value;
		update_label();
		return(this);
	}

	public LabelControl set_font_color(Color color) {
		this.color = color;
		update_label();
		return(this);
	}
}
