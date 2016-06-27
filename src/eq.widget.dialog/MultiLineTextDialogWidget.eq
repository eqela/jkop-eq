
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

public class MultiLineTextDialogWidget : DialogWidget
{
	class Line
	{
		public String text;
		public String font;
	}

	Collection lines;
	BoxWidget box;

	public MultiLineTextDialogWidget add_line(String text, String font = null) {
		if(text == null) {
			return(this);
		}
		if(lines == null) {
			lines = LinkedList.create();
		}
		var line = new Line();
		line.text = text;
		line.font = font;
		lines.append(line);
		create_widgets();
		return(this);
	}

	void create_widgets() {
		if(is_initialized() == false || box == null) {
			return;
		}
		box.remove_children();
		foreach(Line line in lines) {
			box.add(LabelWidget.for_string(line.text).set_wrap(true).set_font(Theme.font().modify(line.font)));
		}
	}

	public void initialize() {
		base.initialize();
		set_dialog_main_widget(VScrollerWidget.instance().add_scroller(AlignWidget.instance().set_maximize_width(true).add(box = BoxWidget.vertical().set_spacing(px("1mm")))));
		create_widgets();
	}

	public void cleanup() {
		base.cleanup();
		box = null;
	}
}
