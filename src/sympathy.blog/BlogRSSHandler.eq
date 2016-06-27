
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

public class BlogRSSHandler : HTTPRequestHandlerAdapter
{
	property String site_title;
	property String site_slogan;
	property String site_url;
	property String site_language;
	property BlogDatabase db;
	property int article_count = 20;

	public BlogRSSHandler() {
		site_language = "en";
	}

	public bool on_http_get(HTTPRequest req) {
		var xml = new XMLMaker();
		xml.add(XMLMakerStartElement.for_name("rss").attribute("version", "0.92"));
			xml.add(XMLMakerStartElement.for_name("channel"));
				xml.add(XMLMakerStartElement.for_name("title"));
					xml.add(site_title);
				xml.add(XMLMakerEndElement.for_name("title"));
				xml.add(XMLMakerStartElement.for_name("link"));
					xml.add(site_url);
				xml.add(XMLMakerEndElement.for_name("link"));
				xml.add(XMLMakerStartElement.for_name("description"));
					xml.add(XMLMakerCData.for_text(site_slogan));
				xml.add(XMLMakerEndElement.for_name("description"));
				xml.add(XMLMakerStartElement.for_name("lastBuildDate"));
					xml.add("FIXME");
				xml.add(XMLMakerEndElement.for_name("lastBuildDate"));
				xml.add(XMLMakerStartElement.for_name("language"));
					xml.add(site_language);
				xml.add(XMLMakerEndElement.for_name("language"));
				foreach(HashTable article in db.get_articles(null, false, 0, article_count)) {
					xml.add(XMLMakerStartElement.for_name("item"));
						xml.add(XMLMakerStartElement.for_name("title"));
							xml.add(article.get_string("title"));
						xml.add(XMLMakerEndElement.for_name("title"));
						xml.add(XMLMakerStartElement.for_name("description"));
							xml.add(XMLMakerCData.for_text(article.get_string("intro")));
						xml.add(XMLMakerEndElement.for_name("description"));
						xml.add(XMLMakerStartElement.for_name("link"));
							xml.add("%s/articles/%s".printf().add(site_url).add(article.get_string("title_id")).to_string());
						xml.add(XMLMakerEndElement.for_name("link"));
					xml.add(XMLMakerEndElement.for_name("item"));
				}
			xml.add(XMLMakerEndElement.for_name("channel"));
		xml.add(XMLMakerEndElement.for_name("rss"));
		req.send_response(HTTPResponse.for_xml_string(xml.to_string()));
		return(true);
	}
}