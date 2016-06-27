
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

public interface LabelControl : Widget
{
	public static LabelControl instance() {
		return(ControlEngine.engine.create_label_control());
	}

	public static LabelControl for_text(String text) {
		var v = LabelControl.instance();
		if(v != null) {
			v.set_text(text);
		}
		return(v);
	}

	public static LabelControl for_bold_text(String text) {
		return(LabelControl.for_text(text).set_font_bold(true));
	}

	public static LabelControl for_string(String text) {
		return(LabelControl.for_text(text));
	}

	public LabelControl set_text(String text);
	public LabelControl set_font_bold(bool value);
	public LabelControl set_font_color(Color color);
	public LabelControl set_text_align(int align);
}
