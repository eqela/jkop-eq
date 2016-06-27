
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

public class TATokenizedParagraphLayout : TAParagraphLayout, Size
{
	class SpaceLayout
	{
		property int count = 1;
	}

	property String text;
	property Font font;
	property Color default_color;
	property Frame frame;
	property int dpi;
	Collection layouts;
	property double char_width = 0;
	property double char_height = 0;
	double width = 0;

	public virtual Iterator tokenize(String text) {
		return(LinkedList.create().add(text).iterate());
	}

	public virtual Color color_for_token(String token) {
		return(default_color);
	}

	int is_empty_token(String token) {
		int v = 0;
		var it = token.iterate();
		int c;
		while((c = it.next_char()) > 0) {
			if(c == ' ') {
				v ++;
			}
			else {
				return(0);
			}
		}
		return(v);
	}

	public TATokenizedParagraphLayout initialize() {
		if(char_width < 1 || char_height < 1) {
			var l1 = TextLayout.for_properties(TextProperties.for_string("X X").set_font(font), frame, dpi);
			var l2 = TextLayout.for_properties(TextProperties.for_string("XX").set_font(font), frame, dpi);
			if(l1 != null) {
				if(l2 != null) {
					char_width = l1.get_width() - l2.get_width();
				}
				char_height = l1.get_height();
			}
		}
		layouts = LinkedList.create();
		width = 0;
		foreach(String token in tokenize(text)) {
			int et = is_empty_token(token);
			if(et > 0) {
				layouts.append(new SpaceLayout().set_count(et));
				width += et * char_width;
			}
			else {
				var props = TextProperties.for_string(token).set_font(font).set_color(color_for_token(token));
				var layout = TextLayout.for_properties(props, frame, dpi);
				if(layout != null) {
					layouts.append(layout);
					width += char_width * token.get_length();
				}
			}
		}
		return(this);
	}

	public Collection get_display_list() {
		var v = LinkedList.create();
		double x = 0;
		foreach(Object layout in layouts) {
			if(layout is SpaceLayout) {
				x += ((SpaceLayout)layout).get_count() * char_width;
			}
			else if(layout is TextLayout) {
				v.add(new DrawObjectOperation().set_object(layout).set_x(x));
				var props = ((TextLayout)layout).get_text_properties();
				int c = 0;
				if(props != null) {
					var text = props.get_text();
					if(text != null) {
						c = text.get_length();
					}
				}
				x += char_width * c;
			}
		}
		return(v);
	}

	public double get_width() {
		return(width);
	}

	public double get_height() {
		return(char_height);
	}
}
