
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

public class TASimpleParagraphLayout : TAParagraphLayout, Size
{
	property String text;
	property Font font;
	property Color color;
	property double wrapwidth;
	property Frame frame;
	property int dpi;
	TextLayout layout;

	public TASimpleParagraphLayout initialize() {
		var props = TextProperties.for_string(text);
		props.set_font(font);
		props.set_default_color(color);
		if(wrapwidth > 0) {
			props.set_wrap_width(wrapwidth);
		}
		layout = TextLayout.for_properties(props, frame, dpi);
		return(this);
	}

	public Collection get_display_list() {
		return(LinkedList.create().append(new DrawObjectOperation().set_object(layout)));
	}

	public double get_width() {
		if(layout == null) {
			return(0);
		}
		return(layout.get_width());
	}

	public double get_height() {
		if(layout == null) {
			return(0);
		}
		return(layout.get_height());
	}
}
