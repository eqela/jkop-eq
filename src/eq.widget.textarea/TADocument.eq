
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

public class TADocument : Stringable
{
	public static TADocument for_text(String s) {
		var v = new TADocument();
		v.set_text(s);
		v.set_type(TADocumentType.TEXT);
		return(v);
	}

	public static TADocument for_markup(String s) {
		var v = new TADocument();
		v.set_text(s);
		v.set_type(TADocumentType.MARKUP);
		return(v);
	}

	Array paragraphs;
	Stack undo_buffer;
	property int type;
	property String paragraph_spacing;
	property TADocumentListener listener;
	property int undo_buffer_limit = 10000;

	public TADocument() {
		paragraphs = Array.create();
		undo_buffer = Stack.create();
		type = TADocumentType.TEXT;
		paragraph_spacing = "0px";
	}

	public TADocument enable_undo() {
		undo_buffer = Stack.create();
		return(this);
	}

	public TADocument disable_undo() {
		undo_buffer = null;
		return(this);
	}

	public void clear_undo_buffer() {
		undo_buffer = Stack.create();
	}

	public int get_undo_buffer_entry_count() {
		if(undo_buffer == null) {
			return(0);
		}
		return(undo_buffer.count());
	}

	////////////////////////////////
	// Data acccess / getters

	public TADocumentPosition get_position_start() {
		return(TADocumentPosition.for_xy(0, 0));
	}

	public TADocumentPosition get_position_end() {
		var c = get_paragraph_count();
		if(c < 1) {
			return(get_position_start());
		}
		var ll = get_paragraph(c-1);
		if(ll == null) {
			return(TADocumentPosition.for_xy(0, c-1));
		}
		return(TADocumentPosition.for_xy(ll.get_length(), c-1));
	}

	public EditableString get_first_paragraph() {
		return(paragraphs.get(0) as EditableString);
	}

	public EditableString get_last_paragraph() {
		int c = paragraphs.count();
		if(c < 1) {
			return(null);
		}
		return(paragraphs.get(c-1) as EditableString);
	}

	public EditableString get_paragraph(int n) {
		return(paragraphs.get(n) as EditableString);
	}

	public int get_paragraph_count() {
		return(paragraphs.count());
	}

	public Array get_paragraphs() {
		return(paragraphs);
	}

	public String get_content_text() {
		if(type == TADocumentType.MARKUP) {
			// FIXME: Convert to text
		}
		return(to_string());
	}

	public String get_content_markup() {
		if(type == TADocumentType.TEXT) {
			// FIXME: Convert to markup
		}
		return(to_string());
	}

	public String to_string_range(TADocumentPosition start, TADocumentPosition end) {
		if(start == null || end == null || paragraphs == null) {
			return(null);
		}
		var sb = StringBuffer.create();
		int n, sx, ex;
		for(n = start.get_y(); n <= end.get_y(); n++) {
			var pp = paragraphs.get(n) as EditableString;
			if(pp == null) {
				continue;
			}
			if(n == start.get_y()) {
				sx = start.get_x();
				if(n == end.get_y()) {
					ex = end.get_x();
				}
				else {
					ex = pp.get_length();
				}
			}
			else if(n == end.get_y()) {
				sx = 0;
				ex = end.get_x();
			}
			else {
				sx = 0;
				ex = pp.get_length();
			}
			sb.append(pp.to_string_range(sx, ex-sx));
			if(n < end.get_y()) {
				sb.append_c((int)'\n');
			}
		}
		return(sb.to_string());
	}

	public String to_string() {
		var sb = StringBuffer.create();
		bool first = true;
		foreach(EditableString st in paragraphs) {
			if(first == false) {
				sb.append_c((int)'\n');
			}
			first = false;
			sb.append(st.to_string());
		}
		return(sb.to_string());
	}

	////////////////////////////////
	// internal implementation

	TADocumentPosition execute_operation(Object o) {
		if(o == null) {
			return(null);
		}
		if(o is ReplaceWithStringOperation) {
			return(replace_with_string(((ReplaceWithStringOperation)o).get_str(), false));
		}
		if(o is InsertStringOperation) {
			var iso = (InsertStringOperation)o;
			var r = insert_string(iso.get_pos(), iso.get_string(), false);
			if(iso.get_cursor_start()) {
				r = iso.get_pos();
			}
			return(r);
		}
		if(o is InsertCharacterOperation) {
			var ico = (InsertCharacterOperation)o;
			return(insert_character(ico.get_pos(), ico.get_character(), false));
		}
		if(o is DeleteCharacterOperation) {
			return(delete_current(((DeleteCharacterOperation)o).get_pos(), false));
		}
		if(o is DeleteRangeOperation) {
			var dr = (DeleteRangeOperation)o;
			return(delete_range(dr.get_pos_start(), dr.get_pos_end(), false, false));
		}
		return(null);
	}

	String filter_string(String str) {
		var sb = StringBuffer.create();
		foreach(Integer i in str) {
			var c = i.to_integer();
			if(TACharacter.is_printable(c) || c == '\n') {
				sb.append_c(c);
			}
		}
		return(sb.to_string());
	}

	void set_text(String ss) {
		var s = filter_string(ss);
		paragraphs = Array.create();
		if(s != null) {
			foreach(String paragraph in s.split((int)'\n')) {
				var ee = paragraph.as_editable();
				if(ee == null) {
					ee = EditableString.for_string("");
				}
				paragraphs.append(ee);
			}
		}
	}

	TADocumentPosition getpos(TADocumentPosition pos) {
		if(pos != null) {
			return(pos);
		}
		return(get_position_end());
	}

	EditableString get_current_paragraph(TADocumentPosition pos) {
		if(pos.get_y() < 0) {
			pos.set_y(0);
		}
		if(pos.get_y() >= paragraphs.count()) {
			pos.set_y(paragraphs.count() - 1);
		}
		return(get_paragraph(pos.get_y()));
	}

	EditableString get_or_create_paragraph(TADocumentPosition pos) {
		if(pos.get_y() < 0) {
			pos.set_y(0);
		}
		if(pos.get_y() > paragraphs.count()) {
			pos.set_y(paragraphs.count());
		}
		var paragraph = get_paragraph(pos.get_y());
		if(paragraph == null) {
			paragraph = EditableString.for_string("");
			paragraphs.append(paragraph);
			pos.set_x(0);
			pos.set_y(paragraphs.count()-1);
		}
		return(paragraph);
	}

	void do_insert_character(TADocumentPosition pos, int c) {
		var paragraph = get_or_create_paragraph(pos);
		if(c == '\n') {
			String nn;
			var x = pos.get_x();
			if(x >= paragraph.get_length()) {
				nn = "";
			}
			else {
				nn = paragraph.to_string_range(x, paragraph.get_length()-x);
				paragraph.remove(x, paragraph.get_length()-x);
			}
			var nl = EditableString.for_string(nn);
			paragraphs.insert(nl, pos.get_y() + 1);
			pos.set_y(pos.get_y() + 1);
			pos.set_x(0);
			return;
		}
		if(TACharacter.is_printable(c)) {
			paragraph.insert_char(c, pos.get_x());
			pos.set_x(pos.get_x()+1);
		}
	}

	////////////////////////////////
	// operation classes

	class ReplaceWithStringOperation
	{
		property String str;
	}

	class InsertStringOperation
	{
		property TADocumentPosition pos;
		property String string;
		property bool cursor_start = false;
	}

	class InsertCharacterOperation
	{
		property TADocumentPosition pos;
		property int character;
	}

	class DeleteCharacterOperation
	{
		property TADocumentPosition pos;
	}

	class DeleteRangeOperation
	{
		property TADocumentPosition pos_start;
		property TADocumentPosition pos_end;
	}

	////////////////////////////////
	// Public API

	public TADocumentPosition undo() {
		if(undo_buffer == null) {
			return(null);
		}
		return(execute_operation(undo_buffer.pop()));
	}

	void add_to_undo_buffer(Object o) {
		if(undo_buffer == null) {
			return;
		}
		undo_buffer.push(o);
		while(undo_buffer_limit > 0 && undo_buffer.count() > undo_buffer_limit) {
			if(undo_buffer.pop_under() == null) {
				break;
			}
		}
	}

	public TADocumentPosition replace_with_string(String s, bool undo = true) {
		if(undo && undo_buffer != null) {
			add_to_undo_buffer(new ReplaceWithStringOperation().set_str(to_string()));
		}
		set_text(s);
		if(listener != null) {
			listener.on_ta_document_replaced(s);
		}
		return(get_position_end());
	}

	public TADocumentPosition append_string(String s, bool undo = true) {
		return(insert_string(get_position_end(), s, undo));
	}

	public TADocumentPosition prepend_string(String s, bool undo = true) {
		return(insert_string(get_position_start(), s, undo));
	}

	public TADocumentPosition insert_string(TADocumentPosition pos, String s, bool undo = true) {
		var pp = getpos(pos);
		var mypos = pp.dup();
		StringBuffer sb;
		foreach(Integer i in s) {
			var c = i.to_integer();
			if(c == '\n') {
				String remainder;
				if(sb != null) {
					var paragraph = get_or_create_paragraph(mypos);
					int p = mypos.get_x(), l = paragraph.get_length()-mypos.get_x();
					remainder = paragraph.to_string_range(p, l);
					paragraph.remove(p, l);
					var ss = sb.to_string();
					paragraph.insert(ss, p);
					mypos.set_x(mypos.get_x()+ss.get_length());
					sb = null;
				}
				do_insert_character(mypos, (int)'\n');
				if(String.is_empty(remainder) == false) {
					var paragraph = get_or_create_paragraph(mypos);
					paragraph.insert(remainder, mypos.get_x());
				}
			}
			else if(TACharacter.is_printable(c)) {
				if(sb == null) {
					sb = StringBuffer.create();
				}
				sb.append_c(c);
			}
		}
		if(sb != null) {
			var paragraph = get_or_create_paragraph(mypos);
			var ss = sb.to_string();
			paragraph.insert(ss, mypos.get_x());
			mypos.set_x(mypos.get_x()+ss.get_length());
			sb = null;
		}
		if(undo && undo_buffer != null && mypos.is_same(pp) == false) {
			add_to_undo_buffer(new DeleteRangeOperation().set_pos_start(pp).set_pos_end(mypos));
		}
		if(listener != null) {
			listener.on_ta_document_insert(pp, mypos, s);
		}
		return(mypos);
	}

	public TADocumentPosition insert_character(TADocumentPosition pos, int c, bool undo = true) {
		var pp = getpos(pos);
		var mypos = pp.dup();
		do_insert_character(mypos, c);
		if(undo && undo_buffer != null && mypos.is_same(pp) == false) {
			add_to_undo_buffer(new DeleteCharacterOperation().set_pos(pp.dup()));
		}
		if(listener != null) {
			listener.on_ta_document_insert(pp, mypos, String.for_character(c));
		}
		return(mypos);
	}

	public TADocumentPosition delete_current(TADocumentPosition pos, bool undo = true) {
		var pp = getpos(pos);
		var mypos = pp.dup();
		var ll = get_current_paragraph(mypos);
		if(ll == null) {
			return(mypos);
		}
		int c = 0;
		bool merge = false;
		if(pos.get_x() >= ll.get_length()) {
			var nl = get_paragraph(pos.get_y()+1);
			if(nl == null) {
				return(mypos);
			}
			paragraphs.remove_index(pos.get_y()+1);
			ll.append(nl.to_string());
			merge = true;
			c = (int)'\n';
		}
		else {
			c = ll.get_char(pos.get_x());
			ll.remove_char(pos.get_x());
		}
		if(undo && undo_buffer != null && c > 0) {
			add_to_undo_buffer(new InsertCharacterOperation().set_pos(pp.dup()).set_character(c));
		}
		if(listener != null) {
			listener.on_ta_document_delete_char(pos, merge);
		}
		return(mypos);
	}

	void delete_paragraphs(int start, int end) {
		if(paragraphs != null) {
			paragraphs.remove_range(start, end);
		}
	}

	public TADocumentPosition delete_range(TADocumentPosition start, TADocumentPosition end, bool cursor_start = false, bool undo = true) {
		if(start == null || end == null) {
			return(start);
		}
		String content;
		if(undo) {
			content = to_string_range(start, end);
		}
		if(start.get_y() == end.get_y()) {
			int sx = start.get_x(), ex = end.get_x();
			int x1, x2;
			if(sx < ex) {
				x1 = sx;
				x2 = ex;
			}
			else {
				x1 = ex;
				x2 = sx;
			}
			var pp = get_paragraph(start.get_y());
			if(pp != null) {
				pp.remove(x1, x2-x1);
			}
		}
		else {
			int y1, y2, x1, x2;
			if(start.get_y() < end.get_y()) {
				y1 = start.get_y();
				x1 = start.get_x();
				y2 = end.get_y();
				x2 = end.get_x();
			}
			else {
				y1 = end.get_y();
				x1 = end.get_x();
				y2 = start.get_y();
				x2 = start.get_x();
			}
			String retain;
			if(x1 > 0) {
				var p1 = get_paragraph(y1);
				if(p1 != null) {
					retain = p1.to_string_range(0, x1);
				}
			}
			if(retain != null || x2 > 0) {
				var p2 = get_paragraph(y2);
				if(p2 != null) {
					if(x2 > 0) {
						p2.remove(0, x2);
					}
					if(retain != null) {
						p2.prepend(retain);
					}
				}
			}
			delete_paragraphs(y1, y2-1);
		}
		if(undo && undo_buffer != null) {
			add_to_undo_buffer(new InsertStringOperation().set_string(content).set_pos(start)
				.set_cursor_start(cursor_start));
		}
		if(listener != null) {
			listener.on_ta_document_delete_range(start, end);
		}
		return(start);
	}
}
