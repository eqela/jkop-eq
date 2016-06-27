
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

public class RichTextDocumentDisplayWidget : LayerWidget
{
	public static RichTextDocumentDisplayWidget for_document(RichTextDocument document) {
		return(new RichTextDocumentDisplayWidget().set_document(document));
	}

	property RichTextDocument document;
	property String paragraph_spacing;
	property HashTable styles;
	property String document_margin;
	BoxWidget box;
	Widget animation;

	public RichTextDocumentDisplayWidget() {
		set_paragraph_spacing("1mm");
		set_document_margin("1mm");
	}

	public RichTextDocumentDisplayWidget set_style(String id, RichTextStyle style) {
		if(styles == null) {
			styles = HashTable.create();
		}
		if(id != null && style != null) {
			styles.set(id, style);
		}
		return(this);
	}

	class UpdateLayoutsTaskListener : EventReceiver
	{
		property BoxWidget box;
		property RichTextDocumentDisplayWidget widget;
		public void on_event(Object o) {
			box.set_staging_mode(true);
			foreach(UpdateLayoutsTaskResult rr in (Collection)o) {
				var w = rr.get_widget();
				if(w == null) {
				}
				else {
					if(w is LayoutArrayWidget) {
						((LayoutArrayWidget)w).set_layouts(rr.get_layouts());
					}
					if(w.is_enabled() == false) {
						w.set_enabled(true);
					}
				}
			}
			box.set_staging_mode(false);
			widget.on_layouts_done();
		}
	}

	class UpdateLayoutsTaskResult
	{
		property Array layouts;
		property Widget widget;
	}

	class UpdateLayoutsTask : RunnableTask
	{
		property ContainerWidget container;
		property Color draw_color;
		property Frame frame;
		property int dpi;

		public void run(EventReceiver listener, BooleanValue abortflag) {
			var results = LinkedList.create();
			foreach(Widget ww in container.iterate_children()) {
				Array layouts;
				if(ww is LayoutArrayWidget) {
					layouts = ((LayoutArrayWidget)ww).create_layouts(draw_color, frame, dpi);
				}
				results.add(new UpdateLayoutsTaskResult().set_layouts(layouts).set_widget(ww));
			}
			EventReceiver.event(listener, results);
		}
	}

	public virtual Widget create_widget_for_paragraph(RichTextParagraph pp) {
		Widget w;
		var pw = RichTextParagraphDisplayWidget.for_paragraph(pp);
		if(pw != null) {
			pw.set_styles(styles);
			w = pw;
		}
		return(w);
	}

	public void initialize() {
		base.initialize();
		box = BoxWidget.vertical();
		box.set_lazy_render(false);
		box.set_spacing(px(paragraph_spacing));
		box.set_margin(px(document_margin));
		if(document != null) {
			box.set_staging_mode(true);
			foreach(RichTextParagraph pp in document.get_paragraphs()) {
				var w = create_widget_for_paragraph(pp);
				if(w is RichTextParagraphDisplayWidget == false) {
					w.set_enabled(false);
				}
				if(w != null) {
					box.add(w);
				}
			}
			box.set_staging_mode(false);
		}
		add(box);
	}

	public void on_layouts_done() {
		if(animation != null) {
			remove(animation);
			animation = null;
		}
		if(box != null) {
			box.set_enabled(true);
		}
	}

	public void first_start() {
		base.first_start();
		if(box != null) {
			box.set_enabled(false);
		}
		add(AlignWidget.instance().add_align(0, 0, animation = WaitAnimationWidget.icon()));
		var ult = new UpdateLayoutsTask().set_container(box).set_draw_color(get_draw_color()).set_frame(get_frame()).set_dpi(get_dpi());
		var lll = new UpdateLayoutsTaskListener().set_box(box).set_widget(this);
		IFDEF("target_wpcs") {
			ult.run(lll, null);
		}
		ELSE IFDEF("target_html") {
			ult.run(lll, null);
		}
		ELSE {
			start_task(ult, lll);
		}
	}
}
