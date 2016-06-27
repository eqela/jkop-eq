
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

public class TAScrolledDocumentWidget : LayerWidget, TADocumentListener
{
	public static TAScrolledDocumentWidget for_document(TADocument td) {
		return(new TAScrolledDocumentWidget().set_document(td));
	}

	TADocument document;
	Font font;
	int firstparagraph = 0;
	int lastparagraph = 0;
	VBoxWidget paragraphs;
	ScrollBarWidget scrollbar;
	property bool wrap_lines = true;
	property int tab_spaces = -1;
	property int current_offset = 0;
	property bool ignore_trailing_empty_line = false;
	property TAParagraphWidgetCallback paragraph_callback;

	public TAScrolledDocumentWidget() {
		document = new TADocument();
	}

	public Font get_font() {
		return(font);
	}

	public virtual void on_font_changed() {
	}

	public TAScrolledDocumentWidget set_font(Font font) {
		this.font = font;
		on_font_changed();
		if(is_initialized()) {
			scroll_to_first(firstparagraph);
		}
		return(this);
	}

	public TAScrolledDocumentWidget set_text(String str) {
		set_document(TADocument.for_text(str));
		return(this);
	}

	public TAScrolledDocumentWidget set_document(TADocument d) {
		if(document != null) {
			document.set_listener(null);
		}
		document = d;
		if(is_initialized()) {
			document.set_listener(this);
			scroll_to_first(0);
		}
		return(this);
	}

	public int get_first_paragraph() {
		return(firstparagraph);
	}

	public int get_last_paragraph() {
		return(lastparagraph);
	}

	public TADocument get_document() {
		return(document);
	}

	public void initialize() {
		base.initialize();
		if(document != null) {
			document.set_listener(this);
		}
		add(paragraphs = VBoxWidget.instance());
		paragraphs.set_spacing(px(document.get_paragraph_spacing()));
		add(AlignWidget.instance().add_align(1, 0, scrollbar = new ScrollBarWidget()));
		scroll_to_first(0);
	}

	public void cleanup() {
		base.cleanup();
		if(document != null) {
			document.set_listener(null);
		}
		paragraphs = null;
		scrollbar = null;
	}

	void update_scrollbar() {
		if(scrollbar == null) {
			return;
		}
		if(document == null) {
			scrollbar.update(0, 0, 0);
			return;
		}
		scrollbar.update(firstparagraph, lastparagraph-firstparagraph, get_paragraph_count());
	}

	public virtual void on_document_scrolled() {
		update_scrollbar();
	}

	public void on_resize() {
		base.on_resize();
		// FIXME: This gives terrible performance
		if(get_height() > 0) {
			scroll_to_first(firstparagraph);
		}
		else {
			paragraphs.remove_children();
		}
	}

	public void on_ta_document_replaced(String str) {
		scroll_to_first(0);
	}

	bool is_printable(String str) {
		foreach(Integer i in str) {
			var c = i.to_integer();
			if(c == ' ' || c == '\t' || c == '\r' || c == '\n') {
				continue;
			}
			return(true);
		}
		return(false);
	}

	bool update_paragraph(int cpar) {
		var pp = paragraphs.get_child(cpar - firstparagraph) as TAParagraphWidget;
		if(pp != null) {
			var ntext = document.get_paragraph(cpar);
			pp.set_text(ntext);
			return(true);
		}
		return(false);
	}

	public void on_ta_document_insert(TADocumentPosition start, TADocumentPosition end, String str) {
		if(paragraphs == null) {
			return;
		}
		if(end.get_y() < firstparagraph || start.get_y() > lastparagraph) {
			return;
		}
		if(start.get_y() == end.get_y()) {
			if(update_paragraph(start.get_y())) {
				return;
			}
		}
		// FIXME: Technically this is overkill. We would only need to move the
		// paragraphs from current one forward. Ideally just INSERT a widget in between,
		// not having to redo everything .. It's just that this one is SO MUCH easier to do.
		scroll_to_first(firstparagraph);
	}

	public void on_ta_document_delete_char(TADocumentPosition pos, bool merge) {
		if(pos.get_y() < firstparagraph || pos.get_y() > lastparagraph) {
			return;
		}
		if(merge == false) {
			if(update_paragraph(pos.get_y())) {
				return;
			}
		}
		scroll_to_first(firstparagraph);
	}

	public void on_ta_document_delete_range(TADocumentPosition start, TADocumentPosition end) {
		if(start == null || end == null) {
			return;
		}
		var y1 = start.get_y();
		if(start.get_x() > 0) {
			y1++;
		}
		var y2 = end.get_y() - 1;
		if(y1 < firstparagraph && y2 < firstparagraph) {
			var diff = y2 - y1;
			firstparagraph -= diff;
			lastparagraph -= diff;
		}
		else if(y1 < firstparagraph && y2 >= firstparagraph) {
			var diff = firstparagraph - y1;
			firstparagraph -= diff;
			lastparagraph -= diff;
		}
		else if(y2 > lastparagraph) {
			// nothing to care for here
		}
		else {
			scroll_to_first(firstparagraph);
		}
	}

	int get_paragraph_count() {
		if(document == null) {
			return(0);
		}
		var pc = document.get_paragraph_count();
		if(ignore_trailing_empty_line) {
			if(pc > 0) {
				var lp = document.get_paragraph(pc-1);
				if(lp == null || lp.get_length() < 1) {
					pc --;
				}
			}
		}
		return(pc);
	}

	public void scroll_until_first(int fp) {
		while(true) {
			int ofp = firstparagraph;
			if(fp > firstparagraph) {
				scroll(1);
			}
			else if(fp < firstparagraph) {
				scroll(-1);
			}
			if(ofp == firstparagraph) {
				break;
			}
		}
	}

	public void scroll_until_last(int lp) {
		while(true) {
			int olp = lastparagraph;
			if(lp > lastparagraph) {
				scroll(1);
			}
			else if(lp < lastparagraph) {
				scroll(-1);
			}
			if(olp == lastparagraph) {
				break;
			}
		}
	}

	public void move_horizontally(int n) {
		change_current_offset(current_offset + n);
	}

	public void change_current_offset(int newoffset) {
		current_offset = newoffset;
		if(current_offset < 0) {
			current_offset = 0;
		}
		scroll_to_first(firstparagraph);
	}

	public virtual TAParagraphWidget create_paragraph_widget(EditableString text) {
		var v = new TAParagraphWidget().set_document(document).set_text(text)
			.set_font(font).set_wrap(wrap_lines).set_tab_spaces(tab_spaces)
			.set_offset(current_offset);
		if(paragraph_callback != null) {
			paragraph_callback.on_ta_paragraph_widget(v);
		}
		return(v);
	}

	public void scroll_to_first(int fp) {
		if(paragraphs == null) {
			return;
		}
		var firstparagraph = fp;
		if(firstparagraph < 0) {
			firstparagraph = 0;
		}
		paragraphs.remove_children();
		if(document != null) {
			int n, c = get_paragraph_count();
			for(n=firstparagraph; true; n++) {
				paragraphs.add(create_paragraph_widget(document.get_paragraph(n)));
				lastparagraph = n;
				if(paragraphs.get_height_request() >= get_height()) {
					break;
				}
			}
		}
		this.firstparagraph = firstparagraph;
		on_document_scrolled();
	}

	public void scroll_to_last(int ll) {
		var last = ll;
		if(last < 0) {
			scroll_to_first(0);
			return;
		}
		if(paragraphs == null) {
			on_document_scrolled();
			return;
		}
		var max = get_paragraph_count();
		if(max > 0) {
			max --;
		}
		if(last > max) {
			last = max;
		}
		paragraphs.remove_children();
		if(document != null) {
			int n;
			lastparagraph = last;
			for(n=last; n >= 0; n--) {
				paragraphs.prepend(create_paragraph_widget(document.get_paragraph(n)));
				firstparagraph = n;
				if(paragraphs.get_height_request() == get_height()) {
					break;
				}
				else if(paragraphs.get_height_request() > get_height()) {
					paragraphs.remove_first_child();
					firstparagraph++;
					break;
				}
			}
			while(paragraphs.get_height_request() < get_height()) {
				paragraphs.add(create_paragraph_widget(null));
				lastparagraph++;
			}
		}
		on_document_scrolled();
	}

	public void scroll_to_bottom() {
		if(is_at_bottom()) {
			return;
		}
		var pc = get_paragraph_count();
		if(pc > 0) {
			pc --;
		}
		scroll_to_last(pc);
	}

	public void scroll_page(int dy) {
		var diff = (lastparagraph - firstparagraph) / 2;
		if(diff < 1) {
			return;
		}
		int n;
		for(n=0; n<diff; n++) {
			if(scroll(dy) == false) {
				break;
			}
		}
	}

	public bool on_scroll(int x, int y, int dx, int dy) {
		scroll(-dy);
		return(true);
	}

	public bool scroll(int dy) {
		if(dy > 0) {
			if(is_at_bottom()) {
				return(false);
			}
			firstparagraph ++;
			paragraphs.remove_first_child();
			while(paragraphs.get_height_request() < get_height()) {
				lastparagraph ++;
				paragraphs.add(create_paragraph_widget(document.get_paragraph(lastparagraph)));
			}
			on_document_scrolled();
			return(true);
		}
		if(dy < 0) {
			if(firstparagraph < 1) {
				return(false);
			}
			firstparagraph --;
			var dd = document.get_paragraph(firstparagraph);
			var pp = create_paragraph_widget(dd);
			paragraphs.prepend(pp);
			while(true) {
				var lp = paragraphs.get_last_child();
				if(lp == null) {
					break;
				}
				var lphr = lp.get_height_request();
				if(paragraphs.get_height_request() - lphr > get_height()) {
					paragraphs.remove_last_child();
					lastparagraph --;
				}
				else {
					break;
				}
			}
			on_document_scrolled();
			return(true);
		}
		return(false);
	}

	public bool is_at_bottom() {
		if(document == null || paragraphs == null) {
			return(true);
		}
		if(lastparagraph > get_paragraph_count() - 1) {
			return(true);
		}
		return(false);
	}

	public void scroll_until_bottom() {
		if(get_height() < 1) {
			return;
		}
		while(is_at_bottom() == false) {
			scroll(1);
		}
	}
}
