
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

public class MultiLineLabelWidget : VBoxWidget
{
	property Font font;
	String text;
	int align = 0;

	public void initialize() {
		base.initialize();
		if(font == null) {
			font = Theme.font().modify("monospace");
		}
		if(String.is_empty(text) == false) {
			update_text();
		}
	}

	public MultiLineLabelWidget set_text(String str) {
		this.text = str;
		if(is_initialized()) {
			update_text();
		}
		return(this);
	}

	void add_line(String str) {
		var ss = str;
		if(String.is_empty(ss)) {
			ss = " ";
		}
		add(LabelWidget.for_string(ss).set_font(font).set_text_align(align).set_wrap(true));
	}

	public MultiLineLabelWidget add_text(String text) {
		foreach(String str in StringSplitter.split(text, (int)'\n')) {
			add_line(str);
		}
		return(this);
	}

	void update_text() {
		remove_children();
		foreach(String str in StringSplitter.split(text, (int)'\n')) {
			add_line(str);
		}
	}

	public MultiLineLabelWidget set_text_align(int n) {
		align = n;
		update_text();
		return(this);
	}
}
