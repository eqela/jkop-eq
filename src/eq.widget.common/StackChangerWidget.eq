
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

public class StackChangerWidget : ChangerWidget
{
	public static StackChangerWidget instance() {
		return(new StackChangerWidget());
	}

	public void push(Widget widget, int effect = 0) {
		push_widget(widget, effect);
	}

	public bool pop(int effect = 0) {
		return(pop_widget(effect));
	}

	public void push_widget(Widget widget, int effect) {
		if(widget == null) {
			return;
		}
		add_changer(widget, true, effect);
	}

	public bool pop_widget(int effect) {
		var rr = iterate_children_reverse();
		if(rr == null) {
			return(false);
		}
		var cc = rr.next() as Widget;
		if(cc == null) {
			return(false);
		}
		return(replace_with(rr.next() as Widget, effect));
	}
}
