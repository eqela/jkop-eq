
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

public class BackgroundWidget : LayerWidget
{
	public static BackgroundWidget instance() {
		return(new BackgroundWidget());
	}

	property Image tile;
	property Image image;
	property Color color;
	property Color color2;

	public void initialize() {
		base.initialize();
		if(color != null) {
			if(color2 != null) {
				add(CanvasWidget.for_colors(color, color2));
			}
			else {
				add(CanvasWidget.for_color(color));
			}
		}
		if(image != null) {
			add(ImageWidget.for_image(image).set_mode("fill"));
		}
		if(tile != null) {
			add(ImageWidget.for_image(tile).set_mode("tile"));
		}
	}
}
