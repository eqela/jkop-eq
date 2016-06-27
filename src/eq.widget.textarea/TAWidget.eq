
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

public class TAWidget : LayerWidget
{
	TADocumentWidget doc;
	property bool enable_scrolling = true;
	property Color background_color;
	property Color text_color;

	public TAWidget() {
		doc = new TADocumentWidget();
	}

	public TAWidget set_text(String str) {
		doc.set_document(TADocument.for_text(str));
		return(this);
	}

	public TAWidget set_markup(String str) {
		doc.set_document(TADocument.for_markup(str));
		return(this);
	}

	public TAWidget set_document(TADocument d) {
		doc.set_document(d);
		return(this);
	}

	public TAWidget set_font(Font font) {
		doc.set_font(font);
		return(this);
	}

	public String get_text() {
		var d = doc.get_document();
		if(d == null) {
			return(null);
		}
		return(d.get_content_text());
	}

	public String get_markup() {
		var d = doc.get_document();
		if(d == null) {
			return(null);
		}
		return(d.get_content_markup());
	}

	public TADocument get_document() {
		return(doc.get_document());
	}

	public void initialize() {
		base.initialize();
		var bgc = background_color;
		var txc = text_color;
		if(bgc == null) {
			bgc = Color.instance("#000000");
		}
		if(txc == null) {
			txc = Color.instance("#FFFFFF");
		}
		set_draw_color(txc);
		add(CanvasWidget.for_color(bgc));
		if(enable_scrolling) {
			add(VScrollerWidget.instance().add_scroller(doc));
		}
		else {
			add(doc);
		}
	}
}
