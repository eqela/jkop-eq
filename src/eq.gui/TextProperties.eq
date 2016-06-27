
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

public class TextProperties
{
	public static TextProperties for_string(String tt) {
		return(new TextProperties().set_text(tt));
	}

	public TextProperties dup() {
		return(new TextProperties()
			.set_text(text).set_font(font).set_wrap_width(wrap_width)
			.set_alignment(alignment).set_color(color)
			.set_outline_color(outline_color)
		);
	}

	public static int LEFT = 0;
	public static int CENTER = 1;
	public static int RIGHT = 2;
	public static int JUSTIFY = 3;

	property String text;
	property Font font;
	property int wrap_width;
	property int alignment;
	Color color;
	Color outline_color;
	property Color default_color;

	public TextProperties set_color(Color c) {
		color = c;
		return(this);
	}

	public TextProperties set_outline_color(Color c) {
		outline_color = c;
		return(this);
	}

	public Color get_color() {
		if(color != null) {
			return(color);
		}
		if(font != null) {
			var cc = font.get_color();
			if(cc != null) {
				return(cc);
			}
		}
		if(default_color != null) {
			return(default_color);
		}
		return(null);
	}

	public Color get_outline_color() {
		if(outline_color != null) {
			return(outline_color);
		}
		if(font != null) {
			return(font.get_outline_color());
		}
		return(null);
	}
}
