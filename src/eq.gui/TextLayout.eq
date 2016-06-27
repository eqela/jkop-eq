
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

public interface TextLayout : Size
{
	public static TextLayout for_properties(TextProperties text, Frame frame, int dpi) {
		if(GUI.engine == null) {
			return(null);
		}
		return(GUI.engine.layout_text(text, frame, dpi));
	}

	public static TextLayout for_properties_with_limit(TextProperties text, Frame frame, int maxwidth, int dpi) {
		if(text == null) {
			return(null);
		}
		var tt = text.dup();
		tt.set_wrap_width(0);
		var lt = TextLayout.for_properties(text, frame, dpi);
		if(lt == null) {
			return(null);
		}
		int ltw = lt.get_width();
		if(ltw <= maxwidth) {
			return(lt);
		}
		var ddp = tt.dup();
		ddp.set_text("..");
		var dotdot = TextLayout.for_properties(ddp, frame, dpi);
		if(dotdot == null) {
			return(lt);
		}
		var idx = lt.xy_to_index(maxwidth-dotdot.get_width(), 0) - 1;
		if(idx < 1) {
			return(lt);
		}
		var ttt = tt.get_text();
		if(ttt == null) {
			return(lt);
		}
		tt.set_text(ttt.substring(0, idx).append(".."));
		return(TextLayout.for_properties(tt, frame, dpi));
	}

	public TextProperties get_text_properties();
	public Rectangle get_cursor_position(int index);
	public int xy_to_index(double x, double y);
}
