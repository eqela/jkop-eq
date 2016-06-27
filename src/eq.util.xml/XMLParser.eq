
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

public class XMLParser
{
	bool abortflag = false;
	bool abortrv = false;

	public static XMLParser create() {
		return(new XMLParser());
	}

	public void abort(bool v) {
		this.abortflag = true;
		this.abortrv = v;
	}

	public bool parse_string(String str) {
		return(parse_input_stream(InputStream.create(StringReader.create(str))));
	}

	public virtual void on_start_element(String element, HashTable params) {
	}

	public virtual void on_end_element(String element) {
	}

	public virtual void on_cdata(String cdata) {
	}

	public virtual void on_comment(String comment) {
	}

	private void on_tag_string(String tagstring) {
		if(tagstring.get_char(0) == '/') {
			var end = tagstring.substring(1);
			on_end_element(end);
		}
		else {
			StringBuffer element = StringBuffer.create();
			var params = HashTable.create();
			var it = tagstring.iterate();
			int c;
			// element name
			while((c = it.next_char()) > 0) {
				if(c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == '/') {
					if(element.count() > 0) {
						break;
					}
				}
				else {
					element.append_c(c);
				}
			}
			// parameters
			while(c > 0 && c != '/') {
				StringBuffer pname = StringBuffer.create();
				StringBuffer pval = StringBuffer.create();
				while(c == ' ' || c == '\t' || c == '\n' || c == '\r') {
					c = it.next_char();
				}
				while(c > 0 && c != ' ' && c != '\t' && c != '\n' && c != '\r' && c != '=') {
					pname.append_c(c);
					c = it.next_char();
				}
				while(c == ' ' || c == '\t' || c == '\n' || c == '\r') {
					c = it.next_char();
				}
				if(c != '=') {
					; // error; but we will try to survive it anyway.
				}
				else {
					c = it.next_char();
					while(c == ' ' || c == '\t' || c == '\n' || c == '\r') {
						c = it.next_char();
					}
					if(c != '"') {
						; // should not be as per spec; try to deal with it anyway.
						while(c > 0 && c != ' ' && c != '\t' && c != '\n' && c != '\r') {
							pval.append_c(c);
							c = it.next_char();
						}
						while(c == ' ' || c == '\t' || c == '\n' || c == '\r') {
							c = it.next_char();
						}
					}
					else {
						c = it.next_char();
						while(c > 0 && c != '"') {
							pval.append_c(c);
							c = it.next_char();
						}
						if(c != '"') {
							; // error; but ignore it.
						}
						else {
							c = it.next_char();
						}
						while(c == ' ' || c == '\t' || c == '\n' || c == '\r') {
							c = it.next_char();
						}
					}
				}
				var pnamestr = pname.to_string();
				var pvalstr = pval.to_string();
				params.set(pnamestr, pvalstr);
			}
			var els = element.to_string();
			on_start_element(els, params);
			if(c == '/') {
				on_end_element(els);
			}
		}
	}

	public bool parse_reader(Reader reader) {
		return(parse_input_stream(InputStream.create(reader)));
	}

	class InputStreamWrapper
	{
		InputStream ist;
		int current;
		Stack bytes;

		public static InputStreamWrapper create(InputStream ist) {
			var v = new InputStreamWrapper();
			v.ist = ist;
			return(v);
		}

		public InputStreamWrapper() {
			bytes = Stack.create();
		}

		public bool nextbyte() {
			var b = bytes.pop() as Integer;
			if(b != null) {
				current = b.to_integer();
				return(true);
			}
			if(ist.nextbyte()) {
				current = ist.getbyte();
				return(true);
			}
			return(false);
		}

		public int getbyte() {
			return(current);
		}

		public void pushbyte(int b) {
			bytes.push(Primitive.for_integer(b));
		}

		public bool is_eof() {
			if(bytes.count() > 0) {
				return(false);
			}
			return(ist.is_eof());
		}
	}

	public bool parse_input_stream(InputStream aist) {
		String cdata_start = "![CDATA[";
		String comment_start = "!--";
		StringBuffer tag = null;
		StringBuffer def = null;
		StringBuffer cdata = null;
		StringBuffer comment = null;
		var ist = InputStreamWrapper.create(aist);
		while(ist!=null && ist.is_eof() == false && abortflag == false) {
			if(ist.nextbyte()) {
				int nxb = (int)ist.getbyte();
				if(nxb == 0) {
					continue;
				}
				if(tag != null) {
					if(nxb == '>') {
						on_tag_string(tag.to_string());
						tag = null;
					}
					else {
						tag.append_c(nxb);
						if(nxb == '[' && tag.count() == cdata_start.get_length() && cdata_start.equals(tag.dup_string())) {
							tag = null;
							cdata = StringBuffer.create();
						}
						else if(nxb == '-' && tag.count() == comment_start.get_length() && comment_start.equals(tag.dup_string())) {
							tag = null;
							comment = StringBuffer.create();
						}
					}
				}
				else if(cdata != null) {
					int c0 = nxb, c1 = 0, c2 = 0;
					if(c0 == ']') {
						if(ist.nextbyte()) {
							c1 = (int)ist.getbyte();
						}
						if(c1 == ']') {
							if(ist.nextbyte()) {
								c2 = (int)ist.getbyte();
							}
							if(c2 == '>') {
								on_cdata(cdata.to_string());
								cdata = null;
							}
						}
					}
					if(cdata != null) {
						if(c2 > 0) {
							ist.pushbyte(c2);
						}
						if(c1 > 0) {
							ist.pushbyte(c1);
						}
						if(c0 > 0) {
							cdata.append_c(c0);
						}
					}
				}
				else if(comment != null) {
					int c0 = nxb, c1 = 0, c2 = 0;
					if(c0 == '-') {
						if(ist.nextbyte()) {
							c1 = (int)ist.getbyte();
						}
						if(c1 == '-') {
							if(ist.nextbyte()) {
								c2 = (int)ist.getbyte();
							}
							if(c2 == '>') {
								on_comment(comment.to_string());
								comment = null;
							}
						}
					}
					if(comment != null) {
						if(c2 > 0) {
							ist.pushbyte(c2);
						}
						if(c1 > 0) {
							ist.pushbyte(c1);
						}
						if(c0 > 0) {
							comment.append_c(c0);
						}
					}
				}
				else {
					if(nxb == '<') {
						if(def != null) {
							on_cdata(def.to_string());
							def = null;
						}
						tag = StringBuffer.create();
					}
					else {
						if(def == null) {
							def = StringBuffer.create();
						}
						def.append_c(nxb);
					}
				}
			}
		}
		if(abortflag == false) {
			return(true);
		}
		return(abortrv);
	}
}