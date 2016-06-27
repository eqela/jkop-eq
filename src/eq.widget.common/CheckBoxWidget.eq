
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

public class CheckBoxWidget : ClickWidget, DataAwareObject
{
	class SquareWidget : Widget
	{
		bool checked;

		public SquareWidget() {
			checked = false;
		}

		public void start() {
			base.start();
			set_size_request_override(px("7mm"), px("7mm"));
		}

		public SquareWidget set_checked(bool c) {
			checked = c;
			update_view();
			return(this);
		}

		public bool is_checked() {
			return(checked);
		}

		public Collection render() {
			var ll = LinkedList.create();
			int width = get_width();
			int height = get_height();
			int sz = (int)width * 0.5;
			int square_x = (int) (width * 0.5) - (sz * 0.5);
			int square_y = (int) (height * 0.5) - (sz * 0.5);
			var square = RectangleShape.create(0, 0, sz, sz);
			if(checked) {
				ll.add(new FillColorOperation().set_x(square_x).set_y(square_y).set_shape(square)
					.set_color(Color.instance("white")));
				var cs = CustomShape.create(sz * 0.1, sz * 0.5);
				cs.line(sz * 0.4, sz * 0.80);
				cs.line(sz * 0.85, sz * 0.2);
				cs.line(sz * 0.75, sz * 0.105);
				cs.line(sz * 0.38, sz * 0.6);
				cs.line(sz * 0.18, sz * 0.40);
				ll.add(new FillColorOperation().set_x(square_x + 1).set_y(square_y + 1).set_shape(cs).set_color(Color.instance("black")));
			}
			else {
				ll.add(new FillColorOperation().set_x(square_x).set_y(square_y).set_shape(square)
					.set_color(Color.instance("white")));
			}
			return(ll);
		}
	}

	public static CheckBoxWidget for_widget(Widget widget, bool is_checked = false) {
		return(new CheckBoxWidget().set_widget(widget).set_checked(is_checked));
	}

	public static CheckBoxWidget for_string(String text, bool is_checked = false) {
		var widget = LabelWidget.for_string(text).set_text_align(LabelWidget.LEFT);
		var cbw = new CheckBoxWidget().set_widget(widget).set_checked(is_checked);
		return(cbw);
	}

	property Widget widget;
	SquareWidget square_widget;
	bool checked;

	public void set_data(Object o) {
		if(o != null && o is Boolean) {
			set_checked(((Boolean)o).to_boolean());
		}
	}

	public Object get_data() {
		return(Primitive.for_boolean(checked));
	}

	public CheckBoxWidget set_checked(bool c) {
		checked = c;
		if(square_widget != null) {
			square_widget.set_checked(c);
		}
		return(this);
	}

	public bool is_checked() {
		return(checked);
	}

	public void initialize() {
		base.initialize();
		var hb = HBoxWidget.instance();
		square_widget = new SquareWidget();
		square_widget.set_checked(checked);
		hb.add_hbox(0, square_widget);
		hb.add_hbox(1, widget);
		add(hb);
	}

	public override void on_clicked() {
		if(checked) {
			checked = false;
			square_widget.set_checked(false);
		}
		else {
			checked = true;
			square_widget.set_checked(true);
		}
		raise_event(this, false);
	}

	public void cleanup() {
		base.cleanup();
		square_widget = null;
	}
}

