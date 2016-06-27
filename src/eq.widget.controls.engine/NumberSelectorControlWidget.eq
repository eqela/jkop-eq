
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

// FIXME: This is really a lowest possible way to get it done. Need a better widget.
public class NumberSelectorControlWidget : LayerWidget, NumberSelectorControl
{
	TextInputWidget tiw;
	int value = 0;

	public void initialize() {
		base.initialize();
		add(tiw = TextInputWidget.instance());
		tiw.set_input_type(TextInputWidget.INPUT_TYPE_INTEGER);
		tiw.set_text(String.for_integer(value));
	}

	public void cleanup() {
		base.cleanup();
		if(tiw != null) {
			var vv = tiw.get_text();
			if(vv != null) {
				value = vv.to_integer();
			}
		}
		tiw = null;
	}

	public NumberSelectorControl set_value(int n) {
		value = n;
		if(tiw != null) {
			tiw.set_text(String.for_integer(n));
		}
		return(this);
	}

	public NumberSelectorControl set_minimum_value(int n) {
		// FIXME
		return(this);
	}

	public NumberSelectorControl set_maximum_value(int n) {
		// FIXME
		return(this);
	}

	public int get_value() {
		if(tiw != null) {
			var vv = tiw.get_text();
			if(vv == null) {
				return(0);
			}
			return(vv.to_integer());
		}
		return(value);
	}
}
