
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

public class HTMLElement
{
	public static HTMLElement create(String type) {
		if(type == null) {
			return(null);
		}
		ptr el;
		embed {{{
			el = document.createElement(type.to_strptr());
		}}}
		if(el == null) {
			return(null);
		}
		return(new HTMLElement().set_element(el));
	}

	property ptr element;

	public String get_id() {
		return(get_attribute("id"));
	}

	public Collection get_classes() {
		return(LinkedList.for_iterator(StringSplitter.split(get_attribute("class"), ' ')));
	}

	public void remove_from_dom() {
		var element = get_element();
		if(element == null) {
			return;
		}
		embed {{{
			element.parentNode.removeChild(element);
		}}}
	}

	public String get_attribute(String attr) {
		var element = get_element();
		if(attr == null || element == null) {
			return(null);
		}
		strptr v;
		embed {{{
			v = element.getAttribute(attr.to_strptr());
		}}}
		if(v == null) {
			return(null);
		}
		return(String.for_strptr(v));
	}

	public HTMLElement set_attribute(String attr, String val) {
		var element = get_element();
		if(attr == null || element == null) {
			return(this);
		}
		var v = val;
		if(v == null) {
			v = "";
		}
		embed {{{
			element.setAttribute(attr.to_strptr(), v.to_strptr());
		}}}
		return(this);
	}

	public HTMLElement set_style(String key, String val) {
		var element = get_element();
		if(key == null || element == null) {
			return(this);
		}
		var v = val;
		if(v == null) {
			v = "";
		}
		embed {{{
			element.style[key.to_strptr()] = v.to_strptr();
		}}}
		return(this);
	}

	public String get_style(String key) {
		var element = get_element();
		if(key == null || element == null) {
			return(null);
		}
		strptr v;
		embed {{{
			v = element.style[key.to_strptr()];
		}}}
		if(v == null) {
			return(null);
		}
		return(String.for_strptr(v));
	}

	public HTMLElement add_sibling_before(HTMLElement sibling) {
		if(sibling == null) {
			return(this);
		}
		var tel = this.get_element();
		var nel = sibling.get_element();
		if(tel == null || nel == null) {
			return(this);
		}
		embed {{{
			tel.parentNode.insertBefore(nel, tel);
		}}}
		return(this);
	}

	public HTMLElement add_sibling_after(HTMLElement sibling) {
		if(sibling == null) {
			return(this);
		}
		var tel = this.get_element();
		var nel = sibling.get_element();
		if(tel == null || nel == null) {
			return(this);
		}
		embed {{{
			tel.parentNode.insertBefore(nel, tel.nextSibling);
		}}}
		return(this);
	}

	public HTMLElement append_child(HTMLElement child) {
		var element = get_element();
		if(element == null || child == null || child.get_element() == null) {
			return(this);
		}
		embed {{{
			element.appendChild(child.get_element());
		}}}
		return(this);
	}

	public HTMLElement prepend_child(HTMLElement child) {
		var element = get_element();
		if(element == null || child == null || child.get_element() == null) {
			return(this);
		}
		embed {{{
			element.insertBefore(child.get_element(), element.firstChild);
		}}}
		return(this);
	}

	public Collection get_children() {
		var element = get_element();
		if(element == null) {
			return(null);
		}
		var v = LinkedList.create();
		ptr p;
		embed {{{
			if(element.children && element.children.length) {
				var els = element.children;
				for(var i = 0; i<els.length; i++) {
					p = els[i];
					}}}
					v.append(new HTMLElement().set_element(p));
					embed {{{
				}
			}
		}}}
		return(v);
	}

	public int get_width() {
		var element = get_element();
		if(element == null) {
			return(0);
		}
		int v;
		embed {{{
			v = element.offsetWidth;
		}}}
		return(v);
	}

	public int get_height() {
		var element = get_element();
		if(element == null) {
			return(0);
		}
		int v;
		embed {{{
			v = element.offsetHeight;
		}}}
		return(v);
	}

	public String get_inner_html() {
		var element = get_element();
		if(element == null) {
			return(null);
		}
		strptr v;
		embed {{{
			v = element.innerHTML;
		}}}
		if(v == null) {
			return(null);
		}
		return(String.for_strptr(v));
	}

	public HTMLElement set_inner_html(String ahtml) {
		var element = get_element();
		if(element == null) {
			return(this);
		}
		var html = ahtml;
		if(html == null) {
			html = "";
		}
		embed {{{
			element.innerHTML = html.to_strptr();
		}}}
		return(this);
	}

	public HTMLElement get_element_by_id(String id) {
		var element = get_element();
		if(element == null) {
			return(null);
		}
		ptr el;
		embed {{{
			el = element.getElementById(id.to_strptr());
		}}}
		if(el == null) {
			return(null);
		}
		return(new HTMLElement().set_element(el));
	}

	public Collection get_elements_by_class(String cls) {
		var element = get_element();
		if(element == null || cls == null) {
			return(null);
		}
		var v = LinkedList.create();
		ptr p;
		embed {{{
			var els = element.getElementsByClassName(cls.to_strptr());
			for(var i = 0; i<els.length; i++) {
				p = els[i];
				}}}
				v.append(new HTMLElement().set_element(p));
				embed {{{
			}
		}}}
		return(v);
	}

	public Collection get_elements_by_tag(String tag) {
		var element = get_element();
		if(element == null || tag == null) {
			return(null);
		}
		var v = LinkedList.create();
		ptr p;
		embed {{{
			var els = element.getElementsByTagName(tag.to_strptr());
			for(var i = 0; i<els.length; i++) {
				p = els[i];
				}}}
				v.append(new HTMLElement().set_element(p));
				embed {{{
			}
		}}}
		return(v);
	}

	public HTMLElement add_event_listener(String event, HTMLEventListener handler) {
		var element = get_element();
		if(element == null || event == null || handler == null) {
			return(this);
		}
		embed {{{
			var self = this;
			element.addEventListener(event.to_strptr(), function(e) {
				handler.on_html_event(self, event.to_strptr(), e);
			});
		}}}
		return(this);
	}
}
