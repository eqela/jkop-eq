
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

class MyDraggableSprite : SESpriteEntity, SEPointerListener
{
	int dragging = -1;
	double dragx;
	double dragy;

	public void initialize(SEResourceCache rsc) {
		base.initialize(rsc);
		set_image(SEImage.for_resource("image"));
	}

	public void on_pointer_move(SEPointerInfo pi) {
		if(dragging < 0 || pi.get_id() != dragging) {
			return;
		}
		move(pi.get_x() - dragx, pi.get_y() - dragy);
	}

	public void on_pointer_press(SEPointerInfo pi) {
		if(pi.is_inside(get_x(), get_y(), get_width(), get_height())) {
			dragging = pi.get_id();
			dragx = pi.get_x() - get_x();
			dragy = pi.get_y() - get_y();
		}
	}

	public void on_pointer_release(SEPointerInfo pi) {
		if(dragging >= 0 && dragging == pi.get_id()) {
			dragging = -1;
		}
	}
}
