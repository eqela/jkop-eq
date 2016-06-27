
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

public class XMLMaker : Stringable
{
	property Collection elements;
	property String custom_header;
	property bool single_line = false;
	property String header;

	public XMLMaker() {
		elements = LinkedList.create();
		header = "<?xml version=\"1.0\" encoding=\"utf-8\"?>";
	}

	public XMLMaker start(String element) {
		add(XMLMakerStartElement.for_name(element));
		return(this);
	}

	public XMLMaker start_with_attribute(String element, String k1, String v1) {
		var v = XMLMakerStartElement.for_name(element);
		if(k1 != null) {
			v.attribute(k1, v1);
		}
		add(v);
		return(this);
	}

	public XMLMaker start_with_attributes(String element, HashTable attrs) {
		var v = XMLMakerStartElement.for_name(element);
		if(attrs != null) {
			foreach(String key in attrs.iterate_keys()) {
				v.attribute(key, attrs.get_string(key));
			}
		}
		add(v);
		return(this);
	}

	public XMLMaker end(String element) {
		add(XMLMakerEndElement.for_name(element));
		return(this);
	}

	public XMLMaker cdata(String element) {
		add(XMLMakerCData.for_text(element));
		return(this);
	}

	public XMLMaker text_element(String element, String text) {
		add(XMLMakerStartElement.for_name(element));
		add(text);
		add(XMLMakerEndElement.for_name(element));
		return(this);
	}

	class MyXMLParser : XMLParser
	{
		property XMLMaker maker;
		property bool ignore_empty_cdata = true;
		property bool parse_text_as_cdata = true;

		public override void on_start_element(String element, HashTable params) {
			maker.add(XMLMakerStartElement.for_name(element).set_attributes(params));
		}

		public override void on_end_element(String element) {
			maker.end(element);
		}

		public override void on_cdata(String cdata) {
			if(cdata == null) {
				return;
			}
			if(ignore_empty_cdata) {
				var x = cdata.strip();
				if(String.is_empty(x)) {
					return;
				}
			}
			if(parse_text_as_cdata) {
				maker.cdata(cdata);
			}
			else {
				maker.add(cdata);
			}
		}

		public override void on_comment(String comment) {
		}
	}

	public XMLMaker xmlstring(String xml, bool ignore_empty_cdata = true, bool parse_text_as_cdata = true) {
		var mx = new MyXMLParser();
		mx.set_ignore_empty_cdata(ignore_empty_cdata);
		mx.set_parse_text_as_cdata(parse_text_as_cdata);
		mx.set_maker(this);
		mx.parse_string(xml);
		return(this);
	}

	public XMLMaker add(Object o) {
		if(o != null) {
			elements.add(o);
		}
		return(this);
	}

	void append(StringBuffer sb, int level, String str, bool no_indent, bool no_newline) {
		int n;
		if(single_line == false && no_indent == false) {
			for(n=0; n<level; n++) {
				sb.append_c((int)' ');
				sb.append_c((int)' ');
			}
		}
		sb.append(str);
		if(single_line == false && no_newline == false) {
			sb.append_c((int)'\n');
		}
	}

	String escape_string(String str) {
		var sb = StringBuffer.create();
		if(str != null) {
			var it = str.iterate();
			if(it != null) {
				int c;
				while((c = it.next_char()) > 0) {
					if(c == '"') {
						sb.append("&quot;");
					}
					else if(c == '\'') {
						sb.append("&apos;");
					}
					else if(c == '<') {
						sb.append("&lt;");
					}
					else if(c == '>') {
						sb.append("&gt;");
					}
					else if(c == '&') {
						sb.append("&amp;");
					}
					else {
						sb.append_c(c);
					}
				}
			}
		}
		return(sb.to_string());
	}

	public String to_string() {
		var sb = StringBuffer.create();
		int level = 0;
		if(header != null) {
			append(sb, level, header, false, false);
		}
		if(String.is_empty(custom_header) == false) {
			sb.append(custom_header);
		}
		bool single_line = false;
		foreach(var o in elements) {
			if(o is XMLMakerElement) {
				append(sb, level, ((XMLMakerElement)o).to_string(), single_line, single_line);
			}
			else if(o is XMLMakerStartElement) {
				single_line = ((XMLMakerStartElement)o).get_single_line();
				append(sb, level, ((XMLMakerStartElement)o).to_string(), false, single_line);
				level ++;
			}
			else if(o is XMLMakerEndElement) {
				level --;
				append(sb, level, ((XMLMakerEndElement)o).to_string(), single_line, false);
				single_line = false;
			}
			else if(o is XMLMakerCustomXML) {
				append(sb, level, ((XMLMakerCustomXML)o).get_string(), single_line, single_line);
			}
			else if(o is String) {
				append(sb, level, escape_string((String)o), single_line, single_line);
			}
			else if(o is XMLMakerCData) {
				append(sb, level, ((XMLMakerCData)o).to_string(), single_line, ((XMLMakerCData)o).get_single_line());
			}
		}
		return(sb.to_string());
	}
}