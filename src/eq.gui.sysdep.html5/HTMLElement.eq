
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

	public static HTMLElement for_element(ptr el) {
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
		if(element == null) {
			return;
		}
		var ee = element;
		embed {{{
			ee.parentNode.removeChild(ee);
		}}}
	}

	public String get_attribute(String attr) {
		if(attr == null || element == null) {
			return(null);
		}
		strptr v;
		var ee = element;
		embed {{{
			v = ee.getAttribute(attr.to_strptr());
		}}}
		if(v == null) {
			return(null);
		}
		return(String.for_strptr(v));
	}

	public HTMLElement set_attribute(String attr, String val) {
		if(attr == null || element == null) {
			return(this);
		}
		var ee = element;
		if(val == null) {
			embed {{{
				ee.removeAttribute(attr.to_strptr());
			}}}
		}
		else {
			embed {{{
				ee.setAttribute(attr.to_strptr(), val.to_strptr());
			}}}
		}
		return(this);
	}

	public HTMLElement set_style(String key, String val) {
		if(key == null || element == null) {
			return(this);
		}
		var v = val;
		if(v == null) {
			v = "";
		}
		var ee = element;
		embed {{{
			ee.style[key.to_strptr()] = v.to_strptr();
		}}}
		return(this);
	}

	public String get_style(String key) {
		if(key == null || element == null) {
			return(null);
		}
		strptr v;
		var ee = element;
		embed {{{
			v = ee.style[key.to_strptr()];
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
		if(element == null || child == null || child.get_element() == null) {
			return(this);
		}
		var ee = element;
		embed {{{
			ee.appendChild(child.get_element());
		}}}
		return(this);
	}

	public HTMLElement prepend_child(HTMLElement child) {
		if(element == null || child == null || child.get_element() == null) {
			return(this);
		}
		var ee = element;
		embed {{{
			ee.insertBefore(child.get_element(), ee.firstChild);
		}}}
		return(this);
	}

	public Collection get_children() {
		if(element == null) {
			return(null);
		}
		var v = LinkedList.create();
		ptr p;
		var ee = element;
		embed {{{
			if(ee.children && ee.children.length) {
				var els = ee.children;
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
		if(element == null) {
			return(0);
		}
		int v;
		var ee = element;
		embed {{{
			v = ee.offsetWidth;
		}}}
		return(v);
	}

	public int get_height() {
		if(element == null) {
			return(0);
		}
		int v;
		var ee = element;
		embed {{{
			v = ee.offsetHeight;
		}}}
		return(v);
	}

	public String get_inner_html() {
		if(element == null) {
			return(null);
		}
		strptr v;
		var ee = element;
		embed {{{
			v = ee.innerHTML;
		}}}
		if(v == null) {
			return(null);
		}
		return(String.for_strptr(v));
	}

	public HTMLElement set_inner_html(String ahtml) {
		if(element == null) {
			return(this);
		}
		var html = ahtml;
		if(html == null) {
			html = "";
		}
		var ee = element;
		embed {{{
			ee.innerHTML = html.to_strptr();
		}}}
		return(this);
	}

	public HTMLElement get_element_by_id(String id) {
		if(element == null) {
			return(null);
		}
		ptr el;
		var ee = element;
		embed {{{
			el = ee.getElementById(id.to_strptr());
		}}}
		if(el == null) {
			return(null);
		}
		return(new HTMLElement().set_element(el));
	}

	public Collection get_elements_by_class(String cls) {
		if(element == null || cls == null) {
			return(null);
		}
		var v = LinkedList.create();
		ptr p;
		var ee = element;
		embed {{{
			var els = ee.getElementsByClassName(cls.to_strptr());
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
		if(element == null || tag == null) {
			return(null);
		}
		var v = LinkedList.create();
		ptr p;
		var ee = element;
		embed {{{
			var els = ee.getElementsByTagName(tag.to_strptr());
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
		if(element == null || event == null || handler == null) {
			return(this);
		}
		var ee = element;
		embed {{{
			var self = this;
			ee.addEventListener(event.to_strptr(), function(e) {
				handler.on_html_event(self, event.to_strptr(), e);
			});
		}}}
		return(this);
	}
}
