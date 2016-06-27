
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

public class TableWidget : VBoxWidget
{
	public static TableWidget instance() {
		return(new TableWidget());
	}

	int columns;
	Array column_width;
	Array column_weight;
	property int border_width = 0;
	property Color border_color = null;
	property int padding = 0;

	public TableWidget set_columns(int n) {
		columns = n;
		if(n > 0) {
			column_width = Array.create(n);
			column_weight = Array.create(n);
			int x;
			for(x=0; x<n; x++) {
				column_width.set_index(x, Primitive.for_integer(0));
				column_weight.set_index(x, Primitive.for_integer(1));
			}
		}
		else {
			column_width = null;
			column_weight= null;
		}
		return(this);
	}

	public TableWidget set_column_width(int c, int w) {
		if(column_width != null && c < columns) {
			column_width.set_index(c, Primitive.for_integer(w));
		}
		return(this);
	}

	public TableWidget set_column_weight(int c, int w) {
		if(column_weight != null && c < columns) {
			column_weight.set_index(c, Primitive.for_integer(w));
		}
		return(this);
	}

	public TableWidget add_row(Collection widgets) {
		var row = HBoxWidget.instance();
		int n = 0;
		Iterator it;
		if(widgets != null) {
			it = widgets.iterate();
		}
		for(n=0; n<columns; n++) {
			Widget w;
			if(it != null) {
				w = it.next() as Widget;
			}
			if(w == null) {
				w = new Widget();
			}
			var cwidtho = column_width.get_index(n) as Integer;
			var cweighto = column_weight.get_index(n) as Integer;
			int cwidth = 0;
			int cweight = 1;
			if(cwidtho != null) {
				cwidth = cwidtho.to_integer();
			}
			if(cweighto != null) {
				cweight = cweighto.to_integer();
			}
			if(cwidth > 0) {
				cweight = 0;
			}
			if(cwidth > 0) {
				w.set_width_request_override(cwidth);
			}
			if(border_width > 0 && border_color != null && n == 0) {
				row.add_hbox(0, CanvasWidget.instance().set_color(border_color).set_width_request_override(border_width));
			}
			if(padding > 0) {
				row.add_hbox(cweight, LayerWidget.instance().set_margin(padding).add(w));
			}
			else {
				row.add_hbox(cweight, w);
			}
			if(border_width > 0 && border_color != null) {
				row.add_hbox(0, CanvasWidget.instance().set_color(border_color).set_width_request_override(border_width));
			}
		}
		if(border_width > 0 && border_color != null && count() == 0) {
			add(CanvasWidget.instance().set_color(border_color).set_height_request_override(border_width));
		}
		add(row);
		if(border_width > 0 && border_color != null) {
			add(CanvasWidget.instance().set_color(border_color).set_height_request_override(border_width));
		}
		return(this);
	}

	public void initialize() {
		base.initialize();
		if(border_width > 0 && border_color == null) {
			border_color = get_draw_color();
		}
	}
}
