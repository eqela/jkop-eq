
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

public interface VgContext
{
	public bool stroke(int x, int y, VgPath vp, VgTransform vt, Color c, int linewidth = 1, int style = 0);
	public bool clear(int x, int y, VgPath vp, VgTransform vt);
	public bool fill_color(int x, int y, VgPath vp, VgTransform vt, Color c);
	public bool fill_vertical_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b);
	public bool fill_horizontal_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b);
	public bool fill_radial_gradient(int x, int y, VgPath vp, VgTransform vt, int radius, Color a, Color b);
	public bool fill_diagonal_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b, int direction);
	public bool draw_text(int x, int y, VgTransform vt, TextLayout text);
	public bool draw_graphic(int x, int y, VgTransform vt, Image agraphic);
	public bool clip(int x, int y, VgPath vp, VgTransform vt);
	public bool clip_clear();
}
