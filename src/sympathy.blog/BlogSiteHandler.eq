
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

public class BlogSiteHandler : PadgetSiteHandler
{
	class MyReferenceResolver : RichTextDocumentReferenceResolver
	{
		property BlogDatabase db;

		public String get_reference_href(String refid) {
			if(refid == null || refid.has_prefix("article:") == false) {
				return(null);
			}
			return("/articles/".append(refid.substring(8)));
		}

		public String get_reference_title(String refid) {
			if(db == null) {
				return(refid);
			}
			if(refid == null || refid.has_prefix("article:") == false) {
				return(null);
			}
			var rfid = refid.substring(8);
			var article = db.get_article_by_id(rfid);
			if(article == null) {
				article = db.get_article_by_title_id(rfid);
			}
			if(article == null) {
				return(rfid);
			}
			return(article.get_title());
		}
	}

	property BlogDatabase db;
	property int articles_per_page = 10;
	property int max_attachment_size = 10 * 1024 * 1024;
	property HashTable site_config;

	public BlogSiteHandler() {
		set_favicon_url("/public/favicon.png");
	}

	public void get_css(StringBuffer sb) {
		base.get_css(sb);
		sb.append(TEXTFILE("style.css"));
	}

	public void get_javascript(StringBuffer sb) {
		base.get_javascript(sb);
	}

	public virtual String get_htmlhead_html() {
		return(TEXTFILE("HtmlHead.html"));
	}

	public virtual String get_header_html() {
		return(TEXTFILE("Header.html"));
	}

	public virtual String get_footer_html() {
		return(TEXTFILE("Footer.html"));
	}

	public virtual String get_article_html() {
		return(TEXTFILE("Article.html"));
	}

	public virtual String get_article_list_html() {
		return(TEXTFILE("ArticleList.html"));
	}

	void send_error_redirect(HTTPRequest req, String error) {
		req.send_redirect("/error?error=".append(URLEncoder.encode(error)));
	}

	void append_page_not_found(StringBuffer sb) {
		sb.append("<div>Page not found</div>");
	}

	String date_time_to_nice_string(DateTime dt) {
		if(dt == null) {
			return(null);
		}
		var dets = dt.get_details();
		if(dets == null) {
			return(null);
		}
		var month = dets.get_month() - 1;
		if(month < 0) {
			month = 0;
		}
		if(month > 11) {
			month = 11;
		}
		var months = Array.create().add("January").add("February").add("March")
			.add("April").add("May").add("June").add("July").add("August")
			.add("September").add("October").add("November").add("December");
		return("%s %d, %d".printf().add(months.get(month)).add(dets.get_day()).add(dets.get_year()).to_string());
	}

	void get_article_intro_texts(String intro, HashTable dd) {
		if(String.is_empty(intro)) {
			return;
		}
		var rr = get_reference_resolver();
		var irtd = RichTextDocument.for_wiki_markup_string(intro);
		if(irtd == null) {
			return;
		}
		foreach(RichTextStyledParagraph paragraph in irtd.get_paragraphs()) {
			if(paragraph.is_heading()) {
				continue;
			}
			var html = paragraph.to_html(rr, "intro_paragraph");
			if(String.is_empty(html)) {
				continue;
			}
			dd.set("intro_html", html);
			dd.set("intro_text", paragraph.to_text());
			return;
		}
	}

	/*
	public String get_article_intro_html(String intro) {
		if(String.is_empty(intro)) {
			return(null);
		}
		var rr = get_reference_resolver();
		var irtd = RichTextDocument.for_wiki_markup_string(intro);
		if(irtd == null) {
			return(null);
		}
		foreach(RichTextStyledParagraph paragraph in irtd.get_paragraphs()) {
			if(paragraph.is_heading()) {
				continue;
			}
			var html = paragraph.to_html(rr, "intro_paragraph");
			if(String.is_empty(html)) {
				continue;
			}
			return(html);
		}
		return(null);
	}
	*/

	public String get_article_content_html(String content) {
		if(content == null) {
			return(null);
		}
		var rr = get_reference_resolver();
		var crtd = RichTextDocument.for_wiki_markup_string(content);
		if(crtd != null) {
			return(crtd.to_html(rr));
		}
		return(null);
	}

	MyReferenceResolver _ref_resolver;
	MyReferenceResolver get_reference_resolver() {
		if(_ref_resolver == null) {
			_ref_resolver = new MyReferenceResolver().set_db(db);
		}
		return(_ref_resolver);
	}

	Collection format_list_articles(Collection articles) {
		foreach(HashTable dd in articles) {
			modify_article_data(dd);
		}
		return(articles);
	}

	HashTable modify_article_data(HashTable dd) {
		if(dd == null) {
			return(null);
		}
		// FIXME: Cache the HTML?
		get_article_intro_texts(dd.get_string("intro"), dd);
		//dd.set("intro_html", get_article_intro_html(dd.get_string("intro")));
		dd.set("content_html", get_article_content_html(dd.get_string("content")));
		dd.set("timestamp", date_time_to_nice_string(DateTime.for_time(dd.get_int("timestamp"))));
		return(dd);
	}

	public void initialize() {
		base.initialize();
		add_padget(new HighlightJSPadget());
	}

	public override void initialize_data(HashTable data) {
		base.initialize_data(data);
		data.set("site", site_config);
	}

	public void get_html_header(StringBuffer sb) {
		sb.append("<link rel=\"alternate\" type=\"application/rss+xml\" title=\"RSS\" href=\"/rss\" />\n");
		var themehead = get_htmlhead_html();
		if(themehead != null) {
			sb.append(themehead);
		}
	}

	public override void get_html_body_begin(StringBuffer sb) {
		base.get_html_body_begin(sb);
		sb.append(TEXTFILE("HtmlBodyBegin.html"));
	}

	public void on_padget_application_request(HTTPRequest req, HashTable data, StringBuffer sb) {
		sb.append(get_header_html());
		var r1 = req.pop_resource();
		if(String.is_empty(r1)) {
			r1 = "articles";
		}
		if("articles".equals(r1)) {
			var r2 = req.pop_resource();
			if(String.is_empty(r2)) {
				var ac = db.get_article_count(null, false);
				int pages;
				var app = articles_per_page;
				if(app < 1) {
					pages = 1;
					app = ac;
				}
				else {
					pages = ac /  app;
					if(ac % app > 0) {
						pages ++;
					}
				}
				if(pages < 1) {
					pages = 1;
				}
				int npage = 0;
				var page = req.get_query_parameter("page");
				if(String.is_empty(page) == false) {
					npage = page.to_integer() - 1;
				}
				data.set("articles", format_list_articles(db.get_articles(null, false, npage*app, app)));
				data.set("page_count", pages);
				data.set("current_page", npage + 1);
				if(npage != 0) {
					data.set("previous_page", npage+1-1);
				}
				if(npage < pages - 1) {
					data.set("next_page", npage+1+1);
				}
				sb.append(get_article_list_html());
				data.set("page_tagline", data.get_string("page_description"));
			}
			else {
				if(req.is_for_directory() == false) {
					req.send_redirect_as_directory();
					return;
				}
				var article = db.get_article_by_title_id(r2);
				if(article == null) {
					sb.append("<div><p>No such article</p></div>");
				}
				else {
					data.set("page_title", "%s | %s".printf().add(article.get_title()).add(get_site_title()).to_string());
					var dd = modify_article_data(Serializable.to_hash_table(article));
					data.set("page_description", dd.get_string("intro_text"));
					data.set("article", dd);
					sb.append(get_article_html());
				}
			}
		}
		else if("categories".equals(r1)) {
			var r2 = req.pop_resource();
			if(String.is_empty(r2)) {
				sb.append("category list (FIXME)");
			}
			else {
				sb.append("Category `%s'".printf().add(r2).to_string());
			}
		}
		else {
			append_page_not_found(sb);
		}
		sb.append(get_footer_html());
	}
}
