
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

public class TADocumentWidget : LayerWidget, TADocumentListener
{
	public static TADocumentWidget for_document(TADocument td) {
		return(new TADocumentWidget().set_document(td));
	}

	TADocument document;
	VBoxWidget paragraphbox;
	property Font font;
	property bool enable_cursor = false;

	public TADocumentWidget() {
		document = new TADocument();
	}

	public TADocumentWidget set_document(TADocument d) {
		if(document != null) {
			document.set_listener(null);
		}
		document = d;
		if(is_initialized()) {
			document.set_listener(this);
			redisplay_document();
		}
		return(this);
	}

	public TADocument get_document() {
		return(document);
	}

	// FIXME: Should "hide" / disable widgets that are not being shown (to conserve memory / resources)

	public void initialize() {
		base.initialize();
		if(document != null) {
			document.set_listener(this);
		}
		redisplay_document();
	}

	public void cleanup() {
		base.cleanup();
		if(document != null) {
			document.set_listener(null);
		}
		paragraphbox = null;
	}

	void redisplay_document() {
		remove_children();
		if(document != null) {
			var vb = VBoxWidget.instance();
			vb.set_spacing(px(document.get_paragraph_spacing()));
			foreach(EditableString eds in document.get_paragraphs()) {
				vb.add(new TAParagraphWidget().set_document(document).set_text(eds).set_font(font));
			}
			add(vb);
			paragraphbox = vb;
		}
	}

	void update_paragraph(int index) {
		if(paragraphbox == null) {
			redisplay_document();
			return;
		}
		if(document == null) {
			return;
		}
		var pp = document.get_paragraph(index);
		var pw = paragraphbox.get_child(index) as TAParagraphWidget;
		if(pw == null) {
			paragraphbox.add(new TAParagraphWidget().set_document(document).set_text(pp).set_font(font));
		}
		else {
			pw.set_text(pp);
		}
	}

	public void on_ta_document_replaced(String str) {
		redisplay_document();
	}

	public void on_ta_document_insert(TADocumentPosition start, TADocumentPosition end, String str) {
		// FIXME: This is not correct in a generic case. We should INSERT the vboxes here, and let the 
		// following elements be as is. If we use this logic, we would need to update (remake) all
		// paragraphs following this one (which would work, but is too heavy to do)
		int n, s, e;
		s = start.get_y();
		e = end.get_y();
		for(n=s; n<=e; n++) {
			update_paragraph(n);
		}
	}

	public void on_ta_document_delete_char(TADocumentPosition pos, bool merge) {
		redisplay_document();
	}

	public void on_ta_document_delete_range(TADocumentPosition start, TADocumentPosition end) {
		redisplay_document();
	}
}
