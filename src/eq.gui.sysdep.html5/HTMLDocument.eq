
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

public class HTMLDocument : HTMLElement
{
	public static HTMLDocument instance() {
		return(new HTMLDocument());
	}

	property bool register_click_handlers = true;

	public HTMLDocument() {
		ptr el;
		embed "js" {{{
			el = document;
		}}}
		set_element(el);
	}

	public void initialize() {
		embed "js" {{{
			var self = this;
			window.onload = function() {
				self.on_load();
			};
			window.onresize = function() {
				self.on_resize(window.innerWidth, window.innerHeight);
			};
		}}}
	}

	class ClickHandler : HTMLEventListener
	{
		property HTMLDocument doc;
		public void on_html_event(HTMLElement e, String name, ptr data) {
			if(e != null) {
				doc.on_click_id(e.get_id());
			}
		}
	}

	public virtual void on_load() {
		if(register_click_handlers) {
			var ch = new ClickHandler().set_doc(this);
			foreach(HTMLElement e in get_elements_by_tag("a")) {
				e.add_event_listener("click", ch);
			}
			foreach(HTMLElement e in get_elements_by_tag("button")) {
				e.add_event_listener("click", ch);
			}
		}
	}

	public HTMLElement get_head() {
		var els = get_elements_by_tag("head");
		if(els == null) {
			return(null);
		}
		return(els.get(0) as HTMLElement);
	}

	public HTMLElement get_body() {
		var els = get_elements_by_tag("body");
		if(els == null) {
			return(null);
		}
		return(els.get(0) as HTMLElement);
	}

	public bool append_to_head(HTMLElement el) {
		var bd = get_head();
		if(bd == null) {
			return(false);
		}
		bd.append_child(el);
		return(true);
	}

	public bool append_to_body(HTMLElement el) {
		var bd = get_body();
		if(bd == null) {
			return(false);
		}
		bd.append_child(el);
		return(true);
	}

	public virtual void on_click_id(String id) {
	}

	public virtual void on_resize(int w, int h) {
	}
}
