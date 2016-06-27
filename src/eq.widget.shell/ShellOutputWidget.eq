
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

public class ShellOutputWidget : LayerWidget, ShellOutput, Stringable
{
	TADocument content;
	TAScrolledDocumentWidget widget;
	property int max_paragraphs = 10000;
	property TAParagraphWidgetCallback paragraph_callback;
	property Font font;

	public ShellOutputWidget() {
		content = TADocument.for_text("");
		content.disable_undo();
	}

	public void initialize() {
		base.initialize();
		widget = new TAScrolledDocumentWidget().set_document(content);
		widget.set_paragraph_callback(paragraph_callback);
		widget.set_ignore_trailing_empty_line(true);
		var f = font;
		if(f == null) {
			f = Theme.font().modify("2500um monospace");
		}
		widget.set_font(f);
		add(widget);
	}

	public void cleanup() {
		base.cleanup();
		widget = null;
	}

	public void print(String text) {
		bool scrolldown = false;
		if(widget != null && widget.is_at_bottom()) {
			scrolldown = true;
		}
		var o = content.get_position_end();
		var n = content.append_string(text);
		if(widget != null && scrolldown) {
			if(n.get_y() - o.get_y() > 10) {
				widget.scroll_to_bottom();
			}
			else {
				widget.scroll_until_bottom();
			}
		}
		if(content.get_paragraph_count() > max_paragraphs) {
			content.delete_range(TADocumentPosition.for_xy(0,0), TADocumentPosition.for_xy(0, content.get_paragraph_count() - (max_paragraphs - max_paragraphs/10)));
		}
	}

	public void scroll(int dy) {
		if(widget != null) {
			widget.scroll(dy);
		}
	}

	public void scroll_page(int dy) {
		if(widget != null) {
			widget.scroll_page(dy);
		}
	}

	public void scroll_to_bottom() {
		if(widget != null) {
			widget.scroll_to_bottom();
		}
	}

	public void clear() {
		content.replace_with_string("");
	}

	public String to_string() {
		if(content == null) {
			return(null);
		}
		return(content.to_string());
	}
}
