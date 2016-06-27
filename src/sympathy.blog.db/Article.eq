
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

public class Article : Serializable, Validateable
{
	property String id;
	String title_id;
	String title;
	property int timestamp;
	property int published;
	property String content;
	property String category;
	property String intro;

	public Article() {
		set_timestamp(SystemClock.seconds());
	}

	public Article set_title_id(String tid) {
		title_id = tid;
		return(this);
	}

	public String get_title_id() {
		if(title_id == null) {
			title_id = title_to_id(get_title(), get_timestamp());
		}
		return(title_id);
	}

	public Article set_title(String t) {
		title = t;
		title_id = null;
		return(this);
	}

	public String get_title() {
		return(title);
	}

	public void export_data(HashTable data) {
		data.set("id", get_id());
		data.set("title_id", get_title_id());
		data.set("category", get_category());
		data.set("published", get_published());
		data.set("timestamp", get_timestamp());
		data.set("title", get_title());
		data.set("intro", get_intro());
		data.set("content", get_content());
	}

	public void import_data(HashTable data) {
		set_id(data.get_string("id", id));
		set_title_id(data.get_string("title_id", title_id));
		set_category(data.get_string("category", category));
		set_published(data.get_int("published", published));
		set_timestamp(data.get_int("timestamp", timestamp));
		set_title(data.get_string("title", title));
		set_intro(data.get_string("intro", intro));
		set_content(data.get_string("content", content));
	}

	String title_to_id(String title, int timestamp) {
		if(title == null) {
			return(null);
		}
		var sb = StringBuffer.create();
		var dt = DateTime.for_time(timestamp);
		if(dt != null) {
			var dets = dt.get_details();
			if(dets != null) {
				var month = dets.get_month();
				var year = dets.get_year();
				if(month > 0 && year > 1900) {
					sb.append("%04d-%02d-".printf().add(year).add(month).to_string());
				}
			}
		}
		var it = title.iterate();
		int c, pc = 0;
		while((c = it.next_char()) > 0) {
			if(c >= 'A' && c <= 'Z') {
				c = c - 'A' + 'a';
			}
			if((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '-') {
			}
			else {
				c = (int)'-';
			}
			if(c == '-') {
				if(pc != '-') {
					sb.append_c(c);
				}
			}
			else {
				sb.append_c(c);
			}
			pc = c;
		}
		var r = sb.to_string();
		if(r != null && r.has_suffix("-")) {
			r = r.substring(0, r.get_length()-1);
		}
		return(r);
	}

	public bool validate(Error error) {
		var title = get_title();
		if(String.is_empty(title)) {
			Error.set_error_message(error, "No title");
			return(false);
		}
		if(title.get_length() < 3) {
			Error.set_error_message(error, "Title is too short");
			return(false);
		}
		var title_id = get_title_id();
		if(String.is_empty(title_id)) {
			Error.set_error_message(error, "Invalid title: Cannot determine title ID");
			return(false);
		}
		return(true);
	}

	/*
		if(String.is_empty(id) == false && published == 1) {
			var db = get_database() as BlogDatabase;
			if(db != null) {
				var original = db.get_article_by_id(id);
				if(original != null) {
					if(original.get_published() == 0) {
						set_timestamp(SystemClock.seconds());
					}
				}
			}
		}
	*/
}
