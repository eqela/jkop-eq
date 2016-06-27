
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

public class TATextEditorWidget : LayerWidget, TADocumentListener
{
	class MyParagraphContainerWidget : ContainerWidget, ClipperWidget
	{
		property int spacing = 0;

		public override bool get_always_has_surface() {
			return(true);
		}

		public bool is_surface_container() {
			return(true);
		}

		public void on_move_diff(double diffx, double diffy) {
		}

		public void on_child_added(Widget child) {
		}

		public void on_child_removed(Widget child) {
		}

		public void on_new_child_size_params(Widget w) {
		}

		public void update_children(int offsetx) {
			int y = 0;
			foreach(Widget c in iterate_children()) {
				if(y > 0) {
					y += spacing;
				}
				var hh = c.get_height();
				c.move(0 - offsetx, y);
				y += hh;
			}
		}
	}

	class MyParagraphWidget : Widget
	{
		EditableString text;
		property TATextEditorWidget editor;
		property int tab_spaces = -1;

		public EditableString get_text() {
			return(text);
		}

		void update_text() {
			if(is_initialized() == false) {
				return;
			}
			var layout = create_layout();
			if(layout != null) {
				resize(layout.get_width(), layout.get_height());
			}
			set_surface_content(layout.get_display_list());
		}

		public MyParagraphWidget set_text(EditableString es) {
			text = es;
			update_text();
			return(this);
		}

		public void initialize() {
			base.initialize();
			update_text();
		}

		String expand_tabs(String text, int n) {
			if(text.chr((int)'\t') < 0) {
				return(text);
			}
			var sb = StringBuffer.create();
			var it = text.iterate();
			int c;
			while((c = it.next_char()) > 0) {
				if(c == '\t') {
					int i;
					for(i=0; i<n; i++) {
						sb.append_c((int)' ');
					}
				}
				else {
					sb.append_c(c);
				}
			}
			return(sb.to_string());
		}

		public TAParagraphLayout create_layout() {
			String tt;
			if(text != null) {
				tt = text.to_string();
			}
			if(tt == null) {
				tt = "";
			}
			if(tab_spaces >= 0) {
				tt = expand_tabs(tt, tab_spaces);
			}
			return(editor.create_paragraph_layout(tt));
		}
	}

	public virtual TAParagraphLayout create_paragraph_layout(String tt) {
		var ll = new TASimpleParagraphLayout();
		ll.set_text(tt);
		var f = font;
		if(f == null) {
			f = Theme.font();
		}
		ll.set_font(f);
		ll.set_color(get_draw_color());
		ll.set_frame(get_frame());
		ll.set_dpi(get_dpi());
		return(ll.initialize());
	}

	class SelectionHighlightLayerWidget : Widget
	{
		property Color highlight_color;
		property TATextEditorWidget widget;
		property double charwidth;
		property double charheight;
		TADocumentPosition oldstart;
		TADocumentPosition oldend;
		TADocumentPosition startps;
		TADocumentPosition end;
		int first_paragraph;
		int offset;

		public void update(TADocumentPosition start, TADocumentPosition end, int first_paragraph, int offset, bool redraw = false) {
			oldstart = this.startps;
			oldend = this.end;
			this.startps = start;
			this.end = end;
			this.first_paragraph = first_paragraph;
			this.offset = offset;
			set_surface_content(do_render(!redraw));
		}

		Position to_px_position(TADocumentPosition pos) {
			if(pos == null) {
				return(null);
			}
			int y = (int)((pos.get_y() - first_paragraph) * charheight);
			int x = (int)((widget.col_to_display_col(pos.get_x(), pos.get_y()) - offset) * charwidth);
			return(Position.instance(x,y));
		}

		public Collection render() {
			return(do_render(true));
		}

		public Collection do_render(bool allowclip) {
			var v = LinkedList.create();
			var startpos = to_px_position(startps), endpos = to_px_position(end);
			if(startpos == null || endpos == null) {
				return(v);
			}
			int sx = startpos.get_x(), sy = startpos.get_y(),
				ex = endpos.get_x(), ey = endpos.get_y() + charheight,
				w = get_width(), h = get_height();
			if(sy < 0 && ey < 0) {
				return(v);
			}
			if(sy >= h && ey >= h) {
				return(v);
			}
			if(sx < 0 && ex < 0) {
				return(v);
			}
			if(sx >= w && ex >= w) {
				return(v);
			}
			var cc = highlight_color;
			if(sy <= 0 && ey >= h) {
				v.append(new FillColorOperation().set_shape(RectangleShape.create(0, 0, w, h)).set_color(cc));
				return(v);
			}
			var clipsy = sy, clipey = ey;
			if(oldstart != null && oldend != null) {
				var osp = to_px_position(oldstart), oep = to_px_position(oldend);
				if(osp.get_y() < sy) {
					clipsy = osp.get_y();
				}
				var oepy = oep.get_y() + charheight;
				if(oepy > ey) {
					clipey = oepy;
				}
			}
			if(allowclip) {
				v.append(new ClipOperation().set_shape(RectangleShape.create(0,clipsy,w,clipey-clipsy)));
			}
			var sgy = startps.get_y();
			var egy = end.get_y();
			if(sgy == egy) {
				v.append(new FillColorOperation().set_shape(RectangleShape.create(sx, sy, ex-sx, ey-sy)).set_color(cc));
				return(v);
			}
			v.append(new FillColorOperation().set_shape(RectangleShape.create(sx, sy, w-sx, charheight)).set_color(cc));
			var midh = (int)(ey-sy-charheight-charheight);
			if(midh > 0) {
				v.append(new FillColorOperation().set_shape(RectangleShape.create(0, sy+charheight, w, midh)).set_color(cc));
			}
			v.append(new FillColorOperation().set_shape(RectangleShape.create(0, ey-charheight, ex, charheight)).set_color(cc));
			return(v);
		}
	}

	public static TATextEditorWidget instance() {
		return(new TATextEditorWidget());
	}

	public static TATextEditorWidget for_document(TADocument td) {
		return(new TATextEditorWidget().set_document(td));
	}

	TADocument document;
	Font font;
	int firstparagraph = 0;
	int lastparagraph = 0;
	MyParagraphContainerWidget paragraphs;
	ScrollBarWidget scrollbar;
	property int tab_spaces = -1;
	property int current_offset = 0;
	property bool ignore_trailing_empty_line = false;
	property int visible_lines = -1;
	property TATextEditorWidgetListener listener;
	Clipboard clipboard;
	double charwidth;
	double charheight;
	CanvasWidget cursor;
	CanvasWidget highlight_cursor;
	int current_row;
	int current_col;
	int wants_col;
	bool dirty = false;
	property bool enable_undo_shortcut = true;
	SelectionHighlightLayerWidget selection_layer;
	TADocumentPosition selection_start;
	TADocumentPosition selection_end;
	property Color highlight_color;
	property Color cursor_color;
	int last_height = -1;

	public TATextEditorWidget() {
		document = new TADocument();
		set_font(Theme.font().modify("monospace 2500um"));
		current_row = 0;
		current_col = 0;
		wants_col = 0;
		set_tab_spaces(4);
		highlight_color = Theme.color("eq.widget.textarea.TATextEditorWidget.highlight_color", "#60989d");
		cursor_color = Theme.color("eq.widget.textarea.TATextEditorWidget.cursor_color", "#FFA000");
		clipboard = Clipboard.default();
	}

	public bool is_focusable() {
		return(true);
	}

	public String get_text() {
		if(document == null) {
			return(null);
		}
		return(document.to_string());
	}

	class MyFileReadOperationListener : StringOperationListener
	{
		property TATextEditorWidget widget;
		property BooleanOperationListener listener;
		public void on_string(String str, Error error) {
			if(Error.is_error(error)) {
				if(listener != null) {
					listener.on_boolean(false, error);
				}
				ModalDialog.error(String.as_string(error), null, null, widget.get_frame());
				return;
			}
			widget.on_file_read_content(str);
			if(listener != null) {
				listener.on_boolean(true, null);
			}
		}
	}

	public double get_character_width() {
		return(charwidth);
	}

	public double get_character_height() {
		return(charheight);
	}

	public int get_current_col() {
		return(current_col);
	}

	public int get_current_row() {
		return(current_row);
	}

	public virtual void read_async_file(AsyncFile file, BooleanOperationListener listener = null) {
		if(file == null) {
			if(listener != null) {
				listener.on_boolean(false, Error.instance("null_file", "File object is null"));
			}
			return;
		}
		file.get_contents_string(new MyFileReadOperationListener().set_widget(this).set_listener(listener));
	}

	public void on_file_read_content(String text) {
		set_text(text);
		get_document().clear_undo_buffer();
		set_dirty(false);
	}

	public virtual bool read_file(File file) {
		if(file == null) {
			return(false);
		}
		var text = file.get_contents_string();
		if(text == null) {
			return(false);
		}
		on_file_read_content(text);
		return(true);
	}

	class MyFileWriteOperationListener : BooleanOperationListener
	{
		property TATextEditorWidget widget;
		property BooleanOperationListener listener;
		public void on_boolean(bool v, Error error) {
			if(Error.is_error(error)) {
				if(listener != null) {
					listener.on_boolean(false, error);
				}
				ModalDialog.error(String.as_string(error), null, null, widget.get_frame());
				return;
			}
			if(listener != null) {
				listener.on_boolean(true, null);
			}
			widget.on_file_write_complete();
		}
	}

	public virtual void write_to_async_file(AsyncFile file, BooleanOperationListener listener = null) {
		if(file == null) {
			if(listener != null) {
				listener.on_boolean(false, Error.instance("null_file", "File object is null"));
			}
			return;
		}
		file.set_contents_string(get_document().to_string(), new MyFileWriteOperationListener().set_widget(this).set_listener(listener));
	}

	public virtual bool write_to_file(File file) {
		if(file == null) {
			return(false);
		}
		if(file.set_contents_string(get_document().to_string()) == false) {
			return(false);
		}
		on_file_write_complete();
		return(true);
	}

	public void on_file_write_complete() {
		set_dirty(false);
	}

	public bool is_dirty() {
		return(dirty);
	}

	void update_dirty_status() {
		if(get_document().get_undo_buffer_entry_count() > 0) {
			set_dirty(true);
		}
		else {
			set_dirty(false);
		}
	}

	public Font get_font() {
		if(font == null) {
			font = Theme.font().modify("monospace 2250um");
		}
		return(font);
	}

	public virtual void on_font_changed() {
		update_character_size();
		if(is_initialized()) {
			scroll_to_first(firstparagraph);
		}
	}

	public TATextEditorWidget set_font(Font font) {
		this.font = font;
		on_font_changed();
		return(this);
	}

	public TATextEditorWidget set_text(String str) {
		set_document(TADocument.for_text(str));
		return(this);
	}

	public TATextEditorWidget set_document(TADocument d) {
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

	public void on_ta_document_replaced(String str) {
		scroll_to_first(0);
		update_dirty_status();
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
		var pp = paragraphs.get_child(cpar - firstparagraph) as MyParagraphWidget;
		if(pp != null) {
			var ntext = document.get_paragraph(cpar);
			pp.set_text(ntext);
			return(true);
		}
		return(false);
	}

	public void on_ta_document_insert(TADocumentPosition start, TADocumentPosition end, String str) {
		update_dirty_status();
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
		int f = start.get_y(), l = end.get_y();
		var sp = document.get_paragraph(f);
		update_paragraph(f);
		f++;
		while(f <= l) {
			var pp = document.get_paragraph(f);
			paragraphs.insert(create_paragraph_widget(pp), f-firstparagraph);
			f++;
			lastparagraph++;
		}
		remove_paragraphs_from_end();
		paragraphs.update_children((int)(current_offset * charwidth));
	}

	public void on_ta_document_delete_char(TADocumentPosition pos, bool merge) {
		update_dirty_status();
		if(pos.get_y() > lastparagraph) {
			return;
		}
		if(pos.get_y() < firstparagraph && merge) {
			paragraphs.remove_index(firstparagraph);
			paragraphs.add(create_paragraph_widget(document.get_paragraph(lastparagraph)));
			paragraphs.update_children((int)(current_offset * charwidth));
			return;
		}
		update_paragraph(pos.get_y());
		if(merge) {
			paragraphs.remove_index(pos.get_y() - firstparagraph + 1);
			paragraphs.add(create_paragraph_widget(document.get_paragraph(lastparagraph)));
			paragraphs.update_children((int)(current_offset * charwidth));
		}
	}

	public void on_ta_document_delete_range(TADocumentPosition start, TADocumentPosition end) {
		update_dirty_status();
		if(start == null || end == null) {
			return;
		}
		if(start.get_y() == end.get_y()) {
			update_paragraph(start.get_y());
			return;
		}
		var y1 = start.get_y();
		if(start.get_x() > 0) {
			y1++;
		}
		var y2 = end.get_y() - 1;
		if(y2 < y1) {
			y2 = y1;
		}
		if(y1 < firstparagraph && y2 < firstparagraph) {
			// FIXME: This could be optimized by not using scroll_to_first() if
			// not all lines need to be changed.
			scroll_to_first(firstparagraph - (y2 - y1));
		}
		else if(y1 > lastparagraph && y2 > lastparagraph) {
		}
		else if(y1 < firstparagraph && y2 >= firstparagraph) {
			var diff = firstparagraph - y1;
			firstparagraph -= diff;
			lastparagraph -= diff;
			scroll_to_first(firstparagraph);
		}
		else {
			scroll_to_first(firstparagraph);
		}
	}

	public TATextEditorWidget set_dirty(bool v) {
		if(dirty != v) {
			dirty = v;
			on_dirty_status_changed(dirty);
		}
		return(this);
	}

	public virtual void on_dirty_status_changed(bool newstatus) {
		if(listener != null) {
			listener.on_text_editor_dirty_status_changed();
		}
	}

	public TADocumentPosition get_ta_position() {
		return(TADocumentPosition.for_xy(current_col, current_row));
	}

	public bool move_to_ta_position(TADocumentPosition pos) {
		if(pos == null) {
			return(false);
		}
		if(current_col == pos.get_x() && current_row == pos.get_y()) {
			return(false);
		}
		current_col = pos.get_x();
		current_row = pos.get_y();
		on_cursor_moved();
		return(true);
	}

	public void on_gain_focus() {
		base.on_gain_focus();
		if(cursor != null) {
			cursor.set_color(cursor_color);
			cursor.set_outline_color(null);
		}
	}

	public void on_lose_focus() {
		base.on_lose_focus();
		if(cursor != null) {
			cursor.set_color(null);
			cursor.set_outline_color(cursor_color);
		}
	}

	public int get_width_characters() {
		if(charwidth == 0) {
			return(0);
		}
		return(get_width() / charwidth);
	}

	public int get_height_characters() {
		if(charheight == 0) {
			return(0);
		}
		return(get_height() / charheight);
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
		if(current_offset == newoffset) {
			return;
		}
		current_offset = newoffset;
		if(current_offset < 0) {
			current_offset = 0;
		}
		if(paragraphs != null) {
			paragraphs.update_children((int)(current_offset * charwidth));
		}
		update_selection_layer(false);
		update_cursor();
		clear_highlight_character();
	}

	MyParagraphWidget create_paragraph_widget(EditableString text) {
		return(new MyParagraphWidget().set_editor(this).set_text(text).set_tab_spaces(tab_spaces));
	}

	public int compute_paragraphs_height() {
		if(paragraphs == null) {
			return(0);
		}
		var c = paragraphs.count();
		if(c < 1) {
			return(0);
		}
		var pp = paragraphs.get_child(0);
		if(pp == null) {
			return(0);
		}
		int sp = 0;
		if(document != null) {
			sp = px(document.get_paragraph_spacing());
		}
		if(c < 2) {
			return((int)(c * charheight));
		}
		return((int)(c * charheight + (c-1) * sp));
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
			int hr = 0;
			int ps = 0;
			if(document != null) {
				ps = px(document.get_paragraph_spacing());
			}
			for(n=firstparagraph; true; n++) {
				var pw = create_paragraph_widget(document.get_paragraph(n));
				paragraphs.add(pw);
				lastparagraph = n;
				if(hr > 0) {
					hr += ps;
				}
				hr += charheight;
				if(hr >= get_height()) {
					break;
				}
			}
		}
		paragraphs.update_children((int)(current_offset * charwidth));
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
		if(last > max+1) {
			last = max+1;
		}
		paragraphs.remove_children();
		if(document != null) {
			int n;
			lastparagraph = last;
			for(n=last; n >= 0; n--) {
				paragraphs.prepend(create_paragraph_widget(document.get_paragraph(n)));
				firstparagraph = n;
				if(compute_paragraphs_height() >= get_height()) {
					break;
				}
			}
			while(compute_paragraphs_height() < get_height()) {
				paragraphs.add(create_paragraph_widget(null));
				lastparagraph++;
			}
		}
		paragraphs.update_children((int)(current_offset * charwidth));
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
		if(dx > 0) {
			change_current_offset(current_offset-1);
		}
		else if(dx < 0) {
			change_current_offset(current_offset+1);
		}
		scroll(-dy);
		return(true);
	}

	void remove_paragraphs_from_end() {
		while(true) {
			if(compute_paragraphs_height() - charheight > get_height()) {
				paragraphs.remove_last_child();
				lastparagraph --;
			}
			else {
				break;
			}
		}
	}

	public bool scroll(int dy) {
		if(dy > 0) {
			if(is_at_bottom()) {
				return(false);
			}
			firstparagraph ++;
			paragraphs.remove_first_child();
			while(compute_paragraphs_height() < get_height()) {
				lastparagraph ++;
				paragraphs.add(create_paragraph_widget(document.get_paragraph(lastparagraph)));
			}
			paragraphs.update_children((int)(current_offset * charwidth));
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
			remove_paragraphs_from_end();
			paragraphs.update_children((int)(current_offset * charwidth));
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

	int find_on_row(int rr, int cc, String str) {
		if(String.is_empty(str)) {
			return(cc);
		}
		var row = document.get_paragraph(rr);
		if(row == null) {
			return(-1);
		}
		String tt;
		if(cc < 1) {
			tt = row.to_string();
		}
		else {
			tt = row.to_string_range(cc, row.get_length()-cc);
		}
		if(tt != null) {
			var x = tt.lowercase();
			if(x != null) {
				tt = x;
			}
		}
		var v = tt.str(str);
		if(v >= 0) {
			return(cc + v);
		}
		return(v);
	}

	public bool find(String astr, bool force_move) {
		bool wrapped = false;
		var str = astr;
		if(str == null) {
			str = "";
		}
		str = str.lowercase();
		var rr = current_row;
		var start_row = rr;
		var cc = current_col;
		var pars = document.get_paragraph_count();
		if(selection_start != null && selection_end != null) {
			var sx = selection_start.get_x(),
				sy = selection_start.get_y(),
				ex = selection_end.get_x(),
				ey = selection_end.get_y();
			if(force_move) {
				if(sy > ey) {
					rr = sy;
					cc = sx;
				}
				else if(sy < ey) {
					rr = ey;
					cc = ex;
				}
				else if(sx > ex) {
					rr = sy;
					cc = sx;
				}
				else if(sx < ex) {
					rr = ey;
					cc = ex;
				}
				else {
				}
			}
			else {
				if(sy < ey) {
					rr = sy;
					cc = sx;
				}
				else if(sy > ey) {
					rr = ey;
					cc = ex;
				}
				else if(sx < ex) {
					rr = sy;
					cc = sx;
				}
				else if(sx > ex) {
					rr = ey;
					cc = ex;
				}
				else {
				}
			}
		}
		while(true) {
			var v = find_on_row(rr, cc, str);
			if(v >= 0) {
				selection_start = TADocumentPosition.for_xy(v, rr);
				selection_end = TADocumentPosition.for_xy(v + str.get_length(), rr);
				on_selection_changed();
				current_row = rr;
				current_col = v + str.get_length();
				on_cursor_moved();
				return(true);
			}
			rr ++;
			cc = 0;
			if(rr > start_row && wrapped) {
				break;
			}
			if(rr >= pars) {
				rr = 0;
				wrapped = true;
			}
		}
		return(false);
	}

	void update_character_size() {
		var str = "XxcAFARSDFZXdfsfdlasdf34294qewdsfsSQ@lkfalskdfj32qr3rlskjzfdlkxzjcvljszFDSAFKDSJZLFKAJSDLFKJASLDKFJASLDZLXCVZXCxZXASFDASLKF#JQLK%AJZSKFJLKFJQLKJAWELKFJAWLK#$%!4qsxdfsadfasdlfkjasdfsjdf";
		var str2 = "Xf";
		var tl = GUI.engine.layout_text(TextProperties.for_string(str).set_font(get_font()), get_frame(), get_dpi());
		var tl2 = GUI.engine.layout_text(TextProperties.for_string(str2).set_font(get_font()), get_frame(), get_dpi());
		if(tl != null) {
			charwidth = (tl.get_width()-tl2.get_width()) / (str.get_length()-2);
			charheight = tl.get_height();
		}
		if(charwidth < 1) {
			charwidth = 1;
		}
		if(charheight < 1) {
			charheight = 1;
		}
		if(selection_layer != null) {
			selection_layer.set_charwidth(charwidth);
			selection_layer.set_charheight(charheight);
		}
	}

	class CursorContainerWidget : ContainerWidget
	{
		public void on_resize() {
			base.on_resize();
			if(get_width() < 1 || get_height() < 1) {
				foreach(Widget c in iterate_children()) {
					c.resize(0,0);
				}
			}
		}
	}

	class CursorChangerLayerWidget : Widget
	{
		public CursorChangerLayerWidget() {
			set_cursor(Cursor.for_stock_cursor(Cursor.STOCK_EDITTEXT));
		}
	}

	public void initialize() {
		base.initialize();
		add(selection_layer = new SelectionHighlightLayerWidget().set_widget(this));
		selection_layer.set_highlight_color(highlight_color);
		add(new CursorContainerWidget()
			.add(cursor = CanvasWidget.for_color(null).set_outline_color(cursor_color))
			.add(highlight_cursor = CanvasWidget.for_color(cursor_color).set_outline_color(Color.instance("red")))
		);
		if(document != null) {
			document.set_listener(this);
		}
		add(paragraphs = new MyParagraphContainerWidget());
		paragraphs.set_spacing(px(document.get_paragraph_spacing()));
		add(AlignWidget.instance().add_align(1, 0, scrollbar = new ScrollBarWidget()));
		add(new CursorChangerLayerWidget());
		update_character_size();
		update_cursor();
	}

	public void cleanup() {
		base.cleanup();
		if(document != null) {
			document.set_listener(null);
		}
		paragraphs = null;
		scrollbar = null;
		if(selection_layer != null) {
			selection_layer.set_widget(null);
		}
		selection_layer = null;
		cursor = null;
		highlight_cursor = null;
	}

	public void on_resize() {
		base.on_resize();
		var height = get_height();
		var width = get_width();
		if(height > 0 && width > 0) {
			if(visible_lines > 0) {
				int sz = (get_height() - (visible_lines-1)*px(document.get_paragraph_spacing())) / visible_lines;
				int target = sz;
				while(true) {
					var ff = get_font();
					if(ff == null) {
						ff = Theme.font().modify("monospace");
					}
					var szpx = "%dpx".printf().add(sz).to_string();
					ff.set_size(szpx);
					this.font = ff;
					update_character_size();
					if(charheight > target) {
						int nsz = (int)Math.floor((double)sz * (double)target / (double)charheight);
						if(nsz < 1) {
							break;
						}
						if(nsz == sz) {
							nsz--;
						}
						sz = nsz;
					}
					else {
						break;
					}
				}
				scroll_to_first(firstparagraph);
			}
			else if(lastparagraph <= firstparagraph) {
				scroll_to_first(firstparagraph);
			}
			else if(height > last_height) {
				while(compute_paragraphs_height() < get_height()) {
					lastparagraph ++;
					paragraphs.add(create_paragraph_widget(document.get_paragraph(lastparagraph)));
				}
				paragraphs.update_children((int)(current_offset * charwidth));
			}
			else if(height < last_height) {
				while(compute_paragraphs_height() >= get_height() + paragraphs.get_spacing() + charheight) {
					lastparagraph --;
					paragraphs.remove_last_child();
				}
				paragraphs.update_children((int)(current_offset * charwidth));
			}
		}
		else {
			paragraphs.remove_children();
			lastparagraph = 0;
		}
		last_height = height;
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
		update_cursor();
		update_selection_layer(true);
		clear_highlight_character();
	}

	void on_selection_changed() {
		update_selection_layer(false);
	}

	void update_selection_layer(bool fullredraw) {
		if(selection_layer == null) {
			return;
		}
		TADocumentPosition ss, ee;
		if(selection_start != null && selection_end != null) {
			if(selection_start.get_y() < selection_end.get_y() || (selection_start.get_y() == selection_end.get_y() && selection_start.get_x() < selection_end.get_x())) {
				ss = selection_start;
				ee = selection_end;
			}
			else {
				ss = selection_end;
				ee = selection_start;
			}
		}
		selection_layer.update(ss, ee, get_first_paragraph(), get_current_offset(), fullredraw);
	}

	void init_selection(KeyEvent e) {
		if(e == null || e.get_shift() == false) {
			if(selection_start != null || selection_end != null) {
				selection_start = null;
				selection_end = null;
				on_selection_changed();
			}
			return;
		}
		if(selection_start != null) {
			return;
		}
		selection_start = TADocumentPosition.for_xy(current_col, current_row);
		selection_end = selection_start;
		on_selection_changed();
	}

	void update_selection(KeyEvent e) {
		if(e == null || e.get_shift() == false) {
			if(selection_start != null || selection_end != null) {
				selection_start = null;
				selection_end = null;
				on_selection_changed();
			}
			return;
		}
		selection_end = TADocumentPosition.for_xy(current_col, current_row);
		if(selection_start == null) {
			selection_start = selection_end;
		}
		on_selection_changed();
	}

	public void clipboard_copy() {
		if(clipboard != null) {
			var sel = get_selection_contents();
			if(String.is_empty(sel) == false) {
				clipboard.set_data(ClipboardData.for_string(sel));
			}
		}
	}

	public void clipboard_cut() {
		clipboard_copy();
		delete_selection_contents();
	}

	class ClipboardDataReceiver : EventReceiver
	{
		property TATextEditorWidget widget;
		public void on_event(Object o) {
			if(o != null && o is ClipboardData && widget != null) {
				widget.do_clipboard_paste(((ClipboardData)o).to_string());
			}
		}
	}

	public void do_clipboard_paste(String clipboard_content) {
		delete_selection_contents();
		move_to_ta_position(get_document().insert_string(get_ta_position(), clipboard_content));
	}

	public void clipboard_paste() {
		if(clipboard != null) {
			clipboard.get_data(new ClipboardDataReceiver().set_widget(this));
		}
	}

	String get_selection_contents() {
		TADocumentPosition ss, ee;
		if(selection_start != null && selection_end != null) {
			if(selection_start.get_y() < selection_end.get_y() || (selection_start.get_y() == selection_end.get_y() && selection_start.get_x() < selection_end.get_x())) {
				ss = selection_start;
				ee = selection_end;
			}
			else {
				ss = selection_end;
				ee = selection_start;
			}
		}
		return(get_document().to_string_range(ss, ee));
	}

	bool delete_selection_contents() {
		TADocumentPosition ss, ee;
		if(selection_start != null && selection_end != null) {
			var cursor_start = true;
			if(selection_start.get_y() < selection_end.get_y() || (selection_start.get_y() == selection_end.get_y() && selection_start.get_x() < selection_end.get_x())) {
				ss = selection_start;
				ee = selection_end;
				cursor_start = false;
			}
			else {
				ss = selection_end;
				ee = selection_start;
			}
			clear_selection();
			move_to_ta_position(get_document().delete_range(ss, ee, cursor_start));
			return(true);
		}
		return(false);
	}

	public void clear_selection() {
		if(selection_start == null) {
			return;
		}
		selection_start = null;
		selection_end = null;
		on_selection_changed();
	}

	void move_cursor_abs(int x, int y) {
		var pp = cursor.get_parent() as Widget;
		var px = pp.get_x();
		var py = pp.get_y();
		cursor.move_resize(px + x * charwidth, py + y * charheight, charwidth, charheight);
	}

	void hide_cursor() {
		cursor.resize(0, 0);
	}

	int display_col_to_document_col(int col, int row) {
		var pp = get_document().get_paragraph(row);
		if(pp == null) {
			return(col);
		}
		int v = 0;
		int dn = 0;
		var it = pp.iterate();
		var ts = get_tab_spaces();
		while(true) {
			if(dn >= col) {
				break;
			}
			var c = it.next_char();
			if(c < 1) {
				//break;
				dn ++;
			}
			else if(c == '\t') {
				if(dn + ts > col) {
					break;
				}
				dn += ts;
			}
			else {
				dn ++;
			}
			v ++;
		}
		return(v);
	}

	int current_col_to_display_col() {
		return(col_to_display_col(current_col, current_row));
	}

	public int col_to_display_col(int cn, int rn) {
		var pp = get_document().get_paragraph(rn);
		if(pp == null) {
			return(cn);
		}
		int v = 0;
		int n = 0;
		var it = pp.iterate();
		while(n < cn) {
			int c = it.next_char();
			if(c < 1) {
				v++;
			}
			else if(c == '\t') {
				v += get_tab_spaces();
			}
			else {
				v ++;
			}
			n++;
		}
		return(v);
	}

	void update_cursor() {
		if(cursor == null) {
			return;
		}
		int y = current_row - get_first_paragraph();
		int x = current_col_to_display_col() - get_current_offset();
		if(y < 0 || y >= get_last_paragraph() - get_first_paragraph() || x < 0 || x > get_width_characters()) {
			hide_cursor();
		}
		else {
			move_cursor_abs(x, y);
		}
	}

	void scroll_to_cursor() {
		int dc = current_col_to_display_col();
		if(dc < get_current_offset()) {
			int n = get_current_offset();
			while(dc < n) {
				n -= 16;
				if(n < 0) {
					n = 0;
					break;
				}
			}
			change_current_offset(n);
		}
		if(dc >= get_current_offset() + get_width_characters()) {
			int n = get_current_offset();
			while(dc >= n + get_width_characters()) {
				n += 16;
			}
			change_current_offset(n);
		}
		if(current_row < get_first_paragraph()) {
			if(get_first_paragraph() - current_row >= get_height_characters()) {
				scroll_to_first(current_row);
			}
			else {
				scroll_until_first(current_row);
			}
		}
		else if(current_row >= get_last_paragraph()) {
			if(current_row - get_last_paragraph() >= get_height_characters()) {
				scroll_to_last(current_row+1);
			}
			else {
				scroll_until_last(current_row+1);
			}
		}
	}

	public virtual void on_cursor_moved() {
		clear_highlight_character();
		scroll_to_cursor();
		update_cursor();
	}

	void move_to_end_of_line() {
		var pp = get_document().get_paragraph(current_row);
		if(pp == null) {
			current_col = 0;
		}
		else {
			current_col = pp.get_length();
		}
		wants_col = current_col;
		on_cursor_moved();
	}

	void move_to_beginning_of_line() {
		current_col = 0;
		wants_col = 0;
		on_cursor_moved();
	}

	int adjust_col_for_row(int col, int row) {
		var cc = col;
		if(cc < 0) {
			cc = 0;
		}
		int maxcol = 0;
		var pp = get_document().get_paragraph(row);
		if(pp != null) {
			maxcol = pp.get_length();
		}
		if(cc > maxcol) {
			cc = maxcol;
		}
		return(cc);
	}

	void adjust_current_col() {
		current_col = adjust_col_for_row(current_col, current_row);
	}

	void move_up() {
		if(current_row > 0) {
			var wcol = col_to_display_col(wants_col, current_row);
			current_row --;
			current_col = display_col_to_document_col(wcol, current_row);
			wants_col = current_col;
			adjust_current_col();
			on_cursor_moved();
		}
		else if(current_row == 0 && current_col > 0) {
			current_col = 0;
			wants_col = 0;
			on_cursor_moved();
		}
	}

	void move_down() {
		var pars = get_document().get_paragraph_count();
		if(current_row+1 < pars) {
			var wcol = col_to_display_col(wants_col, current_row);
			current_row ++;
			current_col = display_col_to_document_col(wcol, current_row);
			wants_col = current_col;
			adjust_current_col();
			on_cursor_moved();
		}
		else if(current_row == pars-1) {
			var pp = get_document().get_paragraph(current_row);
			if(pp != null && current_col < pp.get_length()) {
				current_col = pp.get_length();
				wants_col = current_col;
				on_cursor_moved();
			}
		}
	}

	void move_left() {
		if(current_col < 1) {
			if(current_row < 1) {
				return;
			}
			current_row --;
			move_to_end_of_line();
			return;
		}
		current_col --;
		wants_col = current_col;
		on_cursor_moved();
	}

	void move_word_left() {
		if(current_col < 1) {
			move_left();
			return;
		}
		var pp = get_document().get_paragraph(current_row);
		if(pp == null) {
			return;
		}
		int n = 0;
		var it = pp.iterate();
		int c;
		int v = 0;
		bool f = false;
		while((c = it.next_char()) > 0) {
			if(n >= current_col) {
				break;
			}
			var alnum = false;
			if((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_') {
				alnum = true;
			}
			if(f != alnum) {
				v = n;
				f = alnum;
			}
			n++;
		}
		current_col = v;
		wants_col = v;
		on_cursor_moved();
	}

	void move_word_right() {
		var pp = get_document().get_paragraph(current_row);
		if(pp == null) {
			return;
		}
		if(current_col >= pp.get_length()) {
			move_right();
			return;
		}
		int n = 0;
		var it = pp.iterate();
		int c;
		bool f = false;
		while((c = it.next_char()) > 0) {
			if(n < current_col) {
				n++;
				continue;
			}
			var alnum = false;
			if((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_') {
				alnum = true;
			}
			if(n == current_col) {
				f = alnum;
			}
			else {
				if(alnum != f) {
					break;
				}
			}
			n++;
		}
		current_col = n;
		wants_col = n;
		on_cursor_moved();
	}

	void move_right() {
		int maxcol = 0;
		var pp = get_document().get_paragraph(current_row);
		if(pp != null) {
			maxcol = pp.get_length();
		}
		if(current_col+1 > maxcol) {
			if(current_row+1 >= get_document().get_paragraph_count()) {
				return;
			}
			current_row++;
			move_to_beginning_of_line();
			return;
		}
		current_col ++;
		wants_col = current_col;
		on_cursor_moved();
	}

	void move_block_up() {
		if(current_row < 1) {
			move_up();
			return;
		}
		var doc = get_document();
		while(true) {
			if(current_row < 1) {
				break;
			}
			current_row--;
			var pp = doc.get_paragraph(current_row);
			if(pp == null || pp.get_length() < 1) {
				break;
			}
		}
		current_col = 0;
		wants_col = 0;
		on_cursor_moved();
	}

	void move_block_down() {
		var doc = get_document();
		var pars = doc.get_paragraph_count();
		if(current_row >= pars-1) {
			move_down();
			return;
		}
		while(true) {
			if(current_row >= pars-1) {
				break;
			}
			current_row++;
			var pp = doc.get_paragraph(current_row);
			if(pp == null || pp.get_length() < 1) {
				break;
			}
		}
		current_col = 0;
		var pp = doc.get_paragraph(current_row);
		if(pp != null) {
			var ll = pp.get_length();
			if(ll > 0) {
				current_col = ll;
			}
		}
		wants_col = current_col;
		on_cursor_moved();
	}

	void move_page_up() {
		if(current_row < 1 || charheight < 1) {
			return;
		}
		var wcol = col_to_display_col(wants_col, current_row);
		current_row -= get_height() / charheight;
		if(current_row < 0) {
			current_row = 0;
		}
		current_col = display_col_to_document_col(wcol, current_row);
		wants_col = current_col;
		adjust_current_col();
		if(current_row < get_first_paragraph()) {
			scroll_to_first(current_row);
		}
		on_cursor_moved();
	}

	void move_page_down() {
		int pars = get_document().get_paragraph_count();
		if(current_row >= pars-1 || charheight < 1) {
			return;
		}
		var wcol = col_to_display_col(wants_col, current_row);
		current_row += get_height() / charheight;
		if(current_row >= pars) {
			current_row = pars-1;
		}
		current_col = display_col_to_document_col(wcol, current_row);
		wants_col = current_col;
		adjust_current_col();
		if(current_row >= get_last_paragraph()) {
			scroll_to_last(current_row);
		}
		on_cursor_moved();
	}

	public bool on_key_press(KeyEvent e) {
		if(do_on_key_press(e)) {
			grab_focus();
			return(true);
		}
		return(base.on_key_press(e));
	}

	public int get_character_at(int row, int col) {
		if(row < 0 || col < 0) {
			return(-1);
		}
		if(document == null) {
			return(-1);
		}
		var pp = document.get_paragraph(row);
		if(pp == null) {
			return(-1);
		}
		return(pp.get_char(col));
	}

	public bool undo() {
		var doc = get_document();
		if(doc == null) {
			return(true);
		}
		clear_selection();
		var np = doc.undo();
		if(np == null) {
			return(false);
		}
		move_to_ta_position(np);
		return(true);
	}

	public void kill_to_end_of_line() {
		clear_selection();
		var document = get_document();
		if(document == null) {
			return;
		}
		var pp = document.get_paragraph(current_row);
		if(pp == null) {
			return;
		}
		if(current_col >= pp.get_length()) {
			document.delete_current(get_ta_position());
		}
		else {
			document.delete_range(
				TADocumentPosition.for_xy(current_col, current_row),
				TADocumentPosition.for_xy(pp.get_length(), current_row),
				true);
		}
	}

	public void kill_to_beginning_of_line() {
		clear_selection();
		if(current_col < 1) {
			return;
		}
		var document = get_document();
		if(document == null) {
			return;
		}
		var pp = document.get_paragraph(current_row);
		if(pp == null) {
			return;
		}
		var cc = current_col;
		if(cc >= pp.get_length()) {
			cc = pp.get_length();
		}
		move_to_ta_position(document.delete_range(
			TADocumentPosition.for_xy(0, current_row),
			TADocumentPosition.for_xy(cc, current_row),
			false));
	}

	public virtual bool do_on_key_press(KeyEvent e) {
		var str = filter_string(e.get_str());
		var name = e.get_name();
		if(e.is_shortcut("c")) {
			clipboard_copy();
			return(true);
		}
		if(e.is_shortcut("x")) {
			clipboard_cut();
			return(true);
		}
		if(e.is_shortcut("v")) {
			clipboard_paste();
			return(true);
		}
		if(e.is_shortcut("k")) {
			kill_to_end_of_line();
			return(true);
		}
		if(e.is_shortcut("u")) {
			kill_to_beginning_of_line();
			return(true);
		}
		if(enable_undo_shortcut) {
			if(e.is_shortcut("z")) {
				undo();
				return(true);
			}
		}
		if("home".equals(name) || e.is_shortcut("a")) {
			init_selection(e);
			move_to_beginning_of_line();
			update_selection(e);
			return(true);
		}
		if("end".equals(name) || e.is_shortcut("e")) {
			init_selection(e);
			move_to_end_of_line();
			update_selection(e);
			return(true);
		}
		if("delete".equals(name) || e.is_shortcut("d")) {
			delete_selection_contents();
			clear_selection();
			get_document().delete_current(get_ta_position());
			return(true);
		}
		if("backspace".equals(name)) {
			if(delete_selection_contents() == false) {
				clear_selection();
				var cr = current_row, cc = current_col;
				move_left();
				if(cr != current_row || cc != current_col) {
					get_document().delete_current(get_ta_position());
					on_cursor_moved();
				}
			}
			return(true);
		}
		if("pageup".equals(name)) {
			init_selection(e);
			move_page_up();
			update_selection(e);
			return(true);
		}
		if("pagedown".equals(name)) {
			init_selection(e);
			move_page_down();
			update_selection(e);
			return(true);
		}
		if("up".equals(name)) {
			init_selection(e);
			if(e.get_alt()) {
				move_block_up();
			}
			else {
				move_up();
			}
			update_selection(e);
			return(true);
		}
		if("down".equals(name)) {
			init_selection(e);
			if(e.get_alt()) {
				move_block_down();
			}
			else {
				move_down();
			}
			update_selection(e);
			return(true);
		}
		if("left".equals(name)) {
			init_selection(e);
			if(e.get_alt()) {
				move_word_left();
			}
			else {
				move_left();
			}
			update_selection(e);
			return(true);
		}
		if("right".equals(name)) {
			init_selection(e);
			if(e.get_alt()) {
				move_word_right();
			}
			else {
				move_right();
			}
			update_selection(e);
			return(true);
		}
		if("enter".equals(name) || "return".equals(name)) {
			delete_selection_contents();
			clear_selection();
			on_enter_pressed(e);
			return(true);
		}
		if("tab".equals(name)) {
			if(has_focus() && e.get_shift() == false && e.get_alt() == false && e.get_ctrl() == false && e.get_command() == false) {
				delete_selection_contents();
				clear_selection();
				move_to_ta_position(get_document().insert_character(get_ta_position(), (int)'\t'));
				wants_col = current_col;
				return(true);
			}
			return(false);
		}
		if(String.is_empty(str) == false && e.get_ctrl() == false && e.get_alt() == false && e.get_command() == false) {
			delete_selection_contents();
			clear_selection();
			move_to_ta_position(get_document().insert_string(get_ta_position(), str));
			wants_col = current_col;
			on_character_insert(str, e);
			return(true);
		}
		return(false);
	}

	public virtual void on_character_insert(String str, KeyEvent e) {
	}

	public virtual void on_enter_pressed(KeyEvent e) {
		move_to_ta_position(get_document().insert_character(get_ta_position(), (int)'\n'));
	}

	public void set_highlight_character(int col, int row) {
		if(highlight_cursor == null) {
			return;
		}
		int y = row - get_first_paragraph();
		int x = col_to_display_col(col, row) - get_current_offset();
		if(y < 0 || y >= get_last_paragraph() - get_first_paragraph() || x < 0 || x > get_width_characters()) {
		}
		else {
			var pp = highlight_cursor.get_parent() as Widget;
			var px = pp.get_x();
			var py = pp.get_y();
			highlight_cursor.move_resize(px + x * charwidth, py + y * charheight, charwidth, charheight);
		}
	}

	void clear_highlight_character() {
		if(highlight_cursor != null) {
			highlight_cursor.resize(0,0);
		}
	}

	public virtual void on_error_message(String err) {
		Log.error("TATextEditorWidget error: `%s'".printf().add(err));
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

	public TADocumentPosition px_to_position(int x, int y, bool adjust = true) {
		if(charheight < 1 || charwidth < 1) {
			return(null);
		}
		int row = (int)(get_first_paragraph() + y / charheight);
		int col = (int)(get_current_offset() + x / charwidth);
		if(adjust) {
			var doc = get_document();
			var pp = doc.get_paragraph(row);
			if(pp == null) {
				row = doc.get_paragraph_count() - 1;
				pp = doc.get_paragraph(row);
			}
			if(pp == null) {
				row = 0;
				col = 0;
			}
			col = adjust_col_for_row(display_col_to_document_col(col, row), row);
		}
		return(TADocumentPosition.for_xy(col, row));
	}

	public void move_to_px(int ax, int ay) {
		var pos = px_to_position(ax, ay);
		if(pos == null) {
			return;
		}
		current_row = pos.get_y();
		current_col = pos.get_x();
		wants_col = current_col;
		on_cursor_moved();
	}

	bool dragged = false;

	public bool on_pointer_drag(int x, int y, int dx, int dy, int button, bool drop, int id) {
		if(drop) {
			return(base.on_pointer_drag(x,y,dx,dy,button,drop,id));
		}
		var endpp = get_pointer_event_position(x, y);
		var epy = endpp.get_y();
		if(epy < charheight) {
			scroll(-1);
		}
		else if(epy >= get_height()-charheight) {
			scroll(1);
		}
		if(dragged == false) {
			selection_start = null;
		}
		dragged = true;
		var origx = x - dx, origy = y - dy;
		if(selection_start == null) {
			var startpp = get_pointer_event_position(origx, origy);
			selection_start = px_to_position(startpp.get_x(), startpp.get_y());
		}
		selection_end = px_to_position(endpp.get_x(), endpp.get_y());
		on_selection_changed();
		current_row = selection_end.get_y();
		current_col = selection_end.get_x();
		wants_col = current_col;
		on_cursor_moved();
		return(false);
	}

	public bool on_pointer_press(int x, int y, int button, int id) {
		if(is_focusable() && has_focus() == false) {
			grab_focus();
		}
		dragged = false;
		var pp = get_pointer_event_position(x, y);
		move_to_px(pp.get_x(), pp.get_y());
		return(true);
	}

	public bool on_pointer_cancel(int x, int y, int button, int id) {
		clear_selection();
		return(base.on_pointer_cancel(x, y, button, id));
	}

	public bool on_pointer_release(int x, int y, int button, int id) {
		if(dragged == false) {
			clear_selection();
		}
		return(base.on_pointer_release(x, y, button, id));
	}
}
