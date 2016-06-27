
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

public class RssFeedParser : XMLParser
{
	Reader reader;
	RssFeed feed;
	RssFeedItem item;
	Stack data;

	public static RssFeedParser create(Reader reader) {
		var v = new RssFeedParser();
		v.reader = reader;
		return(v);
	}

	public RssFeedParser() {
		data = Stack.create();
	}

	public override void on_start_element(String element, HashTable params) {
		if("item".equals(element)) {
			if(item != null) {
				Log.warning("Nested items encountered. The outer ones will be ignored.");
			}
			item = new RssFeedItem();
		}
		data.push(StringBuffer.create());
	}

	String unescape(String str) {
		if(str == null || str.chr((int)'&') < 0) {
			return(str);
		}
		var sb = StringBuffer.create();
		StringBuffer ab;
		foreach(Integer i in str) {
			var c = i.to_integer();
			if(c == '&') {
				ab = StringBuffer.create();
			}
			if(ab != null) {
				if(c == ';') {
					var ss = ab.to_string();
					if(ss.has_prefix("&#")) {
						var nn = ss.substring(2).to_integer();
						if(nn == 8194 || nn == 8195 || nn == 8201 || nn == 8204 || nn == 8205 || nn == 8206 || nn == 8207) {
							sb.append_c((int)' ');
						}
						else if(nn == 8211 || nn == 8212) {
							sb.append_c((int)'-');
						}
						else if(nn == 8216) {
							sb.append_c((int)'`');
						}
						else if(nn == 8217 || nn == 8242) {
							sb.append_c((int)'\'');
						}
						else if(nn == 8218) {
							sb.append_c((int)',');
						}
						else if(nn == 8220 || nn == 8221 || nn == 8222 || nn == 8243) {
							sb.append_c((int)'"');
						}
						else if(nn == 8226) {
							sb.append_c((int)'*');
						}
						else if(nn == 8230) {
							sb.append("...");
						}
						else if(nn == 8249) {
							sb.append_c((int)'<');
						}
						else if(nn == 8250) {
							sb.append_c((int)'>');
						}
						else if(nn == 8260) {
							sb.append_c((int)'/');
						}
						else if(nn == 215 || nn == 8727) {
							sb.append_c((int)'*');
						}
						else {
							sb.append_c(nn);
						}
					}
					else if(ss.has_prefix("&")) {
						var nn = ss.substring(1);
						if(nn.equals("amp")) {
							sb.append_c((int)'&');
						}
						else if(nn.equals("quot")) {
							sb.append_c((int)'\"');
						}
						else if(nn.equals("lt")) {
							sb.append_c((int)'<');
						}
						else if(nn.equals("gt")) {
							sb.append_c((int)'>');
						}
					}
					else {
						sb.append(ss);
						sb.append_c(c);
					}
					ab = null;
				}
				else {
					ab.append_c(c);
				}
			}
			else {
				sb.append_c(c);
			}
		}
		return(sb.to_string());
	}

	public override void on_end_element(String element) {
		var dd = data.pop() as StringBuffer;
		if(dd == null) {
			Log.warning("RssFeedParser: null StringBuffer when ending element `%s'".printf().add(element));
			return;
		}
		if(item != null) {
			if("item".equals(element)) {
				feed.add(item);
				item = null;
			}
			else if("title".equals(element)) {
				item.set_title(unescape(dd.to_string()));
			}
			else if("description".equals(element)) {
				item.set_description(unescape(dd.to_string()));
			}
			else if("content:encoded".equals(element)) {
				item.set_content_encoded(unescape(dd.to_string()));
			}
			else if("link".equals(element)) {
				item.set_link(unescape(dd.to_string()));
			}
			else if("pubdate".equals_ignore_case(element)) {
				item.set_pub_date(unescape(dd.to_string()));
			}
		}
		else if(feed != null) {
			if("title".equals(element)) {
				feed.set_title(unescape(dd.to_string()));
			}
			else if("link".equals(element)) {
				feed.set_link(unescape(dd.to_string()));
			}
			else if("description".equals(element)) {
				feed.set_description(unescape(dd.to_string()));
			}
			else if("lastBuildDate".equals(element)) {
				feed.set_last_build_date(unescape(dd.to_string()));
			}
			else if("language".equals(element)) {
				feed.set_language(unescape(dd.to_string()));
			}
		}
	}

	public override void on_cdata(String cdata) {
		var dd = data.peek() as StringBuffer;
		if(dd != null) {
			dd.append(cdata);
		}
	}

	public RssFeed parse() {
		feed = new RssFeed();
		if(parse_reader(reader) == false) {
			return(null);
		}
		return(feed);
	}
}

